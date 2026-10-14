const fs = require('fs');
const path = require('path');
const luaparse = require(process.env.FGM_LUAPARSE || 'luaparse');
const root = path.resolve(__dirname, '..');
const files = fs.readFileSync(path.join(root, 'ForeverGM.toc'), 'utf8')
  .split(/\r?\n/).map(line => line.trim()).filter(line => line && !line.startsWith('#'));
for (const file of files) {
  luaparse.parse(fs.readFileSync(path.join(root, file), 'utf8'), {luaVersion: '5.1'});
}
console.log(`PASS: ${files.length} TOC modules parsed in Lua 5.1 mode`);
