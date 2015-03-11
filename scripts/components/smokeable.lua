local Smokeable = Class(function(self, inst)
	self.inst = inst
end)

function Smokeable:CollectInventoryActions(doer, actions)
	table.insert(actions, ACTIONS.SMOKEPIPE)

end

return Smokeable