-- Destroza Dungeon Tracker (frueher: RXP Dungeon Tracker)
-- Zeigt in einem kleinen Fenster, wie viele RestedXP-Guide-Schritte es noch
-- bis zu den naechsten Dungeons sind (guide-uebergreifend ueber die #next-Kette).
-- "Do now" laedt den fertigen RestedXP-Guide "Dungeon Quests" des Dungeons und merkt sich
-- den Schritt im Hauptguide; "Back" springt dorthin zurueck. Schreibt keine eigenen Guides.
-- Benoetigt RestedXP Guides (RXPGuides).

local ADDON_NAME, ns = ...
local L = ns.L   -- Texte in der aktiven Sprache (siehe Locales.lua)

---------------------------------------------------------------------------
-- Konstanten
---------------------------------------------------------------------------
local MAX_ROWS      = 30    -- maximal anzeigbare Dungeons ("alle")
local MAX_SEGMENTS  = 45    -- maximal vorausgelesene Guide-Abschnitte
local TICK_INTERVAL = 0.5   -- Sekunden zwischen Fortschritts-Checks
local FRAME_WIDTH   = 466
local ROW_HEIGHT    = 19
local ROWS_TOP      = 42    -- Abstand von oben bis zur ersten Dungeon-Zeile
-- Spaltenbreiten (Dungeon-Spalte nimmt den Rest)
local COL_STEPS     = 85
local COL_LEVEL     = 55
local COL_BUTTON    = 66
local COL_SHARE     = 52
local COL_GAP       = 10
local BTN_GAP       = 4

local defaults = {
    shown   = true,
    count   = 0,            -- 0 = alle kommenden Dungeons
    locked  = false,
    point   = nil,          -- {point, relPoint, x, y}
    minimap = { hide = false },
    alert   = true,         -- Bildschirmhinweis + Sound, wenn der Guide einen Dungeon betritt
    ahShopping = true,      -- AH-Schritte von RestedXP -> Naowhs Shopping List beim Oeffnen des AH
    lang    = "auto",          -- "auto" = Sprache des Spielclients
}

-- Dungeon-Tags (wie in RXP) + Namen/Abkuerzungen, an denen der Enter-Schritt erkannt wird.
-- Alles in Kleinbuchstaben; es wird auf ganze Woerter geprueft.
local DUNGEONS = {
    { tag = "RFC",    display = "Ragefire Chasm",        min = 13, max = 18, names = { "ragefire chasm", "rfc" } },
    { tag = "WC",     display = "Wailing Caverns",       min = 15, max = 24, names = { "wailing caverns", "wc" } },
    { tag = "DM",     display = "The Deadmines",         min = 17, max = 26, names = { "deadmines" } },
    { tag = "SFK",    display = "Shadowfang Keep",       min = 20, max = 30, names = { "shadowfang keep", "sfk" } },
    { tag = "BFD",    display = "Blackfathom Deeps",     min = 24, max = 32, names = { "blackfathom deeps", "bfd" } },
    { tag = "STOCKS", display = "The Stockade",          min = 24, max = 32, names = { "stockades", "stockade", "stocks" } },
    { tag = "GNOMER", display = "Gnomeregan",            min = 29, max = 38, names = { "gnomeregan", "gnomer" } },
    { tag = "RFK",    display = "Razorfen Kraul",        min = 29, max = 38, names = { "razorfen kraul", "rfk" } },
    { tag = "SM",     display = "Scarlet Monastery",     min = 30, max = 45, names = { "scarlet monastery" } },
    { tag = "RFD",    display = "Razorfen Downs",        min = 37, max = 46, names = { "razorfen downs", "rfd" } },
    { tag = "ULDA",   display = "Uldaman",               min = 41, max = 51, names = { "uldaman", "ulda" } },
    { tag = "ZF",     display = "Zul'Farrak",            min = 43, max = 50, names = { "zul'farrak", "zf" } },
    { tag = "MARA",   display = "Maraudon",              min = 46, max = 55, names = { "maraudon", "mara" } },
    { tag = "ST",     display = "Sunken Temple",         min = 49, max = 56, names = { "sunken temple", "temple of atal'hakkar" } },
    { tag = "BRD",    display = "Blackrock Depths",      min = 52, max = 60, names = { "blackrock depths", "brd" } },
    { tag = "LBRS",   display = "Lower Blackrock Spire", min = 55, max = 60, names = { "lower blackrock spire", "lbrs" } },
    { tag = "UBRS",   display = "Upper Blackrock Spire", min = 55, max = 60, names = { "upper blackrock spire", "ubrs" } },
    { tag = "DME",    display = "Dire Maul",             min = 55, max = 60, names = { "dire maul" } },
    { tag = "SCHOLO", display = "Scholomance",           min = 58, max = 60, names = { "scholomance", "scholo" } },
    { tag = "STRAT",  display = "Stratholme",            min = 58, max = 60, names = { "stratholme", "strat" } },
    -- WoW-Forever-eigene Dungeons
    { tag = "HOT",    display = "Hall of Thanes",        min = 13, max = 20, names = { "hall of thanes" } },
    { tag = "ROL",    display = "Ruins of Lordaeron",    min = 15, max = 22, names = { "ruins of lordaeron" } },
    { tag = "ES",     display = "Excavation Site",       min = 26, max = 33, names = { "excavation site" } },
    { tag = "COD",    display = "City of Dalaran",       min = 28, max = 33, names = { "city of dalaran" } },
    { tag = "TDC",    display = "The Drowned City",      min = 35, max = 40, names = { "drowned city" } },
    { tag = "KS",     display = "Krol'dok Stronghold",   min = 40, max = 45, names = { "krol'dok" } },
    { tag = "AP",     display = "Alcaz Prison",          min = 48, max = 53, names = { "alcaz prison" } },
    { tag = "BH",     display = "Blackmaw Hold",         min = 55, max = 60, names = { "blackmaw hold" } },
    { tag = "TST",    display = "The Shaper's Terrace",  min = 58, max = 60, names = { "shaper's terrace" } },
}

local TEXT_FIELDS = { "text", "rawtext" }

-- RXP-interne Parser-Zustaende, die beim Vorauslesen eines Guides ueberschrieben
-- werden. Wir sichern sie vorher und stellen sie danach wieder her.
local RXP_STATE_KEYS = {
    "currentGuideName", "currentGuideGroup", "guide", "step",
    "lastObjective", "lastElement",
}

---------------------------------------------------------------------------
-- Zustand
---------------------------------------------------------------------------
local DB
local CharDB              -- pro Charakter: Ruecksprungpunkt beim Vorziehen
local analysisCache = {}   -- guideKey -> Analyse (oder false)
local chain                -- aktuelle Vorausschau
local questGuides          -- Dungeon-Tag -> RXP-Guide "Dungeon Quests" (nur Dungeons ausserhalb der Route)
local worker               -- Coroutine, die Guides nach und nach einliest
local lastGuide, lastIdx, lastLevel
local frame, rows, minimapReady

-- Wie viele Dungeons angezeigt werden sollen (0 = alle)
local function Wanted()
    local c = DB and tonumber(DB.count) or 0
    if c <= 0 then return MAX_ROWS end
    return math.min(c, MAX_ROWS)
end

local function GetRXP()
    return _G.RXP
end

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ccffDestroza Dungeons:|r " .. tostring(msg))
end

---------------------------------------------------------------------------
-- Erkennung der Enter-Schritte
---------------------------------------------------------------------------
local function Escape(s)
    return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

-- Ganzes Wort suchen. Wortgrenzen nur dort pruefen, wo das Wort mit einem
-- Buchstaben/Ziffer beginnt bzw. endet (bei z. B. chinesischen Namen gibt es keine).
local wordPatterns = {}
local function HasWord(text, word)
    local pat = wordPatterns[word]
    if not pat then
        local first, last = word:sub(1, 1), word:sub(-1)
        pat = (first:find("%w") and "%f[%w]" or "") .. Escape(word)
            .. (last:find("%w") and "%f[^%w]" or "")
        wordPatterns[word] = pat
    end
    return text:find(pat) ~= nil
end

local function ContainsAny(text, list)
    for i = 1, #list do
        if HasWord(text, list[i]) then return true end
    end
    return false
end

-- Sprachabhaengige Begriffe (Spielclient-Sprache), einmalig aufgebaut
local detectEnter, detectLeave, detectNames
local function BuildDetection()
    detectEnter, detectLeave, detectNames = {}, {}, {}
    local d = ns.DETECT and GetLocale and ns.DETECT[GetLocale()]
    if d then
        for _, w in ipairs(d.enter or {}) do detectEnter[#detectEnter + 1] = w:lower() end
        for _, w in ipairs(d.leave or {}) do detectLeave[#detectLeave + 1] = w:lower() end
        for tag, list in pairs(d.names or {}) do
            detectNames[tag] = detectNames[tag] or {}
            for _, n in ipairs(list) do table.insert(detectNames[tag], n:lower()) end
        end
    end
    -- zusaetzlich: der Dungeon-Name, den der Spielclient selbst liefert
    local RXP = _G.RXP
    if RXP and RXP.GetDungeonName then
        for _, def in ipairs(DUNGEONS) do
            local ok, n = pcall(RXP.GetDungeonName, def.tag)
            if ok and type(n) == "string" and #n >= 4 then
                detectNames[def.tag] = detectNames[def.tag] or {}
                table.insert(detectNames[def.tag], n:lower())
            end
        end
    end
end

local function CleanText(t)
    t = t:gsub("|c%x%x%x%x%x%x%x%x", "")
    t = t:gsub("|cRXP_%u+_", "")       -- noch nicht ersetzte RXP-Farbplatzhalter
    t = t:gsub("|r", "")
    t = t:gsub("|T.-|t", " ")
    t = t:gsub("|A.-|a", " ")
    return t:lower()
end

local function IsEntryText(t)
    if not detectEnter then BuildDetection() end
    local english = HasWord(t, "enter") or t:find("zone in", 1, true) or t:find("instance portal", 1, true)
    if not (english or ContainsAny(t, detectEnter)) then
        return false
    end
    if t:find("re-enter", 1, true) or t:find("return to", 1, true)
        or HasWord(t, "exit") or HasWord(t, "leave") or HasWord(t, "entrance")
        or ContainsAny(t, detectLeave) then
        return false
    end
    return true
end

local function MatchDungeon(t)
    if not detectNames then BuildDetection() end
    for _, d in ipairs(DUNGEONS) do
        for _, name in ipairs(d.names) do
            if HasWord(t, name) then
                return d.tag
            end
        end
    end
    for _, d in ipairs(DUNGEONS) do
        local extra = detectNames[d.tag]
        if extra and ContainsAny(t, extra) then
            return d.tag
        end
    end
end

-- Liefert den Dungeon-Tag, wenn dieser Schritt der "Reingehen"-Schritt ist.
local function DetectEntry(step)
    if type(step) ~= "table" or type(step.elements) ~= "table" then return end
    -- ".dungeon !XYZ" = Alternative fuer den Fall, dass man den Dungeon NICHT laeuft
    -- (z. B. Rogue schleicht solo rein) -> zaehlt nicht als Dungeon-Run.
    if step.dungeonskip then return end
    for _, element in ipairs(step.elements) do
        if type(element) == "table" then
            for _, field in ipairs(TEXT_FIELDS) do
                local t = element[field]
                if type(t) == "string" and t ~= "" then
                    t = CleanText(t)
                    if IsEntryText(t) then
                        local tag = MatchDungeon(t)
                        if tag then return tag end
                    end
                end
            end
        end
    end
end

-- processed: die Schritte, wie RXP sie anzeigt (nummeriert)
-- raw:       alle Schritte des Guides inkl. der wegen RXP-Dungeon-Settings ausgeblendeten
local function FindEntries(processed, raw)
    local found = {}
    if type(processed) ~= "table" then return found end

    local posById = {}
    for i, step in ipairs(processed) do
        local tag = DetectEntry(step)
        if tag then
            found[#found + 1] = { idx = i, tag = tag, order = i, stepId = step.stepId }
        end
        if step.stepId then posById[step.stepId] = i end
    end

    -- Ausgeblendete Dungeon-Schritte (".dungeon XYZ", Dungeon in RXP deaktiviert):
    -- sie wuerden direkt vor dem naechsten sichtbaren Schritt erscheinen.
    if type(raw) == "table" and raw ~= processed then
        local lastShown = 0
        for j, step in ipairs(raw) do
            local pos = step.stepId and posById[step.stepId]
            if pos then
                lastShown = pos
            elseif step.dungeon then
                local tag = DetectEntry(step)
                if tag then
                    local nextShown = processed[lastShown + 1]
                    found[#found + 1] = { idx = lastShown + 1, tag = tag, hidden = true,
                        order = lastShown + j / 100000, stepId = nextShown and nextShown.stepId }
                end
            end
        end
    end

    table.sort(found, function(a, b)
        if a.idx ~= b.idx then return a.idx < b.idx end
        return a.order < b.order
    end)

    -- direkt aufeinanderfolgende Doppel (Varianten desselben Schritts) zusammenfassen
    local entries = {}
    local lastTag, lastIdx
    for _, e in ipairs(found) do
        if not (e.tag == lastTag and lastIdx and e.idx - lastIdx <= 2) then
            entries[#entries + 1] = { idx = e.idx, tag = e.tag, hidden = e.hidden, stepId = e.stepId }
        end
        lastTag, lastIdx = e.tag, e.idx
    end
    return entries
end

---------------------------------------------------------------------------
-- Guide-Kette lesen (ohne RXP-Fortschritt zu veraendern)
---------------------------------------------------------------------------
local function GuideKey(g)
    return g.key or (tostring(g.group) .. "||" .. tostring(g.name))
end

local function LevelRange(name)
    if type(name) ~= "string" then return end
    local a, b = name:match("^(%d+)%-(%d+)")
    a, b = tonumber(a), tonumber(b)
    if a and b and (b > 70 or b < a) then b = a end
    return a, b
end

local function WithProtectedRXPState(fn)
    local RXP = GetRXP()
    local saved = {}
    for i, k in ipairs(RXP_STATE_KEYS) do saved[i] = RXP[k] end
    local ok, result = pcall(fn)
    for i, k in ipairs(RXP_STATE_KEYS) do
        if RXP[k] ~= saved[i] then RXP[k] = saved[i] end
    end
    if ok then return result end
    return nil, result
end

local function IsActive(g)
    local RXP = GetRXP()
    if RXP.IsGuideActive then
        local ok, active = pcall(RXP.IsGuideActive, g)
        if ok then return active end
    end
    return true
end

-- Bildet RXPs #next-Logik nach, laedt den Guide aber nicht.
local function ResolveNext(guide)
    local RXP = GetRXP()
    local nextText = guide and guide.next
    if type(nextText) ~= "string" or nextText == "" then return end

    local group = guide.group
    local found, fallback
    for entry in nextText:gmatch("[^;]+") do
        entry = entry:gsub("^%s+", ""):gsub("%s+$", "")
        local grp, name = entry:match("^(.*)\\%s*(.-)$")
        if grp and grp ~= "" then
            group = grp:gsub("%s+$", "")
        else
            name = entry
        end
        if RXP.affix then
            name = name:gsub("^(%d)-(%d%d?)", RXP.affix)
        end

        local g = RXP.GetGuideTable(group, name)
        if not g and RXP.condenseGroups and RXP.condenseGroups[group] then
            local parent = RXP.condenseGroups[group]
            for otherGroup, displayName in pairs(RXP.condenseGroups) do
                if displayName == parent then
                    g = RXP.GetGuideTable(otherGroup, name)
                    if g then break end
                end
            end
        end
        if not g then
            -- RXP-Guides verweisen manchmal ohne Level-Praefix, z. B. "#next Razorfen Downs"
            -- statt "38-38 Razorfen Downs" -> passenden Abschnitt in derselben Gruppe suchen
            for _, cand in pairs(RXP.guides or {}) do
                if type(cand) == "table" and cand.group == group and type(cand.name) == "string"
                    and cand.name:gsub("^%d+%-%d+%s+", "") == name then
                    g = cand
                    break
                end
            end
        end
        if g then
            fallback = g
            if IsActive(g) then
                found = g
                break
            end
        end
    end
    return found or fallback
end

local function AnalyzeGuide(g)
    local key = GuideKey(g)
    local cached = analysisCache[key]
    if cached ~= nil then return cached or nil end

    local RXP = GetRXP()
    local result = WithProtectedRXPState(function()
        local full = RXP:FetchGuide(g)
        if type(full) ~= "table" or type(full.steps) ~= "table" then return nil end
        local processed = RXP.ProcessGuideTable(full)
        if type(processed) ~= "table" or type(processed.steps) ~= "table" then return nil end
        return {
            guide       = full,
            name        = full.name,
            displayname = full.displayname or full.name,
            group       = full.group,
            n           = #processed.steps,
            entries     = FindEntries(processed.steps, full.steps),
        }
    end)
    analysisCache[key] = result or false
    return result
end

local function AnalyzeCurrent(cur)
    local RXP = GetRXP()
    local raw = WithProtectedRXPState(function()
        local g = RXP.GetGuideTable(cur.group, cur.name)
        g = g and RXP:FetchGuide(g)
        return g and g.steps
    end)
    return {
        guide       = cur,
        name        = cur.name,
        displayname = cur.displayname or cur.name,
        group       = cur.group,
        n           = #cur.steps,
        entries     = FindEntries(cur.steps, raw),
        current     = true,
    }
end

-- Zu einer Guide-Gruppe ohne Dungeons (z. B. "RestedXP Forever Guide (H)") die passende
-- Dungeon-Gruppe finden und dort den Abschnitt, der zur aktuellen Position passt.
local function FindParallelStart(cur)
    local RXP = GetRXP()
    local group = cur.group
    if type(group) ~= "string" then return end
    local dungeonGroup = ns.PARALLEL_GROUPS and ns.PARALLEL_GROUPS[group]
    if not dungeonGroup then
        if group:find("Dungeon", 1, true) then return end
        dungeonGroup = group:gsub("Guide %(", "Dungeon Guide (", 1)
        if dungeonGroup == group then return end
    end

    local g = RXP.GetGuideTable(dungeonGroup, cur.name)
    if g and IsActive(g) then return g, dungeonGroup end

    local curMin = LevelRange(cur.name) or UnitLevel("player")
    local best, bestMin
    for _, guide in pairs(RXP.guides or {}) do
        if type(guide) == "table" and guide.group == dungeonGroup and guide.name then
            local mn = LevelRange(guide.name)
            if mn and mn <= curMin and (not bestMin or mn > bestMin) and IsActive(guide) then
                best, bestMin = guide, mn
            end
        end
    end
    return best, dungeonGroup
end

local function NewTrack()
    return { segs = {}, visited = {}, exhausted = false }
end

local function AttachParallel(c, base)
    local start, dungeonGroup = FindParallelStart(base)
    if start then
        local par = NewTrack()
        par.pending = start
        par.group = dungeonGroup
        c.par = par
    end
    return c
end

local function NewChain(cur)
    local curMin = LevelRange(cur.name)
    local own = NewTrack()
    own.segs[1] = AnalyzeCurrent(cur)
    own.tail = cur
    own.visited[GuideKey(cur)] = true
    own.lastMin = curMin

    return AttachParallel({ current = cur, curMin = curMin, own = own }, cur)
end

-- Waehrend ein Dungeon vorgezogen wird, zeigt die Liste weiter den Hauptguide
-- ab dem gespeicherten Schritt.
local function NewFrozenChain(rp)
    local RXP = GetRXP()
    local g = RXP.GetGuideTable(rp.group, rp.name)
    local a = g and AnalyzeGuide(g)
    if not a then return end
    local seg = {}
    for k, v in pairs(a) do seg[k] = v end
    seg.current = true

    local own = NewTrack()
    own.segs[1] = seg
    own.tail = a.guide
    own.visited[GuideKey(g)] = true
    own.visited[GuideKey(a.guide)] = true
    own.lastMin = LevelRange(a.name)

    return AttachParallel({ current = RXP.currentGuide, curMin = own.lastMin, own = own,
        frozenIdx = tonumber(rp.step) or 1 }, seg)
end

local function ExtendTrack(track)
    local nextGuide
    if track.pending then
        nextGuide, track.pending = track.pending, nil
    else
        nextGuide = ResolveNext(track.tail)
    end
    if not nextGuide or #track.segs >= MAX_SEGMENTS then
        track.exhausted = true
        return
    end
    local key = GuideKey(nextGuide)
    if track.visited[key] then
        track.exhausted = true
        return
    end
    track.visited[key] = true

    local analysis = AnalyzeGuide(nextGuide)
    if not analysis then
        track.exhausted = true
        return
    end
    track.segs[#track.segs + 1] = analysis
    track.tail = analysis.guide
    track.lastMin = LevelRange(analysis.name) or track.lastMin
end

local function CurrentStepIndex()
    if chain and chain.frozenIdx then return chain.frozenIdx end
    return tonumber(RXPCData and RXPCData.currentStep) or 1
end

local HUGE = math.huge
local OVERLEVEL_TOLERANCE = 2   -- Dungeons bleiben bis 2 Level ueber ihrer Obergrenze sichtbar

local function ComputeResults()
    local results = {}
    if not chain then return results end
    local seen = {}
    local order = 0

    -- 1) eigener Guide-Verlauf: mit Schrittzahl
    local curIdx = CurrentStepIndex()
    local offset = 0
    local passed = {}
    for _, seg in ipairs(chain.own.segs) do
        local level = LevelRange(seg.name)
        for _, e in ipairs(seg.entries) do
            local dist = seg.current and (e.idx - curIdx) or (offset + e.idx)
            if dist >= 0 and not seen[e.tag] then
                seen[e.tag] = true
                order = order + 1
                results[#results + 1] = { tag = e.tag, dist = dist, seg = seg, idx = e.idx,
                    stepId = e.stepId, hidden = e.hidden, level = level, order = order }
            elseif dist < 0 then
                passed[#passed + 1] = { tag = e.tag, seg = seg, idx = e.idx, stepId = e.stepId,
                    hidden = e.hidden, level = level, passed = true }
            end
        end
        if seg.current then
            offset = math.max(seg.n - curIdx, 0)
        else
            offset = offset + seg.n
        end
    end
    -- "Alle anzeigen": auch Dungeons, an deren Enter-Schritt man schon vorbei ist
    if DB.showAll then
        for _, r in ipairs(passed) do
            if not seen[r.tag] then
                seen[r.tag] = true
                order = order + 1
                r.order = order
                results[#results + 1] = r
            end
        end
    end

    -- 2) Dungeons, die nur im parallelen Dungeon-Guide vorkommen: nur mit Levelangabe
    if chain.par then
        for _, seg in ipairs(chain.par.segs) do
            local level = LevelRange(seg.name)
            if DB.showAll or not (level and chain.curMin and level < chain.curMin) then
                for _, e in ipairs(seg.entries) do
                    if not seen[e.tag] then
                        seen[e.tag] = true
                        order = order + 1
                        results[#results + 1] = { tag = e.tag, seg = seg, idx = e.idx, stepId = e.stepId,
                            parallel = true, hidden = e.hidden, level = level, order = order }
                    end
                end
            end
        end
    end

    -- 3) Dungeons, die in keiner Route vorkommen, fuer die RXP aber einen "Dungeon Quests"-Guide hat
    local anyExtra = false
    local playerLevel = UnitLevel("player")
    for _, ex in ipairs(ns.QuestGuideList()) do
        if not seen[ex.tag] and (DB.showAll or (ex.maxLevel or 99) + OVERLEVEL_TOLERANCE >= playerLevel) then
            seen[ex.tag] = true
            anyExtra = true
            order = order + 1
            results[#results + 1] = { tag = ex.tag, extra = ex, level = ex.minLevel, order = order,
                seg = { name = ex.minLevel and (ex.minLevel .. "-" .. ex.maxLevel) or ex.name,
                    displayname = ex.guide.displayname or ex.name, n = 0 } }
        end
    end

    if chain.par or anyExtra or DB.showAll then
        local function rank(r) return r.extra and 2 or (r.parallel and 1 or 0) end
        table.sort(results, function(a, b)
            local la, lb = a.level or HUGE, b.level or HUGE
            if la ~= lb then return la < lb end
            if rank(a) ~= rank(b) then return rank(a) < rank(b) end
            return a.order < b.order
        end)
    end

    for i = #results, Wanted() + 1, -1 do results[i] = nil end
    return results
end

-- Muss in diesem Verlauf noch weitergelesen werden?
local function NeedsMore(track, results)
    if not track or track.exhausted then return false end
    if #results < Wanted() then return true end
    local last = results[Wanted()].level
    if not last then return false end
    return not (track.lastMin and track.lastMin > last)
end

local function WorkerBody()
    while chain do
        local results = ComputeResults()
        if NeedsMore(chain.own, results) then
            ExtendTrack(chain.own)
        elseif NeedsMore(chain.par, results) then
            ExtendTrack(chain.par)
        else
            return
        end
        coroutine.yield()
    end
end

---------------------------------------------------------------------------
-- Anzeige
---------------------------------------------------------------------------
local nameCache = {}
local function InGroup()
    if IsInGroup then return IsInGroup() end
    return (GetNumGroupMembers and GetNumGroupMembers() or 0) > 0
end

local function DungeonName(tag)
    if nameCache[tag] then return nameCache[tag] end
    local name
    local RXP = GetRXP()
    if RXP and RXP.GetDungeonName then
        local ok, n = pcall(RXP.GetDungeonName, tag)
        if ok and type(n) == "string" and n ~= "" then name = n end
    end
    if not name then
        for _, d in ipairs(DUNGEONS) do
            if d.tag == tag then name = d.display break end
        end
    end
    name = name or tag
    nameCache[tag] = name
    return name
end

local function LevelColor(minLevel, maxLevel)
    local lvl = UnitLevel("player")
    if not minLevel then return "ffffffff" end
    if maxLevel and lvl > maxLevel then return "ff808080" end  -- ueberlevelt
    if lvl >= minLevel then return "ff40ff40" end      -- passt
    if minLevel - lvl <= 2 then return "ffffd100" end  -- knapp drunter
    return "ffff6040"                                    -- deutlich drunter
end

local function LevelText(seg)
    local a, b = LevelRange(seg.name)
    if not a then return nil end
    local text = (a == b) and (L.LV .. " " .. a) or (L.LV .. " " .. a .. "-" .. b)
    return "|c" .. LevelColor(a, b) .. text .. "|r", a, b
end

local function StepsText(dist)
    if not dist then return nil end
    if dist <= 0 then return "|cff40ff40" .. L.STEPS_NOW .. "|r" end
    if dist == 1 then return L.STEP_ONE end
    return L.STEPS_N:format(dist)
end

local GREY = 0.75
local function ShowRowTooltip(row)
    local r = row.result
    if not r then return end
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine(DungeonName(r.tag))
    if r.extra then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L.TT_EXTRA:format(L.BTN_PULL), GREY, GREY, GREY, true)
        GameTooltip:AddLine(r.extra.guide.group .. ": " .. (r.extra.guide.displayname or r.extra.name), 1, 1, 1, true)
        GameTooltip:Show()
        return
    end
    GameTooltip:AddDoubleLine(L.TT_SECTION, r.seg.displayname or r.seg.name, GREY, GREY, GREY, 1, 1, 1)
    if r.parallel then
        GameTooltip:AddDoubleLine(L.TT_STEP_THERE, L.TT_OF:format(r.idx, r.seg.n), GREY, GREY, GREY, 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L.TT_NOT_IN_GUIDE, GREY, GREY, GREY, true)
        GameTooltip:AddLine(chain and chain.par and chain.par.group or "", 1, 1, 1, true)
        if r.hidden then
            GameTooltip:AddLine(L.TT_ALSO_DISABLED, GREY, GREY, GREY, true)
        end
    else
        if r.hidden then
            GameTooltip:AddDoubleLine(L.TT_WOULD_BE_BEFORE, L.TT_OF:format(r.idx, r.seg.n), GREY, GREY, GREY, 1, 1, 1)
        else
            GameTooltip:AddDoubleLine(L.TT_STEP, L.TT_OF:format(r.idx, r.seg.n), GREY, GREY, GREY, 1, 1, 1)
        end
        GameTooltip:AddDoubleLine(L.TT_REMAINING, r.passed and L.STEPS_PASSED or StepsText(r.dist), GREY, GREY, GREY, 1, 1, 1)
        if r.hidden then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L.TT_HIDDEN, GREY, GREY, GREY, true)
        end
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L.TT_PULL_HINT:format(L.BTN_PULL), 0.4, 0.8, 1, true)
    GameTooltip:Show()
end

local function Render()
    if not frame or not frame:IsShown() then return end

    frame.level:SetText(L.LV .. " " .. UnitLevel("player"))

    local results = ComputeResults()
    local anyHidden, anyParallel = false, false
    for i = 1, MAX_ROWS do
        local row = rows[i]
        local r = results[i]
        row.result = r
        if r then
            local lvText, minLevel, maxLevel = LevelText(r.seg)
            local name = "|c" .. LevelColor(minLevel, maxLevel) .. DungeonName(r.tag) .. "|r"
            if r.hidden then
                name = name .. " |cff9d9d9d*|r"
                anyHidden = true
            end
            row.name:SetText(name)

            if r.extra then
                row.steps:SetText("|cff9d9d9d" .. L.EXTRA_GUIDE .. "|r")
            elseif r.parallel then
                anyParallel = true
                row.steps:SetText("|cff9d9d9d" .. L.DUNGEON_GUIDE .. "|r")
            else
                row.steps:SetText(r.passed and ("|cff808080" .. L.STEPS_PASSED .. "|r") or StepsText(r.dist))
            end
            row.level:SetText(lvText or "")

            local rp = CharDB and CharDB.returnPoint
            if rp and rp.dungeon == r.tag then
                row.button:SetText(L.BTN_ACTIVE)
                row.button:Disable()
                row.button:SetAlpha(0.6)
            else
                row.button:SetText(L.BTN_PULL)
                row.button:Enable()
                row.button:SetAlpha(1)
            end
            row.share:SetText(L.BTN_SHARE)
            row.share:SetAlpha(InGroup() and 1 or 0.5)
            row:Show()
        else
            row:Hide()
        end
    end

    local status
    local rp = CharDB and CharDB.returnPoint
    if not GetRXP() then
        status = L.ST_NO_RXP
    elseif not chain then
        status = L.ST_NO_GUIDE
    elseif #results < Wanted() and worker then
        status = L.ST_SEARCHING
    elseif #results == 0 then
        status = L.ST_NONE
    elseif anyHidden then
        status = L.ST_HIDDEN
    elseif anyParallel and worker then
        status = L.ST_SEARCHING_SHORT
    end
    if rp then
        local pulled = "|cff66ccff" .. L.ST_PULLED:format(DungeonName(rp.dungeon or "?")) .. "|r"
        status = status and (pulled .. "\n" .. status) or pulled
    end

    local shownRows = math.min(#results, Wanted())
    local y = ROWS_TOP + shownRows * ROW_HEIGHT + 2
    if status then
        local lines = 1
        for _ in status:gmatch("\n") do lines = lines + 1 end
        frame.status:SetText(status)
        frame.status:ClearAllPoints()
        frame.status:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -y)
        frame.status:Show()
        y = y + lines * ROW_HEIGHT
    else
        frame.status:Hide()
    end
    if rp then
        local name = (rp.name or "?"):gsub("^0(%d)", "%1"):gsub("%-0(%d)", "-%1")
        frame.back:SetText(L.BTN_BACK:format(name, tostring(rp.step)))
        frame.back:ClearAllPoints()
        frame.back:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -(y + 2))
        frame.back:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
        frame.back:Show()
        y = y + 26
    else
        frame.back:Hide()
    end
    frame:SetHeight(y + 6)
