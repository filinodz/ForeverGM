local _, FGM = ...
local UI, T, C = FGM.UI, FGM.Theme, FGM.Components
local sections = {
 {"dashboard","DASHBOARD"},{"gmtools","GM_TOOLS"},{"skills","SKILLS"},{"spells","SPELLS"},{"languages","LANGUAGES"},{"mounts","MOUNTS"},
 {"items","ITEMS"},{"bis","BIS"},{"teleport","TELEPORT"},{"npcs","NPCS"},{"gameobjects","GAMEOBJECTS"},
 {"quests","QUESTS"},{"achievements","ACHIEVEMENTS"},{"characters","CHARACTERS"},{"accounts","ACCOUNTS"},
 {"moderation","MODERATION"},{"server","SERVER"},{"debug","DEBUG"},{"commands","COMMANDS"},
}
local commandCategories = {accounts="account",characters="character",moderation="moderation",server="server",debug="debug"}
local classTokens = {[1]="WARRIOR",[2]="PALADIN",[3]="HUNTER",[4]="ROGUE",[5]="PRIEST",[7]="SHAMAN",[8]="MAGE",[9]="WARLOCK",[11]="DRUID"}
local slotTokens = {[0]="INVTYPE_NON_EQUIP",[1]="INVTYPE_HEAD",[2]="INVTYPE_NECK",[3]="INVTYPE_SHOULDER",[4]="INVTYPE_BODY",[5]="INVTYPE_CHEST",[6]="INVTYPE_WAIST",[7]="INVTYPE_LEGS",[8]="INVTYPE_FEET",[9]="INVTYPE_WRIST",[10]="INVTYPE_HAND",[11]="INVTYPE_FINGER",[12]="INVTYPE_TRINKET",[13]="INVTYPE_WEAPON",[14]="INVTYPE_SHIELD",[15]="INVTYPE_RANGED",[16]="INVTYPE_CLOAK",[17]="INVTYPE_2HWEAPON",[18]="INVTYPE_BAG",[19]="INVTYPE_TABARD",[20]="INVTYPE_ROBE",[21]="INVTYPE_WEAPONMAINHAND",[22]="INVTYPE_WEAPONOFFHAND",[23]="INVTYPE_HOLDABLE",[24]="INVTYPE_AMMO",[25]="INVTYPE_THROWN",[26]="INVTYPE_RANGEDRIGHT",[28]="INVTYPE_RELIC"}
local function panel(parent) local f=FGM:CreateCompatibleFrame("Frame",nil,parent); T:ApplyPanel(f); return f end
local function icon(parent, size) local x=parent:CreateTexture(nil,"ARTWORK");x:SetSize(size,size);x:SetTexCoord(.06,.94,.06,.94);return x end
local function categoryName(value)
 if value:find("^slot_") then local n=tonumber(value:sub(6));return _G[slotTokens[n] or ""] or FGM:L("ID") .. " " .. tostring(n) end
 local commandLabels={account="ACCOUNTS",character="CHARACTERS",moderation="MODERATION",server="SERVER",debug="DEBUG",gm="CAT_GM",npc="NPCS",gameobject="GAMEOBJECTS",teleport="TELEPORT",quests="QUESTS",achievements="ACHIEVEMENTS",items="ITEMS",spells="SPELLS",skills="SKILLS",lookup="SEARCH",other="CAT_OTHER"}
 return FGM:L(commandLabels[value] or ("CAT_" .. string.upper(value)))
end

