local _, FGM = ...

FGM.UI = FGM.UI or {}

StaticPopupDialogs.FOREVERGM_CONFIRM = {
    text = "%s",
    button1 = YES,
    button2 = CANCEL,
    OnAccept = function(self, data)
        if data and data.callback then data.callback() end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function FGM.UI:ConfirmCommand(command, callback, dangerous)
    local key = dangerous and "CONFIRM_DANGEROUS" or "CONFIRM_BODY"
    StaticPopup_Show("FOREVERGM_CONFIRM", FGM:L(key, command), nil, { callback = callback })
end
