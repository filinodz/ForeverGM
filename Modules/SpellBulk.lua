local _, FGM = ...

function FGM.BuildSpellPlan(kind, selected, target)
    if not target then return {}, {} end
    local source = kind == "mounts" and FGM.Data.Mounts or FGM.Data.Spells
    local commands, entries, seen = {}, {}, {}
    for _, row in ipairs(source or {}) do
        if (kind == "mounts" or row[5] == "gm") and not seen[row[1]] then
            seen[row[1]] = true; entries[#entries+1] = row
            if not selected or selected[row[1]] then commands[#commands+1] = ".learn " .. row[1] end
        end
    end
    return commands, entries
end

function FGM.UI:ShowSpellBulk(kind)
    local target = FGM.Catalog:Target()
    if not target then self:SetStatus(FGM:L("TARGET_REQUIRED")); return end
    local C,T = FGM.Components,FGM.Theme
    local _,entries = FGM.BuildSpellPlan(kind,nil,target)
    if self.bulkPanel then self.bulkPanel:Hide() end
    local p = FGM:CreateCompatibleFrame("Frame",nil,self.main); T:ApplyPanel(p)
    p:SetSize(620,510);p:SetPoint("CENTER");p:SetFrameLevel(self.main:GetFrameLevel()+40);self.bulkPanel=p
    local title=C:Label(p,FGM:L("BULK_PREVIEW",target.name),true,T.colors.gold);title:SetPoint("TOPLEFT",18,-16)
    local hint=C:Label(p,FGM:L(kind=="mounts" and "BULK_MOUNT_HINT" or "BULK_GM_HINT",target.name),false,T.colors.muted)
    hint:SetPoint("TOPLEFT",18,-48);hint:SetWidth(580);hint:SetHeight(52)
    local scroll=CreateFrame("ScrollFrame",nil,p,"UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",14,-112);scroll:SetPoint("BOTTOMRIGHT",-34,90)
    local child=CreateFrame("Frame",nil,scroll);child:SetSize(560,#entries*38);scroll:SetScrollChild(child)
    local selected={};local count=C:Label(p,"",false,T.colors.gold);count:SetPoint("BOTTOMLEFT",18,60)
    local function update()
        local commands=FGM.BuildSpellPlan(kind,selected,target)
        count:SetText(FGM:L("BULK_SPELL_COUNT",#commands));return commands
    end
    for index,entry in ipairs(entries) do
        local row=entry;selected[row[1]]=true
        local box=CreateFrame("CheckButton",nil,child,"UICheckButtonTemplate");box:SetSize(26,26);box:SetPoint("TOPLEFT",4,-(index-1)*38);box:SetChecked(true)
        local image=child:CreateTexture(nil,"ARTWORK");image:SetSize(28,28);image:SetPoint("LEFT",box,"RIGHT",4,0);image:SetTexture(FGM.Catalog:Icon(kind=="mounts" and "mounts" or "spells",row))
        local label=C:Label(child,FGM.Catalog:Name(kind=="mounts" and "mounts" or "spells",row) .. "  |cff888888#" .. row[1] .. "|r",false,T.colors.text)
        label:SetPoint("LEFT",image,"RIGHT",10,0);label:SetWidth(470)
        box:SetScript("OnClick",function(b)selected[row[1]]=b:GetChecked() and true or nil;update()end)
    end
    local run=C:Button(p,FGM:L("BULK_LEARN"),290,30,function()
        local current=FGM.Catalog:Target()
        if not current or current.guid~=target.guid then FGM.UI:SetStatus(FGM:L("TARGET_CHANGED"));return end
        local commands=update();if #commands==0 then return end
        FGM.UI:ConfirmCommand(count:GetText() .. "\n" .. FGM:L("CURRENT_TARGET",target.name),function()
            FGM.CommandExecutor:QueueBulk(commands,{kind=kind,bulk=true,label=FGM:L(kind=="mounts" and "GIVE_MOUNTS" or "GIVE_GM_SPELLS"),targetGUID=target.guid})
            p:Hide()
        end,true)
    end);run:SetPoint("BOTTOMLEFT",18,14)
    local close=C:Button(p,FGM:L("CLOSE"),110,30,function()p:Hide()end);close:SetPoint("BOTTOMRIGHT",-18,14)
    self.bulkProgress=count;self.spellBulkRun=run;update()
end

function FGM.UI:GiveBiS(row)
    local target=FGM.Catalog:Target()
    if not target then self:SetStatus(FGM:L("TARGET_REQUIRED"));return end
    self:ConfirmCommand(FGM:L("BIS_PROFILE_HINT") .. "\n" .. FGM:L("BIS_PARTIAL",row[11] or 0) .. "\n" .. FGM:L("CURRENT_TARGET",target.name),function()
        local commands={}
        for _,id in ipairs(row[4]) do commands[#commands+1]=".additem " .. id .. " 1" end
        FGM.CommandExecutor:QueueBulk(commands,{kind="bis",id=row[1],label=FGM.Catalog:Name("bis",row),bulk=true,targetGUID=target.guid})
    end,true)
end
