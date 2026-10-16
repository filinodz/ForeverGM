local ADDON_NAME, FGM = ...

local eventFrame = CreateFrame("Frame")
FGM.eventFrame = eventFrame

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loaded = ...
        if loaded ~= ADDON_NAME then return end
        FGM:InitializeDatabase()
        FGM.Compatibility:Detect()
        FGM.CommandRegistry:Initialize()
        FGM.State.initialized = true
    elseif event == "PLAYER_LOGIN" then
        FGM.UI:Create()
        FGM.UI:CreateMinimapButton()
        FGM.Catalog:PrimeEnglishItemNames()
        if not FGM.Compatibility.isExpectedInterface then
            FGM:Print(FGM:L("COMPATIBILITY_WARNING", FGM.interface, FGM.Compatibility.interface))
        end
    elseif event == "CHAT_MSG_SYSTEM" then
        FGM.CommandExecutor:OnSystemMessage(...)
    elseif event == "PLAYER_TARGET_CHANGED" then
        if FGM.UI.main then FGM.UI:RefreshIdentity() end
    elseif event == "ITEM_DATA_LOAD_RESULT" or event == "GET_ITEM_INFO_RECEIVED" then
        local id, success = ...
        if success and FGM.UI.main and FGM.UI.activeKind == "items" then
            FGM.UI:RenderPage()
            if FGM.UI.selected and FGM.UI.selected[1]==id then FGM.UI.detailTitle:SetText(FGM.Catalog:Name("items",FGM.UI.selected)) end
        end
    end
end)

eventFrame:SetScript("OnUpdate", function()
    if not FGM.State.initialized then return end
    FGM.Database:OnUpdate()
    FGM.CommandExecutor:OnUpdate()
end)

SLASH_FOREVERGM1 = "/forevergm"
SLASH_FOREVERGM2 = "/fgm"
SlashCmdList.FOREVERGM = function(message)
    local command = string.lower((message or ""):match("^%s*(.-)%s*$"))
    if command == "config" or command == "settings" then
        FGM.UI:Show(); FGM.UI:ShowSettings()
    elseif command == "cancel" then
        FGM.CommandExecutor:Cancel()
    elseif command ~= "" then
        FGM.UI:Show(); FGM.UI:SetSection("commands"); FGM.UI.search:SetText(command); FGM.UI:BeginSearch(command)
    else
        FGM.UI:Toggle()
    end
end
