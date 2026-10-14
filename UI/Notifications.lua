local _, FGM = ...

FGM.Notifications = { active = {} }

function FGM.Notifications:Show(message, color)
    if not FGM.UI.main then return end
    local toast = FGM:CreateCompatibleFrame("Frame", nil, FGM.UI.main)
    toast:SetSize(420, 42)
    toast:SetPoint("TOP", FGM.UI.main, "TOP", 0, -54 - (#self.active * 46))
    FGM.Theme:ApplyPanel(toast, true)
    toast.text = toast:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    toast.text:SetPoint("CENTER")
    toast.text:SetWidth(390)
    toast.text:SetText(message)
    if color then toast.text:SetTextColor(unpack(color)) end
    table.insert(self.active, toast)
    C_Timer.After(3.5, function()
        for i, frame in ipairs(self.active) do
            if frame == toast then table.remove(self.active, i) break end
        end
        toast:Hide()
    end)
end
