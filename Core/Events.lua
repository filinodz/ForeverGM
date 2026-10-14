local ADDON_NAME, FGM = ...

local eventFrame = CreateFrame("Frame")
FGM.eventFrame = eventFrame

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

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
        if not FGM.Compatibility.isExpectedInterface then
            FGM:Print("Compatibility warning: expected interface 16001, detected " .. tostring(FGM.Compatibility.interface) .. ".")
        end
    elseif event == "CHAT_MSG_SYSTEM" then
        FGM.CommandExecutor:OnSystemMessage(...)
    elseif event == "PLAYER_TARGET_CHANGED" then
        if FGM.UI.main then FGM.UI:RefreshIdentity() end
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
