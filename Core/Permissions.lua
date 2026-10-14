local _, FGM = ...

FGM.Permissions = {}

function FGM.Permissions:GetDisplay(record)
    if not record then return FGM:L("GM_UNKNOWN") end
    if record.permissionId then
        return string.format("%s • RBAC %d", record.role or FGM:L("GM_UNKNOWN"), record.permissionId)
    end
    return record.role or FGM:L("GM_UNKNOWN")
end

function FGM.Permissions:CanPrepare(_record)
    -- Deliberately advisory only: only ForeverCore can authorize a command.
    return true
end
