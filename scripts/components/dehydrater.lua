--This was originally the dryer component file and will be the template for new dehydrater component
--------------------------------------------------------------------------------------------------------

--Most references to "dry" have been replaced with "dehydrate" except for the internal functions which I want to leave as is, at least for now, for testing purposes

local function DoDehydrate(inst)
    local dehydrater = inst.components.dehydrater
    if dehydrater then
	    dehydrater.task = nil
        --Force the time to be done in case it's out of sync
        --(also triggers ondried)
        dehydrater.targettime = GetTime() - 1
    	
	    if dehydrater.ondonecooking then
		    dehydrater.ondonecooking(inst, dehydrater.product)
	    end
    end
end

local function ondried(self)
    local time = GetTime()
    if self.product ~= nil and self.targettime ~= nil and self.targettime < time then
        self.inst:AddTag("dehydrated")
        self.inst:RemoveTag("dehydrating")
        self.inst:RemoveTag("candry")
    else
        self.inst:RemoveTag("dehydrated")
        if self.targettime ~= nil and self.targettime >= time then
            self.inst:AddTag("dehydrating")
            self.inst:RemoveTag("candry")
        else
            self.inst:RemoveTag("dehydrating")
            self.inst:AddTag("candry")
        end
    end
end

local Dehydrater = Class(function(self, inst)
    self.inst = inst
    inst:AddTag("candry")
    self.targettime = nil
    self.ingredient = nil
    self.product = nil
    self.onstartcooking = nil
    self.oncontinuecooking = nil
    self.ondonecooking = nil
    self.oncontinuedone = nil
    self.onharvest = nil
end,
nil,
{
    targettime = ondried,
    product = ondried,
})

function Dehydrater:OnRemoveFromEntity()
    self.inst:RemoveTag("dehydrated")
    self.inst:RemoveTag("dehydrating")
    self.inst:RemoveTag("candry")
end

function Dehydrater:SetStartDryingFn(fn)
    self.onstartcooking = fn
end

function Dehydrater:SetContinueDryingFn(fn)
    self.oncontinuecooking = fn
end

function Dehydrater:SetDoneDryingFn(fn)
    self.ondonecooking = fn
end

function Dehydrater:SetContinueDoneFn(fn)
    self.oncontinuedone = fn
end

function Dehydrater:SetOnHarvestFn(fn)
    self.onharvest = fn
end

function Dehydrater:GetTimeToDry()
	if self.targettime then
		return self.targettime - GetTime()
	end
	return 0
end

function Dehydrater:IsDrying()
    return self.targettime ~= nil and self.targettime >= GetTime()
end

function Dehydrater:IsDone()
    return self.product ~= nil and self.targettime ~= nil and self.targettime < GetTime()
end

function Dehydrater:CanDry(dehydratable)
    return self.inst:HasTag("candry") and dehydratable:HasTag("dehydratable")
end

function Dehydrater:StartDrying(dehydratable)
	if self:CanDry(dehydratable) then
	    self.ingredient = dehydratable.prefab
	    if self.onstartcooking then
		    self.onstartcooking(self.inst, dehydratable.prefab)
	    end
	    local cooktime = dehydratable.components.dehydratable:GetDryingTime()
	    self.product = dehydratable.components.dehydratable:GetProduct()
	    self.targettime = GetTime() + cooktime
	    self.task = self.inst:DoTaskInTime(cooktime, DoDehydrate)
	    dehydratable:Remove()
		return true
	end
end

function Dehydrater:OnSave()
    
    if self:IsDrying() then
		local data = {}
		data.cooking = true
		data.ingredient = self.ingredient
		data.product = self.product
		data.time = self:GetTimeToDry()
		return data
    elseif self:IsDone() then
		local data = {}
		data.product = self.product
		data.done = true
		return data		
    end
end

function Dehydrater:OnLoad(data)
    --self.produce = data.produce
    if data.cooking then
		self.product = data.product
		self.ingredient = data.ingredient
		if self.oncontinuecooking then
			self.oncontinuecooking(self.inst, self.ingredient)
			self.targettime = GetTime() + data.time
			self.task = self.inst:DoTaskInTime(data.time, DoDehydrate)
		end
    elseif data.done then
		self.targettime = GetTime() - 1
		self.product = data.product
		if self.oncontinuedone then
			self.oncontinuedone(self.inst, self.product)
		end
    end
end

function Dehydrater:GetDebugString()
    local str = nil
    
	if self:IsDrying() then 
		str = "COOKING" 
	elseif self:IsDone() then
		str = "FULL"
	else
		str = "EMPTY"
	end
    if self.targettime then
        str = str.." ("..tostring(self.targettime - GetTime())..")"
    end
    
    if self.product then
		str = str.. " ".. self.product
    end
    
	return str
end

function Dehydrater:Harvest( harvester )
	if self:IsDone() then
		if self.onharvest then
			self.onharvest(self.inst)
		end
		if self.product then
			if harvester and harvester.components.inventory then
				local loot = SpawnPrefab(self.product)
				if loot then
					if loot and loot.components.perishable then
					    loot.components.perishable:SetPercent(1) --always full perishable
					end
					harvester.components.inventory:GiveItem(loot, nil, self.inst:GetPosition())
				end
			end
			self.product = nil
		end
		
		return true
	end
end

function Dehydrater:LongUpdate(dt)
	if self:IsDrying() then
		if self.task then
			self.task:Cancel()
			self.task = nil
		end

		local time_to_wait = self.targettime - GetTime() - dt
		if time_to_wait <= 0 then
			self.targettime = GetTime()
			DoDehydrat(self.inst)
		else
			self.targettime = GetTime() + time_to_wait
			self.task = self.inst:DoTaskInTime(time_to_wait, DoDehydrat)
		end


	end
end

return Dehydrater