local _, FGM = ...

FGM.Tooltips = {}

function FGM.Tooltips:ShowRecord(owner, kind, record)
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    local native = FGM:GetLanguage() == FGM:GetClientLocale()
    if kind == "items" and record[1] and native then
        GameTooltip:SetHyperlink("item:" .. record[1])
    elseif (kind == "spells" or kind == "mounts") and record[1] and native then
        GameTooltip:SetHyperlink("spell:" .. record[1])
    else
        local name = FGM.Catalog:Name(kind,record)
        GameTooltip:AddLine(name, 1, 0.82, 0.3)
        if record.description then GameTooltip:AddLine(FGM:CommandDescription(record), 0.9, 0.9, 0.9, true) end
        if not native and (kind=="items" or kind=="spells" or kind=="mounts") then GameTooltip:AddLine(FGM:L("NATIVE_TOOLTIP_LANGUAGE"),.6,.6,.6,true) end
        local id = record.id or record[1]
        if id then GameTooltip:AddDoubleLine(FGM:L("ID"), tostring(id), 0.6, 0.6, 0.6, 1, 1, 1) end
        GameTooltip:Show()
    end
end

function FGM.Tooltips:Hide()
    GameTooltip:Hide()
end
