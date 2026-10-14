local _, FGM = ...

FGM.Tooltips = {}

function FGM.Tooltips:ShowRecord(owner, kind, record)
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    if kind == "items" and record[1] then
        GameTooltip:SetHyperlink("item:" .. record[1])
    elseif (kind == "spells" or kind == "mounts") and record[1] then
        GameTooltip:SetHyperlink("spell:" .. record[1])
    else
        local name = record.name or record[2] or FGM:L("ADDON_NAME")
        GameTooltip:AddLine(name, 1, 0.82, 0.3)
        if record.description then GameTooltip:AddLine(record.description, 0.9, 0.9, 0.9, true) end
        local id = record.id or record[1]
        if id then GameTooltip:AddDoubleLine(FGM:L("ID"), tostring(id), 0.6, 0.6, 0.6, 1, 1, 1) end
        GameTooltip:Show()
    end
end

function FGM.Tooltips:Hide()
    GameTooltip:Hide()
end
