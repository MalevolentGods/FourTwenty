--This was originally the dryer component file and will be the template for new dehydrater component
--------------------------------------------------------------------------------------------------------

--Most references to "dry" have been replaced with "dehydrate" except for the internal functions which I want to leave as is, at least for now, for testing purposes
local dried_products = {}
dried_products["weed_dried"] = { tags = {}}


local function DoDehydrate(inst)
	local dehydrater = inst.components.dehydrater
	dehydrater.task = nil
    --Force the time to be done in case it's out of sync
    --(also triggers ondried)
    dehydrater.targettime = GetTime() - 1
    
	if dehydrater.ondonecooking then
		dehydrater.ondonecooking(inst, dehydrater.product)
	end
	dehydrater.done = true
	dehydrater.product = nil
	dehydrater.cooking = nil
	inst.components.container.canbeopened = true
end

local function ondone(self, done)
    --local time = GetTime()
    if done then
		self.inst:AddTag("donedrying")
    else
        self.inst:RemoveTag("donedrying")
       -- if self.targettime ~= nil and self.targettime >= time then
       --     self.inst:AddTag("dehydrating")
       --     self.inst:RemoveTag("readytodry")
       -- else
        --    self.inst:RemoveTag("dehydrating")
        --    self.inst:AddTag("readytodry")
      --  end
    end
end

local function oncheckready(inst)
    if inst.components.dehydrater:ReadyToStart() then
        inst:AddTag("readytodry")
    end
end

local function onitemlose(inst)
	inst:RemoveTag("readytodry")
	if inst.components.dehydrater.done and inst.components.container:IsEmpty() then 
		inst.components.dehydrater.done = nil
	end
end

local function onnotready(inst)
    inst:RemoveTag("readytodry")
end

local Dehydrater = Class(function(self, inst)
    self.inst = inst
	self.cooking = false
    self.done = false
    self.targettime = nil
    self.ingredient = nil
    self.product = nil
	self.productTable = {}
    self.onstartcooking = nil
    self.oncontinuecooking = nil
    self.ondonecooking = nil
    self.oncontinuedone = nil
	self.dried_products = dried_products
	
	
	
    inst:ListenForEvent("itemget", oncheckready)
    inst:ListenForEvent("onclose", oncheckready)

    inst:ListenForEvent("itemlose", onitemlose)
    inst:ListenForEvent("onopen", onnotready)
	
end,
nil,
{
	done = ondone,
	
    --targettime = ondried,
    --product = ondried,
})


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

function Dehydrater:ItemTest(item)
	if item.components.dehydratable or self.dried_products[item.prefab] then
		return true
    end
end

function Dehydrater:ReadyToStart()
	if self.inst.components.container ~= nil and self.inst.components.container:IsFull() then
		local ready = true
		for k,v in pairs (self.inst.components.container.slots) do
			if v and self.dried_products[v.prefab] then
				ready = false
			end
		end
		return ready
	end
end		

function Dehydrater:StartDrying()
	if not self.done and not self.cooking then
		if self.inst.components.container then
		
		self.done = nil
		self.cooking = true
				
		if self.onstartcooking then
			self.onstartcooking(self.inst)
		end
	
		local ings = {}		
		for k,v in pairs (self.inst.components.container.slots) do
			table.insert(ings, v.prefab)
			if v.components.dehydratable then
				self.product = v.components.dehydratable:GetProduct()
				local prod = SpawnPrefab(self.product)
				self.inst.components.container:RemoveItemBySlot(k)
				--self.inst.components.container.slots[k] = prod
				self.inst.components.container:GiveItem(prod,k,nil,false)
				
			end
		end
		local cooktime = TUNING.BASE_COOK_TIME
		self.targettime = GetTime() + cooktime
		self.task = self.inst:DoTaskInTime(cooktime, DoDehydrate)	
		self.inst.components.container:Close()
		self.inst.components.container.canbeopened = false
		end
	end
end


function Dehydrater:OnSave() 
    if self.cooking then
		local data = {}
		data.cooking = true
		data.product = self.product
		--data.product_spoilage = self.product_spoilage
		local time = GetTime()
		if self.targettime and self.targettime > time then
			data.time = self.targettime - time
		end
		return data
    elseif self.done then
		local data = {}
		data.product = self.product
		--data.product_spoilage = self.product_spoilage
		data.done = true
		return data		
    end
end

function Dehydrater:OnLoad(data)
    if data.cooking then
		self.product = data.product
		if self.oncontinuecooking then
			local time = data.time or 1
			--self.product_spoilage = data.product_spoilage or 1
			self.oncontinuecooking(self.inst)
			self.cooking = true
			self.targettime = GetTime() + time
			self.task = self.inst:DoTaskInTime(time, DoDehydrate)
			
			if self.inst.components.container then		
				self.inst.components.container.canbeopened = false
			end
			
		end
    elseif data.done then
		--self.product_spoilage = data.product_spoilage or 1
		self.done = true
		self.product = data.product
		if self.oncontinuedone then
			self.oncontinuedone(self.inst)
		end
		if self.inst.components.container then		
			self.inst.components.container.canbeopened = true
		end
		
    end
end

function Dehydrater:GetDebugString()
    local str = nil
    
	if self:IsDrying() then 
		str = "DEHYDRATING" 
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

function Dehydrater:LongUpdate(dt)
	if self:IsDrying() then
		if self.task then
			self.task:Cancel()
			self.task = nil
		end

		local time_to_wait = self.targettime - GetTime() - dt
		if time_to_wait <= 0 then
			self.targettime = GetTime()
			DoDehydrate(self.inst)
		else
			self.targettime = GetTime() + time_to_wait
			self.task = self.inst:DoTaskInTime(time_to_wait, DoDehydrate)
		end


	end
end

return Dehydrater