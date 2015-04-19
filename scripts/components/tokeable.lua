--This script defines the tokeable component action, which is the guts of the TOKE action that we created in the modmain file.
--This is all still a work in progress as I try to figure shit out. A lot of it is based on the "playable" action used by instruments since that's what the pipe animation is based off of. 
--Long story short: some of this can be removed and more will be added when the joint gets created.
--------------------------------------------------------------------------------------------------------------------

local function EndDebuff(stoner)
	stoner.components.hunger:DoDelta(stoner.components.hunger.burnrate*(-stoner.components.hunger.hungerrate))
end


local Tokeable = Class(
	function(self, inst)
    	self.inst = inst

		--self.range = 15
    	--self.onheard = nil
		self.sanityboost = nil
		self.hungerdebuff = 3
	
	end,
	nil,
	{}
)



function Tokeable:SetSanityBoost(sanitydelta)
	self.sanityboost = sanitydelta
end


function Tokeable:bowlHit(stoner)
	--I added this when I was trying to get the bowl animation to work and I'm not sure if I still need it. It's also kind of a placeholder for the AOE effect I considered giving the joints.
	--local pos = Vector3(stoner.Transform:GetWorldPosition())
	--local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, self.range)
	--for k,v in pairs(ents) do
	--	if v ~= self.inst and self.onheard then
	--		self.onheard(v, stoner, self.inst)
	--	end
	--end
	
	stoner.components.sanity:DoDelta(self.sanityboost)
	stoner.components.hunger:DoDelta(self.hungerdebuff*(-stoner.components.hunger.hungerrate))
	local hightime = TUNING.TOTAL_DAY_TIME/2
	self.targettime = GetTime() + hightime
	self.task = self.inst:DoTaskInTime(hightime, EndDebuff(stoner))
	return true	
end

return Tokeable
