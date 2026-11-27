-- Destroza Profiles: account-wide settings profiles for every Destroza addon.
-- The same file ships in each addon; the newest copy wins (like a library).
--
-- An addon calls, on its ADDON_LOADED, before it fills its defaults:
--   DestrozaProfiles.Init({ id, title, addon, keys = {...}, exclude = {...} }, savedVariablesTable)
-- keys    = top-level keys of the SavedVariables that are settings
-- exclude = "a.b" paths inside those keys that are data (stay account data)
--
-- Stored in savedVariables.dzProfiles:
--   list    = { [name] = settings snapshot }
--   default = name every character uses unless it has its own choice
--   char    = { ["Name - Realm"] = name }  own choice of a character
--   loaded  = the profile the live settings belong to right now
local MINOR = 1
local lib = _G.DestrozaProfiles
if lib and (lib.minor or 0) >= MINOR then return end
lib = lib or {}
_G.DestrozaProfiles = lib
lib.minor = MINOR
lib.reg = lib.reg or {}
lib.order = lib.order or {}

local DEFAULT = "Default"

local function CharKey()
    return (UnitName("player") or "?") .. " - " .. (GetRealmName() or "?")
end
lib.CharKey = CharKey

local function Copy(v)
    if type(v) ~= "table" then return v end
    local t = {}
    for k, x in pairs(v) do t[k] = Copy(x) end
    return t
end

