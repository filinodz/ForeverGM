-- Transport regression tests: never contact a real realm.
function FGM_RUN_COMMAND_TESTS()
    local F, E, S = ForeverGM, ForeverGM.CommandExecutor, FGM_TEST
    local checks = 0
    local function check(value, message) assert(value, message); checks=checks+1 end
    local function reset()
        E:Cancel(); E.lastSent=-math.huge; S.clock=100
    end
    local function tick(value) S.clock=value; E:OnUpdate() end
    reset()
    local before, history, messages = #S.sent, #F.DB.recent, #S.messages
    F.UI:Run("gm on", "")
    check(#S.sent==before+1 and S.sent[#S.sent]==".gm on", "Click did not send immediately")
    check(#E.queue==0 and not E.running, "Single click unnecessarily queued")
    local call=S.chatCalls[#S.chatCalls]
    check(call.channel=="WHISPER" and call.recipient==UnitName("player") and call.language==nil, "Command not sent through self-whisper chat")
    check(F.State.lastStatus==F:L("STATUS_DISPATCHED", ".gm on"), "Sent status implies waiting")
    check(#F.DB.recent==math.min(30,history+1), "Immediate send not recorded exactly once")
    check(#S.messages==messages+1 and S.messages[#S.messages]:find(".gm on",1,true), "Sent command not echoed locally in chat")
    tick(100.1); check(#S.sent==before+1, "Immediate command dispatched twice on OnUpdate")
    F.UI:Run("gm off", "")
    check(#E.queue==1 and #S.sent==before+1 and F.UI.queueButton:IsShown(), "Rapid second click bypassed pacing or queue indicator")
    tick(100.2); check(#S.sent==before+1, "Burst sent before anti-spam delay")
    tick(100.5); check(#S.sent==before+2 and S.sent[#S.sent]==".gm off" and #E.queue==0, "Burst waited for a server reply instead of only pacing")
    check(E.awaiting~=nil, "Optional response observation missing")
    tick(110); check(E.awaiting==nil and #S.sent==before+2, "Silent command left stale response tracking or was resent")
    check(F.State.lastStatus==F:L("STATUS_DISPATCHED", ".gm off"), "Silence became a fabricated failure/success")
    F.UI:Run("server info", ""); check(S.sent[#S.sent]==".server info" and #E.queue==0, "Next click gated on absent server acknowledgement")
    E:OnSystemMessage("Server information")
    check(F.State.lastStatus==F:L("STATUS_RESPONSE", "Server information"), "Optional response not observed")
    tick(111); F.UI:Run("gm on", ""); E:OnSystemMessage("Permission denied")
    check(F.State.lastStatus==F:L("STATUS_FAILED", "Permission denied") and E.awaiting==nil, "Server rejection not surfaced")

    reset(); before=#S.sent; S.confirm=nil
    E:Execute(".server restart 10", nil, true)
    check(#S.sent==before and #E.queue==0 and S.confirm~=nil, "Dangerous command skipped confirmation")
    S.confirm.callback()
    check(#S.sent==before+1 and S.sent[#S.sent]==".server restart 10", "Confirmation did not send synchronously")
    tick(101); check(#S.sent==before+1, "Confirmed command sent twice")

    reset(); before=#S.sent; history=#F.DB.recent
    for _,invalid in ipairs({"gm on", ".gm on\n.server restart 1", ".gm on;.gm off", ".learn |Hspell:1|h", "."..string.rep("x",255)}) do
        E:Execute(invalid); check(#S.sent==before and #E.queue==0 and #F.DB.recent==history, "Invalid command escaped validation")
    end
    check(E:Execute(nil)==false, "Nil command crashed or was accepted")

    -- Exercise both chat API families, without retrying ambiguous sends.
    reset(); before=#S.sent
    local oldModern, oldLegacy, oldName, oldCombat = C_ChatInfo, SendChatMessage, UnitName, InCombatLockdown
    local modernCalls=0
    C_ChatInfo={SendChatMessage=function(text,channel,language,recipient)
        modernCalls=modernCalls+1; oldLegacy(text,channel,language,recipient)
    end}
    SendChatMessage=function()error("Legacy API must not be called when modern API exists")end
    E:Execute(".gm on")
    check(modernCalls==1 and #S.sent==before+1 and S.chatCalls[#S.chatCalls].channel=="WHISPER", "Modern chat API routing failed")
    reset(); C_ChatInfo={}; SendChatMessage=oldLegacy; before=#S.sent
    E:Execute(".gm on"); check(#S.sent==before+1, "Legacy chat API fallback failed")
    reset(); before=#S.sent; history=#F.DB.recent; messages=#S.messages
    SendChatMessage=function()error("Mock transport failure")end
    E:Execute(".gm on")
    check(#S.sent==before and #F.DB.recent==history and #S.messages==messages and E.awaiting==nil, "Failed send reported or recorded as sent")
    check(F.State.lastStatus:find("Mock transport failure",1,true)~=nil, "Transport error not surfaced")
    reset(); SendChatMessage=nil
    check(E:Execute(".gm on")==false and #S.sent==before, "Missing chat API was not rejected")
    reset(); SendChatMessage=oldLegacy; UnitName=function()return nil end
    check(E:Execute(".gm on")==false and #S.sent==before, "Missing character name caused public-channel fallback")
    reset(); UnitName=oldName; InCombatLockdown=function()return true end
    check(E:Execute(".gm on")==false and #S.sent==before, "Combat guard was removed")
    C_ChatInfo,SendChatMessage,UnitName,InCombatLockdown=oldModern,oldLegacy,oldName,oldCombat

    reset(); before=#S.sent
    E:QueueBulk({".learn 201", ".setskill 43 1 300"},{targetGUID=S.guid,bulk=true})
    check(#S.sent==before, "Bulk preview queue dispatched unexpectedly")
    tick(100); check(#S.sent==before+1, "Bulk first send failed")
    tick(100.1); check(#S.sent==before+1, "Bulk anti-spam delay removed")
    tick(100.5); check(#S.sent==before+2 and S.chatCalls[#S.chatCalls].channel=="WHISPER", "Bulk did not continue without server response")
    reset(); E:QueueBulk({".gm on"},{targetGUID="Different-player",bulk=true}); before=#S.sent
    tick(100); check(#S.sent==before and #E.queue==0, "Wrong-target operation sent")
    reset(); E:QueueBulk({".gm on"}); E:Cancel(); before=#S.sent
    tick(200); check(#S.sent==before, "Cancelled queue was dispatched")
    check(E.awaiting==nil, "Cancel did not clear optional response tracking")
    return checks
end
