--This was originally the dryable component file and will be the template for new dehydratable component
--------------------------------------------------------------------------------------------------------


local function ondryable(self)
    if self.product ~= nil and self.drytime ~= nil then
        self.inst:AddTag("dehydratable")
    else
        self.inst:RemoveTag("dehydratable")
    end
end

local Dehydratable = Class(function(self, inst)
    self.inst = inst
    self.product = nil
    self.drytime = nil
end,
nil,
{
    product = ondryable,
    drytime = ondryable,
})

function Dehydratable:OnRemoveFromEntity()
    self.inst:RemoveTag("dehydratable")
end

function Dehydratable:SetProduct(product)
    self.product = product
end

function Dehydratable:GetProduct()
    return self.product
end

function Dehydratable:GetDryingTime()
    return self.drytime
end

function Dehydratable:SetDryTime(time)
    self.drytime = time
end

return Dehydratable