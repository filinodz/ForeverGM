local _, FGM = ...

FGM.Components = {}
local C = FGM.Components

function C:Label(parent, text, size, color)
    local label = parent:CreateFontString(nil, "OVERLAY", size and "GameFontNormalLarge" or "GameFontNormal")
    label:SetText(text or "")
    label:SetJustifyH("LEFT")
    if color then label:SetTextColor(unpack(color)) end
    return label
end

function C:Button(parent, text, width, height, callback)
    local button = FGM:CreateCompatibleFrame("Button", nil, parent)
    button:SetSize(width or 110, height or 28)
    FGM.Theme:ApplyButton(button)
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("CENTER")
    button.text:SetText(text or "")
    if callback then button:SetScript("OnClick", callback) end
    return button
end

function C:EditBox(parent, width, height)
    local edit = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    edit:SetSize(width or 220, height or 28)
    edit:SetAutoFocus(false)
    edit:SetFontObject("ChatFontNormal")
    edit:SetTextInsets(7, 7, 0, 0)
    return edit
end

function C:Divider(parent)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetColorTexture(0.42, 0.32, 0.12, 0.8)
    return line
end

function C:SetButtonText(button, text)
    if button.text then button.text:SetText(text or "") else button:SetText(text or "") end
end
