local _, FGM = ...

FGM.CommandRegistry = { byName = {}, byId = {}, categories = {} }
local Registry = FGM.CommandRegistry

function Registry:Initialize()
    wipe(self.byName)
    wipe(self.byId)
    wipe(self.categories)
    for _, command in ipairs(FGM.Data.Commands or {}) do
        self.byName[command.name] = command
        self.byId[command.id] = command
        self.categories[command.category] = self.categories[command.category] or {}
        table.insert(self.categories[command.category], command)
        command.searchText = string.lower(table.concat({ command.name or "", command.syntax or "", command.description or "", tostring(command.permissionId or "") }, " "))
    end
end

function Registry:Get(name)
    return self.byName[string.lower(name or "")]
end

function Registry:IsDangerous(name)
    local value = string.lower(name or "")
    return value:find("^server shutdown") or value:find("^server restart") or value:find("^ban ")
        or value:find(" delete") or value:find(" erase") or value:find("^kick")
        or value:find("^unban") or value:find("^mute") or value:find("^reload all")
end

function Registry:Build(command, arguments)
    local name = type(command) == "table" and command.name or tostring(command or "")
    local args = tostring(arguments or ""):match("^%s*(.-)%s*$")
    if name:find("[\r\n;]") then return nil, FGM:L("INVALID_COMMAND") end
    if args:find("[\r\n;]") then return nil, FGM:L("INVALID_ARGUMENT") end
    local text = "." .. name
    if args ~= "" then text = text .. " " .. args end
    return text
end
