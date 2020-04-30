local function CMCommands(msg, editbox)
ReloadUI()
end

SLASH_CM1 = "/rl"
SlashCmdList["CM"] = CMCommands

--char sheet frame
local statFrame = CreateFrame("FRAME", nil, CharacterModelFrame)
statFrame.TextLabel = statFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
statFrame.TextLabel:SetFont("Interface\\AddOns\\spellPowerValue\\consolab.ttf", 10, "OUTLINE")
statFrame.TextLabel:SetTextColor(1, 1, 1, 1)
statFrame.TextLabel:SetPoint("BOTTOMLEFT", CharacterModelFrame, "BOTTOMLEFT", 0, 10)
statFrame.TextLabel:SetJustifyH("LEFT")
statFrame.TextLabel:SetJustifyV("TOP")
statFrame:RegisterEvent("PLAYER_LOGIN")
statFrame:RegisterEvent("UNIT_AURA")
statFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
statFrame:RegisterEvent("SPELL_POWER_CHANGED")
statFrame:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
statFrame:RegisterEvent("COMBAT_RATING_UPDATE")

--tooltip frame
local tooltipFrame = CreateFrame("FRAME", nil, GameTooltip)
tooltipFrame.TextLabel = tooltipFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
tooltipFrame.TextLabel:SetFont("Interface\\AddOns\\spellPowerValue\\consolab.ttf", 10, "OUTLINE")
tooltipFrame.TextLabel:SetTextColor(1, 1, 1, 1)
tooltipFrame.TextLabel:SetPoint("TOPRIGHT", GameTooltip, "TOPRIGHT", -5, -5)
tooltipFrame.TextLabel:SetJustifyH("RIGHT")
tooltipFrame.TextLabel:SetJustifyV("CENTER")


--tooltip compare frame
local tooltipCompare1Frame = CreateFrame("FRAME", nil, ShoppingTooltip1)
tooltipCompare1Frame.TextLabel = tooltipCompare1Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
tooltipCompare1Frame.TextLabel:SetFont("Interface\\AddOns\\spellPowerValue\\consolab.ttf", 10, "OUTLINE")
tooltipCompare1Frame.TextLabel:SetTextColor(1, 1, 1, 1)
tooltipCompare1Frame.TextLabel:SetPoint("TOPRIGHT", ShoppingTooltip1, "TOPRIGHT", -5, -5)
tooltipCompare1Frame.TextLabel:SetJustifyH("RIGHT")
tooltipCompare1Frame.TextLabel:SetJustifyV("CENTER")



--tooltip compare frame
local tooltipCompare2Frame = CreateFrame("FRAME", nil, ShoppingTooltip2)
tooltipCompare2Frame.TextLabel = tooltipCompare2Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
tooltipCompare2Frame.TextLabel:SetFont("Interface\\AddOns\\spellPowerValue\\consolab.ttf", 10, "OUTLINE")
tooltipCompare2Frame.TextLabel:SetTextColor(1, 1, 1, 1)
tooltipCompare2Frame.TextLabel:SetPoint("TOPRIGHT", ShoppingTooltip2, "TOPRIGHT", -5, -5)
tooltipCompare2Frame.TextLabel:SetJustifyH("RIGHT")
tooltipCompare2Frame.TextLabel:SetJustifyV("CENTER")


--variable init getCurrentStats
local hitValue
local critValue
local intValue
--variable init speTooltip
local spVal

--variable init speTooltipCompare1
local spValComp1

