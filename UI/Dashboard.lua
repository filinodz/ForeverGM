local _, FGM = ...
local UI, T, C = FGM.UI, FGM.Theme, FGM.Components
local emblem = "Interface\\AddOns\\ForeverGM\\Assets\\ForeverGM-Minimap-v2"
local collections = {
    {"items", "ITEMS"}, {"spells", "SPELLS"}, {"quests", "QUESTS"},
    {"npcs", "NPCS"}, {"gameobjects", "GAMEOBJECTS"}, {"skills", "SKILLS"},
    {"bis", "BIS"}, {"mounts", "MOUNTS"}, {"teleport", "TELEPORT"},
    {"languages", "LANGUAGES"}, {"achievements", "ACHIEVEMENTS"}, {"commands", "COMMANDS"},
}

local function number(value)
    local text = tostring(value)
    local result
    repeat text, result = text:gsub("^(%d+)(%d%d%d)", "%1,%2") until result == 0
    return text
end

local function texture(parent, size, file)
    local image = parent:CreateTexture(nil, "ARTWORK")
    image:SetSize(size, size); image:SetTexture(file); image:SetTexCoord(.06, .94, .06, .94)
    image:SetPoint("LEFT", 12, 0)
    return image
end

local function card(parent, file, title, callback, hint)
    local button = FGM:CreateCompatibleFrame("Button", nil, parent)
    T:ApplyPanel(button, true)
    button.icon = texture(button, 40, file)
    button.title = C:Label(button, title, false, T.colors.text)
    button.title:SetPoint("TOPLEFT", 64, -12); button.title:SetPoint("TOPRIGHT", -12, -12)
    button.title:SetHeight(30); button.title:SetJustifyV("TOP")
    button:SetScript("OnClick", callback)
    button:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(T.colors.gold))
        self:SetBackdropColor(.13, .12, .075, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine(title, 1, .82, .3)
        GameTooltip:AddLine(hint, .85, .88, .93, true); GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(T.colors.goldDim))
        self:SetBackdropColor(unpack(T.colors.panelAlt)); GameTooltip:Hide()
    end)
    return button
end