local function Split(path)
    local t = {}
    for p in path:gmatch("[^%.]+") do t[#t + 1] = p end
    return t
end

local function GetPath(root, parts)
    local t = root
    for i = 1, #parts do
        if type(t) ~= "table" then return nil end
        t = t[parts[i]]
    end
    return t
end

local function SetPath(root, parts, v)
    local t = root
    for i = 1, #parts - 1 do
        if type(t[parts[i]]) ~= "table" then
            if v == nil then return end
            t[parts[i]] = {}
        end
        t = t[parts[i]]
    end
    t[parts[#parts]] = v
end

-------------------------------------------------------------------------------
-- Core
-------------------------------------------------------------------------------
local function Snapshot(e)
    local s = {}
    for _, k in ipairs(e.keys) do s[k] = Copy(e.root[k]) end
    for _, parts in ipairs(e.ex) do SetPath(s, parts, nil) end
    return s
end

local function Save(e)
    local st = e.store
    if st.loaded and st.list[st.loaded] then st.list[st.loaded] = Snapshot(e) end
end

local function Load(e, name)
    local keep = {}
    for i, parts in ipairs(e.ex) do keep[i] = GetPath(e.root, parts) end
    local p = e.store.list[name] or {}
    for _, k in ipairs(e.keys) do e.root[k] = Copy(p[k]) end
    for i, parts in ipairs(e.ex) do
        if keep[i] ~= nil then SetPath(e.root, parts, keep[i]) end
    end
    e.store.loaded = name
end

local function Wanted(e)
    local st = e.store
    local own = st.char[CharKey()]
    if own and st.list[own] then return own end
    if not st.list[st.default] then st.default = DEFAULT; st.list[DEFAULT] = st.list[DEFAULT] or {} end
    return st.default
end

local function Sorted(st)
    local t = {}
    for n in pairs(st.list) do t[#t + 1] = n end
    table.sort(t, function(a, b)
        if a == st.default then return true elseif b == st.default then return false end
        return a:lower() < b:lower()
    end)
    return t
end

function lib.Init(spec, root)
    local e = lib.reg[spec.id]
    if not e then
        e = {}
        lib.reg[spec.id] = e
        lib.order[#lib.order + 1] = spec.id
    end
    for k, v in pairs(spec) do e[k] = v end
    e.ex = {}
    for _, path in ipairs(spec.exclude or {}) do e.ex[#e.ex + 1] = Split(path) end
    e.root = root
    local st = root.dzProfiles
    if type(st) ~= "table" then
        -- first start: the settings you have become "Default"
        st = { list = {}, default = DEFAULT, char = {} }
        root.dzProfiles = st
        e.store = st
        st.list[DEFAULT] = Snapshot(e)
        st.loaded = DEFAULT
    end
    st.list = st.list or {}
    st.char = st.char or {}
    st.default = st.default or DEFAULT
    e.store = st
    local want = Wanted(e)
    if want ~= st.loaded then
        Save(e)
        Load(e, want)
    end
    return e
end

local function E(id) return lib.reg[id] end

function lib.Addons() return lib.order end
function lib.Title(id) return E(id) and E(id).title or id end
function lib.List(id) local e = E(id); return e and Sorted(e.store) or {} end
function lib.Active(id) local e = E(id); return e and e.store.loaded end
function lib.Default(id) local e = E(id); return e and e.store.default end
function lib.Own(id) local e = E(id); return e and e.store.char[CharKey()] end
function lib.Exists(id, name) local e = E(id); return e and e.store.list[name] ~= nil end

local function NeedReload()
    if not StaticPopupDialogs.DESTROZA_PROFILES_RELOAD then
        StaticPopupDialogs.DESTROZA_PROFILES_RELOAD = {
            text = "Profile changed.\nReload the UI now so it takes effect?",
            button1 = "Reload", button2 = "Later",
            OnAccept = function() ReloadUI() end,
            timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
        }
    end
    StaticPopup_Show("DESTROZA_PROFILES_RELOAD")
end
lib.NeedReload = NeedReload

-- Load what this character should use now. Returns true when it changed.
local function Switch(e, noPopup)
    local want = Wanted(e)
    if want == e.store.loaded then return false end
    Save(e)
    Load(e, want)
    if not noPopup then NeedReload() end
    return true
end

-- This character uses `name` (the Default profile = follow the default).
function lib.Use(id, name, noPopup)
    local e = E(id)
    if not (e and e.store.list[name]) then return false end
    e.store.char[CharKey()] = (name ~= e.store.default) and name or nil
    return Switch(e, noPopup)
end

function lib.FollowDefault(id)
    local e = E(id); if not e then return end
    e.store.char[CharKey()] = nil
    return Switch(e)
end

function lib.SetDefault(id, name)
    local e = E(id)
    if not (e and e.store.list[name]) then return end
    e.store.default = name
    -- a character whose own choice is the new default just follows it now
    if e.store.char[CharKey()] == name then e.store.char[CharKey()] = nil end
    return Switch(e)
end

-- New profile; from = profile to copy, nil = default settings of the addon.
function lib.New(id, name, from)
    local e = E(id)
    if not e or name == "" or e.store.list[name] then return false end
    if from and from == e.store.loaded then
        e.store.list[name] = Snapshot(e)
    elseif from and e.store.list[from] then
        e.store.list[name] = Copy(e.store.list[from])
    else
        e.store.list[name] = {}
    end
    return true
end

function lib.Rename(id, old, new)
    local e = E(id)
    if not e or new == "" or not e.store.list[old] or e.store.list[new] then return false end
    local st = e.store
    st.list[new], st.list[old] = st.list[old], nil
    if st.default == old then st.default = new end
    if st.loaded == old then st.loaded = new end
    for k, v in pairs(st.char) do if v == old then st.char[k] = new end end
    return true
end

function lib.Delete(id, name)
    local e = E(id)
    if not e or name == e.store.default or not e.store.list[name] then return false end
    local st = e.store
    st.list[name] = nil
    for k, v in pairs(st.char) do if v == name then st.char[k] = nil end end
    if st.loaded == name then
        st.loaded = nil
        Load(e, Wanted(e))
        NeedReload()
    end
    return true
end

-------------------------------------------------------------------------------
-- Export / Import: !DZP1:<addon>:<name>:<data>, no code is ever run
-------------------------------------------------------------------------------
local function EscStr(s)
    return '"' .. s:gsub("[^%w_%-%.]", function(c) return ("\\%03d"):format(c:byte()) end) .. '"'
end

local function Ser(v, out)
    local t = type(v)
    if t == "boolean" then out[#out + 1] = v and "T" or "F"
    elseif t == "number" then out[#out + 1] = "n" .. ("%.15g"):format(v)
    elseif t == "string" then out[#out + 1] = EscStr(v)
    elseif t == "table" then
        out[#out + 1] = "{"
        for k, x in pairs(v) do
            local kt, xt = type(k), type(x)
            if (kt == "string" or kt == "number") and (xt == "string" or xt == "number" or xt == "boolean" or xt == "table") then
                Ser(k, out); out[#out + 1] = "="; Ser(x, out); out[#out + 1] = ","
            end
        end
        out[#out + 1] = "}"
    end
end

local function Parse(s)
    local pos, depth = 1, 0
    local function Val()
        local c = s:sub(pos, pos)
        if c == "T" then pos = pos + 1; return true
        elseif c == "F" then pos = pos + 1; return false
        elseif c == "n" then
            local num = s:match("^[%-%+%deE%.naif]+", pos + 1)
            local v = num and tonumber(num)
            if not v then error("bad number") end
            pos = pos + 1 + #num
            return v
        elseif c == '"' then
            local stop = s:find('"', pos + 1, true)
            if not stop then error("bad text") end
            local raw = s:sub(pos + 1, stop - 1)
            pos = stop + 1
            return (raw:gsub("\\(%d%d%d)", function(d) return string.char(tonumber(d) % 256) end))
        elseif c == "{" then
            depth = depth + 1
            if depth > 40 then error("too deep") end
            pos = pos + 1
            local t = {}
            while s:sub(pos, pos) ~= "}" do
                if pos > #s then error("unexpected end") end
                local k = Val()
                if s:sub(pos, pos) ~= "=" then error("bad table") end
                pos = pos + 1
                local v = Val()
                if k ~= nil then t[k] = v end
                if s:sub(pos, pos) == "," then pos = pos + 1 end
            end
            pos = pos + 1
            depth = depth - 1
            return t
        end
        error("bad value")
    end
    local v = Val()
    if type(v) ~= "table" then error("bad data") end
    return v
end

function lib.Export(id, name)
    local e = E(id)
    if not (e and e.store.list[name]) then return end
    local data = (name == e.store.loaded) and Snapshot(e) or e.store.list[name]
    local out = {}
    Ser(data, out)
    return ("!DZP1:%s:%s:%s"):format(id, EscStr(name), table.concat(out))
end

-- Returns id, name, data   or   nil, error text
function lib.Decode(str)
    str = (str or ""):gsub("%s+", "")
    local id, rest = str:match("^!DZP1:([%w_]+):(.+)$")
    if not id then return nil, "This is not a Destroza profile string." end
    local ok, name, data = pcall(function()
        local stop = rest:find('"', 2, true)
        if rest:sub(1, 1) ~= '"' or not stop or rest:sub(stop + 1, stop + 1) ~= ":" then error("bad name") end
        local n = rest:sub(2, stop - 1):gsub("\\(%d%d%d)", function(d) return string.char(tonumber(d) % 256) end)
        return n, Parse(rest:sub(stop + 2))
    end)
    if not ok then return nil, "The profile string is damaged or incomplete." end
    return id, name, data
end

-- Adds the decoded profile under `name`. Only the addon's setting keys are taken.
function lib.Import(id, name, data)
    local e = E(id)
    if not e or name == "" or e.store.list[name] then return false end
    local p = {}
    for _, k in ipairs(e.keys) do p[k] = Copy(data[k]) end
    for _, parts in ipairs(e.ex) do SetPath(p, parts, nil) end
    e.store.list[name] = p
    return true
end

function lib.FreeName(id, base)
    local e = E(id)
    if not e then return base end
    base = (base and base ~= "") and base or "Imported"
    if not e.store.list[base] then return base end
    local i = 2
    while e.store.list[base .. " " .. i] do i = i + 1 end
    return base .. " " .. i
end

-- the live settings go into the profile on every logout / reload
if not lib.saver then
    lib.saver = CreateFrame("Frame")
    lib.saver:RegisterEvent("PLAYER_LOGOUT")
end
lib.saver:SetScript("OnEvent", function()
    for _, id in ipairs(lib.order) do
        local e = lib.reg[id]
        if e and e.store then pcall(Save, e) end
    end
end)

-------------------------------------------------------------------------------
-- Window (EllesmereUI look): addons on the left, profiles on the right
-------------------------------------------------------------------------------
local WHITE8 = "Interface\\Buttons\\WHITE8X8"
local BG = { 0.069, 0.058, 0.047 }
local win

local function Accent()
    local g = _G.EllesmereUI and _G.EllesmereUI.ELLESMERE_GREEN
    if g and g.r then return g.r, g.g, g.b end
    return 12 / 255, 210 / 255, 157 / 255
end

local function Font(fs, size)
    local path
    local eui = _G.EllesmereUI
    if eui and eui.GetFontPath then
        local ok, p = pcall(eui.GetFontPath)
        if ok then path = p end
    end
    if not (path and fs:SetFont(path, size, "")) then fs:SetFont(STANDARD_TEXT_FONT, size, "") end
    fs:SetShadowOffset(1, -1)
    fs:SetShadowColor(0, 0, 0, 0.6)
end

local function Text(parent, size, alpha)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    Font(fs, size)
    fs:SetTextColor(1, 1, 1, alpha or 1)
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(false)
    return fs
end

local function Skin(f, bgA, borderA, r, g, b)
    if bgA and bgA > 0 then
        local bg = f:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(r or BG[1], g or BG[2], b or BG[3], bgA)
        f._bg = bg
    end
    f._edges = {}
    for _, d in ipairs({ { "TOPLEFT", "TOPRIGHT", true }, { "BOTTOMLEFT", "BOTTOMRIGHT", true },
                         { "TOPLEFT", "BOTTOMLEFT" }, { "TOPRIGHT", "BOTTOMRIGHT" } }) do
        local t = f:CreateTexture(nil, "BORDER")
        t:SetColorTexture(1, 1, 1, borderA or 0.08)
        t:SetPoint(d[1]); t:SetPoint(d[2])
        if d[3] then t:SetHeight(1) else t:SetWidth(1) end
        f._edges[#f._edges + 1] = t
    end
end

local function Border(f, r, g, b, a) for _, t in ipairs(f._edges) do t:SetColorTexture(r, g, b, a) end end

local function Tip(owner, title, text)
    owner:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(title, 1, 1, 1)
        if text then GameTooltip:AddLine(text, nil, nil, nil, true) end
        GameTooltip:Show()
    end)
    owner:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

local function Button(parent, label, w, h, onClick, tip)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w, h)
    Skin(b, 0.6, 0.15, 0.1, 0.1, 0.1)
    b.text = Text(b, 11, 0.85)
    b.text:SetPoint("CENTER")
    b.text:SetText(label)
    b:SetScript("OnEnter", function(self)
        if not self:IsEnabled() then return end
        local r, g, bl = Accent(); Border(self, r, g, bl, 0.8); self.text:SetTextColor(1, 1, 1, 1)
    end)
    b:SetScript("OnLeave", function(self) Border(self, 1, 1, 1, 0.15); self.text:SetTextColor(1, 1, 1, self:IsEnabled() and 0.85 or 0.3) end)
    b:SetScript("OnClick", onClick)
    b:SetScript("OnEnable", function(self) self.text:SetTextColor(1, 1, 1, 0.85) end)
    b:SetScript("OnDisable", function(self) self.text:SetTextColor(1, 1, 1, 0.3) end)
    if tip then Tip(b, label, tip) end
    return b
end

local function Version(addon)
    local get = (C_AddOns and C_AddOns.GetAddOnMetadata) or _G.GetAddOnMetadata
    return addon and get and get(addon, "Version") or "?"
end

local ROWS, ROW_H = 9, 22
local Refresh

local function Ask(o)
    -- o = { title, text, value, multi, readOnly, okText, onOk(value) }
    local d = win.dialog
    d.title:SetText(o.title)
    d.info:SetText(o.text or "")
    d.single:SetShown(not o.multi)
    d.scroll:SetShown(o.multi and true or false)
    local box = o.multi and d.multi or d.single
    box:SetText(o.value or "")
    d.ok:SetShown(not o.readOnly)
    d.ok.text:SetText(o.okText or "OK")
    d.cancel.text:SetText(o.readOnly and "Close" or "Cancel")
    d.onOk = o.onOk
    d.box = box
    d:Show()
    box:SetFocus()
    box:HighlightText()
end

local function Msg(text) win.status:SetText(text or "") end

local function Build()
    win = CreateFrame("Frame", "DestrozaProfilesFrame", UIParent)
    win:SetSize(600, 400)
    win:SetPoint("CENTER")
    win:SetFrameStrata("HIGH")
    win:SetToplevel(true)
    win:SetClampedToScreen(true)
    win:EnableMouse(true)
    win:SetMovable(true)
    win:RegisterForDrag("LeftButton")
    win:SetScript("OnDragStart", win.StartMoving)
    win:SetScript("OnDragStop", win.StopMovingOrSizing)
    Skin(win, 0.96, 0.08)
    tinsert(UISpecialFrames, "DestrozaProfilesFrame")

    local r, g, b = Accent()
    local title = Text(win, 14, 1)
    title:SetPoint("TOPLEFT", 14, -12)
    title:SetText(("|cff%02x%02x%02xDestroza|r Profiles"):format(r * 255, g * 255, b * 255))

    local close = CreateFrame("Button", nil, win)
    close:SetSize(24, 24)
    close:SetPoint("TOPRIGHT", -6, -6)
    close.text = Text(close, 16, 0.6)
    close.text:SetPoint("CENTER")
    close.text:SetText("x")
    close:SetScript("OnEnter", function(self) self.text:SetTextColor(1, 1, 1, 1) end)
    close:SetScript("OnLeave", function(self) self.text:SetTextColor(1, 1, 1, 0.6) end)
    close:SetScript("OnClick", function() win:Hide() end)

    win.version = Text(win, 10, 0.53)
    win.version:SetPoint("RIGHT", close, "LEFT", -8, 0)
    win.version:SetJustifyH("RIGHT")

    local line = win:CreateTexture(nil, "BORDER")
    line:SetColorTexture(1, 1, 1, 0.08)
    line:SetPoint("TOPLEFT", 1, -38); line:SetPoint("TOPRIGHT", -1, -38); line:SetHeight(1)

    -- left: addons
    local left = CreateFrame("Frame", nil, win)
    left:SetPoint("TOPLEFT", 8, -46)
    left:SetPoint("BOTTOMLEFT", 8, 8)
    left:SetWidth(170)
    Skin(left, 0.25, 0.06, 0, 0, 0)
    win.addonBtns = {}

    -- right: profiles
    local right = CreateFrame("Frame", nil, win)
    right:SetPoint("TOPLEFT", left, "TOPRIGHT", 8, 0)
    right:SetPoint("BOTTOMRIGHT", -8, 8)
    Skin(right, 0.25, 0.06, 0, 0, 0)
    win.right = right

    win.info1 = Text(right, 12, 1)
    win.info1:SetPoint("TOPLEFT", 12, -10)
    win.info2 = Text(right, 11, 0.6)
    win.info2:SetPoint("TOPLEFT", 12, -28)

    local listBox = CreateFrame("Frame", nil, right)
    listBox:SetPoint("TOPLEFT", 10, -48)
    listBox:SetPoint("RIGHT", -10, 0)
    listBox:SetHeight(ROWS * ROW_H + 4)
    Skin(listBox, 0.3, 0.06, 0, 0, 0)
    listBox:EnableMouseWheel(true)
    listBox:SetScript("OnMouseWheel", function(_, delta)
        win.offset = math.max(0, math.min((win.offset or 0) - delta, math.max(0, #win.names - ROWS)))
        Refresh()
    end)
    win.rows = {}
    for i = 1, ROWS do
        local row = CreateFrame("Button", nil, listBox)
        row:SetHeight(ROW_H)
        row:SetPoint("TOPLEFT", 2, -2 - (i - 1) * ROW_H)
        row:SetPoint("RIGHT", -2, 0)
        row.sel = row:CreateTexture(nil, "BACKGROUND")
        row.sel:SetAllPoints()
        row.sel:SetTexture(WHITE8)
        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(1, 1, 1, 0.05)
        row.name = Text(row, 12, 1)
        row.name:SetPoint("LEFT", 8, 0)
        row.tag = Text(row, 11, 1)
        row.tag:SetPoint("RIGHT", -8, 0)
        row.tag:SetJustifyH("RIGHT")
        row:SetScript("OnClick", function(self) win.selected = self.profile; Refresh() end)
        row:SetScript("OnDoubleClick", function(self)
            if lib.Use(win.id, self.profile) then Msg("This character now uses " .. self.profile .. ".") end
            Refresh()
        end)
        win.rows[i] = row
    end

    local function Sel() return win.id, win.selected end
    local bw, bh, gap = 124, 22, 6
    local y0 = -48 - ROWS * ROW_H - 14
    local function Place(btn, col, rowN) btn:SetPoint("TOPLEFT", 10 + (col - 1) * (bw + gap), y0 - (rowN - 1) * (bh + gap)) end

    win.bUse = Button(right, "Use on this character", bw, bh, function()
        local id, s = Sel()
        if s and lib.Use(id, s) then Msg("This character now uses " .. s .. ".") end
        Refresh()
    end, "This character uses the selected profile. Double-click a profile does the same.")
    Place(win.bUse, 1, 1)
    win.bDefault = Button(right, "Set as Default", bw, bh, function()
        local id, s = Sel()
        if s then lib.SetDefault(id, s); Msg(s .. " is the Default for all characters now.") end
        Refresh()
    end, "Every character without its own choice uses this profile - new characters too.")
    Place(win.bDefault, 2, 1)
    win.bFollow = Button(right, "Follow Default", bw, bh, function()
        lib.FollowDefault(win.id); Msg("This character follows the Default again."); Refresh()
    end, "Remove this character's own choice: it uses the Default profile again.")
    Place(win.bFollow, 3, 1)

    win.bNew = Button(right, "New", bw, bh, function()
        local id = win.id
        Ask({ title = "New profile", text = "Name of the new profile (starts with the default settings):",
            value = lib.FreeName(id, "New Profile"), okText = "Create", onOk = function(v)
                if lib.New(id, v) then win.selected = v; Msg("Profile " .. v .. " created.") else Msg("That name is taken.") end
            end })
    end, "A new profile with the addon's default settings.")
    Place(win.bNew, 1, 2)
    win.bCopy = Button(right, "Copy", bw, bh, function()
        local id, s = Sel(); if not s then return end
        Ask({ title = "Copy profile", text = "Name for the copy of " .. s .. ":",
            value = lib.FreeName(id, s), okText = "Copy", onOk = function(v)
                if lib.New(id, v, s) then win.selected = v; Msg("Copied to " .. v .. ".") else Msg("That name is taken.") end
            end })
    end)
    Place(win.bCopy, 2, 2)
    win.bRename = Button(right, "Rename", bw, bh, function()
        local id, s = Sel(); if not s then return end
        Ask({ title = "Rename profile", text = "New name for " .. s .. ":", value = s, okText = "Rename",
            onOk = function(v)
                if v == s then return end
                if lib.Rename(id, s, v) then win.selected = v; Msg("Renamed to " .. v .. ".") else Msg("That name is taken.") end
            end })
    end)
    Place(win.bRename, 3, 2)
    win.bDelete = Button(right, "Delete", bw, bh, function()
        local id, s = Sel(); if not s then return end
        Ask({ title = "Delete profile", text = "Delete " .. s .. "? Characters using it go back to the Default.",
            okText = "Delete", onOk = function()
                if lib.Delete(id, s) then win.selected = nil; Msg(s .. " deleted.") end
            end })
        win.dialog.single:ClearFocus()
        win.dialog.single:Hide()
    end, "The Default profile cannot be deleted - set another one as Default first.")
    Place(win.bDelete, 1, 3)
    win.bExport = Button(right, "Export", bw, bh, function()
        local id, s = Sel(); if not s then return end
        Ask({ title = "Export " .. s, text = "Ctrl+A, Ctrl+C to copy. Import it on another account or PC.",
            value = lib.Export(id, s), multi = true, readOnly = true })
    end)
    Place(win.bExport, 2, 3)
    win.bImport = Button(right, "Import", bw, bh, function()
        local id = win.id
        Ask({ title = "Import profile", text = "Paste a profile string (Ctrl+V):", multi = true, okText = "Import",
            onOk = function(v)
                local pid, name, data = lib.Decode(v)
                if not pid then Msg(name); return end
                if pid ~= id then
                    Msg(("That is a profile for %s, not %s."):format(lib.Title(pid), lib.Title(id)))
                    return
                end
                C_Timer.After(0, function()
                    Ask({ title = "Import profile", text = "Name for the imported profile:",
                        value = lib.FreeName(id, name), okText = "Import", onOk = function(n)
                            if lib.Import(id, n, data) then win.selected = n; Msg("Imported as " .. n .. ".") else Msg("That name is taken.") end
                        end })
                end)
            end })
    end)
    Place(win.bImport, 3, 3)

    win.status = Text(right, 11, 0.7)
    win.status:SetPoint("BOTTOMLEFT", 12, 10)
    win.status:SetPoint("RIGHT", -12, 0)

    -- input overlay
    local d = CreateFrame("Frame", nil, right)
    d:SetAllPoints()
    d:SetFrameLevel(right:GetFrameLevel() + 20)
    d:EnableMouse(true)
    Skin(d, 0.98, 0.1)
    d.title = Text(d, 13, 1)
    d.title:SetPoint("TOPLEFT", 14, -14)
    d.info = Text(d, 11, 0.65)
    d.info:SetPoint("TOPLEFT", 14, -34)
    d.info:SetPoint("RIGHT", -14, 0)
    d.info:SetWordWrap(true)

    local function Box(parent, multi)
        local e = CreateFrame("EditBox", nil, parent)
        e:SetAutoFocus(false)
        e:SetMultiLine(multi)
        Font(e, 12)
        e:SetTextColor(1, 1, 1, 1)
        e:SetTextInsets(6, 6, 4, 4)
        e:SetScript("OnEscapePressed", function() d:Hide() end)
        return e
    end
    d.single = Box(d, false)
    d.single:SetPoint("TOPLEFT", 14, -60)
    d.single:SetPoint("RIGHT", -14, 0)
    d.single:SetHeight(24)
    d.single:SetMaxLetters(40)
    Skin(d.single, 0.5, 0.15, 0, 0, 0)
    d.single:SetScript("OnEnterPressed", function() d.ok:Click() end)

    d.scroll = CreateFrame("ScrollFrame", nil, d)
    d.scroll:SetPoint("TOPLEFT", 14, -60)
    d.scroll:SetPoint("BOTTOMRIGHT", -14, 44)
    Skin(d.scroll, 0.5, 0.15, 0, 0, 0)
    d.multi = Box(d.scroll, true)
    d.multi:SetWidth(380)
    d.scroll:SetScrollChild(d.multi)
    d.scroll:EnableMouse(true)
    d.scroll:SetScript("OnMouseDown", function() d.multi:SetFocus() end)
    d.scroll:SetScript("OnSizeChanged", function(self, w) d.multi:SetWidth(math.max(50, w - 4)) end)

    d.ok = Button(d, "OK", 110, 24, function()
        local v = d.box and d.box:GetText() or ""
        if d.box == d.single then v = strtrim(v) end
        local fn = d.onOk
        d:Hide()
        if fn then fn(v) end
        Refresh()
    end)
    d.ok:SetPoint("BOTTOMRIGHT", -14, 12)
    d.cancel = Button(d, "Cancel", 110, 24, function() d:Hide() end)
    d.cancel:SetPoint("RIGHT", d.ok, "LEFT", -8, 0)
    d:SetScript("OnHide", function() d.single:ClearFocus(); d.multi:ClearFocus() end)
    d:Hide()
    win.dialog = d
    win:SetScript("OnHide", function() d:Hide() end)
end

Refresh = function()
    if not (win and win:IsShown()) then return end
    local r, g, b = Accent()
    -- addon buttons
    for i, id in ipairs(lib.order) do
        local btn = win.addonBtns[i]
        if not btn then
            btn = CreateFrame("Button", nil, win)
            btn:SetHeight(26)
            btn:SetPoint("TOPLEFT", 9, -47 - (i - 1) * 26)
            btn:SetWidth(168)
            btn.sel = btn:CreateTexture(nil, "BACKGROUND")
            btn.sel:SetAllPoints()
            local hl = btn:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetColorTexture(1, 1, 1, 0.05)
            btn.bar = btn:CreateTexture(nil, "OVERLAY")
            btn.bar:SetPoint("TOPLEFT"); btn.bar:SetPoint("BOTTOMLEFT"); btn.bar:SetWidth(2)
            btn.text = Text(btn, 12, 1)
            btn.text:SetPoint("LEFT", 12, 0)
            btn.text:SetPoint("RIGHT", -6, 0)
            btn:SetScript("OnClick", function(self)
                win.id = self.id; win.selected = lib.Active(self.id); win.offset = 0; Msg(""); Refresh()
            end)
            win.addonBtns[i] = btn
        end
        btn.id = id
        btn.text:SetText(lib.Title(id))
        local on = id == win.id
        btn.sel:SetColorTexture(r, g, b, on and 0.12 or 0)
        btn.bar:SetColorTexture(r, g, b, on and 1 or 0)
        btn.text:SetTextColor(1, 1, 1, on and 1 or 0.65)
        btn:Show()
    end

    local id = win.id
    local e = lib.reg[id]
    win.version:SetText(e and ((e.addon or id) .. " v" .. Version(e.addon)) or "")
    if not e then return end
    local active, default, own = lib.Active(id), lib.Default(id), lib.Own(id)
    win.info1:SetText(("This character: |cffffffff%s|r  %s"):format(active or "?",
        own and "|cff9d9d9d(own choice)|r" or "|cff9d9d9d(follows the Default)|r"))
    win.info2:SetText(("Default for all characters: %s - profiles are account-wide."):format(default))

    win.names = lib.List(id)
    if win.selected and not lib.Exists(id, win.selected) then win.selected = nil end
    win.selected = win.selected or active
    win.offset = math.max(0, math.min(win.offset or 0, math.max(0, #win.names - ROWS)))
    for i, row in ipairs(win.rows) do
        local name = win.names[i + win.offset]
        row.profile = name
        if name then
            row.name:SetText(name)
            local tags = {}
            if name == default then tags[#tags + 1] = ("|cff%02x%02x%02xDefault|r"):format(r * 255, g * 255, b * 255) end
            if name == active then tags[#tags + 1] = "|cffffffffactive|r" end
            row.tag:SetText(table.concat(tags, "  "))
            row.sel:SetColorTexture(r, g, b, name == win.selected and 0.18 or 0)
            row:Show()
        else
            row:Hide()
        end
    end
    local s = win.selected
    win.bUse:SetEnabled(s ~= nil and s ~= active)
    win.bDefault:SetEnabled(s ~= nil and s ~= default)
    win.bFollow:SetEnabled(own ~= nil)
    win.bCopy:SetEnabled(s ~= nil)
    win.bRename:SetEnabled(s ~= nil)
    win.bDelete:SetEnabled(s ~= nil and s ~= default)
    win.bExport:SetEnabled(s ~= nil)
end
lib.Refresh = Refresh

function lib.Open(id)
    if not win then Build() end
    if id and lib.reg[id] then
        if win.id ~= id then win.offset = 0; win.selected = nil end
        win.id = id
    end
    win.id = win.id or lib.order[1]
    win:Show()
    win:Raise()
    Msg("")
    Refresh()
end

function lib.Toggle(id)
    if win and win:IsShown() and (not id or win.id == id) then win:Hide() else lib.Open(id) end
end
