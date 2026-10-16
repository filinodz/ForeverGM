local _, FGM = ...
FGM.Database = { token = 0 }
local DB = FGM.Database
local definitions = {
    commands = "Commands", spells = "Spells", skills = "Skills", languages = "Languages",
    mounts = "Mounts", items = "Items", teleport = "Teleports", quests = "Quests",
    npcs = "Creatures", gameobjects = "GameObjects", achievements = "Achievements", bis = "ItemSets", gmtools = "GMTools",
}
function DB:GetSource(kind)
    if kind == "gmtools" and not FGM.Data.GMTools then FGM.Catalog:BuildGMTools() end
    return FGM.Data[definitions[kind] or "Commands"] or {}
end
function DB:Normalize(value)
    value = string.lower(tostring(value or ""))
    for _, pair in ipairs({ {"é","e"}, {"è","e"}, {"ê","e"}, {"É","e"}, {"à","a"}, {"â","a"}, {"ô","o"}, {"î","i"}, {"ï","i"}, {"û","u"}, {"ç","c"}, {"ñ","n"} }) do value = value:gsub(pair[1], pair[2]) end
    return value
end
function DB:Search(kind, text, callback, predicate)
    self.token = self.token + 1
    local token, index, results = self.token, 1, {}
    local source = self:GetSource(kind)
    local needle = self:Normalize(text):match("^%s*(.-)%s*$")
    local numeric = tonumber(needle)
    self.job = function()
        if token ~= DB.token then return end
        local stop = math.min(index + 499, #source)
        for i = index, stop do
            local row = source[i]
            local id, name = row.id or row[1], row.name or row[2]
            local match = needle == "" or (numeric and tonumber(id) == numeric)
            if not match then
                local haystack = row.searchText or tostring(name or "")
                if kind == "items" then haystack = haystack .. " " .. tostring(row[10] or "") end
                if kind == "skills" and FGM.Catalog then haystack = haystack .. " " .. FGM.Catalog:SkillName(row) end
                if kind ~= "commands" and kind ~= "gmtools" and FGM.Catalog then haystack=haystack .. " " .. FGM.Catalog:Name(kind,row,true) end
                match = self:Normalize(haystack):find(needle, 1, true) ~= nil
            end
            if match and (not predicate or predicate(row)) then results[#results + 1] = row end
        end
        index = stop + 1
        if index > #source then DB.job = nil; callback(results) end
    end
end
function DB:OnUpdate() if self.job then self.job() end end
function DB:Cancel() self.token = self.token + 1; self.job = nil end