end

---------------------------------------------------------------------------
-- Steuerung
---------------------------------------------------------------------------
local workerFrame = CreateFrame("Frame")
workerFrame:Hide()
workerFrame:SetScript("OnUpdate", function(self)
    if not worker then self:Hide() return end
    if InCombatLockdown() then return end
    local ok, err = coroutine.resume(worker)
    if not ok then
        worker = nil
        if chain then
            chain.own.exhausted = true
            if chain.par then chain.par.exhausted = true end
        end
        Print(L.MSG_READ_ERROR:format(tostring(err)))
    elseif coroutine.status(worker) == "dead" then
        worker = nil
    end
    if not worker then self:Hide() end
    Render()
end)

local function StartWorker()
    if worker or not chain then return end
    worker = coroutine.create(WorkerBody)
    workerFrame:Show()
end

local function Rebuild()
    worker = nil
    local RXP = GetRXP()
    local cur = RXP and RXP.currentGuide
    local rp = CharDB and CharDB.returnPoint
    local valid = type(cur) == "table" and not cur.empty and type(cur.steps) == "table" and #cur.steps > 0

    -- wieder im Hauptguide (per Zurueck-Button oder von Hand) -> Vorzieh-Modus beenden
    if rp and valid and cur.group == rp.group and cur.name == rp.name then
        CharDB.returnPoint = nil
        rp = nil
    end

    if rp and RXP then
        chain = NewFrozenChain(rp)
        if not chain then
            Print(L.MSG_MAIN_LOST)
            CharDB.returnPoint = nil
            return Rebuild()
        end
        StartWorker()
    elseif not valid then
        chain = nil
    else
        chain = NewChain(cur)
        StartWorker()
    end
    Render()