--stat weights
local function getCurrentStats(self)
    local _,_,_,_,talent = GetTalentInfo(3,3)
    local spellPower = GetSpellBonusDamage(5)
    local spellHit = (100 - (17 - (GetSpellHitModifier(5) + (talent * 2)))) / 100
    local spellCrit = GetSpellCritChance(5) / 100
    local spellCoef = 0.814
    local spellBase = 457
    local spellDmg = spellBase + (spellCoef * spellPower)
    hitValue = format("%.2f",((spellDmg / spellCoef) / spellHit) / 100)
    critValue = format("%.2f",((spellDmg / spellCoef) / (1 + spellCrit)) / 100)
    intValue = format("%.2f",critValue / 59.5)
    local spe = format("%.2f",(spellPower + ((GetSpellHitModifier(5) + (talent * 2) * hitValue) + (GetSpellCritChance(5) * critValue))))
    local hitLen = strlen(hitValue)
    local critLen = strlen(critValue)
    local intLen = strlen(intValue)
    
    local maxLen = math.max(hitLen, critLen, intLen)
    local minLen = math.min(hitLen, critLen, intLen)
    if hitLen == maxLen then
        statFrame.TextLabel:SetText(spe.." SPe\n1% HIT  = "..hitValue.." SP\n1% CRIT =  "..critValue.." SP\n1  INT  =  "..intValue.." SPe")
    elseif critLen == maxLen then
        statFrame.TextLabel:SetText(spe.." SPe\n1% HIT  =  "..hitValue.." SP\n1% CRIT = "..critValue.." SP\n1  INT  =  "..intValue.." SPe")
    else
        statFrame.TextLabel:SetText(spe.." SPe\n1% HIT  = "..hitValue.." SP\n1% CRIT = "..critValue.." SP\n1  INT  = "..intValue.." SPe")
    end
end
statFrame:SetScript("OnEvent", getCurrentStats)

--tooltip stats
local function speTooltip(self)
    local intNum = 0
    local hitNum = 0
    local critNum = 0
    local spNum = 0
    local rowLast = 0
    for i=1, GameTooltip:NumLines() do
        if _G["GameTooltipTextLeft"..i]:GetText() ~= nil then
             spetext = _G["GameTooltipTextLeft"..i]:GetText()
             intFind = strmatch(spetext:lower(),"^+%d+ intellect$")
             spellFind = strmatch(spetext:lower(),".*spell.*%d+")
             hitFind = strmatch(spetext:lower(),"hit.*$")
             critFind = strmatch(spetext:lower(),"crit.*$")
            if not strmatch(spetext:lower(),".*use:.*") then
                if intFind ~= nil then
                    if i ~= rowLast then
                        intNum = (strmatch(intFind,"%d+") * intValue) + intNum
                        rowLast = i
                    end
                end
                if spellFind ~= nil and not strmatch(spellFind,".*set.*") then
                    if strmatch(spellFind,"18\/spell") then
                        hitNum = (strmatch(hitFind,"%d+") * hitValue) + hitNum
                        spNum = strmatch(spellFind,"%d+") + spNum
                        rowLast = i
                    else
                        if hitFind ~= nil then
                            if i ~= rowLast then
                                hitNum = (strmatch(hitFind,"%d+") * hitValue) + hitNum
                                rowLast = i
                            end
                        end
                        if critFind ~= nil then
                            if i ~= rowLast then
                                critNum = (strmatch(critFind,"%d+") * critValue) + critNum
                                rowLast = i
                            end
                        end
                        if not (strmatch(spellFind,".*shadow.*") or strmatch(spellFind,".*fire.*") or strmatch(spellFind,".*nature.*") or strmatch(spellFind,".*arcane.*")) and strmatch(spellFind,".*damage.*")  then
                            if i ~= rowLast then
                                spNum = strmatch(spellFind,"%d+") + spNum
                                rowLast = i
                            end
                        end
                    end
                end
            end
        end
    end
    spVal = intNum + hitNum + critNum + spNum
    if spVal > 0 then
        tooltipFrame.TextLabel:SetText(spVal.." SPe")
    else
        tooltipFrame.TextLabel:SetText("")
    end
end
GameTooltip:HookScript("OnTooltipSetItem", speTooltip)
GameTooltip:HookScript("OnHide", speTooltip)


