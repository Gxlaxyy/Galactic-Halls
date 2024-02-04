--[[
# Script Name:  <Galactic Halls>
# Description:  <Hall of Memories Divination, Picks up Jars and fills, then hands in once filled.>
# Version:      <2.0>
# Datum:        <2024.02.04>
# Author:       <Unknown- Edits/changes made by Disc - Gxlaxy>

> Changes - Added in an Anti Idle to prevent it from logging out every 5 minutes (thanks to Higgins for the function)
> Changed the Value of "API.InvItemcount_1(42900) == 28" to "API.InvItemcount_1(42900) >=27" to prevent it from breaking if there was not enough jars in invent.
> Updated doactions in Several lines to updated Id changes.
> Offsets updated to work with current versions.
> Added a GUI to track xp.
> NOTE - I DID NOT CREATE THIS SCRIPT JUST EDITED, CHANGED, AND ADDED FUNCTIONS TO THE ORIGNAL CREATORS VERSION (Unknown)
--]]

print("Run Galactic Hall of Memories.")
print("Entering Eternal xp mode")

local API = require("api")
local UTILS = require("utils")
local MAX_IDLE_TIME_MINUTES = 5
local startTime, afk = os.time(), os.time()
ScripCuRunning1 = ""
local startXp = API.GetSkillXP("DIVINATION")
local skill = "DIVINATION"
local currentlvl = API.XPLevelTable(API.GetSkillXP(skill))



local ID = {
    AAGI = 25551,
    SEREN = 25552,
    JUNA = 25553,
    SWORD_OF_EDICTS = 25554,
    CRES = 25555,
    KNOWLEDGE_FRAGMENT = 25564
}

local function findNpc(npcID, distance)
    distance = distance or 25
    return #API.GetAllObjArrayInteract({ npcID }, distance, 1) > 0
end

local function CoreMemoryCheck()
    local npcData = {
        { ID = ID.AAGI },
        { ID = ID.SEREN },
        { ID = ID.JUNA },
        { ID = ID.SWORD_OF_EDICTS },
        { ID = ID.CRES },
        { ID = ID.KNOWLEDGE_FRAGMENT },
    }

    for _, npc in ipairs(npcData) do
        if findNpc(npc.ID, 75) and API.InvItemcount_1(42900) < 28 and (API.InvItemcount_1(42898) >= 1 or API.InvItemcount_1(42899) >= 1) then
            DoAction_NPC(0xc8, API.OFF_ACT_InteractNPC_route, { npc.ID }, 75)
            API.WaitUntilMovingandAnimEnds()
            API.RandomSleep2(2000, 1000, 1000)
            return true
        end
    end
    return false
end

-- Rounds a number to the nearest integer or to a specified number of decimal places.
local function round(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

-- Format a number with commas as thousands separator
local function formatNumberWithCommas(amount)
    local formatted = tostring(amount)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

function formatNumber(num)
    if num >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    else
        return tostring(num)
    end
end

-- Format script elapsed time to [hh:mm:ss]
local function formatElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    return string.format("[%02d:%02d:%02d]", hours, minutes, seconds)
end

local function calcProgressPercentage(skill, currentExp)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    if currentLevel == 120 then return 100 end
    local nextLevelExp = XPForLevel(currentLevel + 1)
    local currentLevelExp = XPForLevel(currentLevel)
    local progressPercentage = (currentExp - currentLevelExp) / (nextLevelExp - currentLevelExp) * 100
    return math.floor(progressPercentage)
end

local function printProgressReport(final)
    local skill = "DIVINATION"
    local currentXp = API.GetSkillXP(skill)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - startXp)
    local xpPH = round((diffXp * 60) / elapsedMinutes)
    local time = formatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    local xplvlup = API.XPForLevel(currentLevel + 1)
    local xp99 = API.XPForLevel(99)
    local timeNeeded = round(((xplvlup - currentXp) / xpPH) * 60)
    local timeneededfor99 = round(((xp99 - currentXp) / xpPH) * 60)
    IGP.radius = calcProgressPercentage(skill, API.GetSkillXP(skill)) / 100
    IGP.string_value = time ..
        " | " ..
        string.lower(skill):gsub("^%l", string.upper) ..
        ": " ..
        currentLevel ..
        " | XP/H: " ..
        formatNumber(xpPH) ..
        " | XP: " ..
        formatNumber(diffXp) ..
        " | TTL: " .. formatNumber(timeNeeded) .. "m" .. " | TTL99: " .. formatNumber(timeneededfor99) .. "m"
