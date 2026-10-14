local ADDON_NAME, FGM = ...

_G.ForeverGM = FGM
FGM.name = ADDON_NAME
FGM.version = "0.11.0"
FGM.interface = 16001
FGM.Data = FGM.Data or {}
FGM.Locales = FGM.Locales or {}
FGM.Modules = FGM.Modules or {}
FGM.UI = FGM.UI or {}
FGM.State = FGM.State or { initialized = false, visible = false }

function FGM:RegisterLocale(locale, values)
    self.Locales[locale] = values
end

function FGM:L(key, ...)
    local selected = self.DB and self.DB.profile.language or (GetLocale and GetLocale()) or "enUS"
    if selected == "auto" then selected = (GetLocale and GetLocale()) or "enUS" end
    local tableForLocale = self.Locales[selected] or self.Locales.enUS or {}
    local value = tableForLocale[key] or (self.Locales.enUS and self.Locales.enUS[key]) or key
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, value, ...)
        if ok then return formatted end
    end
    return value
end

function FGM:RegisterModule(id, definition)
    definition.id = id
    self.Modules[id] = definition
end

function FGM:Print(message)
    local prefix = "|cffffcc66ForeverGM|r: "
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(prefix .. tostring(message))
    end
end

function FGM:SafeCall(label, callback, ...)
    local ok, result = pcall(callback, ...)
    if not ok then
        self:Print(self:L("ERROR_RUNTIME", label, tostring(result)))
        return nil, result
    end
    return result
end
