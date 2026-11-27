-- Destroza Dungeon Tracker - RestedXP / Naowh compatibility
-- Naowh Forever skins RestedXP's waypoint arrow by hooking a method
-- "UpdateVisuals" on RXPG_ARROW. Current RestedXP builds (4.11.39 and later)
-- don't have that method any more: Naowh's hook throws at login, and the rest
-- of Naowh's RestedXP skin (banners, frame, rules, guide window) is never set
-- up -- the skin looks reset after every restart.
-- This gives the arrow an empty UpdateVisuals and calls it whenever RestedXP
-- repaints the arrow (UpdateSubTheme), which is when Naowh wants to know.
-- The same for the targeting module's RenderTargetFrameBackground, which
-- Naowh's guide-window skin hooks (called here after the module's UpdateTheme).
-- Does nothing once RestedXP has the methods again. Naowh is not changed.
local arrow = _G.RXPG_ARROW
if type(arrow) == "table" and type(arrow.UpdateVisuals) ~= "function" then
    arrow.UpdateVisuals = function() end
    if type(arrow.UpdateSubTheme) == "function" then
        hooksecurefunc(arrow, "UpdateSubTheme", function(self)
            local ok, err = pcall(self.UpdateVisuals, self)
            if not ok then geterrorhandler()(err) end
        end)
    end
end

local rxp = _G.RXP
local targeting = type(rxp) == "table" and rxp.targeting
if type(targeting) == "table" and type(targeting.RenderTargetFrameBackground) ~= "function" then
    targeting.RenderTargetFrameBackground = function() end
    if type(targeting.UpdateTheme) == "function" then
        hooksecurefunc(targeting, "UpdateTheme", function(self)
            local ok, err = pcall(self.RenderTargetFrameBackground, self)
            if not ok then geterrorhandler()(err) end
        end)
    end
end