end

local function Refresh()
    wipe(analysisCache)
    questGuides = nil
    lastGuide = nil
    Rebuild()
    lastGuide = GetRXP() and GetRXP().currentGuide
end

-- Hinweis, wenn der aktuelle RXP-Schritt das Betreten eines Dungeons ist (einmal je Guide und Dungeon)
local lastAlertStep
local alerted = {}
local function CheckDungeonAlert()
    if not DB or DB.alert == false then return end
    local RXP = GetRXP()
    local g = RXP and RXP.currentGuide
    if type(g) ~= "table" or type(g.steps) ~= "table" then return end
    local idx = tonumber(RXPCData and RXPCData.currentStep) or 1
    local key = tostring(g.group) .. "|" .. tostring(g.name) .. ":" .. idx
    if key == lastAlertStep then return end
    lastAlertStep = key
    if not detectNames then BuildDetection() end
    local step = g.steps[idx]
    local tag = DetectEntry(step)
    if not tag then return end
    local once = tostring(g.name) .. ":" .. tag
    if alerted[once] then return end
    alerted[once] = true
    local msg = L.ALERT_ENTER:format(DungeonName(tag))
    if RaidNotice_AddMessage and RaidWarningFrame then
        RaidNotice_AddMessage(RaidWarningFrame, msg,
            (ChatTypeInfo and ChatTypeInfo["RAID_WARNING"]) or { r = 1, g = 0.82, b = 0 })
    end
    if PlaySound and SOUNDKIT and SOUNDKIT.RAID_WARNING then PlaySound(SOUNDKIT.RAID_WARNING) end
    Print(msg)
