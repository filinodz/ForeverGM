"""Read regular WDC5 tables using ForeverCore DB2FileLoader column semantics.

Sparse/encrypted sections are rejected or skipped, never guessed. Layout hashes
must match the supplied metadata. Used only by the offline data generator.
"""
import struct
from pathlib import Path


class WDC5:
    def __init__(self, path, layout_hash):
        self.path = Path(path)
        self.data = self.path.read_bytes()
        if self.data[:4] != b"WDC5":
            raise ValueError(f"{path}: expected WDC5")
        h = struct.unpack_from("<9IHh7I", self.data, 136)
        self.count, self.fields, self.size, self.strings = h[:4]
        self.layout, self.flags, self.index = h[5], h[9], h[10]
        if self.flags & 4:
            self.index = -1
        self.packed = h[12]
        if self.layout != layout_hash or self.flags & 1:
            raise ValueError(f"{path}: unsupported layout {self.layout:08X} / flags {self.flags}")
        self.sections = [struct.unpack_from("<Q8I", self.data, 204 + i * 40) for i in range(h[-1])]
        offset = 204 + h[-1] * 40 + self.fields * 4
        self.columns = [struct.unpack_from("<HH5I", self.data, offset + i * 24) for i in range(h[11])]
        offset += h[14]
        self.pallets, self.common = {}, {}
        # TrinityCore writes all scalar pallets, then all array pallets.
        for compression in (3, 4):
            for i, column in enumerate(self.columns):
                if column[3] == compression:
                    length = column[2]
                    self.pallets[i] = struct.unpack_from(f"<{length // 4}I", self.data, offset)
                    offset += length
        for i, column in enumerate(self.columns):
            if column[3] == 2:
                length = column[2]
                self.common[i] = dict(struct.iter_unpack("<II", self.data[offset:offset + length]))
                offset += length

    def number(self, position, field, record_id=0, array=0):
        bit_offset, bit_size, additional, compression, arg1, arg2, arg3 = self.columns[field]
        if compression == 0:
            return struct.unpack_from("<I", self.data, position + bit_offset // 8 + array * 4)[0]
        if compression == 2:
            return self.common[field].get(record_id, arg1)
        offset = self.packed * 8 + arg1
        width = arg2
        raw = int.from_bytes(self.data[position + offset // 8: position + offset // 8 + 8], "little")
        value = (raw >> (offset % 8)) & ((1 << width) - 1)
        if compression in (1, 5):
            return value
        if compression in (3, 4):
            return self.pallets[field][value * (arg3 if compression == 4 else 1) + array]
        raise ValueError(f"Unsupported compression {compression}")

    def string(self, position, field):
        relative = self.number(position, field)
        if relative == 0:
            return ""
        start = position + self.columns[field][0] // 8 + relative
        stop = self.data.find(b"\0", start)
        if stop < 0:
            raise ValueError("Unterminated DB2 string")
        return self.data[start:stop].decode("utf-8")

    def rows(self, selected_fields, string_fields=()):
        for section in self.sections:
            tact, offset, count, string_size, catalog, id_size, parent_size, catalog_count, copies = section
            if tact not in (0, 0x5452494E49545900):
                continue
            if catalog_count:
                raise ValueError("Sparse DB2 is unsupported")
            records = {}
            id_offset = offset + count * self.size + string_size
            for i in range(count):
                position = offset + i * self.size
                record_id = self.number(position, self.index) if self.index >= 0 else struct.unpack_from("<I", self.data, id_offset + i * 4)[0]
                values = {}
                for field in selected_fields:
                    if isinstance(field, tuple):
                        values[field] = self.number(position, field[0], record_id, field[1])
                    else:
                        values[field] = self.string(position, field) if field in string_fields else self.number(position, field, record_id)
                records[record_id] = values
                yield record_id, values
            copy_offset = id_offset + id_size
            for i in range(copies):
                new_id, source_id = struct.unpack_from("<II", self.data, copy_offset + i * 8)
                if source_id in records:
                    yield new_id, dict(records[source_id])