function UI:CreateDashboard()
    if self.dashboard then return end
    local scroll = CreateFrame("ScrollFrame", nil, self.content, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -46); scroll:SetPoint("BOTTOMRIGHT", -32, 12)
    local body = CreateFrame("Frame", nil, scroll); body:SetSize(600, 900); scroll:SetScrollChild(body)
    self.dashboard, self.dashboardBody = scroll, body
    local hero = FGM:CreateCompatibleFrame("Frame", nil, body); T:ApplyPanel(hero, true)
    hero:SetPoint("TOPLEFT", 4, 0); hero:SetHeight(112); self.dashboardHero = hero
    local mark = texture(hero, 76, emblem); mark:SetTexCoord(0, 1, 0, 1)
    local welcome = C:Label(hero, FGM:L("DASH_WELCOME"), true, T.colors.gold)
    welcome:SetPoint("TOPLEFT", 104, -14); welcome:SetPoint("TOPRIGHT", -14, -14); welcome:SetHeight(34)
    self.dashboardIdentity = C:Label(hero, "", false, T.colors.text)
    self.dashboardIdentity:SetPoint("TOPLEFT", 104, -51); self.dashboardIdentity:SetPoint("TOPRIGHT", -14, -51)
    self.dashboardIdentity:SetHeight(24)
    self.dashboardBuild = C:Label(hero, FGM.Compatibility:Summary(), false, T.colors.muted)
    self.dashboardBuild:SetPoint("TOPLEFT", 104, -78); self.dashboardBuild:SetPoint("TOPRIGHT", -14, -78)
    self.dashboardBuild:SetFontObject("GameFontNormalSmall"); self.dashboardBuild:SetHeight(24)
    self.dashboardStatsTitle = C:Label(body, FGM:L("DASH_CATALOG"), true, T.colors.gold)
    self.dashboardStatsHint = C:Label(body, FGM:L("DASH_CATALOG_HINT"), false, T.colors.muted)
    self.dashboardStatsHint:SetFontObject("GameFontNormalSmall")
    self.dashboardStats = {}
    for _, entry in ipairs(collections) do
        local kind, key = entry[1], entry[2]
        local count = #FGM.Database:GetSource(kind)
        local b = card(body, FGM.Catalog.sectionIcons[kind], FGM:L(key), function() UI:SetSection(kind) end, FGM:L("DASH_OPEN_COLLECTION"))
        b.kind, b.count = kind, count
        b.title:SetFontObject("GameFontNormalSmall"); b.title:SetTextColor(unpack(T.colors.muted))
        b.title:SetHeight(28); b.icon:SetSize(46, 46)
        b.value = C:Label(b, number(count), true, T.colors.gold)
        b.value:SetPoint("BOTTOMLEFT", 64, 13); b.value:SetPoint("BOTTOMRIGHT", -12, 13)
        self.dashboardStats[#self.dashboardStats + 1] = b
    end
    self.dashboardToolsTitle = C:Label(body, FGM:L("QUICK_ACTIONS"), true, T.colors.gold)
    self.dashboardToolsHint = C:Label(body, FGM:L("DASH_TOOLS_HINT"), false, T.colors.muted)
    self.dashboardToolsHint:SetFontObject("GameFontNormalSmall")
    self.dashboardShortcuts = {}
    for _, record in ipairs(FGM.Database:GetSource("gmtools")) do
        local row = record
        local b = card(body, row.icon, FGM:L(row.labelKey), function()
            -- Explicit commands, never speculative on/off state or permission bypass.
            UI:Run(row, row.defaultArgs or "", {kind="gmtools", id=row.id, label=FGM:L(row.labelKey)}, true)
        end, FGM:L("DASH_CONFIRM_HINT") .. "\n" .. (FGM.CommandRegistry:Build(row, row.defaultArgs or "") or row.syntax))
        b.command = row
        b.meta = C:Label(b, FGM:L("DASH_COMMAND"), false, T.colors.muted)
        b.meta:SetFontObject("GameFontNormalSmall"); b.meta:SetPoint("BOTTOMLEFT", 64, 10)
        self.dashboardShortcuts[#self.dashboardShortcuts + 1] = b
    end
    local workflows = {
        {"GIVE_WEAPONS", FGM.Catalog.sectionIcons.skills, function() UI:ShowSkillBulk("weapons") end},
        {"BULK_PROFESSIONS", "Interface\\Icons\\Trade_Alchemy", function() UI:ShowSkillBulk("professions") end},
        {"LEARN_CLASS_SELF", FGM.Catalog.sectionIcons.spells, function()
            UI:ConfirmCommand(FGM:L("LEARN_CLASS_SELF_HINT"), function()
                UI:Run("learn my trainer", "", {kind="spells", label=FGM:L("LEARN_CLASS_SELF")})
            end)
        end},
        {"SETTINGS", FGM.Catalog.sectionIcons.debug, function() UI:ShowSettings() end},
    }
    for _, workflow in ipairs(workflows) do
        local entry = workflow
        local b = card(body, entry[2], FGM:L(entry[1]), entry[3], FGM:L("DASH_WORKFLOW_HINT"))
        b.workflow = entry[1]
        b.meta = C:Label(b, FGM:L(entry[1] == "SETTINGS" and "DASH_OPEN" or "DASH_PREVIEW"), false, T.colors.muted)
        b.meta:SetFontObject("GameFontNormalSmall"); b.meta:SetPoint("BOTTOMLEFT", 64, 10)
        self.dashboardShortcuts[#self.dashboardShortcuts + 1] = b
    end
    self.dashboardNote = C:Label(body, FGM:L("DASH_SAFETY"), false, T.colors.muted)
    self.dashboardNote:SetFontObject("GameFontNormalSmall"); self.dashboardNote:SetJustifyV("TOP")
    scroll:Hide()
end

function UI:LayoutDashboard()
    if not self.dashboard then return end
    local width = math.max(200, self.dashboard:GetWidth())
    self.dashboardBody:SetWidth(width); self.dashboardHero:SetWidth(width - 8)
    local function heading(title, hint, y)
        title:ClearAllPoints(); title:SetPoint("TOPLEFT", 6, -y)
        hint:ClearAllPoints(); hint:SetPoint("TOPLEFT", 6, -y-26); hint:SetWidth(width-12); hint:SetHeight(28)
        return y + 60
    end
    local function grid(cards, y, height)
        local columns = math.max(1, math.min(4, math.floor((width + 8) / 210)))
        local cardWidth = (width - 8 - (columns-1)*8) / columns
        for i, b in ipairs(cards) do
            b:ClearAllPoints(); b:SetSize(cardWidth, height)
            b:SetPoint("TOPLEFT", 4 + ((i-1)%columns)*(cardWidth+8), -y-math.floor((i-1)/columns)*(height+8))
        end
        return y + math.ceil(#cards/columns)*(height+8)
    end
    local y = heading(self.dashboardStatsTitle, self.dashboardStatsHint, 132)
    y = grid(self.dashboardStats, y, 88) + 16
    y = heading(self.dashboardToolsTitle, self.dashboardToolsHint, y)
    y = grid(self.dashboardShortcuts, y, 80) + 12
    self.dashboardNote:ClearAllPoints(); self.dashboardNote:SetPoint("TOPLEFT", 6, -y)
    self.dashboardNote:SetWidth(width-12); self.dashboardNote:SetHeight(52)
    self.dashboardBody:SetHeight(y + 64)
end

function UI:ShowDashboard()
    self.results = {}; self.selected = nil
    for _, b in ipairs(self.rows) do b.record = nil; b:Hide() end
    self.empty:Hide(); self.dashboard:SetVerticalScroll(0)
    self:RefreshIdentity(); self:LayoutDashboard()
end
