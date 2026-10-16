local _, FGM = ...
FGM.Catalog = {}
local Catalog = FGM.Catalog
local fallback = "Interface\\Icons\\INV_Misc_QuestionMark"
Catalog.sectionIcons = {
    dashboard="Interface\\Icons\\INV_Misc_EngGizmos_17", commands="Interface\\Icons\\INV_Misc_Book_09",
    accounts="Interface\\Icons\\INV_Misc_GroupLooking", characters="Interface\\Icons\\INV_Misc_Head_Human_01",
    spells="Interface\\Icons\\INV_Misc_Book_11", skills="Interface\\Icons\\Trade_BlackSmithing",
    languages="Interface\\Icons\\INV_Misc_Note_01", mounts="Interface\\Icons\\Ability_Mount_RidingHorse",
    items="Interface\\Icons\\INV_Misc_Bag_08", bis="Interface\\Icons\\INV_Chest_Plate03",
    npcs="Interface\\Icons\\INV_Misc_Head_Orc_01", gameobjects="Interface\\Icons\\INV_Misc_Gear_01",
    teleport="Interface\\Icons\\Spell_Arcane_TeleportStormWind", quests=134939,
    achievements="Interface\\Icons\\INV_Misc_Trophy_Argent", moderation="Interface\\Icons\\Ability_Warrior_Challange",
    server="Interface\\Icons\\INV_Misc_EngGizmos_05", debug="Interface\\Icons\\INV_Misc_Gear_01",
    gmtools="Interface\\Icons\\Spell_Holy_DivineShield",
}
local names = { [43]="SWORD_1H", [44]="AXE_1H", [54]="MACE_1H", [55]="SWORD_2H", [160]="MACE_2H", [172]="AXE_2H", [136]="STAVES" }
function Catalog:SkillName(row) return names[row[1]] and FGM:L(names[row[1]]) or FGM:LocalizedName("skills",row) or FGM:L("MISSING_DATA_NAME",FGM:L("SKILLS"),row[1]) end
function Catalog:ItemMap()
    if not self.itemMap then
        self.itemMap={};for _,row in ipairs(FGM.Data.Items or {})do self.itemMap[row[1]]=row end
    end
    return self.itemMap
end
function Catalog:Name(kind, row, noRequest)
    if row.labelKey then return FGM:L(row.labelKey) end
    if kind == "commands" then return "." .. row.name end
    if kind == "skills" then return self:SkillName(row) end
    if kind == "bis" and row[6]=="bis" then return FGM:L("TIER_BIS") .. " · " .. FGM:ClassName(row[9]) .. " · " .. FGM:L(row[10]) end
    if kind == "teleport" then return row[2] end -- Command destination token, never translate.
    local name = FGM:LocalizedName(kind,row)
    if name then return name end
    local matchingClient = FGM:GetLanguage() == FGM:GetClientLocale()
    if (kind == "spells" or kind == "mounts") and matchingClient then
        local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(row[1])
        if info and info.name and info.name~="" then return info.name end
        if GetSpellInfo then name = GetSpellInfo(row[1]) or name end
    elseif kind == "items" and matchingClient then
        local get = C_Item and C_Item.GetItemInfo or GetItemInfo
        if get then name = get(row[1]) end
        if not name and not noRequest and C_Item and C_Item.RequestLoadItemDataByID then
            self.requestedItems=self.requestedItems or {}
            if not self.requestedItems[row[1]] then self.requestedItems[row[1]]=true;C_Item.RequestLoadItemDataByID(row[1]) end
        end
    end
    return name and name ~= "" and name or FGM:L("MISSING_DATA_NAME",FGM:L(({items="ITEMS",spells="SPELLS",mounts="MOUNTS",languages="LANGUAGES",quests="QUESTS",npcs="NPCS",gameobjects="GAMEOBJECTS",bis="BIS",achievements="ACHIEVEMENTS"})[kind] or "ID"),row[1])
end

function Catalog:PrimeEnglishItemNames()
    -- Only the small remaining English gap is preloaded, never thousands of
    -- cross-locale requests. The game controls what can actually be resolved.
    if FGM:GetLanguage()~="enUS" or FGM:GetClientLocale()~="enUS" then return end
    if not (C_Item and C_Item.RequestLoadItemDataByID) then return end
    local requested=0
    for _,row in ipairs(FGM.Data.Items or {})do
        if not FGM:LocalizedName("items",row) and requested<128 then
            self:Name("items",row);requested=requested+1
        end
    end
