--- dehydratable.lua ---
------------------------------------------------------
-- Type: Component
-- Description: Define what makes something 'dehydratable'
------------------------------------------------------

-- If the item is able to be dehydrated, give it the proper tag
local function ondryable(self)
    if self.product ~= nil and self.drytime ~= nil then
        self.inst:AddTag("dehydratable")
    end
end

-- Create a custom dehydratable class
local Dehydratable = Class(
    function(self, inst)
        self.inst = inst
        self.product = nil
        self.drytime = nil
    end,
    nil,
    {
        product = ondryable,
        drytime = ondryable,
    }
)

-- Define the product of dehydration
function Dehydratable:SetProduct(product)
    self.product = product
end

-- Check what product will dehydrtate into
function Dehydratable:GetProduct()
	return self.product
end

-- Check the dryin gtime
function Dehydratable:GetDryingTime()
    return self.drytime
end

-- Define the drying time
function Dehydratable:SetDryTime(time)
    self.drytime = time
end

return Dehydratable