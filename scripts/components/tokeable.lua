--- dehydrater.lua --
------------------------------------------------------
-- Type: Component
-- Description: Defines the tokeable component action, which is the guts of the TOKE action.
-- A lot of this is based on the "playable" action used by instruments since that's what the pipe animation is based off of. 
------------------------------------------------------

-- Return hunger to normal when the debuff ends (are you sure this works??)
local function EndDebuff(stoner)
	stoner.components.hunger:DoDelta(stoner.components.hunger.burnrate*(-stoner.components.hunger.hungerrate))
end

-- Create a custom tokeable class
local Tokeable = Class(
	function(self, inst)
    	self.inst = inst
		--self.range = 15
    	--self.onheard = nil
		self.sanityboost = nil

		-- Hard code the hunger debuff. May want to revist this.
		self.hungerdebuff = 3
	
	end,
	nil,
	{}
)

-- Set the sanity boost amount. 
function Tokeable:SetSanityBoost(sanitydelta)
	self.sanityboost = sanitydelta
end

-- What to do when the item is smoked
function Tokeable:bowlHit(stoner)

	--I added this when I was trying to get the bowl animation to work and I'm not sure if I still need it. It's also kind of a placeholder for the AOE effect I considered giving the joints.
	--local pos = Vector3(stoner.Transform:GetWorldPosition())
	--local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, self.range)
	--for k,v in pairs(ents) do
	--	if v ~= self.inst and self.onheard then
	--		self.onheard(v, stoner, self.inst)
	--	end
	--end
	
	-- One-time sanity boost
	stoner.components.sanity:DoDelta(self.sanityboost)

	-- Increase rate of hunger (debuff)
	stoner.components.hunger:DoDelta(self.hungerdebuff*(-stoner.components.hunger.hungerrate))

	-- Define how long high state lasts
	local hightime = TUNING.TOTAL_DAY_TIME/2

	-- Create a task to end the debuff 
	self.targettime = GetTime() + hightime
	self.task = self.inst:DoTaskInTime(hightime, EndDebuff(stoner))
	
	return true	
end

return Tokeable