--tooltip1 stats
local function speTooltipCompare1(self)
    local intNumComp1 = 0
    local hitNumComp1 = 0
    local critNumComp1 = 0
    local spNumComp1 = 0
    local rowLastComp1 = 0
    for i=1, ShoppingTooltip1:NumLines() do
         spetextComp1 = _G["ShoppingTooltip1TextLeft"..i]:GetText()
         intFindComp1 = strmatch(spetextComp1:lower(),"^+%d+ intellect$")
         spellFindComp1 = strmatch(spetextComp1:lower(),".*spell.*%d+")
         hitFindComp1 = strmatch(spetextComp1:lower(),"hit.*$")
         critFindComp1 = strmatch(spetextComp1:lower(),"crit.*$")
        if not strmatch(spetextComp1:lower(),".*use:.*") then
            if intFindComp1 ~= nil then
                if i ~= rowLast then
                    intNumComp1 = (strmatch(intFindComp1,"%d+") * intValue) + intNumComp1
                    rowLastComp1 = i
                end
            end
            if spellFindComp1 ~= nil and not strmatch(spellFindComp1,".*set.*")then
                if strmatch(spellFindComp1,"18\/spell") then
                    hitNumComp1 = (strmatch(hitFindComp1,"%d+") * hitValue) + hitNumComp1
                    spNumComp1 = strmatch(spellFindComp1,"%d+") + spNumComp1
                    rowLastComp1 = i
                else
                    if hitFindComp1 ~= nil then
                        if i ~= rowLastComp1 then
                            hitNumComp1 = (strmatch(hitFindComp1,"%d+") * hitValue) + hitNumComp1
                            rowLastComp1 = i
                        end
                    end
                    if critFindComp1 ~= nil then
                        if i ~= rowLastComp1 then
                            critNumComp1 = (strmatch(critFindComp1,"%d+") * critValue) + critNumComp1
                            rowLastComp1 = i
                        end
                    end
                    if not (strmatch(spellFindComp1,".*shadow.*") or strmatch(spellFindComp1,".*fire.*") or strmatch(spellFindComp1,".*nature.*") or strmatch(spellFindComp1,".*arcane.*")) and strmatch(spellFindComp1,".*damage.*") then
                        if i ~= rowLastComp1 then
                            spNumComp1 = strmatch(spellFindComp1,"%d+") + spNumComp1
                            rowLastComp1 = i
                        end
                    end
                end
            end
        end
    end
    spValComp1 = intNumComp1 + hitNumComp1 + critNumComp1 + spNumComp1
    if spValComp1 > 0 then
        if spVal ~= nil then
            if spVal > spValComp1 then
                tooltipFrame.TextLabel:SetText("|cFF00FF00"..spVal.." SPe\n+"..(spVal - spValComp1).." SPe|r")
                tooltipCompare1Frame.TextLabel:SetText("|cFFFF0000"..spValComp1.." SPe|r")
            elseif spValComp1 > spVal then
                tooltipFrame.TextLabel:SetText("|cFFFF0000"..spVal.." SPe\n–"..(spValComp1 - spVal).." SPe|r")
                tooltipCompare1Frame.TextLabel:SetText("|cFF00FF00"..spValComp1.." SPe\n|r")
            else
                tooltipFrame.TextLabel:SetText(spVal.." SPe")
                tooltipCompare1Frame.TextLabel:SetText(spValComp1.." SPe")
            end
        end
    else
        tooltipCompare1Frame.TextLabel:SetText("")
    end
end
GameTooltip:HookScript("OnTooltipSetItem", speTooltipCompare1)