end
function Catalog:Icon(kind, row)
    if row.icon then return row.icon end
    -- Client-extracted icon of DEFAULT QUEST ITEM - Scroll (armory item 3519).
    -- Numeric FileDataID avoids the missing classic_beta_ legacy texture path.
    if kind == "quests" then return self.sectionIcons.quests end
    if kind == "bis" then return row[5]>0 and row[5] or self.sectionIcons.bis end
    if kind == "spells" or kind == "mounts" then
        local icon = kind == "spells" and row[3] or row[4]
        if icon and icon > 0 then return icon end
        if C_Spell and C_Spell.GetSpellTexture then return C_Spell.GetSpellTexture(row[1]) or fallback end
        if GetSpellTexture then return GetSpellTexture(row[1]) or fallback end
    elseif kind == "items" then
        if row[9] and row[9] > 0 then return row[9] end
        if C_Item and C_Item.GetItemIconByID then return C_Item.GetItemIconByID(row[1]) or fallback end
    elseif kind == "skills" then
        local spell = FGM.Data.SkillLearnSpells[row[1]]
        if spell and C_Spell and C_Spell.GetSpellTexture then return C_Spell.GetSpellTexture(spell) or row[4] end
        return row[4] > 0 and row[4] or self.sectionIcons.skills
    elseif kind == "languages" then return row[3] > 0 and row[3] or self.sectionIcons.languages
    elseif kind == "achievements" then return row[5] > 0 and row[5] or self.sectionIcons.achievements end
    return self.sectionIcons[kind] or fallback
end
function Catalog:Category(kind, row)
    if kind == "commands" then return row.category end
    if kind == "spells" then return row[5] or "other" end
    if kind == "skills" then
        local categories = { [6]="weapons", [7]="class", [8]="armor", [9]="secondary", [10]="languages", [11]="professions", [12]="internal" }
        if row[1] == 762 or row[1] == 148 or row[1] == 3011 then return "riding" end
        return categories[row[3]] or "other"
    end
    if kind == "items" then return "slot_" .. row[8] end
    if kind == "mounts" then return "mounts" end
    if kind == "bis" then return row[6] or "other" end
    return "all"
end

function Catalog:BuildGMTools()
    FGM.Data.GMTools = {}
    local actions = {
        {"gm on","GM_ON","","Spell_Nature_Lightning"}, {"gm off","GM_OFF","","Spell_Nature_Lightning"},
        {"gm fly","FLY_ON","on","Ability_Druid_FlightForm"}, {"gm fly","FLY_OFF","off","Ability_Druid_FlightForm"},
        {"cheat god","GOD_ON","on","Spell_Holy_DivineShield"}, {"cheat god","GOD_OFF","off","Spell_Holy_DivineShield"},
        {"gm visible","INVISIBLE_ON","off","Ability_Vanish"}, {"gm visible","INVISIBLE_OFF","on","Ability_Vanish"},
        {"gm chat","GM_CHAT_ON","on","INV_Letter_15"}, {"gm chat","GM_CHAT_OFF","off","INV_Letter_15"},
        {"modify speed all","NORMAL_SPEED","1","Ability_Rogue_Sprint"}, {"server info","SERVER","","INV_Misc_EngGizmos_05"},
    }
    for _,action in ipairs(actions) do
        local command = FGM.CommandRegistry:Get(action[1])
        if command and command.availability ~= "unsupported" then
            local row={};for key,value in pairs(command)do row[key]=value end
            row.id=command.id .. "_" .. action[2];row.labelKey=action[2];row.defaultArgs=action[3];row.icon="Interface\\Icons\\" .. action[4]
            FGM.Data.GMTools[#FGM.Data.GMTools+1]=row
        end
    end
end
function Catalog:ClassMatches(mask, classID)
    return not classID or classID == 0 or (mask and bit.band(mask, 2 ^ (classID - 1)) ~= 0)
end
function Catalog:Target()
    local unit = UnitExists("target") and "target" or "player"
    if not UnitIsPlayer(unit) then return nil end
    local _, _, classID = UnitClass(unit)
    local _, _, raceID = UnitRace(unit)
    return { unit=unit, guid=UnitGUID(unit), name=UnitName(unit), classID=classID, raceID=raceID, level=UnitLevel(unit) }
end
function Catalog:CompatibleSkill(row, target)
    if not target or not target.classID or not target.raceID then return false end
    local allowed = false
    for _, rule in ipairs(FGM.Data.SkillRules or {}) do
        if rule[1] == row[1] then
            local classMatch = rule[2] == 0 or rule[2] == -1 or bit.band(rule[2], 2^(target.classID-1)) ~= 0
            local raceBit = target.raceID == 95 and 32 or target.raceID == 96 and 33 or target.raceID-1
            local low, high = rule[3], rule[6] or 0
            local raceMask = raceBit>=32 and high or low
            local raceMatch = (low==0 and high==0) or raceMask==-1 or bit.band(raceMask,2^(raceBit%32))~=0
            if classMatch and raceMatch then
                if target.level >= rule[5] then allowed = true end
            end
        end
    end
    return allowed
end
function Catalog:SkillValue(row, maximize, target)
    local category = self:Category("skills", row)
    if category == "languages" then return 300, 300 end
    if category == "armor" or row[1] == 118 then return 1, 1 end
    local maximum = category == "weapons" and math.min(300, math.max(1, (target and target.level or 60)*5)) or 300
    return maximize and maximum or 1, maximum
end
