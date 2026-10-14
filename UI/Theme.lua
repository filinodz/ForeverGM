local _, FGM = ...

FGM.Theme = {
    colors = {
        background = { 0.025, 0.03, 0.045, 0.98 },
        panel = { 0.055, 0.065, 0.085, 0.97 },
        panelAlt = { 0.085, 0.095, 0.12, 0.95 },
        gold = { 0.93, 0.72, 0.25, 1 },
        goldDim = { 0.48, 0.36, 0.14, 1 },
        text = { 0.92, 0.9, 0.82, 1 },
        muted = { 0.58, 0.6, 0.66, 1 },
        success = { 0.31, 0.82, 0.48, 1 },
        danger = { 0.92, 0.3, 0.26, 1 },
    },
    backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    },
}

function FGM.Theme:ApplyPanel(frame, alternate)
    if not frame.SetBackdrop then return end
    frame:SetBackdrop(self.backdrop)
    frame:SetBackdropColor(unpack(alternate and self.colors.panelAlt or self.colors.panel))
    frame:SetBackdropBorderColor(unpack(self.colors.goldDim))
end

function FGM.Theme:ApplyButton(button)
    if button.SetBackdrop then
        button:SetBackdrop(self.backdrop)
        button:SetBackdropColor(0.08, 0.09, 0.12, 1)
        button:SetBackdropBorderColor(unpack(self.colors.goldDim))
    end
    button:SetScript("OnEnter", function(self)
        if self.SetBackdropColor then self:SetBackdropColor(0.16, 0.14, 0.09, 1) end
    end)
    button:SetScript("OnLeave", function(self)
        if self.SetBackdropColor then self:SetBackdropColor(0.08, 0.09, 0.12, 1) end
    end)
end