-- tooltip2 stats
 function speTooltipCompare2(self)
    local intNumComp2 = 0
    local hitNumComp2 = 0
    local critNumComp2 = 0
    local spNumComp2 = 0
    local spValComp2 = 0
    local rowLastComp2 = 0
    for i=1, ShoppingTooltip2:NumLines() do
         spetextComp2 = _G["ShoppingTooltip2TextLeft"..i]:GetText()
         intFindComp2 = strmatch(spetextComp2:lower(),"^+%d+ intellect$")
         spellFindComp2 = strmatch(spetextComp2:lower(),".*spell.*%d+")
         hitFindComp2 = strmatch(spetextComp2:lower(),"hit.*$")
         critFindComp2 = strmatch(spetextComp2:lower(),"crit.*$")
        if not strmatch(spetextComp2:lower(),".*use:.*") then
            if intFindComp2 ~= nil then
                if i ~= rowLast then
                    intNumComp2 = (strmatch(intFindComp2,"%d+") * intValue) + intNumComp2
                    rowLastComp2 = i
                end
            end
            if spellFindComp2 ~= nil and not strmatch(spellFindComp2,".*set.*")then
                if strmatch(spellFindComp2,"18\/spell") then
                    hitNumComp2 = (strmatch(hitFindComp2,"%d+") * hitValue) + hitNumComp2
                    spNumComp2 = strmatch(spellFindComp2,"%d+") + spNumComp2
                    rowLastComp2 = i
                else
                    if hitFindComp2 ~= nil then
                        if i ~= rowLastComp2 then
                            hitNumComp2 = (strmatch(hitFindComp2,"%d+") * hitValue) + hitNumComp2
                            rowLastComp2 = i
                        end
                    end
                    if critFindComp2 ~= nil then
                        if i ~= rowLastComp2 then
                            critNumComp2 = (strmatch(critFindComp2,"%d+") * critValue) + critNumComp2
                            rowLastComp2 = i
                        end
                    end
                    if not (strmatch(spellFindComp2,".*shadow.*") or strmatch(spellFindComp2,".*fire.*") or strmatch(spellFindComp2,".*nature.*") or strmatch(spellFindComp2,".*arcane.*")) and strmatch(spellFindComp2,".*damage.*") then
                        if i ~= rowLastComp2 then
                            spNumComp2 = strmatch(spellFindComp2,"%d+") + spNumComp2
                            rowLastComp2 = i
                        end
                    end
                end
            end
        end
    end
    spValComp2 = intNumComp2 + hitNumComp2 + critNumComp2 + spNumComp2
    if spValComp2 > 0 then
        if spVal ~= nil then
            if (spVal > spValComp1) and (spVal > spValComp2) then
                tooltipFrame.TextLabel:SetText("|cFF00FF00"..spVal.." SPe|r")
                tooltipCompare1Frame.TextLabel:SetText("|cFFFF0000"..spValComp1.." SPe\n"..(spValComp1 - spVal).." SPe|r")
                tooltipCompare2Frame.TextLabel:SetText("|cFFFF0000"..spValComp2.." SPe\n"..(spValComp2 - spVal).." SPe|r")
            elseif (spValComp1 > spVal and spVal > spValComp2) then
                tooltipFrame.TextLabel:SetText("|cFFFFFF00"..spVal.." SPe|r")
                tooltipCompare1Frame.TextLabel:SetText("|cFF00FF00"..spValComp1.." SPe\n+"..(spValComp1 - spVal).." SPe|r")
                tooltipCompare2Frame.TextLabel:SetText("|cFFFF0000"..spValComp2.." SPe\n"..(spValComp2 - spVal).." SPe|r")
            elseif (spValComp2 > spVal and spVal > spValComp1) then
                tooltipFrame.TextLabel:SetText("|cFFFFFF00"..spVal.." SPe|r")
                tooltipCompare1Frame.TextLabel:SetText("|cFFFF0000"..spValComp1.." SPe\n"..(spValComp1 - spVal).." SPe|r")
                tooltipCompare2Frame.TextLabel:SetText("|cFF00FF00"..spValComp2.." SPe\n+"..(spValComp2 - spVal).." SPe|r")                
            elseif (spValComp2 > spVal and spValComp1 > spVal) then
                tooltipFrame.TextLabel:SetText("|cFFFF0000"..spVal.." SPe|r")
                tooltipCompare1Frame.TextLabel:SetText("|cFF00FF00"..spValComp1.." SPe\n+"..(spValComp1 - spVal).." SPe|r")
                tooltipCompare2Frame.TextLabel:SetText("|cFF00FF00"..spValComp2.." SPe\n+"..(spValComp2 - spVal).." SPe|r")
            end
        end
    else
        tooltipCompare2Frame.TextLabel:SetText("")
    end
end
GameTooltip:HookScript("OnTooltipSetItem", speTooltipCompare2)