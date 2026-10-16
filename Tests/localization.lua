function FGM_RUN_LOCALIZATION_TESTS()
    local F,E,S=ForeverGM,ForeverGM.CommandExecutor,FGM_TEST
    local checks=0
    local function check(value,message)assert(value,message);checks=checks+1 end
    local function drain()while F.Database.job do F.Database:OnUpdate()end end
    local oldLocale,oldLanguage,oldItem,oldSpell,oldGetItem,oldGetSpell=GetLocale,F.DB.profile.language,C_Item,C_Spell,GetItemInfo,GetSpellInfo
    local itemMap=F.Catalog:ItemMap()
    for _,locale in ipairs({"enUS","frFR","esES"})do
        F.DB.profile.language=locale
        for key in pairs(F.Locales.enUS)do check(F.Locales[locale][key]~=nil,"Untranslated interface key " .. locale .. ":" .. key)end
        local warning=F:L("COMPATIBILITY_WARNING",16001,16002)
        check(warning:find("16001",1,true) and warning:find("16002",1,true),"Compatibility warning did not format interface versions")
        for _,skill in ipairs(F.Data.Skills)do
            local label=F.Catalog:SkillName(skill)
            check(label and not label:find("#",1,true),"Skill translation missing: " .. locale .. ":" .. skill[1])
        end
        for _,language in ipairs(F.Data.Languages)do check(F:LocalizedName("languages",language)~=nil,"Language record not translated")end
        local slots={};for _,item in ipairs(F.Data.Items)do slots[item[8]]=true end
        for slot in pairs(slots)do check(F.Locales[locale]["SLOT_" .. slot]~=nil,"Untranslated inventory slot " .. slot)end
    end
    F.DB.profile.language="enUs";GetLocale=function()return "frFR"end
    local nativeCalls=0
    C_Item={GetItemInfo=function()nativeCalls=nativeCalls+1;return "FR CLIENT NAME"end}
    check(F:GetLanguage()=="enUS" and F.Catalog:Name("items",itemMap[25])=="Worn Shortsword","English selection used French source/client names")
    check(nativeCalls==0,"Wrong-language client item API was used")
    for _,alias in ipairs({"ENUS","enGB","engb"})do F.DB.profile.language=alias;check(F:GetLanguage()=="enUS","English locale alias failed")end
    F.DB.profile.language="esMX";check(F:GetLanguage()=="esES","Spanish locale alias failed")
    F.DB.profile.language="auto";GetLocale=function()return "esMX"end;check(F:GetLanguage()=="esES","Auto did not follow client locale")
    GetLocale=function()return "deDE"end;check(F:GetLanguage()=="enUS" and F:GetClientLocale()=="deDE","Unsupported client locale was mistaken for English")
    check(F.Catalog:Name("items",{999999,"German source name",1,1,1,1,1,1,1,""}):find("translation unavailable",1,true)~=nil,"Unsupported client language leaked into English UI")
    F.DB.profile.language="enUS";GetLocale=function()return "enUS"end
    C_Item={GetItemInfo=function()return nil end}
    F.UI:SetSection("items");drain();F.UI:BeginSearch("Worn Shortsword");drain()
    check(#F.UI.results>0 and F.UI.results[1][1]==25,"English name search missed French-base item")
    F.DB.profile.language="esES"
    local unavailable=F.Catalog:Name("items",{999999,"French source name",1,1,1,1,1,1,1,"English alias"})
    check(unavailable:find("traducción no disponible",1,true)~=nil and not unavailable:find("French source",1,true) and not unavailable:find("English alias",1,true),"Missing Spanish data leaked another language")
    F.DB.profile.language="frFR";check(F.Catalog:Name("items",itemMap[25])==F.Data.LocalizedNames.frFR.items[25],"French item name ignored")
    check(F:ClassName(1)=="Guerrier" and F:L("SLOT_1")=="Tête","Class/slot labels followed client instead of selected locale")
    check(F.Permissions:GetDisplay({role="Administrator",permissionId=1}):find("Administrateur",1,true)~=nil,"Role untranslated")
    check(F:CommandDescription({name="server info",description="English help"}):find("English help",1,true)==nil,"Wrong-language command help leaked")
    local teleport={1,"Stormwind",0}
    check(F.Catalog:Name("teleport",teleport)=="Stormwind","Translated a server command destination token")
    local oldLink=GameTooltip.SetHyperlink;local links=0;GameTooltip.SetHyperlink=function()links=links+1 end
    F.DB.profile.language="frFR";F.Tooltips:ShowRecord(F.UI.main,"items",itemMap[25]);check(links==0,"Native tooltip leaked wrong client language")
    F.DB.profile.language="enUS";F.Tooltips:ShowRecord(F.UI.main,"items",itemMap[25]);check(links==1,"Matching-language native tooltip missing")
    GameTooltip.SetHyperlink=oldLink
    local loaded,requests=false,0
    C_Item={GetItemInfo=function(id)if loaded then return "Loaded English item"end end,RequestLoadItemDataByID=function(id)requests=requests+1 end}
    F.Catalog.requestedItems={}
    local row={999999,"French source name",1,1,1,1,1,1,1,""}
    F.Catalog:Name("items",row);F.Catalog:Name("items",row)
    check(requests==1,"Uncached item was not requested once")
    local requestBefore=requests;F.Catalog:PrimeEnglishItemNames()
    check(requests-requestBefore==23,"English cache preload did not match the 23-name offline gap")
    F.Catalog:PrimeEnglishItemNames();check(requests-requestBefore==23,"English preload requested missing IDs twice")
    F.UI:SetSection("items");drain();F.UI.selected=row;F.UI.args:SetText("7");loaded=true
    F.eventFrame.scripts.OnEvent(F.eventFrame,"ITEM_DATA_LOAD_RESULT",999999,true)
    check(F.UI.detailTitle:GetText()=="Loaded English item" and F.UI.args:GetText()=="7","Cache refresh failed or overwrote item quantity")
    GetLocale,F.DB.profile.language,C_Item,C_Spell,GetItemInfo,GetSpellInfo=oldLocale,oldLanguage,oldItem,oldSpell,oldGetItem,oldGetSpell

    local target=F.Catalog:Target();local plan,mounts=F.BuildSpellPlan("mounts",nil,target);local seen={}
    check(#plan==#F.Data.Mounts and #mounts==141,"All-mount plan does not match verified catalog")
    for _,command in ipairs(plan)do check(command:match("^%.learn %d+$") and not seen[command],"Duplicate or invalid mount command");seen[command]=true end
    local gm,entries=F.BuildSpellPlan("gm",nil,target)
    check(#gm==2 and #entries==2,"GM plan included arbitrary internal/class spells")
    for _,row in ipairs(entries)do check(row[5]=="gm","Non-GM spell in bulk grant")end
    local selected={[mounts[1][1]]=true};check(#F.BuildSpellPlan("mounts",selected,target)==1,"Bulk selection ignored")
    check(#F.BuildSpellPlan("mounts",nil,nil)==0,"Missing target accepted")
    E:Cancel();local before=#S.sent
    F.UI:SetSection("mounts");drain();check(F.UI.bulkButtons[1]:IsShown(),"Mount bulk toolbar missing")
    F.UI:ShowSpellBulk("mounts");check(F.UI.bulkPanel:IsShown() and #S.sent==before,"Opening preview sent mount commands")
    S.confirm=nil;F.UI.spellBulkRun.scripts.OnClick(F.UI.spellBulkRun)
    check(S.confirm~=nil and #E.queue==0,"Mount grant skipped confirmation")
    S.confirm.callback();check(#E.queue==141 and E.queue[1].metadata.targetGUID==target.guid,"Mount queue lacks captured target")
    local oldGuid=S.guid;S.guid="Different target";S.clock=300;E:OnUpdate()
    check(#S.sent==before and #E.queue==0,"Mount queue sent after target changed");S.guid=oldGuid
    local oldIsPlayer=UnitIsPlayer;UnitIsPlayer=function()return false end
    F.UI.bulkPanel:Hide();F.UI:ShowSpellBulk("gm");check(not F.UI.bulkPanel:IsShown(),"NPC target accepted for bulk spells")
    UnitIsPlayer=oldIsPlayer
    F.UI:SetSection("bis");drain()
    local tierCounts={t1=0,t2=0,t3=0,bis=0};local unavailableCount=0
    for _,set in ipairs(F.UI.results)do
        if tierCounts[set[6]] then tierCounts[set[6]]=tierCounts[set[6]]+1 end
        if set[8] and #set[8]>0 then
            unavailableCount=unavailableCount+1;F.UI:SelectRecord(set)
            check(not F.UI.actionButtons[1]:IsShown(),"Missing legacy tier items can be granted")
        else
            for _,id in ipairs(set[4])do check(itemMap[id]~=nil,"Grantable collection references an unvalidated item")end
        end
    end
    check(tierCounts.t1==9 and tierCounts.t2==9 and tierCounts.t3==9,"Nine class sets per tier not exposed")
    check(tierCounts.bis==9 and unavailableCount==18,"BiS candidates or unavailable-set status missing")
    for _,set in ipairs(F.Data.BiS.profiles)do
        check(set[7]:find("https://www.icy-veins.com/wow-classic/",1,true)==1 and set[11]>=0,"BiS source/coverage missing")
        E:Cancel();S.confirm=nil;F.UI:GiveBiS(set)
        check(S.confirm~=nil and #E.queue==0,"BiS grant skipped confirmation")
        S.confirm.callback();check(#E.queue==#set[4],"BiS item grant incomplete")
        for _,operation in ipairs(E.queue)do check(operation.text:match("^%.additem %d+ 1$") and operation.metadata.targetGUID==S.guid,"BiS synthetic ID sent as a server set or target unguarded")end
        E:Cancel()
    end
    for _,width in ipairs({820,1000,1160,1600})do
        F.UI.main:SetSize(width,760)
        check(F.UI.bulkBar:GetHeight()>=36,"Bulk toolbar collapsed")
        for _,button in ipairs(F.UI.bulkButtons)do check(button.points[1][4]+button:GetWidth()<=F.UI.content:GetWidth(),"Wrapped toolbar exceeds content width")end
    end
    return checks
end
