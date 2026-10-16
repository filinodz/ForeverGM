local _, FGM = ...

FGM.Permissions = {}

function FGM.Permissions:GetDisplay(record)
    if not record then return FGM:L("GM_UNKNOWN") end
    if record.permissionId then
        return string.format("%s • RBAC %d", FGM:UIRole(record.role), record.permissionId)
    end
    return FGM:UIRole(record.role)
end

function FGM.Permissions:CanPrepare(_record)
    -- Deliberately advisory only: only ForeverCore can authorize a command.
    return true
end
