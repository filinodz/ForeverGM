local _, FGM = ...

FGM.Compatibility = {}
local C = FGM.Compatibility

function C:Detect()
    local version, build, date, interface = GetBuildInfo()
    self.version = version or "unknown"
    self.build = tonumber(build) or 0
    self.buildDate = date or "unknown"
    self.interface = tonumber(interface) or 0
    self.locale = GetLocale and GetLocale() or "enUS"
    self.isExpectedInterface = self.interface == FGM.interface
    self.hasMapAPI = C_Map and C_Map.GetBestMapForUnit and true or false
    self.hasBackdropTemplate = BackdropTemplateMixin and true or false
    self.hasModernAddonAPI = C_AddOns and true or false
    return self
end

function C:Summary()
    return string.format("%s (%d) • Interface %d • %s", self.version, self.build, self.interface, self.locale)
end

function FGM:CreateCompatibleFrame(frameType, name, parent)
    if BackdropTemplateMixin then
        return CreateFrame(frameType, name, parent, "BackdropTemplate")
    end
    return CreateFrame(frameType, name, parent)
end