end

local function setupGUI()
    IGP = API.CreateIG_answer()
    IGP.box_start = FFPOINT.new(5, 5, 0)
    IGP.box_name = "PROGRESSBAR"
    IGP.colour = ImColor.new(116, 2, 179);
    IGP.string_value = "DIVINATION"
end

function drawGUI()
    DrawProgressBar(IGP)
end

local Cselect = API.ScriptDialogWindow2("Hall Of Memories",
    { "Faded memories", "Lustrous memories", "Brilliant memories", "Radiant memories", "Luminous memories",
        "Incandescent memories" }, "Start", "Close").Name
if Cselect == "Faded memories" then
    print(Cselect)
    ScripCuRunning1 = "Faded memories"
elseif Cselect == "Lustrous memories" then
    print(Cselect)
    ScripCuRunning1 = "Lustrous memories"
elseif Cselect == "Brilliant memories" then
    print(Cselect)
    ScripCuRunning1 = "Brilliant memories"
elseif Cselect == "Radiant memories" then
    print(Cselect)
    ScripCuRunning1 = "Radiant memories"
elseif Cselect == "Luminous memories" then
    print(Cselect)
    ScripCuRunning1 = "Luminous memories"
elseif Cselect == "Incandescent memories" then
    print(Cselect)
    ScripCuRunning1 = "Incandescent memories"
end



function FillJars()
    if not CoreMemoryCheck() then
        API.DoAction_NPC_str(0xc8, 1488, { ScripCuRunning1 }, 74)
        API.RandomSleep2(2000, 1500, 2000)
        API.WaitUntilMovingandAnimEnds()
        API.RandomSleep2(2000, 1500, 2000)
    end
end

function GrabJars()
    API.DoAction_Tile(WPOINT.new(2229, 9116, 0))
    API.WaitUntilMovingEnds()
    API.RandomSleep2(1000, 1500, 2000)
    API.DoAction_Object_r(0x29, 0, { 111374 }, 70, WPOINT.new(2230, 9116, 0), 74)

    while not API.InvFull_() do
        API.RandomSleep2(200, 200, 200)
    end

    print("Got Jars, time to gather some shit")
end

function DepositJars()
    API.DoAction_Tile(WPOINT.new(2207, 9120, 0))
    API.WaitUntilMovingEnds()
    API.RandomSleep2(2000, 1000, 1000)
    API.DoAction_Object_r(0x29, 0, { 111375 }, 74, WPOINT.new(2204, 9134, 0), 74)
    API.RandomSleep2(2000, 1000, 1000)
    API.WaitUntilMovingEnds()
    drawGUI()
    while API.InvItemcount_1(42900) >= 1 do
        API.RandomSleep2(1000, 1000, 1000)
    end
end

local function idleCheck() -- Thanks to Higgins for this Function
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        print("Eternal Mode Continuing.")
        API.PIdle2()
        afk = os.time()
    end
end

--main loop

API.Write_LoopyLoop(1)
setupGUI()
while (API.Read_LoopyLoop())
do -----------------------------------------------------------------------------------
    idleCheck()
    drawGUI()
    printProgressReport()
    CoreMemoryCheck()


    if API.InvFull_() then
        if (API.InvItemcount_1(42898) >= 1 or API.InvItemcount_1(42899) >= 1) then
            FillJars()
        elseif API.InvItemcount_1(42900) >= 2 then
            DepositJars()
        end
    else
        GrabJars()
    end
end ----------------------------------------------------------------------------------

print("Entering the Black Hole - Buh bye")
