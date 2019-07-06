local surface = surface

-- Fonts
surface.CreateAdvancedFont("PureSkinMSTACKImageMsg", {font = "Trebuchet24", size = 21, weight = 1000})
surface.CreateAdvancedFont("PureSkinMSTACKMsg", {font = "Trebuchet18", size = 15, weight = 900})
surface.CreateAdvancedFont("PureSkinRole", {font = "Trebuchet24", size = 30, weight = 700})
surface.CreateAdvancedFont("PureSkinBar", {font = "Trebuchet24", size = 21, weight = 1000})
surface.CreateAdvancedFont("PureSkinWep", {font = "Trebuchet24", size = 21, weight = 1000})
surface.CreateAdvancedFont("PureSkinWepNum", {font = "Trebuchet24", size = 21, weight = 700})
surface.CreateAdvancedFont("PureSkinItemInfo", {font = "Trebuchet24", size = 14, weight = 700})
surface.CreateAdvancedFont("PureSkinTimeLeft", {font = "Trebuchet24", size = 24, weight = 800})

-- base drawing functions
include("cl_drawing_functions.lua")

local base = "scalable_hud"

DEFINE_BASECLASS(base)

HUD.Base = base

HUD.previewImage = Material("vgui/ttt/huds/pure_skin/preview.png")

function HUD:Initialize()
	self:ForceElement("pure_skin_playerinfo")
	self:ForceElement("pure_skin_roundinfo")
	self:ForceElement("pure_skin_wswitch")
	self:ForceElement("pure_skin_drowning")
	self:ForceElement("pure_skin_mstack")
	self:ForceElement("pure_skin_sidebar")
	self:ForceElement("pure_skin_miniscoreboard")
	self:ForceElement("pure_skin_punchometer")
	self:ForceElement("pure_skin_target")
	self:ForceElement("pure_skin_pickup")
	self:ForceElement("pure_skin_teamindicator")

	BaseClass.Initialize(self)
end

-- Voice overriding
include("cl_voice.lua")

-- Popup overriding
include("cl_popup.lua")
