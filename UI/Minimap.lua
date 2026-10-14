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
    button:SetSize(38, 38); button:SetFrameStrata("MEDIUM"); button:SetFrameLevel(8)
    button:SetHitRectInsets(2, 2, 2, 2)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    -- The asset has its own centered gold rim: do not cover it with the offset tracking border.
    local icon = button:CreateTexture(nil, "ARTWORK"); icon:SetSize(34, 34); icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\AddOns\\ForeverGM\\Assets\\ForeverGM-Minimap-v2")
    icon:SetTexCoord(0, 1, 0, 1); button.icon = icon
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick", function(_, mouseButton) if mouseButton == "RightButton" then FGM.UI:Show(); FGM.UI:ShowSettings() else FGM.UI:Toggle() end end)
    button:SetScript("OnDragStart", function(self) self.dragging = true end)
    button:SetScript("OnDragStop", function(self) self.dragging = false end)
    button:SetScript("OnUpdate", function(self)
        if not self.dragging then return end
        local mx, my = Minimap:GetCenter(); local px, py = GetCursorPosition(); local scale = Minimap:GetEffectiveScale()
        FGM.DB.profile.minimap.angle = math.deg(math.atan2((py / scale) - my, (px / scale) - mx)); position(self)
    end)
    button:SetScript("OnMouseDown", function() icon:SetSize(30, 30) end)
    button:SetScript("OnMouseUp", function() icon:SetSize(button.hovered and 36 or 34, button.hovered and 36 or 34) end)
    button:SetScript("OnEnter", function(self)
        self.hovered = true; icon:SetSize(36, 36)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT"); GameTooltip:AddLine("ForeverGM " .. FGM.version, 1, 0.82, 0.3)
        GameTooltip:AddLine(FGM:L("MINIMAP_TOOLTIP"), 0.9, 0.9, 0.9, true); GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() button.hovered = false; icon:SetSize(34, 34); GameTooltip:Hide() end)
    position(button); button:SetShown(not FGM.DB.profile.minimap.hidden)
end