function UI:Create()
 if self.main then return end
 local w=FGM.DB.profile.window
 local f=panel(UIParent);self.main=f;_G.ForeverGMMainFrame=f
 f:SetSize(math.max(820,w.width),math.max(620,w.height));f:SetPoint(w.point,UIParent,w.relativePoint,w.x,w.y)
 f:SetFrameStrata("HIGH");f:SetClampedToScreen(true);f:SetMovable(true);f:SetResizable(true);f:SetScale(FGM.DB.profile.scale)
 if f.SetResizeBounds then f:SetResizeBounds(820,620,1920,1200) else f:SetMinResize(820,620) end
 table.insert(UISpecialFrames,"ForeverGMMainFrame")
 local header=panel(f);header:SetPoint("TOPLEFT",6,-6);header:SetPoint("TOPRIGHT",-6,-6);header:SetHeight(66)
 header:EnableMouse(true);header:RegisterForDrag("LeftButton");header:SetScript("OnDragStart",function() f:StartMoving() end)
 header:SetScript("OnDragStop",function() f:StopMovingOrSizing();UI:SaveGeometry() end)
 local emblem=icon(header,54);emblem:SetTexCoord(0,1,0,1);emblem:SetPoint("LEFT",10,0);emblem:SetTexture("Interface\\AddOns\\ForeverGM\\Assets\\ForeverGM-Emblem")
 local title=C:Label(header,"ForeverGM",true,T.colors.gold);title:SetPoint("TOPLEFT",74,-12)
 self.subtitle=C:Label(header,FGM:L("TAGLINE"),false,T.colors.muted);self.subtitle:SetPoint("TOPLEFT",74,-36)
 self.identity=C:Label(header,"",false,T.colors.text);self.identity:SetPoint("RIGHT",-132,0);self.identity:SetJustifyH("RIGHT")
 local close=C:Button(header,"X",30,28,function() UI:Hide() end);close:SetPoint("TOPRIGHT",-10,-10)
 local minimize=C:Button(header,"-",30,28,function() UI:Hide() end);minimize:SetPoint("RIGHT",close,"LEFT",-4,0)
 local settings=C:Button(header,"",30,28,function() UI:ShowSettings() end);settings:SetPoint("RIGHT",minimize,"LEFT",-4,0)
 local settingsIcon=icon(settings,21);settingsIcon:SetPoint("CENTER");settingsIcon:SetTexture(FGM.Catalog.sectionIcons.debug)

 local nav=panel(f);nav:SetPoint("TOPLEFT",8,-80);nav:SetPoint("BOTTOMLEFT",8,38);nav:SetWidth(174);self.nav=nav
 local navScroll=CreateFrame("ScrollFrame",nil,nav,"UIPanelScrollFrameTemplate");navScroll:SetPoint("TOPLEFT",4,-6);navScroll:SetPoint("BOTTOMRIGHT",-25,6)
 local navChild=CreateFrame("Frame",nil,navScroll);navChild:SetSize(142,#sections*36);navScroll:SetScrollChild(navChild)
 self.sidebarButtons={}
 for index,section in ipairs(sections) do
  local id,key=section[1],section[2]
  local b=C:Button(navChild,FGM:L(key),142,33,function() UI:SetSection(id) end);b:SetPoint("TOPLEFT",0,-(index-1)*36)
  b.text:ClearAllPoints();b.text:SetPoint("LEFT",32,0);b.text:SetPoint("RIGHT",-3,0);b.text:SetJustifyH("LEFT");b.text:SetFontObject("GameFontNormalSmall")
  b.icon=icon(b,23);b.icon:SetPoint("LEFT",5,0);b.icon:SetTexture(FGM.Catalog.sectionIcons[id]);self.sidebarButtons[id]=b
 end
 local content=panel(f);content:SetPoint("TOPLEFT",nav,"TOPRIGHT",8,0);content:SetPoint("BOTTOMRIGHT",-8,38);self.content=content
 self.sectionTitle=C:Label(content,"",true,T.colors.gold);self.sectionTitle:SetPoint("TOPLEFT",16,-14)
 self.search=C:EditBox(content,280,30);self.search:SetPoint("TOPRIGHT",-16,-10)
 self.search:SetScript("OnEscapePressed",function(e)e:ClearFocus()end)
 self.search:SetScript("OnTextChanged",function(e,user) if user then UI:BeginSearch(e:GetText()) end end)
 self.search.placeholder=C:Label(self.search,FGM:L("SEARCH"),false,T.colors.muted);self.search.placeholder:SetPoint("LEFT",8,0)
 self.search:SetScript("OnEditFocusGained",function(e)e.placeholder:Hide()end)
 self.search:SetScript("OnEditFocusLost",function(e)e.placeholder:SetShown(e:GetText()=="")end)
 self.categoryButton=C:Button(content,"",180,28,function()UI:ShowFilterMenu("category")end);self.categoryButton:SetPoint("TOPLEFT",14,-52)
 self.classButton=C:Button(content,"",150,28,function()UI:ShowFilterMenu("class")end);self.classButton:SetPoint("LEFT",self.categoryButton,"RIGHT",8,0)
 self.favoriteButton=C:Button(content,FGM:L("SHOW_FAVORITES"),122,28,function()UI.onlyFavorites=not UI.onlyFavorites;UI:BeginSearch(UI.search:GetText())end);self.favoriteButton:SetPoint("LEFT",self.classButton,"RIGHT",8,0)
 self.countText=C:Label(content,"",false,T.colors.muted);self.countText:SetPoint("TOPLEFT",16,-92)
 self.bulkBar=CreateFrame("Frame",nil,content);self.bulkBar:SetPoint("TOPLEFT",14,-114);self.bulkBar:SetPoint("TOPRIGHT",-14,-114);self.bulkBar:SetHeight(30)
 self.bulkButtons={}
 for i=1,3 do local b=C:Button(self.bulkBar,"",150,28);b:SetPoint("LEFT",(i-1)*158,0);b:Hide();self.bulkButtons[i]=b end

 self.scroll=CreateFrame("ScrollFrame",nil,content,"UIPanelScrollFrameTemplate")
 self.scrollChild=CreateFrame("Frame",nil,self.scroll);self.scrollChild:SetSize(400,1);self.scroll:SetScrollChild(self.scrollChild)
 self.rows={}
 for i=1,60 do
  local b=FGM:CreateCompatibleFrame("Button",nil,self.scrollChild);T:ApplyPanel(b,true);b:SetHeight(76)
  b.icon=icon(b,44);b.icon:SetPoint("LEFT",10,0)
  b.name=C:Label(b,"",false,T.colors.text);b.name:SetPoint("TOPLEFT",64,-12);b.name:SetPoint("TOPRIGHT",-9,-12);b.name:SetJustifyV("TOP");b.name:SetHeight(30)
  b.meta=C:Label(b,"",false,T.colors.muted);b.meta:SetFontObject("GameFontNormalSmall");b.meta:SetPoint("BOTTOMLEFT",64,12);b.meta:SetPoint("BOTTOMRIGHT",-8,12)
  b:SetScript("OnClick",function(x)if x.record then UI:SelectRecord(x.record) end end)
  b:SetScript("OnEnter",function(x)x:SetBackdropBorderColor(unpack(T.colors.gold));if x.record then FGM.Tooltips:ShowRecord(x,UI.activeKind,x.record) end end)
  b:SetScript("OnLeave",function(x)x:SetBackdropBorderColor(unpack(T.colors.goldDim));GameTooltip:Hide()end)
  b:Hide();self.rows[i]=b
 end
 self.empty=C:Label(self.scrollChild,"",false,T.colors.muted);self.empty:SetPoint("TOPLEFT",14,-20);self.empty:SetWidth(420)

 self.detail=panel(content);T:ApplyPanel(self.detail,true)
 self.detailIcon=icon(self.detail,46);self.detailIcon:SetPoint("TOPLEFT",12,-12)
 self.detailTitle=C:Label(self.detail,FGM:L("DETAIL_EMPTY"),true,T.colors.gold);self.detailTitle:SetPoint("TOPLEFT",70,-12);self.detailTitle:SetPoint("TOPRIGHT",-12,-12);self.detailTitle:SetHeight(42);self.detailTitle:SetJustifyV("TOP")
 self.detailScroll=CreateFrame("ScrollFrame",nil,self.detail,"UIPanelScrollFrameTemplate");self.detailScroll:SetPoint("TOPLEFT",12,-70);self.detailScroll:SetPoint("BOTTOMRIGHT",-30,140)
 self.detailChild=CreateFrame("Frame",nil,self.detailScroll);self.detailChild:SetSize(230,200);self.detailScroll:SetScrollChild(self.detailChild)
 self.detailText=C:Label(self.detailChild,"",false,T.colors.text);self.detailText:SetPoint("TOPLEFT");self.detailText:SetJustifyV("TOP")
 self.argsLabel=C:Label(self.detail,FGM:L("ARGUMENTS"),false,T.colors.muted);self.argsLabel:SetPoint("BOTTOMLEFT",14,115)
 self.args=C:EditBox(self.detail,240,28);self.args:SetPoint("BOTTOMLEFT",14,82)
 self.actionButtons={}
 for i=1,4 do self.actionButtons[i]=C:Button(self.detail,"",116,28);self.actionButtons[i]:Hide();self.actionButtons[i].text:SetFontObject("GameFontNormalSmall") end

 self.pager=CreateFrame("Frame",nil,content);self.pager:SetPoint("BOTTOMLEFT",12,10);self.pager:SetPoint("BOTTOMRIGHT",-12,10);self.pager:SetHeight(28)
 self.previous=C:Button(self.pager,"<",34,28,function()UI.page=math.max(1,UI.page-1);UI.scroll:SetVerticalScroll(0);UI:RenderPage()end);self.previous:SetPoint("LEFT")
 self.pageLabel=C:Label(self.pager,"",false,T.colors.muted);self.pageLabel:SetPoint("LEFT",self.previous,"RIGHT",12,0)
 self.next=C:Button(self.pager,">",34,28,function()UI.page=math.min(math.max(1,math.ceil(#UI.results/60)),UI.page+1);UI.scroll:SetVerticalScroll(0);UI:RenderPage()end);self.next:SetPoint("RIGHT")
 self.statusText=C:Label(f,FGM:L("STATUS_READY"),false,T.colors.muted);self.statusText:SetPoint("BOTTOMLEFT",16,14);self.statusText:SetPoint("BOTTOMRIGHT",-180,14);self.statusText:SetHeight(14)
 self.queueButton=C:Button(f,FGM:L("CANCEL_QUEUE"),150,24,function()FGM.CommandExecutor:Cancel()end);self.queueButton:SetPoint("BOTTOMRIGHT",-24,8);self.queueButton:Hide()
 self.versionText=C:Label(f,"v" .. FGM.version,false,T.colors.gold);self.versionText:SetPoint("BOTTOMRIGHT",-24,14)
 local resize=CreateFrame("Button",nil,f);resize:SetSize(24,24);resize:SetPoint("BOTTOMRIGHT",-2,2)
 resize:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up");resize:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
 resize:SetScript("OnMouseDown",function()f:StartSizing("BOTTOMRIGHT")end);resize:SetScript("OnMouseUp",function()f:StopMovingOrSizing();UI:SaveGeometry()end)
 f:SetScript("OnSizeChanged",function()UI:Layout()end)
 f:SetScript("OnShow",function()UI:RefreshIdentity();UI:Layout()end)
 f:Hide();self:SetSection("skills");self:Layout()
end

function UI:Layout()
 if not self.content or not self.detail then return end
 local width=self.content:GetWidth();local wide=width>=860
 self.search:SetWidth(math.max(200,math.min(380,width*.43)))
 self.identity:SetWidth(math.max(100,self.main:GetWidth()-480))
 self.subtitle:SetWidth(240)
 self.scroll:ClearAllPoints();self.detail:ClearAllPoints()
 if wide then
  local detailWidth=math.min(340,math.floor(width*.32))
  self.detail:SetPoint("TOPRIGHT",-12,-114);self.detail:SetPoint("BOTTOMRIGHT",-12,48);self.detail:SetWidth(detailWidth)
  self.scroll:SetPoint("TOPLEFT",12,-154);self.scroll:SetPoint("BOTTOMRIGHT",-detailWidth-44,48)
 else
  self.detail:SetPoint("BOTTOMLEFT",12,48);self.detail:SetPoint("BOTTOMRIGHT",-12,48);self.detail:SetHeight(200)
  self.scroll:SetPoint("TOPLEFT",12,-146);self.scroll:SetPoint("BOTTOMRIGHT",-32,262)
 end
 local sw=math.max(200,self.scroll:GetWidth());self.scrollChild:SetWidth(sw)
 self.empty:SetWidth(math.max(180,sw-28))
 local dw=math.max(240,self.detail:GetWidth());self.detailChild:SetWidth(dw-48);self.detailText:SetWidth(dw-48)
 self.detailChild:SetHeight(math.max(1,self.detailText:GetStringHeight()+12))
 self.args:SetWidth(dw-30)
 for i,b in ipairs(self.actionButtons) do
  b:ClearAllPoints();local col=(i-1)%2;local row=math.floor((i-1)/2)
  b:SetWidth((dw-36)/2);b:SetPoint("BOTTOMLEFT",12+col*((dw-36)/2+12),12+(1-row)*32)
 end
 if not wide then
  self.detailScroll:ClearAllPoints();self.detailScroll:SetPoint("TOPLEFT",12,-70);self.detailScroll:SetPoint("BOTTOMLEFT",12,12);self.detailScroll:SetWidth(math.max(180,dw*.48-32))
  self.detailChild:SetWidth(math.max(180,dw*.48-50));self.detailText:SetWidth(math.max(180,dw*.48-50))
  self.argsLabel:ClearAllPoints();self.argsLabel:SetPoint("TOPLEFT",dw*.5,-70)
  self.args:ClearAllPoints();self.args:SetPoint("TOPLEFT",dw*.5,-93);self.args:SetWidth(dw*.5-18)
  for i,b in ipairs(self.actionButtons) do b:ClearAllPoints();local col=(i-1)%2;local row=math.floor((i-1)/2);b:SetWidth((dw*.5-30)/2);b:SetPoint("BOTTOMLEFT",dw*.5+col*((dw*.5-30)/2+8),14+(1-row)*32) end
 else
  self.detailScroll:ClearAllPoints();self.detailScroll:SetPoint("TOPLEFT",12,-70);self.detailScroll:SetPoint("BOTTOMRIGHT",-30,140)
  self.argsLabel:ClearAllPoints();self.argsLabel:SetPoint("BOTTOMLEFT",14,115);self.args:ClearAllPoints();self.args:SetPoint("BOTTOMLEFT",14,82)
 end
 self.detailChild:SetHeight(math.max(1,self.detailText:GetStringHeight()+12))
 self:RenderPage()
end

function UI:SaveGeometry()
 local p,_,rp,x,y=self.main:GetPoint(1);local w=FGM.DB.profile.window
 w.point,w.relativePoint,w.x,w.y=p,rp,x,y;w.width,w.height=self.main:GetWidth(),self.main:GetHeight()
end
function UI:RefreshIdentity()
 local target=FGM.Catalog:Target();self.identity:SetText((UnitName("player") or "?") .. " · " .. (GetRealmName() or "?") .. "\n" .. FGM:L("CURRENT_TARGET",target and target.name or "—"))
end
function UI:Show()self:Create();self.main:Show();FGM.State.visible=true end
function UI:Hide()if self.main then self.main:Hide()end;FGM.State.visible=false end
function UI:Toggle()if self.main and self.main:IsShown()then self:Hide()else self:Show()end end
function UI:SetStatus(message)if self.statusText then self.statusText:SetText(message)end end
function UI:UpdateQueue(n)
 if not self.queueButton then return end
 self.queueButton:SetShown(n>0);self.versionText:SetShown(n==0);C:SetButtonText(self.queueButton,FGM:L("QUEUE_PROGRESS",n))
end

function UI:SetSection(id)
 FGM.Database:Cancel();if self.filterMenu then self.filterMenu:Hide()end
 self.activeSection=id;self.activeKind=commandCategories[id] and "commands" or id
 self.category="all";self.classID=0;self.onlyFavorites=false;self.results={};self.page=1;self.selected=nil
 for key,b in pairs(self.sidebarButtons)do b:SetBackdropBorderColor(unpack(key==id and T.colors.gold or T.colors.goldDim))end
 for _,pair in ipairs(sections)do if pair[1]==id then self.sectionTitle:SetText(FGM:L(pair[2])) end end
 self.search:SetText("");self.search.placeholder:Show();self:ClearActions()
 for _,b in ipairs(self.bulkButtons)do b:Hide()end
 self.detailIcon:SetTexture(FGM.Catalog.sectionIcons[id]);self.detailTitle:SetText(FGM:L("DETAIL_EMPTY"));self.detailText:SetText("")
 C:SetButtonText(self.categoryButton,FGM:L("FILTER_CATEGORY") .. ": " .. FGM:L("ALL"))
 C:SetButtonText(self.classButton,FGM:L("ALL_CLASSES"));self.classButton:SetEnabled(id=="spells" or id=="bis")
 if id=="skills" then
  self:SetBulkButton(1,"GIVE_ALL_SKILLS",function()UI:ShowSkillBulk("all")end)
  self:SetBulkButton(2,"GIVE_WEAPONS",function()UI:ShowSkillBulk("weapons")end)
  self:SetBulkButton(3,"BULK_PROFESSIONS",function()UI:ShowSkillBulk("professions")end)
 elseif id=="languages" then
  self:SetBulkButton(1,"LEARN_ALL_LANGUAGES",function()UI:Run("learn all languages","",nil,true)end)
 elseif id=="spells" then
  self:SetBulkButton(1,"CAT_GM",function()UI.category="gm";UI.classID=0;C:SetButtonText(UI.classButton,FGM:L("ALL_CLASSES"));UI:BeginSearch(UI.search:GetText());C:SetButtonText(UI.categoryButton,categoryName("gm"))end)
  self:SetBulkButton(2,"TRAINER_SPELLS",function()UI.category="trainer";UI:BeginSearch(UI.search:GetText());C:SetButtonText(UI.categoryButton,FGM:L("TRAINER_SPELLS"))end)
  self:SetBulkButton(3,"LEARN_CLASS_SELF",function()
    UI:ConfirmCommand(FGM:L("LEARN_CLASS_SELF_HINT"),function()UI:Run("learn my trainer","",{kind="spells",label=FGM:L("LEARN_CLASS_SELF")})end)
  end)
 end
 if id=="dashboard" then self:ShowDashboard()
 else self:BeginSearch("")end
end
function UI:SetBulkButton(i,key,callback)local b=self.bulkButtons[i];C:SetButtonText(b,FGM:L(key));b:SetScript("OnClick",callback);b:Show()end

function UI:ShowFilterMenu(mode)
 if self.filterMenu then self.filterMenu:Hide()end
 local menu=panel(self.main);self.filterMenu=menu;menu:SetFrameLevel(self.main:GetFrameLevel()+30);menu:SetWidth(240)
 menu:SetPoint("TOPLEFT",mode=="class" and self.classButton or self.categoryButton,"BOTTOMLEFT",0,-2)
 local options={{value=mode=="class" and 0 or "all",label=FGM:L("ALL")}}
 if mode=="class" then
  for _,id in ipairs({1,2,3,4,5,7,8,9,11})do options[#options+1]={value=id,label=LOCALIZED_CLASS_NAMES_MALE[classTokens[id]] or classTokens[id]}end
 else
  local seen={}
  for _,row in ipairs(FGM.Database:GetSource(self.activeKind))do local cat=FGM.Catalog:Category(self.activeKind,row);if not seen[cat]and cat~="all"then seen[cat]=true;options[#options+1]={value=cat,label=categoryName(cat)}end end
  table.sort(options,function(a,b)return a.label<b.label end)
  if self.activeKind=="spells" then
   options[#options+1]={value="trainer",label=FGM:L("TRAINER_SPELLS")}
   options[#options+1]={value="questspells",label=FGM:L("QUEST_SPELLS")}
  end
 end
 local scroll=CreateFrame("ScrollFrame",nil,menu,"UIPanelScrollFrameTemplate");scroll:SetPoint("TOPLEFT",6,-6);scroll:SetPoint("BOTTOMRIGHT",-26,6)
 local child=CreateFrame("Frame",nil,scroll);child:SetSize(204,#options*28);scroll:SetScrollChild(child);menu:SetHeight(math.min(330,#options*28+12))
 for index,option in ipairs(options)do local value,label=option.value,option.label
  local b=C:Button(child,label,202,26,function()
   if mode=="class"then UI.classID=value;C:SetButtonText(UI.classButton,label)else UI.category=value;C:SetButtonText(UI.categoryButton,label)end
   menu:Hide();UI:BeginSearch(UI.search:GetText())
  end);b:SetPoint("TOPLEFT",0,-(index-1)*28)
 end
end

function UI:BeginSearch(text)
 if self.activeSection=="dashboard"then return end
 local section,kind,category,classID,favorites=self.activeSection,self.activeKind,self.category,self.classID,self.onlyFavorites
 self.countText:SetText(FGM:L("LOADING"))
 FGM.Database:Search(kind,text,function(results)
  if UI.activeSection~=section then return end
  UI.results=results;UI.page=1;UI.scroll:SetVerticalScroll(0);UI:RenderPage()
 end,function(row)
  if commandCategories[section]and row.category~=commandCategories[section]then return false end
  if kind=="spells" and category=="trainer" then
   if (row[8] or 0)==0 or not FGM.Catalog:ClassMatches(row[8],classID)then return false end
  elseif kind=="spells" and category=="questspells" then
   if (row[10] or 0)==0 or not FGM.Catalog:ClassMatches(row[10],classID)then return false end
  elseif category~="all"and FGM.Catalog:Category(kind,row)~=category then return false end
  if kind=="spells"and classID~=0 and category~="trainer" and category~="questspells" and not FGM.Catalog:ClassMatches(row[4],classID)then return false end
  if kind=="bis"and classID~=0 and row[3]~=-1 and not FGM.Catalog:ClassMatches(row[3],classID)then return false end
  if favorites and not FGM.DB.favorites[kind .. ":" .. tostring(row.id or row[1])]then return false end
  return true
 end)
end

function UI:RenderPage()
 if not self.rows then return end
 local results=self.results or {};local total=#results;local pages=math.max(1,math.ceil(total/60));self.page=math.min(self.page or 1,pages)
 local width=math.max(200,self.scroll:GetWidth());local columns=math.max(1,math.floor(width/220));local cardWidth=(width-8-(columns-1)*8)/columns
 local shown=0
 for i,b in ipairs(self.rows)do
  local row=results[(self.page-1)*60+i]
  if row then
   b.record=row;b:ClearAllPoints();b:SetSize(cardWidth,76);b:SetPoint("TOPLEFT",4+((i-1)%columns)*(cardWidth+8),-math.floor((i-1)/columns)*84)
   b.icon:SetTexture(FGM.Catalog:Icon(self.activeKind,row));b.name:SetText(FGM.Catalog:Name(self.activeKind,row))
   b.meta:SetText(FGM:L("ID") .. " " .. tostring(row.id or row[1]))
   if self.activeKind=="items" then b.meta:SetText("#" .. row[1] .. " · " .. FGM:L("ITEM_LEVEL") .. " " .. row[4])end
   b:SetBackdropBorderColor(unpack(row==self.selected and T.colors.gold or T.colors.goldDim))
   local color=self.activeKind=="items"and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[row[3]]
   if color then b.name:SetTextColor(color.r,color.g,color.b)else b.name:SetTextColor(unpack(T.colors.text))end
   b:Show();shown=shown+1
  else b.record=nil;b:Hide()end
 end
 self.scrollChild:SetHeight(math.max(1,math.ceil(shown/columns)*84));self.empty:SetShown(total==0)
 if total==0 and self.activeSection~="dashboard"and self.activeSection~="bis"then self.empty:SetText(FGM:L("NO_RESULTS"))end
 self.countText:SetText(FGM:L("RESULTS",total));self.pageLabel:SetText(FGM:L("PAGE",self.page,pages,total));self.previous:SetEnabled(self.page>1);self.next:SetEnabled(self.page<pages)
end

function UI:ShowDashboard()
 self.results={};self:RenderPage();self.detailTitle:SetText(FGM:L("DASH_WELCOME"));self.detailIcon:SetTexture("Interface\\AddOns\\ForeverGM\\Assets\\ForeverGM-Emblem")
 local lines={FGM.Compatibility:Summary(),"",FGM:L("MINIMAP_HELP"),""}
 for _,kind in ipairs({"skills","spells","mounts","items","teleport"})do lines[#lines+1]=FGM:L("DASH_DATA",FGM:L(string.upper(kind)),#FGM.Database:GetSource(kind))end
 self.empty:SetText(table.concat(lines,"\n"));self.empty:Show()
 self:SetAction(1,FGM:L("SKILLS"),function()UI:SetSection("skills")end);self:SetAction(2,FGM:L("SPELLS"),function()UI:SetSection("spells")end)
end
function UI:ClearActions()
 for _,b in ipairs(self.actionButtons or {})do b:Hide();b:SetScript("OnClick",nil)end
 self.args:SetText("");self.argsLabel:SetText(FGM:L("ARGUMENTS"));self.args:Show();self.argsLabel:Show()
end
function UI:SetAction(index,label,callback)local b=self.actionButtons[index];C:SetButtonText(b,label);b:SetScript("OnClick",callback);b:Show()end
function UI:Run(name,args,metadata,confirm)
 local record=type(name)=="table"and name or FGM.CommandRegistry:Get(name)
 if not record or record.availability=="unsupported"then self:SetStatus(FGM:L("DATA_UNAVAILABLE"));return end
 local command,err=FGM.CommandRegistry:Build(record,args);if not command then self:SetStatus(err);return end
 FGM.CommandExecutor:Execute(command,metadata,confirm)
end

function UI:SelectRecord(row)
 if not row then return end
 self.selected=row;self:ClearActions();local kind,id=self.activeKind,row.id or row[1];local name=FGM.Catalog:Name(kind,row)
 self.detailTitle:SetText(name);self.detailIcon:SetTexture(FGM.Catalog:Icon(kind,row))
 local meta={kind=kind,id=id,label=name};local lines={FGM:L("ID") .. ": " .. tostring(id)}
 if kind=="commands"or kind=="gmtools"then
  self.args:SetText(row.defaultArgs or "")
  lines={FGM:L("SYNTAX") .. "\n" .. row.syntax,"",FGM:L("PERMISSION") .. "\n" .. FGM.Permissions:GetDisplay(row),"",row.description}
  if row.availability~="unsupported"then self:SetAction(1,FGM:L("EXECUTE"),function()UI:Run(row,UI.args:GetText(),meta)end)end
  self:SetAction(2,FGM:L("COPY"),function()UI:Copy(FGM.CommandRegistry:Build(row,UI.args:GetText()))end)
 elseif kind=="spells"or kind=="mounts"then
  lines[#lines+1]=categoryName(FGM.Catalog:Category(kind,row));local description=C_Spell and C_Spell.GetSpellDescription and C_Spell.GetSpellDescription(id)
  if description and description~=""then lines[#lines+1]="";lines[#lines+1]=description end
  self:SetAction(1,FGM:L("LEARN"),function()UI:Run("learn",tostring(id),meta)end)
  self:SetAction(2,FGM:L("UNLEARN"),function()UI:Run("unlearn",tostring(id),meta,true)end)
  self:SetAction(3,FGM:L("CAST"),function()UI:Run("cast",tostring(id),meta)end)
  self.args:Hide();self.argsLabel:Hide()
 elseif kind=="skills"or kind=="languages"then
  local skill=kind=="skills"and row or {row[1],row[2],10,row[3]};local value,max=FGM.Catalog:SkillValue(skill,true,FGM.Catalog:Target())
  self.args:SetText(value .. " " .. max);self.argsLabel:SetText(FGM:L("SET_VALUE"));lines[#lines+1]=categoryName(FGM.Catalog:Category("skills",skill))
  local learn=FGM.Data.SkillLearnSpells[id]
  if learn then self:SetAction(1,FGM:L("SKILL_LEARN"),function()UI:Run("learn",tostring(learn),meta)end)end
  self:SetAction(2,FGM:L("SET_SKILL"),function()
   local a,b=UI.args:GetText():match("^(%d+)%s+(%d+)$");a,b=tonumber(a),tonumber(b)
   if not a or not b or a<1 or a>b or b>65535 then UI:SetStatus(FGM:L("INVALID_ARGUMENT"));return end
   UI:Run("setskill",id .. " " .. a .. " " .. b,meta)
  end)
 elseif kind=="bis"then
  local itemMap=FGM.Catalog:ItemMap()
  lines[#lines+1]=FGM:L("SET_COLLECTION_HINT");lines[#lines+1]=""
  for _,itemID in ipairs(row[4])do local item=itemMap[itemID];lines[#lines+1]="• " .. (item and item[2]or tostring(itemID)) .. " (#" .. itemID .. ")"end
  self.args:Hide();self.argsLabel:Hide()
  self:SetAction(1,FGM:L("GIVE_SET"),function()UI:Run("additem set",tostring(id),meta,true)end)
  self:SetAction(2,FGM:L("COPY_ID"),function()UI:Copy(id)end)
 elseif kind=="items"then
  lines[#lines+1]=FGM:L("ITEM_LEVEL") .. ": " .. row[4];lines[#lines+1]=categoryName("slot_" .. row[8]);self.args:SetText("1");self.argsLabel:SetText(FGM:L("COUNT"))
  self:SetAction(1,FGM:L("ADD_ITEM"),function()local n=tonumber(UI.args:GetText());if not n or n<1 or n>1000 or n%1~=0 then UI:SetStatus(FGM:L("INVALID_ARGUMENT"));return end;UI:Run("additem",id .. " " .. n,meta)end)
  self:SetAction(2,FGM:L("COPY_ID"),function()UI:Copy(id)end)
 elseif kind=="teleport"then
  lines[#lines+1]=FGM:L("MAP") .. ": " .. row[3];lines[#lines+1]=string.format("%.2f, %.2f, %.2f",row[4],row[5],row[6])
  self:SetAction(1,FGM:L("TELEPORT_ACTION"),function()UI:Run("tele",row[2],meta)end)
 elseif kind=="quests"then
  self:SetAction(1,FGM:L("ADD_QUEST"),function()UI:Run("quest add",tostring(id),meta)end)
  self:SetAction(2,FGM:L("COMPLETE_QUEST"),function()UI:Run("quest complete",tostring(id),meta,true)end)
  self:SetAction(3,FGM:L("REMOVE_QUEST"),function()UI:Run("quest remove",tostring(id),meta,true)end)
 elseif kind=="achievements"then lines[#lines+1]=row[3];self:SetAction(1,FGM:L("GRANT_ACHIEVEMENT"),function()UI:Run("achievement add",tostring(id),meta)end)
 elseif kind=="npcs"then lines[#lines+1]=row[3];self:SetAction(1,FGM:L("SPAWN_NPC"),function()UI:Run("npc add",tostring(id),meta,true)end)
 elseif kind=="gameobjects"then self:SetAction(1,FGM:L("SPAWN_GO"),function()UI:Run("gobject add",tostring(id),meta,true)end)end
 local favoriteKey=kind .. ":" .. tostring(id)
 self:SetAction(4,FGM.DB.favorites[favoriteKey]and FGM:L("UNFAVORITE")or FGM:L("FAVORITE"),function()FGM:ToggleFavorite(favoriteKey,meta);UI:SelectRecord(row)end)
 self.detailText:SetText(table.concat(lines,"\n"));self:Layout()
end
function UI:Copy(value)
 if not value then return end
 if not self.copyPanel then
  local p=panel(self.main);p:SetSize(460,110);p:SetPoint("CENTER");p:SetFrameLevel(self.main:GetFrameLevel()+40)
  local e=C:EditBox(p,420,28);e:SetPoint("TOP",0,-20);local close=C:Button(p,FGM:L("CLOSE"),100,26,function()p:Hide()end);close:SetPoint("BOTTOM",0,14)
  self.copyPanel,self.copyEdit=p,e
 end
 self.copyPanel:Show();self.copyEdit:SetText(tostring(value));self.copyEdit:SetFocus();self.copyEdit:HighlightText()
end
function UI:ShowSettings()
 self:Show()
 if not self.settings then
  local p=panel(self.main);p:SetSize(420,330);p:SetPoint("CENTER");p:SetFrameLevel(self.main:GetFrameLevel()+25)
  local title=C:Label(p,FGM:L("SETTINGS"),true,T.colors.gold);title:SetPoint("TOPLEFT",18,-18)
  local close=C:Button(p,FGM:L("CLOSE"),90,28,function()p:Hide()end);close:SetPoint("TOPRIGHT",-14,-14)
  local lang=C:Label(p,FGM:L("LOCALE"),false,T.colors.text);lang:SetPoint("TOPLEFT",20,-64)
  for i,locale in ipairs({"auto","enUS","frFR","esES"})do local l=locale;local b=C:Button(p,l,82,28,function()FGM.DB.profile.language=l;FGM:Print(FGM:L("RELOAD_TO_APPLY",l))end);b:SetPoint("TOPLEFT",20+(i-1)*92,-86)end
  local hide=C:Button(p,FGM:L("HIDE_MINIMAP"),250,28,function()FGM.DB.profile.minimap.hidden=not FGM.DB.profile.minimap.hidden;UI.minimap:SetShown(not FGM.DB.profile.minimap.hidden)end);hide:SetPoint("TOPLEFT",20,-134)
  local reset=C:Button(p,FGM:L("RESET_WINDOW"),250,28,function()UI.main:ClearAllPoints();UI.main:SetPoint("CENTER");UI.main:SetSize(1160,760);UI:SaveGeometry()end);reset:SetPoint("TOPLEFT",20,-174)
  for i,option in ipairs({{.85,"SCALE_SMALL"},{1,"SCALE_NORMAL"},{1.15,"SCALE_LARGE"}})do local value=option[1];local b=C:Button(p,FGM:L(option[2]),90,28,function()FGM.DB.profile.scale=value;UI.main:SetScale(value)end);b:SetPoint("TOPLEFT",20+(i-1)*100,-220)end
  local info=C:Label(p,FGM.Compatibility:Summary(),false,T.colors.muted);info:SetPoint("BOTTOMLEFT",20,24);self.settings=p
 end
 self.settings:Show()
end
