local _, FGM = ...

local defaults = {
    schema = 2,
    profile = {
        language = "auto",
        scale = 1,
        minimap = { hidden = false, angle = 220 },
        window = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 0, width = 1160, height = 760 },
        confirmDangerous = true,
        commandDelay = 0.45,
    },
    favorites = {},
    recent = {},
    teleportHistory = {},
}

local function merge(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then target[key] = {} end
            merge(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

function FGM:InitializeDatabase()
    if type(ForeverGMDB) ~= "table" then ForeverGMDB = {} end
    merge(ForeverGMDB, defaults)
    if (ForeverGMDB.schema or 0) < 2 then
        ForeverGMDB.profile.commandDelay = ForeverGMDB.profile.commandDelay or 0.45
        ForeverGMDB.schema = 2
    end
    self.DB = ForeverGMDB
end

function FGM:RememberRecent(kind, id, label, command)
    local recent = self.DB.recent
    table.insert(recent, 1, { kind = kind, id = id, label = label, command = command, at = time() })
    while #recent > 30 do table.remove(recent) end
end

function FGM:ToggleFavorite(key, record)
    if self.DB.favorites[key] then
        self.DB.favorites[key] = nil
        return false
    end
    self.DB.favorites[key] = record
    return true
end
