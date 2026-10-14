-- Runtime regression checks against mocked WoW APIs. No server is contacted.
unpack = table.unpack
function wipe(t) for k in pairs(t) do t[k] = nil end end
bit = { band=function(a,b)
 a,b=math.floor(a),math.floor(b);if a<0 then a=a+4294967296 end;if b<0 then b=b+4294967296 end
 local result,power=0,1;while a>0 and b>0 do if a%2==1 and b%2==1 then result=result+power end;a=math.floor(a/2);b=math.floor(b/2);power=power*2 end;return result
end }
_G.FGM_TEST = { clock=20, classID=8, raceID=1, level=60, guid="Player-A", sent={} }
function GetTime()return FGM_TEST.clock end
function time()return 1 end
function GetBuildInfo()return "1.60.1","70338","2026-10-14",16001 end
function GetLocale()return "frFR"end
function UnitExists()return true end
function UnitIsPlayer()return true end
function UnitName()return "TestMage"end
function UnitClass()return "Mage","MAGE",FGM_TEST.classID end
function UnitRace()return "Human","Human",FGM_TEST.raceID end
function UnitLevel()return FGM_TEST.level end
function UnitGUID()return FGM_TEST.guid end
function GetRealmName()return "Forever"end
function GetCursorPosition()return 180,200 end
math.atan2 = math.atan2 or function(y,x)return math.atan(y,x)end
function InCombatLockdown()return false end
function SendChatMessage(text)FGM_TEST.sent[#FGM_TEST.sent+1]=text end
DEFAULT_CHAT_FRAME={AddMessage=function()end}
YES="Yes";CANCEL="Cancel";StaticPopupDialogs={};UISpecialFrames={};SlashCmdList={}
LOCALIZED_CLASS_NAMES_MALE={WARRIOR="Warrior",PALADIN="Paladin",HUNTER="Hunter",ROGUE="Rogue",PRIEST="Priest",SHAMAN="Shaman",MAGE="Mage",WARLOCK="Warlock",DRUID="Druid"}
C_Spell={GetSpellTexture=function(id)return id+100000 end}
local frame={}
frame.__index=frame
local function new(parent)return setmetatable({parent=parent,points={},scripts={},shown=true,text=""},frame)end
function CreateFrame(_,_,parent)return new(parent or UIParent)end
function frame:SetSize(w,h)self.width=w;self.height=h;if self.scripts.OnSizeChanged then self.scripts.OnSizeChanged(self,w,h)end end
function frame:SetWidth(w)self.width=w end
function frame:SetHeight(h)self.height=h end
function frame:SetPoint(point,a,b,c,d)
 local relative,relativePoint,x,y
 if type(a)=="table"then relative=a;relativePoint=b;x=c or 0;y=d or 0 else relative=self.parent;relativePoint=point;x=a or 0;y=b or 0 end
 self.points[#self.points+1]={point,relative,relativePoint,x,y}
end
function frame:ClearAllPoints()self.points={} end
function frame:GetPoint()local p=self.points[1]or {"CENTER",UIParent,"CENTER",0,0};return unpack(p)end
function frame:GetWidth()
 if self.width then return self.width end
 local left,right
 for _,p in ipairs(self.points)do
  local w=(p[2]and p[2]:GetWidth())or 0
  if p[1]:find("LEFT")then left=p[4]+(p[3]:find("RIGHT")and w or 0)end
  if p[1]:find("RIGHT")then right=p[4]+(p[3]:find("LEFT")and 0 or w)end
 end
 if left and right then return right-left end
 return self.parent and self.parent:GetWidth()or 1000
end
function frame:GetHeight()return self.height or 400 end
function frame:SetScript(key,fn)self.scripts[key]=fn end
function frame:CreateTexture()return new(self)end
function frame:CreateFontString()return new(self)end
function frame:SetTexture(value)self.texture=value end
function frame:GetTexture()return self.texture end
function frame:SetText(value)self.text=value;if self.scripts.OnTextChanged then self.scripts.OnTextChanged(self,false)end end
function frame:GetText()return self.text end
function frame:GetStringHeight()return math.max(14,math.ceil(#self.text/math.max(10,(self.width or 250)/7))*14)end
function frame:SetShown(value)self.shown=value end
function frame:Show()self.shown=true;if self.scripts.OnShow then self.scripts.OnShow(self)end end
function frame:Hide()self.shown=false end
function frame:IsShown()return self.shown end
function frame:SetChecked(v)self.checked=v end
function frame:GetChecked()return self.checked end
function frame:GetFrameLevel()return 1 end
function frame:GetCenter()return 100,200 end
function frame:SetVerticalScroll(value)self.scrollOffset=value end
function frame:SetScrollChild(child)self.child=child end
function frame:GetEffectiveScale()return 1 end
for _,method in ipairs({"SetBackdrop","SetBackdropColor","SetBackdropBorderColor","SetFrameStrata","SetClampedToScreen","SetMovable","SetResizable","SetScale","SetResizeBounds","SetMinResize","EnableMouse","RegisterForDrag","SetFontObject","SetJustifyH","SetJustifyV","SetTextColor","SetTexCoord","SetAutoFocus","SetTextInsets","SetEnabled","SetNormalTexture","SetHighlightTexture","SetFrameLevel","SetFocus","ClearFocus","HighlightText","StartMoving","StopMovingOrSizing","StartSizing","RegisterEvent","RegisterForClicks","SetPushedTexture","SetHitRectInsets"})do frame[method]=function()end end
UIParent=new();UIParent:SetSize(1920,1080);Minimap=new(UIParent);GameTooltip=new(UIParent)
function GameTooltip:SetOwner()end;function GameTooltip:AddLine()end;function GameTooltip:AddDoubleLine()end;function GameTooltip:SetHyperlink()end
function StaticPopup_Show(_,_,_,data)FGM_TEST.confirm=data end
C_Timer={After=function(_,fn)fn()end}

function FGM_RUN_TESTS()
 local F=ForeverGM;F:InitializeDatabase();F.Compatibility:Detect();F.CommandRegistry:Initialize();F.State.initialized=true
 F.UI:Create()
 local checks=0
 local function check(condition,message)assert(condition,message);checks=checks+1 end
 local function drainSearch()local n=0;while F.Database.job do F.Database:OnUpdate();n=n+1;assert(n<1000,"search did not finish")end end
 check(F.UI.activeSection=="dashboard" and F.UI.dashboard:IsShown(),"Dashboard must be the landing page")
 check(not F.UI.pager:IsShown() and not F.UI.search:IsShown() and not F.UI.detail:IsShown(),"Dashboard has irrelevant collection controls")
 check(#F.UI.dashboardStats==12 and #F.UI.dashboardShortcuts==16,"Dashboard tiles missing")
 check(F.UI.dashboardStats[1].value:GetText()=="24,288","Catalog count formatting incorrect")
 for _,tile in ipairs(F.UI.dashboardStats)do
  check(tile.count==#F.Database:GetSource(tile.kind),"Dashboard count differs from catalog")
  check(tile.icon.texture~=nil,"Dashboard stat icon missing")
  tile.scripts.OnClick(tile);drainSearch();check(F.UI.activeSection==tile.kind,"Stat tile opens wrong collection")
  check(F.UI.pager:IsShown() and F.UI.search:IsShown() and not F.UI.dashboard:IsShown(),"Collection controls did not return")
  check(#F.UI.scroll.points==2 and #F.UI.detail.points==2,"Collection viewport not anchored after dashboard navigation")
  F.UI:SetSection("dashboard")
 end
 for _,width in ipairs({820,1000,1160,1600,1920})do
  F.UI.main:SetSize(width,760)
  check(not F.UI.pager:IsShown() and not F.Database.job,"Dashboard resize triggered pagination or search")
  for _,cards in ipairs({F.UI.dashboardStats,F.UI.dashboardShortcuts})do
   for _,tile in ipairs(cards)do
    check(tile.points[1][4]+tile.width<=F.UI.dashboard:GetWidth(),"Dashboard card exceeds viewport")
    check(tile.width>=190,"Dashboard card too narrow")
    check(-tile.points[1][5]+tile.height<=F.UI.dashboardBody:GetHeight(),"Dashboard card below scroll extent")
   end
  end
 end
 for _,tile in ipairs(F.UI.dashboardShortcuts)do
  if tile.command then
   FGM_TEST.confirm=nil;local queued=#F.CommandExecutor.queue;local sent=#FGM_TEST.sent
   tile.scripts.OnClick(tile)
   check(FGM_TEST.confirm~=nil and #F.CommandExecutor.queue==queued and #FGM_TEST.sent==sent,"GM shortcut dispatched before confirmation")
   FGM_TEST.confirm.callback()
   check(F.CommandExecutor.queue[#F.CommandExecutor.queue].text==F.CommandRegistry:Build(tile.command,tile.command.defaultArgs or ""),"Shortcut command/default arguments changed")
   F.CommandExecutor:Cancel()
  elseif tile.workflow=="LEARN_CLASS_SELF" then
   FGM_TEST.confirm=nil;tile.scripts.OnClick(tile);check(FGM_TEST.confirm~=nil,"Class workflow skipped confirmation")
   FGM_TEST.confirm.callback();check(F.CommandExecutor.queue[#F.CommandExecutor.queue].text==".learn my trainer","Class workflow is not self-only")
   F.CommandExecutor:Cancel()
  else
   tile.scripts.OnClick(tile)
   check(tile.workflow=="SETTINGS" and F.UI.settings:IsShown() or F.UI.bulkPanel and F.UI.bulkPanel:IsShown(),"Dashboard workflow did not open")
   if F.UI.bulkPanel then F.UI.bulkPanel:Hide()end;if F.UI.settings then F.UI.settings:Hide()end
  end
 end
 F.UI:CreateMinimapButton();local launcher=F.UI.minimap
 check(launcher:GetWidth()==38 and launcher.icon.texture:find("Minimap%-v2"),"New minimap medallion not installed")
 launcher.scripts.OnEnter(launcher);check(launcher.icon:GetWidth()==36,"Minimap hover feedback missing")
 launcher.scripts.OnMouseDown(launcher);check(launcher.icon:GetWidth()==30,"Minimap pressed feedback missing")
 launcher.scripts.OnMouseUp(launcher);launcher.scripts.OnLeave(launcher);check(launcher.icon:GetWidth()==34,"Minimap icon did not reset")
 F.UI:Show();launcher.scripts.OnClick(launcher,"LeftButton");check(not F.UI.main:IsShown(),"Minimap toggle did not close")
 launcher.scripts.OnClick(launcher,"LeftButton");check(F.UI.main:IsShown(),"Minimap toggle did not open")
 launcher.scripts.OnClick(launcher,"RightButton");check(F.UI.settings:IsShown(),"Minimap right-click settings broken");F.UI.settings:Hide()
 launcher.scripts.OnDragStart(launcher);launcher.scripts.OnUpdate(launcher);launcher.scripts.OnDragStop(launcher)
 check(F.DB.profile.minimap.angle==0 and not launcher.dragging,"Minimap drag did not persist angle")
 for key in pairs(F.Locales.enUS)do check(F.Locales.frFR[key]~=nil and F.Locales.esES[key]~=nil,"Missing translation: " .. key)end
 check(F.Data.SkillLearnSpells[43]==201 and F.Data.SkillLearnSpells[95]==204,"Wrong weapon/defense proficiency mapping")
 F.UI:SetSection("skills");drainSearch();check(#F.UI.results==154,"Skills should open populated")
 check(F.UI.rows[1].icon.texture~=nil,"Cards need icons")
 F.UI:SetSection("spells");drainSearch();check(#F.UI.results==32337,"Empty search must browse complete spell collection")
 F.UI.category="class";F.UI.classID=8;F.UI:BeginSearch("");drainSearch();check(#F.UI.results>100,"Mage class filter empty")
 for _,r in ipairs(F.UI.results)do check(F.Catalog:ClassMatches(r[4],8),"foreign class spell")end
 F.UI.category="gm";F.UI.classID=0;F.UI:BeginSearch("");drainSearch();check(#F.UI.results==2,"Core GM/debug library not populated")
 F.UI.category="internal";F.UI:BeginSearch("");drainSearch();check(#F.UI.results==26,"Internal spells missing")
 F.UI.category="trainer";F.UI:BeginSearch("");drainSearch();check(#F.UI.results==1388,"Reference trainer data missing")
 F.UI.category="questspells";F.UI:BeginSearch("");drainSearch();check(#F.UI.results==51,"Quest spell data missing")
 F.UI.category="racial";F.UI:BeginSearch("");drainSearch();check(#F.UI.results==5,"Forever racial data missing")
 F.UI:SetSection("mounts");drainSearch();check(#F.UI.results==136,"Mount DB2 not loaded")
 F.UI:SetSection("quests");drainSearch();check(F.UI.sidebarButtons.quests.icon.texture==134939,"Quest navigation icon missing")
 check(F.UI.rows[1].icon.texture==134939,"Quest card icon missing");F.UI:SelectRecord(F.UI.results[1]);check(F.UI.detailIcon.texture==134939,"Quest inspector icon missing")
 F.UI:SetSection("items");drainSearch();check(#F.UI.results==24288,"Items missing on opening")
 F.UI.page=math.ceil(#F.UI.results/60);F.UI:RenderPage();check(F.UI.rows[1].record~=nil,"Last page inaccessible")
 for _,width in ipairs({820,1160,1600})do
  F.UI.main:SetSize(width,760);check(F.UI.rows[1].width>100,"Card width invalid after resize")
  local last=F.UI.rows[1];check(last.points[1][4]+last.width<=F.UI.scroll:GetWidth()+1,"Card overflows viewport")
  F.UI:SelectRecord(F.UI.results[1]);check(F.UI.args:GetWidth()>0,"Argument form collapsed")
 end
 F.UI:SetSection("accounts");drainSearch();check(#F.UI.results>0,"Command category empty")
 F.UI:SetSection("gmtools");drainSearch();check(#F.UI.results==12,"GM shortcut icons missing");F.UI:SelectRecord(F.UI.results[3]);check(F.UI.args:GetText()=="on","GM flight action lost default argument")
 F.UI:SetSection("bis");drainSearch();check(#F.UI.results>180,"Validated equipment sets missing");F.UI:SelectRecord(F.UI.results[1]);check(F.UI.actionButtons[1]:IsShown(),"Give set action unavailable")
 local itemMap=F.Catalog:ItemMap();for _,set in ipairs(F.UI.results)do for _,id in ipairs(set[4])do check(itemMap[id]~=nil,"Set references missing item")end end
 F.UI:SetSection("accounts");drainSearch()
 for _,r in ipairs(F.UI.results)do check(r.category=="account","Category filtered after pagination")end
 F.UI:SetSection("skills");drainSearch();F.UI:ShowSkillBulk("all");check(F.UI.bulkPanel:IsShown(),"Bulk preview unavailable")
 local target=F.Catalog:Target();local plan,entries=F.BuildSkillPlan("all",false,nil,target)
 local ids={};for _,s in ipairs(entries)do ids[s[1]]=true end
 check(ids[136],"Mage missing staff skill");check(not ids[55],"Mage must not bulk-learn two-handed swords")
 check(not ids[183] and not ids[2933],"Internal/test skills leaked into bulk")
 check(#plan>#entries,"Proficiency learning spells missing")
 FGM_TEST.classID=1;local _,warrior=F.BuildSkillPlan("weapons",true,nil,F.Catalog:Target());local found=false
 for _,s in ipairs(warrior)do if s[1]==55 then found=true end end;check(found,"Warrior missing two-handed swords")
 FGM_TEST.raceID=95;local _,skyborne=F.BuildSkillPlan("weapons",true,nil,F.Catalog:Target());check(#skyborne>5,"Skyborne race mask bit 32 was not handled")
 FGM_TEST.raceID=96;local _,skyborneHorde=F.BuildSkillPlan("weapons",true,nil,F.Catalog:Target());check(#skyborneHorde>5,"Skyborne race mask bit 33 was not handled")
 FGM_TEST.raceID=1
 F.CommandExecutor:QueueBulk({".setskill 55 1 300",".setskill 44 1 300"},{targetGUID=FGM_TEST.guid,bulk=true})
 FGM_TEST.clock=30;F.CommandExecutor:OnUpdate();check(#FGM_TEST.sent==1,"Queue did not dispatch first action")
 FGM_TEST.guid="Player-B";FGM_TEST.clock=31;F.CommandExecutor:OnUpdate();check(#FGM_TEST.sent==1 and #F.CommandExecutor.queue==0,"Target change failed to cancel queue")
 local command,error=F.CommandRegistry:Build("learn","133\n.server restart 1");check(command==nil and error~=nil,"Command injection accepted")
 local before=#FGM_TEST.sent;F.CommandExecutor:Execute(".ban character Test 1h reason",nil,true);check(#FGM_TEST.sent==before and FGM_TEST.confirm~=nil,"Dangerous action skipped confirmation")
 F.UI:ShowSettings();check(F.UI.settings:IsShown(),"Settings did not open")
 F.UI:SetSection("spells");F.UI:ShowFilterMenu("class");check(F.UI.filterMenu:IsShown(),"Class menu did not open")
 return checks
end
