local _, FGM = ...

local function position(button)
    local angle = math.rad(FGM.DB.profile.minimap.angle or 220)
    local radius = 80
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

function FGM.UI:CreateMinimapButton()
    if self.minimap or not Minimap then return end
    local button = CreateFrame("Button", "ForeverGMMinimapButton", Minimap)
    self.minimap = button
    button:SetSize(32, 32); button:SetFrameStrata("MEDIUM"); button:SetFrameLevel(8)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local border = button:CreateTexture(nil, "OVERLAY"); border:SetSize(54, 54); border:SetPoint("CENTER"); border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    local icon = button:CreateTexture(nil, "BACKGROUND"); icon:SetSize(22, 22); icon:SetPoint("CENTER"); icon:SetTexture("Interface\\AddOns\\ForeverGM\\Assets\\ForeverGM-Minimap")
    if not icon:GetTexture() then icon:SetTexture("Interface\\Icons\\INV_Misc_EngGizmos_17") end
    icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick", function(_, mouseButton) if mouseButton == "RightButton" then FGM.UI:Show(); FGM.UI:ShowSettings() else FGM.UI:Toggle() end end)
    button:SetScript("OnDragStart", function(self) self.dragging = true end)
    button:SetScript("OnDragStop", function(self) self.dragging = false end)
    button:SetScript("OnUpdate", function(self)
        if not self.dragging then return end
        local mx, my = Minimap:GetCenter(); local px, py = GetCursorPosition(); local scale = UIParent:GetEffectiveScale()
        FGM.DB.profile.minimap.angle = math.deg(math.atan2((py / scale) - my, (px / scale) - mx)); position(self)
    end)
    button:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_LEFT"); GameTooltip:AddLine("ForeverGM " .. FGM.version, 1, 0.82, 0.3); GameTooltip:AddLine(FGM:L("MINIMAP_TOOLTIP"), 0.9, 0.9, 0.9); GameTooltip:Show() end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    position(button); button:SetShown(not FGM.DB.profile.minimap.hidden)
end
