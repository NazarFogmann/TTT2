---
---@class SPRINT
SPRINT = {
	-- Set up ConVars
	convars = {
		-- @realm shared
		enabled = CreateConVar("ttt2_sprint_enabled", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "Toggle Sprint (Def: 1)"),
		-- @realm shared
		multiplier = CreateConVar("ttt2_sprint_max", "0.5", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "The speed modifier the player will receive. Will be added on top of 1, so 0.5 => 1.5 speed. (Def: 0.5)"),
		-- @realm shared
		consumption = CreateConVar("ttt2_sprint_stamina_consumption", "0.6", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "The speed of the stamina consumption (per second; Def: 0.6)"),
		-- @realm shared
		regeneration = CreateConVar("ttt2_sprint_stamina_regeneration", "0.3", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "The regeneration time of the stamina (per second; Def: 0.3)"),
		-- @realm shared
		showCrosshair = CreateConVar("ttt2_sprint_crosshair", "0", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "Should the Crosshair be visible while sprinting? (Def: 0)"),
	},
}

---
-- Checks if the player is pressing any movement keys and the sprint key at the same time.
-- @param Player ply
-- @return boolean
-- @realm shared
function SPRINT:PlayerWantsToSprint(ply)
	local isSprinting = ply:KeyDown(IN_SPEED)
	local inMovement = ply:KeyDown(IN_FORWARD)
		or ply:KeyDown(IN_BACK)
		or ply:KeyDown(IN_MOVERIGHT)
		or ply:KeyDown(IN_MOVELEFT)

	return isSprinting and inMovement
end

---
-- Checks if the player wants to sprint and actually can sprint.
-- @param Player ply
-- @return boolean
-- @realm shared
function SPRINT:IsSprinting(ply)
	return self.convars.enabled:GetBool() and self:PlayerWantsToSprint(ply) and ply:GetStamina() > 0
end

---
-- Calculates the new stamina values for a given player.
-- @param Player ply
-- @realm shared
function SPRINT:HandleStaminaCalculation(ply)
	local staminaRegeneratonRate = self.convars.regeneration:GetFloat()
	local staminaConsumptionRate = self.convars.consumption:GetFloat()

	local sprintStamina = ply:GetStamina()
	local playerWantsToSprint = self:PlayerWantsToSprint(ply)

	if (sprintStamina == 1 and not playerWantsToSprint) or (sprintStamina == 0 and playerWantsToSprint) then
		return
	end

	-- Note: This is a table, because it is passed by reference and multiple addons can adjust the value.
	local rateModifier = { 1 }
	local newStamina = 0

	if playerWantsToSprint then
		---
		-- @realm shared
		hook.Run("TTT2StaminaDrain", ply, rateModifier)

		newStamina = math.max(sprintStamina - FrameTime() * rateModifier[1] * staminaConsumptionRate, 0)
	else
		---
		-- @realm shared
		hook.Run("TTT2StaminaRegen", ply, rateModifier)

		local tarkovFactor = math.max(0, math.min(ply:Health() / 100, 1.0 - ply:GetNWInt("EffectAMT")))

		newStamina = math.Clamp(sprintStamina + FrameTime() * rateModifier[1] * staminaRegeneratonRate, 0, tarkovFactor)
	end

	ply:SetStamina(newStamina)
end

---
-- Calculates the sprint speed multiplier value for a given player.
-- @param Player ply
-- @realm shared
function SPRINT:HandleSpeedMultiplierCalculation(ply)
	if not self:IsSprinting(ply) then
		return 1
	end

	local sprintMultiplierModifier = { 1 }

	---
	-- @realm shared
	hook.Run("TTT2PlayerSprintMultiplier", ply, sprintMultiplierModifier)

	return (1 + self.convars.multiplier:GetFloat()) * sprintMultiplierModifier[1]
end

---
-- A hook that is called once every frame/tick to modify the stamina regeneration.
-- @note This hook is predicted and should be therefore run on both server and client.
-- @param Player ply The player whose modifier should be set
-- @param table modifierTbl The table in which the modifier can be changed
-- @hook
-- @realm shared
function GM:TTT2StaminaRegen(ply, modifierTbl) 
	
end

---
-- A hook that is called once every frame/tick to modify the stamina drain.
-- @note This hook is predicted and should be therefore run on both server and client.
-- @param Player ply The player whose modifier should be set
-- @param table modifierTbl The table in which the modifier can be changed
-- @hook
-- @realm shared
function GM:TTT2StaminaDrain(ply, modifierTbl) 

end

local CMoveData = FindMetaTable("CMoveData")

function CMoveData:RemoveKeys(keys)
    local newbuttons = bit.band(self:GetButtons(), bit.bnot(keys))
    self:SetButtons(newbuttons)
end

hook.Add("SetupMove", "Nerf Jump", function(ply, mv)
    if ply:OnGround() and mv:KeyPressed(IN_JUMP) then

		local stamina = ply:GetStamina()

		if stamina < 0.25 then
			mv:RemoveKeys(IN_JUMP)
			return
		end

        ply:SetJumpPower(math.max(120, 160 * stamina))

		if SERVER then
			ply:SetStamina(math.max(stamina - 0.2, 0))
		end
	end
end)