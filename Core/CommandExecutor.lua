local _, FGM = ...

FGM.CommandExecutor = { queue = {}, lastSent = -math.huge, awaiting = nil, running = false }
local Executor = FGM.CommandExecutor

local failurePatterns = { "unknown command", "syntax", "permission", "not have", "failed", "error", "introuvable", "permiso", "erreur" }

function Executor:SetStatus(key, ...)
    local message = FGM:L(key, ...)
    FGM.State.lastStatus = message
    if FGM.UI and FGM.UI.SetStatus then FGM.UI:SetStatus(message) end
end

function Executor:Validate(text)
    if type(text) ~= "string" or text:sub(1, 1) ~= "." or #text > 255 then
        return false, FGM:L("INVALID_COMMAND")
    end
    if text:find("[\r\n;]") or text:find("|H") or text:find("|h") then
        return false, FGM:L("INVALID_ARGUMENT")
    end
    return true
end

function Executor:DispatchNow(text, metadata)
    if metadata and metadata.targetGUID then
        local target = FGM.Catalog:Target()
        if not target or target.guid ~= metadata.targetGUID then
            self:Cancel(); self:SetStatus("STATUS_FAILED", FGM:L("TARGET_CHANGED")); return false
        end
    end
    local valid, errorMessage = self:Validate(text)
    if not valid then
        self:SetStatus("STATUS_FAILED", errorMessage)
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        self:Cancel(); self:SetStatus("STATUS_FAILED", FGM:L("COMBAT_UNAVAILABLE"))
        return false
    end
    local send = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
    if not send then self:Cancel(); self:SetStatus("STATUS_FAILED", FGM:L("DATA_UNAVAILABLE")); return false end
    local recipient = UnitName("player")
    if not recipient or recipient == "" then
        self:Cancel(); self:SetStatus("STATUS_FAILED", FGM:L("CHAT_SELF_UNAVAILABLE")); return false
    end
    -- ForeverCore parses dot commands before chat routing. Self-whispers use
    -- the normal chat API without delayed public SAY traffic or a fake handshake.
    local sent, errorMessage = pcall(send, text, "WHISPER", nil, recipient)
    if not sent then self:Cancel(); self:SetStatus("STATUS_FAILED", tostring(errorMessage)); return false end
    self.lastSent = GetTime()
    self.awaiting = { command = text, sentAt = self.lastSent }
    FGM:RememberRecent(metadata and metadata.kind or "command", metadata and metadata.id or text, metadata and metadata.label or text, text)
    self:SetStatus("STATUS_DISPATCHED", text)
    FGM:Print(FGM:L("STATUS_DISPATCHED", text))
    if metadata and metadata.bulk then
        self.bulkSent = (self.bulkSent or 0) + 1
        if FGM.UI.bulkProgress then FGM.UI.bulkProgress:SetText(FGM:L("BULK_RESULTS", self.bulkSent, self.bulkTotal or 0)) end
    end
    return true
end

function Executor:Execute(text, metadata, forceConfirm)
    local valid, errorMessage = self:Validate(text)
    if not valid then self:SetStatus("STATUS_FAILED", errorMessage); return false end
    local dangerous = forceConfirm or FGM.CommandRegistry:IsDangerous(text:sub(2))
    if dangerous and FGM.UI and FGM.UI.ConfirmCommand then
        FGM.UI:ConfirmCommand(text, function() Executor:Queue(text, metadata) end, true)
        return
    end
    return self:Queue(text, metadata)
end

function Executor:Queue(text, metadata)
    -- A normal button/confirmation click sends immediately. Only bursts and
    -- bulk operations need OnUpdate pacing; no server response gates sending.
    if #self.queue == 0 and GetTime() - self.lastSent >= (FGM.DB.profile.commandDelay or 0.45) then
        local sent = self:DispatchNow(text, metadata)
        self.running = false
        if FGM.UI and FGM.UI.UpdateQueue then FGM.UI:UpdateQueue(0) end
        return sent
    end
    table.insert(self.queue, { text = text, metadata = metadata })
    if #self.queue > 1 or GetTime() - self.lastSent < (FGM.DB.profile.commandDelay or 0.45) then
        self:SetStatus("STATUS_RATE_LIMIT")
    end
    self.running = true
    if FGM.UI and FGM.UI.UpdateQueue then FGM.UI:UpdateQueue(#self.queue) end
end

function Executor:QueueBulk(commands, metadata)
    self.bulkSent = 0
    self.bulkTotal = #commands
    for _, text in ipairs(commands) do
        table.insert(self.queue, { text = text, metadata = metadata })
    end
    self.running = #self.queue > 0
    if FGM.UI and FGM.UI.UpdateQueue then FGM.UI:UpdateQueue(#self.queue) end
end

function Executor:Cancel()
    wipe(self.queue)
    self.running = false
    self.awaiting = nil
    self:SetStatus("STATUS_CANCELLED")
    if FGM.UI and FGM.UI.UpdateQueue then FGM.UI:UpdateQueue(0) end
end

function Executor:OnUpdate()
    -- Response tracking is optional and expires silently. It never blocks a
    -- command, leaves an indefinite waiting message, or implies success.
    if self.awaiting and GetTime() - self.awaiting.sentAt > 8 then self.awaiting = nil end
    if not self.running or #self.queue == 0 then return end
    if GetTime() - self.lastSent < (FGM.DB.profile.commandDelay or 0.45) then return end
    local nextCommand = table.remove(self.queue, 1)
    self:DispatchNow(nextCommand.text, nextCommand.metadata)
    self.running = #self.queue > 0
    if FGM.UI and FGM.UI.UpdateQueue then FGM.UI:UpdateQueue(#self.queue) end
end

function Executor:OnSystemMessage(message)
    if not self.awaiting then return end
    if GetTime() - self.awaiting.sentAt > 8 then self.awaiting = nil; return end
    local lower = string.lower(tostring(message or ""))
    for _, pattern in ipairs(failurePatterns) do
        if lower:find(pattern, 1, true) then
            self:SetStatus("STATUS_FAILED", message)
            self.awaiting = nil
            return
        end
    end
    self:SetStatus("STATUS_RESPONSE", message)
    self.awaiting = nil
end
