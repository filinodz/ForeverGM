local _, FGM = ...
FGM.Data.LocalizedNames = FGM.Data.LocalizedNames or {}
FGM.Data.LocalizedDetails = FGM.Data.LocalizedDetails or {}
local bases = {spells="frFR",mounts="frFR",skills="frFR",languages="frFR",quests="enUS",npcs="enUS",gameobjects="enUS",achievements="enUS"}

function FGM:LocalizedName(kind, row)
    local locale, id = self:GetLanguage(), row[1]
    local names = self.Data.LocalizedNames[locale] or {}
    local value = names[kind] and names[kind][id]
    if value and value ~= "" then return value end
    if kind == "items" and locale == "enUS" and row[10] and row[10] ~= "" then return row[10] end
    if bases[kind] == locale and row[2] and row[2] ~= "" then return row[2] end
end

function FGM:LocalizedDetail(kind, row)
    local locale = self:GetLanguage()
    local details = self.Data.LocalizedDetails[locale] or {}
    if details[kind] and details[kind][row[1]] then return details[kind][row[1]] end
    if locale == "enUS" and (kind == "npcs" or kind == "achievements") then return row[3] end
    return ""
end

function FGM:ClassName(id)
    local key = ({[1]="WARRIOR",[2]="PALADIN",[3]="HUNTER",[4]="ROGUE",[5]="PRIEST",[7]="SHAMAN",[8]="MAGE",[9]="WARLOCK",[11]="DRUID"})[id]
    return key and self:L("CLASS_" .. key) or self:L("ALL_CLASSES")
end

function FGM:UIRole(role)
    local key = ({Player="ROLE_PLAYER",Moderator="ROLE_MODERATOR",["Game Master"]="ROLE_GM",Gamemaster="ROLE_GM",Administrator="ROLE_ADMIN",["Explicit RBAC grant"]="ROLE_EXPLICIT"})[role]
    return self:L(key or "GM_UNKNOWN")
end

function FGM:CommandDescription(record)
    if self:GetLanguage() == "enUS" then return record.description end
    return self:L("COMMAND_HELP_LOCAL", record.name)
end