end

local function Tick()
    pcall(CheckDungeonAlert)
    if not frame or not frame:IsShown() then return end
    local RXP = GetRXP()
    local cur = RXP and RXP.currentGuide
    -- Guides nie im Kampf einlesen: erst nach dem Kampf neu aufbauen
    if cur ~= lastGuide and not InCombatLockdown() then
        lastGuide = cur
        Rebuild()
    end
    local idx, lvl = CurrentStepIndex(), UnitLevel("player")
    if idx ~= lastIdx or lvl ~= lastLevel then
        lastIdx, lastLevel = idx, lvl
        StartWorker()
        Render()
    end
end

local function SetShown(show)
    DB.shown = show and true or false
    if show then
        frame:Show()
        lastIdx = nil
        Tick()
        Render()
    else
        frame:Hide()
    end
end

local function Toggle()
    SetShown(not frame:IsShown())
end

---------------------------------------------------------------------------
-- Dungeon vorziehen / zurueck zum Hauptguide
---------------------------------------------------------------------------
local function DungeonDef(tag)
    for _, d in ipairs(DUNGEONS) do
        if d.tag == tag then return d end
    end
end

-- RXP hat pro Dungeon einen eigenen "Dungeon Quests"-Guide:
-- alle Quests einsammeln -> rein -> abgeben.
local function QuestGuideTag(g)
    if not (type(g) == "table" and type(g.group) == "string" and type(g.name) == "string"
        and g.group:find("Dungeon Quests", 1, true)) then return end
    local n = g.name:lower():gsub("^%d+%.?%s*", "")
    for _, d in ipairs(DUNGEONS) do
        for _, word in ipairs(d.names) do
            if HasWord(n, word) then return d.tag, d end
        end
    end
end

local function FindQuestGuide(tag)
    local RXP = GetRXP()
    if not RXP then return end
    local best
    for _, g in pairs(RXP.guides or {}) do
        if QuestGuideTag(g) == tag and IsActive(g) and (not best or g.name < best.name) then
            best = g
        end
    end
    return best
end

