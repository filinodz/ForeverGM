local _, FGM = ...
FGM:RegisterModule("skills", { label = "SKILLS", kind = "skills", commands = { "setskill", "maxskill", "learn all crafts", "learn all recipes" } })

local function buildPlan(mode, maximize, selected, target)
    local commands, entries, seen = {}, {}, {}
    for _, skill in ipairs(FGM.Data.Skills) do
        local cat = FGM.Catalog:Category("skills", skill)
        local permittedCategory = cat == "weapons" or cat == "armor" or cat == "languages" or cat == "professions"
            or skill[1] == 129 or skill[1] == 185 or skill[1] == 356 or skill[1] == 762 or skill[1] == 40 or skill[1] == 633
        local matches = mode == "all" or (mode == "weapons" and cat == "weapons")
            or (mode == "professions" and (cat == "professions" or skill[1] == 129 or skill[1] == 185 or skill[1] == 356))
        local normalized = FGM.Database:Normalize(skill[2])
        local testLine = normalized:find("test",1,true) or normalized:find("dnt",1,true) or normalized:find("dnd",1,true)
        if permittedCategory and matches and not testLine and not seen[normalized] and FGM.Catalog:CompatibleSkill(skill,target) then
            seen[normalized] = true
            entries[#entries+1] = skill
            if not selected or selected[skill[1]] then
                local value, max = FGM.Catalog:SkillValue(skill,maximize,target)
                local learn = FGM.Data.SkillLearnSpells[skill[1]]
                if learn then commands[#commands+1] = ".learn " .. learn end
                commands[#commands+1] = ".setskill " .. skill[1] .. " " .. value .. " " .. max
            end
        end
    end
    return commands, entries
end
FGM.BuildSkillPlan = buildPlan

function FGM.UI:ShowSkillBulk(mode)
    local target=FGM.Catalog:Target()
    if not target then self:SetStatus(FGM:L("TARGET_REQUIRED"));return end
    local commands, entries=buildPlan(mode,false,nil,target)
    if self.bulkPanel then self.bulkPanel:Hide() end
    local C,T=FGM.Components,FGM.Theme
    local panel=FGM:CreateCompatibleFrame("Frame",nil,self.main);T:ApplyPanel(panel);panel:SetSize(620,510);panel:SetPoint("CENTER");panel:SetFrameLevel(self.main:GetFrameLevel()+40);self.bulkPanel=panel
    local title=C:Label(panel,FGM:L("BULK_PREVIEW",target.name),true,T.colors.gold);title:SetPoint("TOPLEFT",18,-16)
    local hint=C:Label(panel,FGM:L("BULK_HINT",target.name),false,T.colors.muted);hint:SetPoint("TOPLEFT",18,-48);hint:SetWidth(580)
    local scroll=CreateFrame("ScrollFrame",nil,panel,"UIPanelScrollFrameTemplate");scroll:SetPoint("TOPLEFT",14,-105);scroll:SetPoint("BOTTOMRIGHT",-34,110)
    local child=CreateFrame("Frame",nil,scroll);child:SetSize(560,#entries*36);scroll:SetScrollChild(child)
    local selected={};local maximize=false
    local count=C:Label(panel,"",false,T.colors.gold);count:SetPoint("BOTTOMLEFT",18,82)
    local valueLabels={}
    local function update()
        local plan=buildPlan(mode,maximize,selected,target);local n=0;for _,s in ipairs(entries)do if selected[s[1]]then n=n+1 end end
        count:SetText(FGM:L("BULK_SELECTED",n,#plan));return plan
    end
    for i,skill in ipairs(entries)do
        local row=skill;selected[row[1]]=true
        local box=CreateFrame("CheckButton",nil,child,"UICheckButtonTemplate");box:SetSize(26,26);box:SetPoint("TOPLEFT",4,-(i-1)*36);box:SetChecked(true)
        local texture=child:CreateTexture(nil,"ARTWORK");texture:SetSize(28,28);texture:SetPoint("LEFT",box,"RIGHT",4,0);texture:SetTexture(FGM.Catalog:Icon("skills",row))
        local label=C:Label(child,FGM.Catalog:SkillName(row) .. "  |cff888888#" .. row[1] .. "|r",false,T.colors.text);label:SetPoint("LEFT",texture,"RIGHT",10,0);label:SetWidth(360)
        local value,max=FGM.Catalog:SkillValue(row,false,target)
        local values=C:Label(child,value .. " / " .. max,false,T.colors.muted);values:SetPoint("RIGHT",box,"LEFT",545,0);valueLabels[row[1]]=values
        box:SetScript("OnClick",function(b)selected[row[1]]=b:GetChecked() and true or nil;update()end)
    end
    local maxbox=CreateFrame("CheckButton",nil,panel,"UICheckButtonTemplate");maxbox:SetSize(26,26);maxbox:SetPoint("BOTTOMLEFT",18,50)
    local maxlabel=C:Label(panel,FGM:L("BULK_MAX"),false,T.colors.text);maxlabel:SetPoint("LEFT",maxbox,"RIGHT",6,0)
    maxbox:SetScript("OnClick",function(b)
        maximize=b:GetChecked()and true or false
        for _,skill in ipairs(entries)do local value,max=FGM.Catalog:SkillValue(skill,maximize,target);valueLabels[skill[1]]:SetText(value .. " / " .. max)end
        update()
    end)
    local run=C:Button(panel,FGM:L("BULK_EXECUTE"),270,30,function()
        local current=FGM.Catalog:Target()
        if not current or current.guid~=target.guid then FGM.UI:SetStatus(FGM:L("TARGET_CHANGED"));return end
        local plan=update();if #plan==0 then return end
        FGM.UI:ConfirmCommand(count:GetText() .. "\n" .. FGM:L("CURRENT_TARGET",target.name),function()
            FGM.CommandExecutor:QueueBulk(plan,{kind="skills",label=FGM:L("GIVE_ALL_SKILLS"),bulk=true,targetGUID=target.guid})
            panel:Hide()
        end,true)
    end);run:SetPoint("BOTTOMLEFT",18,12)
    local close=C:Button(panel,FGM:L("CLOSE"),110,30,function()panel:Hide()end);close:SetPoint("BOTTOMRIGHT",-18,12)
    self.bulkProgress=count;update()
end
