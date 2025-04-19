--- dehydrater.lua --
------------------------------------------------------
-- Type: Component
-- Description: Define what make something a dehydrater
--------------------------------------------------------------------------------------------------------

-- Create an empty array with a "weed_dried" element containing "tags"
local dried_products = {}
dried_products["weed_dried"] = { tags = {}}

-- I think this primes the dehydrater after it's finished and emptied?
local function DoDehydrate(inst)
	local dehydrater = inst.components.dehydrater
	dehydrater.task = nil
    
    -- Force the time to be done in case it's out of sync (also triggers ondried) huh?
    dehydrater.targettime = GetTime() - 1
    
    -- huh? seems like a mess
	if dehydrater.ondonecooking then
		dehydrater.ondonecooking(inst, dehydrater.product)
	end
	dehydrater.done = true
	dehydrater.product = nil
	dehydrater.cooking = nil
	inst.components.container.canbeopened = true
end

-- What to do when dehydrating is done
local function ondone(self, done)
    
    -- If done == true then add the donedrying flag
    if done then
		self.inst:AddTag("donedrying")
    
    -- If done != true then remove the donedrying tag (if it exists)
    else
        self.inst:RemoveTag("donedrying")

       -- -- Some old cruff I dont even remember  
       -- if self.targettime ~= nil and self.targettime >= time then
       --     self.inst:AddTag("dehydrating")
       --     self.inst:RemoveTag("readytodry")
       -- else
        --    self.inst:RemoveTag("dehydrating")
        --    self.inst:AddTag("readytodry")
      --  end
    end
end

-- If the dehydrater is ready to go, add the readytodry tag
local function oncheckready(inst)
    if inst.components.dehydrater:ReadyToStart() then
        inst:AddTag("readytodry")
    end
end

-- If an item is removed from the dehydrater, remove the readytodry flag
local function onitemlose(inst)
	inst:RemoveTag("readytodry")

	-- If the dehydrater is finished and all items are removed, set done == nil
	if inst.components.dehydrater.done and inst.components.container:IsEmpty() then 
		inst.components.dehydrater.done = nil
	end
end

-- If the dehydrator is not ready, remove the ready to dry tag
local function onnotready(inst)
    inst:RemoveTag("readytodry")
end

-- Create a custom class for the dehydrater
local Dehydrater = Class(
	function(self, inst)
    	self.inst = inst
		self.cooking = false
    	self.done = true
    	self.targettime = nil
    	self.ingredient = nil
    	self.product = nil
		self.productTable = {}
    	self.onstartcooking = nil
    	self.oncontinuecooking = nil
    	self.ondonecooking = nil
    	self.oncontinuedone = nil
		self.dried_products = dried_products

		-- Listen for events
		inst:ListenForEvent("itemget", oncheckready)
    	inst:ListenForEvent("onclose", oncheckready)
    	inst:ListenForEvent("itemlose", onitemlose)
    	inst:ListenForEvent("onopen", onnotready)


	end,
	nil,
	{
		done = ondone,
	}
)

-- Start dehydrating
function Dehydrater:SetStartDryingFn(fn)
    self.onstartcooking = fn
end

-- Currently dehydrating
function Dehydrater:SetContinueDryingFn(fn)
    self.oncontinuecooking = fn
end

-- Stop dehydrating
function Dehydrater:SetDoneDryingFn(fn)
    self.ondonecooking = fn
end

-- Dehydrating finished
function Dehydrater:SetContinueDoneFn(fn)
    self.oncontinuedone = fn
end

-- Get time left to dehydrate
function Dehydrater:GetTimeToDry()
	if self.targettime then
		return self.targettime - GetTime()
	end
	return 0
end

-- Check if dehydrater is working
function Dehydrater:IsDrying()
    return self.targettime ~= nil and self.targettime >= GetTime()
end

-- Check if dehydrater is done
function Dehydrater:IsDone()
    return self.product ~= nil and self.targettime ~= nil and self.targettime < GetTime()
end

-- Check if items are dehydratable
function Dehydrater:ItemTest(item)
	if item.components.dehydratable or self.dried_products[item.prefab] then
		return true
    end
end

-- Check if dehydrater is ready to start
function Dehydrater:ReadyToStart()

	-- If container is not empty and full (seems redundant) of raw ingredients then return ready
	if self.inst.components.container ~= nil then
		local ready = true
		--for k,v in pairs (self.inst.components.container.slots) do
		--	if v and self.dried_products[v.prefab] then
		--		ready = false
		--	end
		--end
		return ready
	end
end		

-- Dehydrate the shit
function Dehydrater:StartDrying()

	-- If the dehydrater isn't done or cooking
	if self.done and not self.cooking then

		-- Now cooking
		self.done = nil
		self.cooking = true

		-- huh?
		if self.onstartcooking then
			self.onstartcooking(self.inst)
		end
	
		-- What in the fuck is an ing?
		local ings = {}

		-- Check each slot's current product and replace it with the dried counterpart
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

		-- Set the base cook time
		local cooktime = TUNING.BASE_COOK_TIME

		-- Figure out the cook time
		self.targettime = GetTime() + cooktime

		-- Define the actual task
		self.task = self.inst:DoTaskInTime(cooktime, DoDehydrate)

		-- Close the dehydrater and prevent it from being opened
		self.inst.components.container:Close()
		self.inst.components.container.canbeopened = false

	end
end

-- Save the dehydrater state
function Dehydrater:OnSave()

	-- If something's dehydrating, save the contents and time to completion 
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

	-- If the dehydrater is finished, save the contents
    elseif self.done then
		local data = {}
		data.product = self.product
		--data.product_spoilage = self.product_spoilage
		data.done = true
		return data		
    end
end

-- Load the dehydrater state
function Dehydrater:OnLoad(data)

	-- If something was dehydrating, return it to that state
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

	-- If dehydrater was done, return any contents it had
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

-- Define inspect tool tips and target time
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

-- Define a long update (whatever the hell that is)
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