-- Alle Dungeons mit RXP-Quest-Guide, nach Level sortiert (fuer Dungeons ausserhalb der Route)
function ns.QuestGuideList()
    if questGuides then return questGuides end
    local RXP = GetRXP()
    local list, byTag = {}, {}
    for _, g in pairs((RXP and RXP.guides) or {}) do
        local tag, d = QuestGuideTag(g)
        if tag and IsActive(g) and (not byTag[tag] or g.name < byTag[tag].name) then
            byTag[tag] = { tag = tag, guide = g, name = g.name, dungeonName = d.display,
                minLevel = d.min, maxLevel = d.max }
        end
    end
    for _, ex in pairs(byTag) do list[#list + 1] = ex end
    table.sort(list, function(a, b)
        if (a.minLevel or 0) ~= (b.minLevel or 0) then return (a.minLevel or 0) < (b.minLevel or 0) end
        return a.dungeonName < b.dungeonName
    end)
    -- erst merken, wenn RXP seine Guides geladen hat (sonst beim naechsten Aufruf erneut suchen)
    if #list > 0 then questGuides = list end
    return list
end

local function PullTarget(r)
    local RXP = GetRXP()
    local qg = FindQuestGuide(r.tag)
    if qg then
        return qg, nil, nil, qg.displayname or qg.name
    end
    if r.extra then return end
    -- kein Quest-Guide: direkt zum Enter-Schritt im passenden Abschnitt
    local g = RXP.GetGuideTable(r.seg.group, r.seg.name)
    if g then
        return g, r.idx, r.stepId, L.TARGET_STEP:format(r.seg.displayname or r.seg.name, r.idx)
    end
end

local function DoPull(r)
    local RXP = GetRXP()
    if not RXP then return end
    if InCombatLockdown() then Print(L.MSG_COMBAT) return end
    local cur = RXP.currentGuide
    if type(cur) ~= "table" or cur.empty then Print(L.MSG_NO_GUIDE) return end

    local target, step, stepId = PullTarget(r)
    if not target then Print(L.MSG_NO_TARGET:format(DungeonName(r.tag))) return end

    -- Ruecksprungpunkt nur beim ersten Vorziehen merken (sonst bliebe man im Quest-Guide haengen)
    if not CharDB.returnPoint then
        local curStep = tonumber(RXPCData.currentStep)
        local curStepId = RXPCData.currentStepId
        if not curStep then curStep, curStepId = RXP.GetGuideProgress() end
        CharDB.returnPoint = {
            group    = cur.group,
            name     = cur.name,
            key      = cur.key,
            step     = curStep,
            stepId   = curStepId,
            stepSkip = CopyTable(RXPCData.stepSkip or {}),
        }
    end
    CharDB.returnPoint.dungeon = r.tag

    if step and target.key and RXPCData.guideProgress then
        RXPCData.guideProgress[target.key] = { step = step, stepId = stepId }
    end

    local ok, err = pcall(RXP.LoadGuide, RXP, target)
    if not ok then
        Print(L.MSG_LOAD_FAIL:format(tostring(err)))
    else
        Print(L.MSG_PULLED:format(DungeonName(r.tag), L.CMD_BACK))
    end
    lastGuide = nil
    Tick()
    Render()
end

local function ReturnBack()
    local RXP = GetRXP()
    local rp = CharDB and CharDB.returnPoint
    if not rp then Print(L.MSG_NOTHING_PULLED) return end
    if not RXP then return end
    if InCombatLockdown() then Print(L.MSG_COMBAT) return end

    local g = RXP.GetGuideTable(rp.group, rp.name)
    if not g then
        Print(L.MSG_MAIN_NOT_FOUND:format(tostring(rp.name)))
        return
    end

    -- gespeicherten Schritt erzwingen und manuell uebersprungene Schritte wiederherstellen
    local progress = { step = rp.step, stepId = rp.stepId }
    if RXPCData.guideProgress then
        if rp.key then RXPCData.guideProgress[rp.key] = progress end
        if g.key then RXPCData.guideProgress[g.key] = { step = rp.step, stepId = rp.stepId } end
    end
    RXPCData.stepSkip = CopyTable(rp.stepSkip or {})

    local ok, err = pcall(RXP.LoadGuide, RXP, g, true)
    if not ok then
        Print(L.MSG_MAIN_LOAD_FAIL:format(tostring(err)))
        return
    end
    CharDB.returnPoint = nil
    Print(L.MSG_BACK:format(tostring(rp.name), tostring(rp.step)))
    lastGuide = nil
    Tick()
    Render()
end

-- Hinweis: StaticPopupDialogs gehoert der Blizzard-UI und darf nie neu zugewiesen
-- werden (sonst "has been blocked from an action..."). Nur einen eigenen Eintrag anlegen.
StaticPopupDialogs["DESTROZA_DT_PULL"] = {
    text = "%s",
    button1 = YES or "Ja",
    button2 = NO or "Nein",
    OnAccept = function(self, data) DoPull(data) end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

---------------------------------------------------------------------------
-- Quests eines Dungeons mit der Gruppe teilen
---------------------------------------------------------------------------
local SHARE_DELAY = 1.2   -- Sekunden zwischen zwei geteilten Quests (sonst gehen Angebote unter)
local sharing = false

local questIdCache = {}
local function DungeonQuestIds(tag)
    if questIdCache[tag] then return questIdCache[tag] end
    local ids = {}
    local qg = FindQuestGuide(tag)
    local RXP = GetRXP()
    if qg and RXP then
        -- Guide-Text erst aufbereiten lassen (RXP haelt die Guides komprimiert vor)
        local steps = WithProtectedRXPState(function()
            local full = RXP:FetchGuide(qg)
            local processed = type(full) == "table" and RXP.ProcessGuideTable(full)
            return type(processed) == "table" and processed.steps
        end)
        for _, st in ipairs(type(steps) == "table" and steps or {}) do
            for _, e in ipairs(st.elements or {}) do
                if e.tag == "accept" and tonumber(e.questId) then ids[tonumber(e.questId)] = true end
            end
        end
        questIdCache[tag] = ids
    end
    return ids
end

-- Questlog-Index einer Quest (eingeklappte Kategorien vorher aufklappen)
local function QuestLogIndex(questID)
    local n = GetNumQuestLogEntries and GetNumQuestLogEntries() or 0
    for i = 1, n do
        local _, _, _, isHeader, isCollapsed, _, _, id = GetQuestLogTitle(i)
        if isHeader and isCollapsed and ExpandQuestHeader then
            ExpandQuestHeader(0)
            return QuestLogIndex(questID)
        end
        if not isHeader and id == questID then return i end
    end
end

-- Quests dieses Dungeons im Questlog, die man teilen kann: { {id, title, index} }
local function ShareableQuests(tag)
    local wanted = DungeonQuestIds(tag)
    local list = {}
    local n = GetNumQuestLogEntries and GetNumQuestLogEntries() or 0
    local selected = GetQuestLogSelection and GetQuestLogSelection()
    for i = 1, n do
        local title, _, _, isHeader, _, _, _, id = GetQuestLogTitle(i)
        if not isHeader and id and wanted[id] then
            SelectQuestLogEntry(i)
            if GetQuestLogPushable() then list[#list + 1] = { id = id, title = title } end
        end
    end
    if selected and SelectQuestLogEntry then SelectQuestLogEntry(selected) end
    return list
end

local function ShareDungeonQuests(r)
    if sharing then return end
    if not InGroup() then Print(L.MSG_SHARE_NOGROUP) return end
    local name = DungeonName(r.tag)
    QuestLogIndex(-1)   -- klappt eingeklappte Kategorien auf
    local list = ShareableQuests(r.tag)
    if #list == 0 then Print(L.MSG_SHARE_NONE:format(name)) return end
    local titles = {}
    for _, q in ipairs(list) do titles[#titles + 1] = q.title end
    Print(L.MSG_SHARING:format(#list, name, table.concat(titles, ", ")))
    sharing = true
    for i, q in ipairs(list) do
        C_Timer.After((i - 1) * SHARE_DELAY, function()
            local idx = QuestLogIndex(q.id)
            if idx then
                local selected = GetQuestLogSelection and GetQuestLogSelection()
                SelectQuestLogEntry(idx)
                if GetQuestLogPushable() then QuestLogPushQuest() end
                if selected and selected > 0 then SelectQuestLogEntry(selected) end
            end
            if i == #list then sharing = false end
        end)
    end
end

local function ShowShareTooltip(button, row)
    local r = row.result
    if not r then return end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L.TT_SHARE_TITLE:format(DungeonName(r.tag)))
    if not InGroup() then
        GameTooltip:AddLine(L.MSG_SHARE_NOGROUP, 1, 0.4, 0.25, true)
    end
    local list = ShareableQuests(r.tag)
    if #list == 0 then
        GameTooltip:AddLine(L.TT_SHARE_NONE, 0.7, 0.7, 0.7, true)
    else
        for _, q in ipairs(list) do GameTooltip:AddLine("- " .. q.title, 1, 1, 1) end
    end
    GameTooltip:Show()
end

local function ConfirmPull(r)
    local RXP = GetRXP()
    if not (RXP and r) then return end
    local _, _, _, targetLabel = PullTarget(r)
    if not targetLabel then
        Print(L.MSG_NO_TARGET:format(DungeonName(r.tag)))
        return
    end
    local rp = CharDB.returnPoint
    local backName, backStep
    if rp then
        backName, backStep = rp.name, rp.step
    else
        backName = RXP.currentGuide and RXP.currentGuide.name or "?"
        backStep = tonumber(RXPCData.currentStep) or RXP.GetGuideProgress()
    end
    local text = L.POPUP:format(DungeonName(r.tag), targetLabel, tostring(backName),
        tostring(backStep), L.CMD_BACK)
    StaticPopup_Show("DESTROZA_DT_PULL", text, nil, r)
end

---------------------------------------------------------------------------
-- Fenster
---------------------------------------------------------------------------
local function SavePosition()
    local point, _, relPoint, x, y = frame:GetPoint(1)
    DB.point = { point, relPoint, x, y }
end

local function ApplyPosition()
    frame:ClearAllPoints()
    local p = DB.point
    if p then
        frame:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        frame:SetPoint("RIGHT", UIParent, "RIGHT", -60, 120)
    end
end

---------------------------------------------------------------------------
-- Flache Optik: dunkler Hintergrund, 1-Pixel-Rahmen
---------------------------------------------------------------------------
local FLAT       = "Interface\\Buttons\\WHITE8X8"
local C_BG       = { 0.06, 0.06, 0.06, 0.90 }
local C_BORDER   = { 0, 0, 0, 1 }
local C_BTN      = { 0.15, 0.15, 0.15, 1 }
local C_LINE     = { 0.22, 0.22, 0.22, 1 }
local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil

-- 1 echter Bildschirmpixel, unabhaengig von UI-Skalierung
local function PixelSize(f)
    if PixelUtil and PixelUtil.GetNearestPixelSize and f.GetEffectiveScale then
        local ok, size = pcall(PixelUtil.GetNearestPixelSize, 1, f:GetEffectiveScale(), 1)
        if ok and size then return size end
    end
    return 1
end

local function ApplyFlat(f, bg, border)
    if not f.SetBackdrop then return end
    local px = PixelSize(f)
    f:SetBackdrop({
        bgFile = FLAT, edgeFile = FLAT, edgeSize = px,
        insets = { left = px, right = px, top = px, bottom = px },
    })
    f:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    f:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

local function CreateFlatButton(parent, width, height, text)
    local b = CreateFrame("Button", nil, parent, BACKDROP_TEMPLATE)
    b:SetSize(width, height)
    ApplyFlat(b, C_BTN, C_BORDER)

    local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("CENTER", 0, 0)
    b:SetFontString(fs)
    if GameFontHighlightSmall then
        b:SetNormalFontObject(GameFontHighlightSmall)
        b:SetHighlightFontObject(GameFontHighlightSmall)
    end
    if GameFontDisableSmall then b:SetDisabledFontObject(GameFontDisableSmall) end
    b:SetText(text or "")

    -- Hover: leicht aufhellen (ohne OnEnter-Skripte zu belegen)
    b:SetHighlightTexture(FLAT)
    local hl = b:GetHighlightTexture()
    if hl then
        hl:SetVertexColor(1, 1, 1, 0.12)
        hl:ClearAllPoints()
        local px = PixelSize(b)
        hl:SetPoint("TOPLEFT", px, -px)
        hl:SetPoint("BOTTOMRIGHT", -px, px)
    end
    return b
end

local function CreateMainFrame()
    frame = CreateFrame("Frame", "DestrozaDungeonTrackerFrame", UIParent, BACKDROP_TEMPLATE)
    frame:SetSize(FRAME_WIDTH, 60)
    -- ESC closes the window like Blizzard's own; remember it as closed
    -- (but not when the whole UI is hidden with Alt+Z)
    tinsert(UISpecialFrames, "DestrozaDungeonTrackerFrame")
    frame:HookScript("OnHide", function()
        if UIParent:IsShown() and DB then DB.shown = false end
    end)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        if not DB.locked then self:StartMoving() end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition()
    end)
    ApplyFlat(frame, C_BG, C_BORDER)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, -8)
    title:SetText(L.TITLE)
    frame.title = title

    -- Version, small and dim, right after the title
    local ver = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    ver:SetPoint("LEFT", title, "RIGHT", 6, 0)
    ver:SetText("v" .. (((C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata)(ADDON_NAME, "Version") or "?"))
    frame.version = ver

    local close = CreateFlatButton(frame, 16, 16, "x")
    close:SetPoint("TOPRIGHT", -5, -5)
    close:SetScript("OnClick", function() SetShown(false) end)
    frame.close = close

    -- feine Trennlinie unter der Titelzeile
    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetTexture(FLAT)
    line:SetVertexColor(C_LINE[1], C_LINE[2], C_LINE[3], C_LINE[4])
    line:SetHeight(PixelSize(frame))
    line:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -24)
    line:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -24)

    local level = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    level:SetPoint("RIGHT", close, "LEFT", -6, 0)
    frame.level = level

    -- Spaltenkoepfe
    local function Header(text, justify, width, anchorX)
        local h = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        h:SetText(text)
        h:SetJustifyH(justify)
        if width then h:SetWidth(width) end
        h:SetPoint("TOP" .. (justify == "LEFT" and "LEFT" or "RIGHT"), frame,
            "TOP" .. (justify == "LEFT" and "LEFT" or "RIGHT"), anchorX, -27)
        return h
    end
    local right = -10 - COL_SHARE - BTN_GAP - COL_BUTTON - COL_GAP
    frame.headers = {
        dungeon = Header(L.COL_DUNGEON, "LEFT", nil, 10),
        level   = Header(L.COL_LEVEL, "RIGHT", COL_LEVEL, right),
        steps   = Header(L.COL_STEPS, "RIGHT", COL_STEPS, right - COL_LEVEL - COL_GAP),
    }

    rows = {}
    for i = 1, MAX_ROWS do
        local row = CreateFrame("Frame", nil, frame)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -(ROWS_TOP + (i - 1) * ROW_HEIGHT))
        row:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
        row:EnableMouse(true)
        row:SetScript("OnEnter", function(self) self.hl:Show() ShowRowTooltip(self) end)
        row:SetScript("OnLeave", function(self) self.hl:Hide() GameTooltip:Hide() end)
        -- Ziehen des Fensters auch ueber die Zeilen erlauben
        row:RegisterForDrag("LeftButton")
        local hl = row:CreateTexture(nil, "BACKGROUND")
        hl:SetAllPoints()
        hl:SetColorTexture(1, 1, 1, 0.05)
        hl:Hide()
        row.hl = hl
        row:SetScript("OnDragStart", function()
            if not DB.locked then frame:StartMoving() end
        end)
        row:SetScript("OnDragStop", function() frame:StopMovingOrSizing() SavePosition() end)

        -- Spalte 5: Teilen
        local share = CreateFlatButton(row, COL_SHARE, ROW_HEIGHT - 3, L.BTN_SHARE)
        share:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        share:SetScript("OnClick", function()
            GameTooltip:Hide()
            if row.result then ShareDungeonQuests(row.result) end
        end)
        share:SetScript("OnEnter", function(self) row.hl:Show() ShowShareTooltip(self, row) end)
        share:SetScript("OnLeave", function() row.hl:Hide() GameTooltip:Hide() end)
        row.share = share

        -- Spalte 4: Knopf
        local button = CreateFlatButton(row, COL_BUTTON, ROW_HEIGHT - 3, L.BTN_PULL)
        button:SetPoint("RIGHT", share, "LEFT", -BTN_GAP, 0)
        button:SetScript("OnClick", function()
            GameTooltip:Hide()
            if row.result then ConfirmPull(row.result) end
        end)
        button:SetScript("OnEnter", function() row.hl:Show() ShowRowTooltip(row) end)
        button:SetScript("OnLeave", function() row.hl:Hide() GameTooltip:Hide() end)
        row.button = button

        -- Spalte 3: Level
        local level = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        level:SetPoint("RIGHT", button, "LEFT", -COL_GAP, 0)
        level:SetWidth(COL_LEVEL)
        level:SetJustifyH("RIGHT")
        row.level = level

        -- Spalte 2: Schritte
        local steps = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        steps:SetPoint("RIGHT", level, "LEFT", -COL_GAP, 0)
        steps:SetWidth(COL_STEPS)
        steps:SetJustifyH("RIGHT")
        row.steps = steps

        -- Spalte 1: Dungeon
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        name:SetPoint("LEFT", row, "LEFT", 0, 0)
        name:SetPoint("RIGHT", steps, "LEFT", -COL_GAP, 0)
        name:SetJustifyH("LEFT")
        if name.SetWordWrap then name:SetWordWrap(false) end
        row.name = name

        row:Hide()
        rows[i] = row
    end

    local back = CreateFlatButton(frame, 100, 20, "")
    back:SetScript("OnClick", function() ReturnBack() end)
    back:Hide()
    frame.back = back

    local status = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    status:SetJustifyH("LEFT")
    frame.status = status

    frame:SetScript("OnShow", function() Render() end)
    ApplyPosition()
end

---------------------------------------------------------------------------
-- Minimap-Button (ueber das von RXP mitgelieferte LibDBIcon)
---------------------------------------------------------------------------
local function SetupMinimap()
    if minimapReady then return end
    local LDB    = LibStub and LibStub("LibDataBroker-1.1", true)
    local DBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
    if not (LDB and DBIcon) then return end

    local launcher = LDB:NewDataObject("Destroza_DungeonTracker", {
        type = "launcher",
        text = "Destroza Dungeons",
        icon = "Interface\\Icons\\INV_Misc_Key_03",
        OnClick = function(_, button)
            if button == "RightButton" then
                Refresh()
                Print(L.MSG_RECALC)
            else
                Toggle()
            end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine("Destroza Dungeon Tracker")
            tt:AddLine(L.MM_LEFT, 0.8, 0.8, 0.8)
            tt:AddLine(L.MM_RIGHT, 0.8, 0.8, 0.8)
            tt:AddLine(L.MM_DRAG, 0.8, 0.8, 0.8)
        end,
    })
    if launcher then
        DBIcon:Register("Destroza_DungeonTracker", launcher, DB.minimap)
        minimapReady = true
    end
end

local function ToggleMinimap(silent)
    local DBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
    if not DBIcon or not minimapReady then
        Print(L.MSG_MM_NA)
        return
    end
    DB.minimap.hide = not DB.minimap.hide
    if DB.minimap.hide then
        DBIcon:Hide("Destroza_DungeonTracker")
        if not silent then Print(L.MSG_MM_HIDDEN) end
    else
        DBIcon:Show("Destroza_DungeonTracker")
        if not silent then Print(L.MSG_MM_SHOWN) end
    end
end

---------------------------------------------------------------------------
-- Slash-Befehle
---------------------------------------------------------------------------
local function PrintHelp()
    Print(L.HELP_TITLE)
    local function line(text) DEFAULT_CHAT_FRAME:AddMessage("  " .. text) end
    line(L.HELP_TOGGLE)
    line(L.HELP_COUNT:format(L.CMD_COUNT, L.CMD_ALL, MAX_ROWS))
    line(L.HELP_BUTTON:format(L.BTN_PULL))
    line(L.HELP_BACK:format(L.CMD_BACK))
    line(L.HELP_MINIMAP)
    line(L.HELP_LOCK)
    line(L.HELP_RESET)
    line(L.HELP_REFRESH)
    line(L.HELP_LANG:format(L.CMD_LANG))
    line(L.HELP_DEBUG)
end

-- Sprache des Fensters umstellen (Texte, die nicht bei jedem Render neu gesetzt werden)
local function ApplyLanguage(code)
    ns.SetLanguage(code)
    if frame then
        frame.title:SetText(L.TITLE)
        frame.headers.dungeon:SetText(L.COL_DUNGEON)
        frame.headers.level:SetText(L.COL_LEVEL)
        frame.headers.steps:SetText(L.COL_STEPS)
        Render()
    end
end

local function PrintDebug()
    if ns.AHDebug then ns.AHDebug() end
    if not chain then Print("Keine Kette (kein Guide geladen).") return end
    Print(("Aktueller Schritt: %d"):format(CurrentStepIndex()))
    local function dump(label, track)
        if not track then return end
        DEFAULT_CHAT_FRAME:AddMessage(("%s - %d Abschnitte, fertig: %s"):format(
            label, #track.segs, tostring(track.exhausted)))
        for i, seg in ipairs(track.segs) do
            local tags = {}
            for _, e in ipairs(seg.entries) do
                tags[#tags + 1] = e.tag .. "@" .. e.idx .. (e.hidden and "*" or "")
            end
            DEFAULT_CHAT_FRAME:AddMessage(("  %d. %s (%d Schritte) %s"):format(
                i, tostring(seg.name), seg.n, table.concat(tags, ", ")))
        end
    end
    DEFAULT_CHAT_FRAME:AddMessage(("RXP quest guides: %d"):format(#ns.QuestGuideList()))
    dump("Eigener Guide", chain.own)
    dump(chain.par and ("Parallel: " .. tostring(chain.par.group)) or "Parallel", chain.par)
end

---------------------------------------------------------------------------
-- Einstellungs-Menue im Fenster (eigenes flaches Menue statt UIDropDownMenu,
-- das bekanntermassen "blocked action"-Fehler verursachen kann)
---------------------------------------------------------------------------
local LANG_NAMES = { en = "English", de = "Deutsch", es = "Español", fr = "Français", pt = "Português", zh = "中文" }
local MENU_WIDTH, MENU_ITEM_H = 180, 16
local menu, menuButton

local function SetLanguageSetting(code)
    DB.lang = code
    ApplyLanguage(code)
end

local function SetCount(n)
    DB.count = n
    StartWorker()
    Render()
end

local function MenuEntries()
    local list = {}
    local function header(text) list[#list + 1] = { header = text } end
    local function item(text, checked, fn, keepOpen)
        list[#list + 1] = { text = text, checked = checked, fn = fn, keep = keepOpen }
    end

    header(L.MENU_LANGUAGE)
    local cur = DB.lang or "auto"
    item(L.MENU_AUTO:format(LANG_NAMES[ns.ClientLanguage()] or "English"), cur == "auto",
        function() SetLanguageSetting("auto") end)
    for _, code in ipairs(ns.LANGUAGES) do
        if ns.CanDisplay(code) then
            item(LANG_NAMES[code] or code, cur == code, function() SetLanguageSetting(code) end)
        end
    end

    header(L.MENU_COUNT)
    item(L.MENU_SHOW_ALL, DB.showAll, function()
        DB.showAll = not DB.showAll
        StartWorker()
    end, true)
    item(L.MENU_ALL, DB.count == 0, function() SetCount(0) end)
    for _, n in ipairs({ 3, 5, 10 }) do
        item(tostring(n), DB.count == n, function() SetCount(n) end)
    end

    header(L.MENU_OPTIONS)
    item(L.MENU_LOCK, DB.locked, function() DB.locked = not DB.locked end, true)
    item(L.MENU_MINIMAP, not DB.minimap.hide, function() ToggleMinimap(true) end, true)
    item(L.MENU_ALERT, DB.alert ~= false, function() DB.alert = (DB.alert == false) end, true)
    item(rawget(L, "MENU_AHSHOP") or "AH steps to Shopping List", DB.ahShopping ~= false,
        function() DB.ahShopping = (DB.ahShopping == false) end, true)
    item(L.MENU_REFRESH, nil, function() Refresh() end)
    item("Profiles", nil, function() if _G.DestrozaProfiles then DestrozaProfiles.Open("dungeontracker") end end)
    return list
end

local BuildMenu

local function CreateMenuItem(index)
    local b = CreateFrame("Button", nil, menu)
    b:SetHeight(MENU_ITEM_H)

    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.10)

    local check = b:CreateTexture(nil, "OVERLAY")
    check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    check:SetSize(14, 14)
    check:SetPoint("LEFT", 0, 0)
    b.check = check

    local text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", 16, 0)
    text:SetPoint("RIGHT", -2, 0)
    text:SetJustifyH("LEFT")
    b.text = text

    b:SetScript("OnClick", function(self)
        local entry = self.entry
        if not entry or entry.header then return end
        entry.fn()
        if entry.keep then BuildMenu() else menu:Hide() end
        Render()
    end)
    menu.items[index] = b
    return b
end

BuildMenu = function()
    local entries = MenuEntries()
    local y = -4
    for i, entry in ipairs(entries) do
        local b = menu.items[i] or CreateMenuItem(i)
        b.entry = entry
        if entry.header and i > 1 then y = y - 4 end
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", menu, "TOPLEFT", 6, y)
        b:SetPoint("RIGHT", menu, "RIGHT", -6, 0)
        if entry.header then
            b.text:SetText("|cff9d9d9d" .. entry.header .. "|r")
            b.text:SetPoint("LEFT", 0, 0)
            b:EnableMouse(false)
            b.check:Hide()
        else
            b.text:SetText(entry.text)
            b.text:SetPoint("LEFT", 16, 0)
            b:EnableMouse(true)
            if entry.checked then b.check:Show() else b.check:Hide() end
        end
        b:Show()
        y = y - MENU_ITEM_H
    end
    for i = #entries + 1, #menu.items do menu.items[i]:Hide() end
    menu:SetHeight(-y + 4)
end

local function ToggleMenu()
    if menu:IsShown() then
        menu:Hide()
    else
        BuildMenu()
        menu:Show()
    end
end

local function CreateMenu()
    -- Menue-Knopf mit drei Strichen, links neben dem "x"
    menuButton = CreateFlatButton(frame, 16, 16, "")
    menuButton:SetPoint("RIGHT", frame.close, "LEFT", -3, 0)
    for i, yOff in ipairs({ 3, 0, -3 }) do
        local bar = menuButton:CreateTexture(nil, "OVERLAY")
        bar:SetTexture(FLAT)
        bar:SetVertexColor(0.85, 0.85, 0.85, 1)
        bar:SetSize(8, PixelSize(menuButton))
        bar:SetPoint("CENTER", 0, yOff)
    end
    menuButton:SetScript("OnClick", function() ToggleMenu() end)
    menuButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(L.MENU_TT)
        GameTooltip:Show()
    end)
    menuButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    frame.level:ClearAllPoints()
    frame.level:SetPoint("RIGHT", menuButton, "LEFT", -6, 0)

    menu = CreateFrame("Frame", nil, frame, BACKDROP_TEMPLATE)
    menu:SetWidth(MENU_WIDTH)
    ApplyFlat(menu, { 0.08, 0.08, 0.08, 0.97 }, C_BORDER)
    menu:SetFrameStrata("DIALOG")
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    menu:SetPoint("TOPRIGHT", menuButton, "BOTTOMRIGHT", 0, -2)
    menu.items = {}
    menu:Hide()

    -- Klick irgendwo anders schliesst das Menue
    pcall(menu.RegisterEvent, menu, "GLOBAL_MOUSE_DOWN")
    menu:SetScript("OnEvent", function(self)
        if self:IsShown() and not self:IsMouseOver() and not menuButton:IsMouseOver() then
            self:Hide()
        end
    end)
end

-- Befehlswoerter in allen Sprachen akzeptieren
local function Set(list) local t = {} for _, v in ipairs(list) do t[v] = true end return t end
local ALIASES = {
    count = Set({ "count", "anzahl", "cantidad", "nombre", "quantidade" }),
    all   = Set({ "all", "alle", "todas", "todos", "tous", "toutes", "全部" }),
    back  = Set({ "back", "zurueck", "zurück", "volver", "retour", "voltar", "返回" }),
    lang  = Set({ "lang", "language", "sprache", "idioma", "langue", "语言" }),
}

SLASH_DESTROZADUNGEONTRACKER1 = "/rxpd"
SLASH_DESTROZADUNGEONTRACKER2 = "/rxpdungeons"
SLASH_DESTROZADUNGEONTRACKER3 = "/ddt"
SlashCmdList.DESTROZADUNGEONTRACKER = function(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    local cmd, arg = msg:match("^(%S*)%s*(.-)$")
    if cmd == "" then
        Toggle()
    elseif cmd == "show" or cmd == "an" or cmd == "on" then
        SetShown(true)
    elseif cmd == "hide" or cmd == "aus" or cmd == "off" then
        SetShown(false)
    elseif ALIASES.count[cmd] then
        local n = tonumber(arg)
        if ALIASES.all[arg] or n == 0 then
            DB.count = 0
            Print(L.MSG_SHOW_ALL)
            StartWorker()
            Render()
        elseif n and n >= 1 and n <= MAX_ROWS then
            DB.count = math.floor(n)
            Print(L.MSG_SHOW_N:format(DB.count))
            StartWorker()
            Render()
        else
            Print(L.MSG_COUNT_USAGE:format(L.CMD_ALL, MAX_ROWS, L.CMD_COUNT))
        end
    elseif cmd == "minimap" then
        ToggleMinimap()
    elseif cmd == "lock" then
        DB.locked = not DB.locked
        Print(DB.locked and L.MSG_LOCKED or L.MSG_UNLOCKED)
    elseif cmd == "reset" then
        DB.point = nil
        ApplyPosition()
        Print(L.MSG_POS_RESET)
    elseif cmd == "refresh" then
        Refresh()
        Print(L.MSG_RECALC)
    elseif ALIASES.back[cmd] then
        ReturnBack()
    elseif ALIASES.lang[cmd] then
        local code = arg ~= "" and arg or nil
        local valid = code == "auto"
        for _, c in ipairs(ns.LANGUAGES) do if c == code then valid = true end end
        if not valid then
            Print(L.MSG_LANG_USAGE:format(L.CMD_LANG))
        elseif not ns.CanDisplay(code) then
            Print(L.MSG_LANG_NO_FONT)
        else
            DB.lang = code
            ApplyLanguage(code)
            Print(L.MSG_LANG_SET:format(code == "auto" and ("auto (" .. ns.activeLanguage .. ")") or code))
        end
    elseif cmd == "debug" then
        PrintDebug()
    else
        PrintHelp()
    end
end

---------------------------------------------------------------------------
-- RestedXP-Auktionshaus-Schritte -> Naowhs Shopping List
-- Beim Oeffnen des Auktionshauses: Ist der aktive RestedXP-Schritt ein
-- AH-Schritt (#ah oder "Auction House" im Text), kommt von jedem seiner
-- .collect-Items die fehlende Menge auf die Shopping List. Was dort schon
-- mit gleicher oder groesserer Menge steht, bleibt unveraendert.
---------------------------------------------------------------------------
local function IsAHStep(step)
    if step.ah then return true end
    for _, el in ipairs(step.elements or {}) do
        for _, key in ipairs(TEXT_FIELDS) do
            local t = el[key]
            if type(t) == "string" and t:lower():find("auction house", 1, true) then return true end
        end
    end
    return false
end

local function CountOf(el)
    local n = 0
    for id in tostring(el.ids or el.id):gmatch("%d+") do
        id = tonumber(id)
        if C_Item and C_Item.GetItemCount then
            n = n + (C_Item.GetItemCount(id, el.includeBank) or 0)
        elseif GetItemCount then
            n = n + (GetItemCount(id, el.includeBank) or 0)
        end
    end
    return n
end

local function NaowhShopping()
    local nf = _G.NaowhForever
    if not nf then return nil end
    if not (nf.Professions and nf.Professions.Shopping) and C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "NaowhForever_Professions")
    end
    local shop = nf.Professions and nf.Professions.Shopping
    if shop and shop.SetItem and shop.Manual then return shop end
end

-- Die Schritte, die RestedXP gerade als aktiv fuehrt, plus der gespeicherte
-- aktuelle Schritt (falls step.active in dieser RXP-Version anders heisst).
local function ActiveSteps(g)
    local out, seen = {}, {}
    for _, step in ipairs(g.steps) do
        if step.active then out[#out + 1] = step; seen[step] = true end
    end
    local cur = g.steps[tonumber(RXPCData and RXPCData.currentStep) or 0]
    if cur and not seen[cur] then out[#out + 1] = cur end
    return out
end

-- verbose: jede Entscheidung in den Chat (fuer /ddt debug)
local function FillAHShopping(verbose)
    local function V(msg) if verbose then Print("|cff9d9d9d[AH]|r " .. msg) end end
    if not DB or DB.ahShopping == false then V("option is off"); return end
    local RXP = GetRXP()
    local g = RXP and RXP.currentGuide
    if not (g and g.steps) then V("no RestedXP guide loaded"); return end
    local shop
    local added, listed, found = {}, 0, false
    for _, step in ipairs(ActiveSteps(g)) do
        local ah = IsAHStep(step)
        V(("step %s: active=%s ah-flag=%s ah-step=%s elements=%d"):format(tostring(step.index),
            tostring(step.active), tostring(step.ah), tostring(ah), #(step.elements or {})))
        if ah then
            found = true
            for _, el in ipairs(step.elements or {}) do
                if el.tag == "collect" and el.id then
                    local need = tonumber(el.numRequired)
                    if need == nil or (need == 0 and not el.completed) then need = tonumber(el.qty) or 0 end
                    local have = CountOf(el)
                    local missing = need - have
                    V(("  item %d: need %s have %d done=%s"):format(el.id, tostring(need), have, tostring(el.completed)))
                    if missing > 0 and not el.completed then
                        shop = shop or NaowhShopping()
                        if not shop then
                            Print("Naowh's Shopping List is not available.")
                            return
                        end
                        local ok, list = pcall(shop.Manual)
                        local cur = ok and type(list) == "table" and list[el.id] or 0
                        if cur < missing then
                            shop.SetItem(el.id, missing)
                            local name = (C_Item.GetItemNameByID and C_Item.GetItemNameByID(el.id))
                                or el.itemName or ("item " .. el.id)
                            added[#added + 1] = missing .. "x " .. name
                        else
                            listed = listed + 1
                        end
                    end
                end
            end
        end
    end
    if #added > 0 then
        Print("RestedXP step: added to the Shopping List (tab \"Shopping List\" in The Market): "
            .. table.concat(added, ", "))
    elseif found and (verbose or listed > 0) then
        Print(listed > 0 and "RestedXP step: everything is already on the Shopping List."
            or "RestedXP step: nothing missing.")
    elseif not found then
        V("no Auction House step active")
    end
end
ns.AHDebug = function() FillAHShopping(true) end

-- Solange das AH offen ist, auch beim Wechsel des RestedXP-Schritts nachsehen.
local ahTicker, ahLastStep
local ahEvents = CreateFrame("Frame")
pcall(ahEvents.RegisterEvent, ahEvents, "AUCTION_HOUSE_SHOW")
pcall(ahEvents.RegisterEvent, ahEvents, "AUCTION_HOUSE_CLOSED")
ahEvents:SetScript("OnEvent", function(_, event)
    if event == "AUCTION_HOUSE_CLOSED" then
        if ahTicker then ahTicker:Cancel(); ahTicker = nil end
        return
    end
    local function Run()
        ahLastStep = RXPCData and RXPCData.currentStep
        local ok, err = pcall(FillAHShopping)
        if not ok then geterrorhandler()(err) end
    end
    -- kurz warten, bis Naowhs Market-Fenster steht
    C_Timer.After(0.3, Run)
    if not ahTicker then
        ahTicker = C_Timer.NewTicker(1, function()
            if (RXPCData and RXPCData.currentStep) ~= ahLastStep then Run() end
        end)
    end
end)

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        DestrozaDungeonTrackerCharDB = DestrozaDungeonTrackerCharDB or {}
        CharDB = DestrozaDungeonTrackerCharDB
        DestrozaDungeonTrackerDB = DestrozaDungeonTrackerDB or {}
        DB = DestrozaDungeonTrackerDB
        -- account-wide settings profiles
        DestrozaProfiles.Init({ id = "dungeontracker", title = "Destroza DungeonTracker", addon = ADDON_NAME,
            keys = { "shown", "count", "locked", "point", "minimap", "alert", "ahShopping", "lang", "showAll" } }, DB)
        for k, v in pairs(defaults) do
            if DB[k] == nil then
                DB[k] = type(v) == "table" and CopyTable(v) or v
            end
        end
        -- ab Version 2 standardmaessig alle Dungeons anzeigen
        if (DB.version or 1) < 2 then
            DB.count = 0
            DB.version = 2
        end
        DB.count = math.max(0, math.min(MAX_ROWS, tonumber(DB.count) or defaults.count))
        if DB.lang and not ns.CanDisplay(DB.lang) then DB.lang = "auto" end
        ns.SetLanguage(DB.lang)
    elseif event == "PLAYER_LOGIN" then
        if not GetRXP() then
            Print(L.MSG_NEED_RXP)
        end
        CreateMainFrame()
        CreateMenu()
        SetupMinimap()
        if DB.shown then frame:Show() else frame:Hide() end
        C_Timer.NewTicker(TICK_INTERVAL, Tick)
    elseif event == "PLAYER_LEVEL_UP" then
        Render()
    end
end)
