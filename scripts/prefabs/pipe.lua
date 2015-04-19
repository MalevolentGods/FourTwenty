--This script creates and defines the pipe prefab
------------------------------------------------------


--These are basically the custom animations and graphics that we're loading for the prefab
local assets =
{

  	Asset("ANIM", "anim/pipe.zip"),
   	Asset("ANIM", "anim/swap_pipe.zip"),
   	Asset("ATLAS", "images/inventoryimages/pipe.xml"),
   	Asset("IMAGE", "images/inventoryimages/pipe.tex"),
}

--What to do when equipping the pipe
local function OnEquip(inst, owner)
	
	--Use the bank swap_pipe's symbol named "swap_pipe" in place of the "swap_object" symbol. 
    owner.AnimState:OverrideSymbol("swap_object", "swap_pipe", "swap_pipe")

	--Hide the normal arm animation state and show the carry animation (using the symbol defined above) 
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")

end

--What to do when un-equipping the pipe
local function OnUnequip(inst, owner)
	
	--Hide the carry arm animation state and show the normal arm animation state
   	owner.AnimState:Hide("ARM_carry")
   	owner.AnimState:Show("ARM_normal")
end

--What to do when the pipe is used up
local function onfinished(inst)

	--Remove the item from your inventory
    inst:Remove()
end

--This function defines the pipe.
--I have no idea what the "Sim" variable inside the function is used for.
local function fn(Sim)

    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    	
	MakeInventoryPhysics(inst)
    
	--Set the bank to "pipe" (pipe.zip) set the build to "pipe" and play the animation named "idle""
	inst.AnimState:SetBank("pipe")
    inst.AnimState:SetBuild("pipe")
    inst.AnimState:PlayAnimation("idle")

	--Needed for multiplayer
	if not TheWorld.ismastersim then
		return inst
    end

    inst.entity:SetPristine()
	
	--Make the item inspectable
    inst:AddComponent("inspectable")
	
	--I had to add hunger and health to give the equip-based debuff. This is temporary until I figure out a way to make it a debuff over time
	inst:AddComponent("hunger")
	inst:AddComponent("health")
	
	--Make the item something that can be put in your inventory
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "pipe"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/pipe.xml"
	
	--Not sure if we still need this but I haven't tested. Might be required for playing horn animation.
    inst:AddTag("horn")

	--Same as the tag. Might be neccessary for horn animation and/or HORN tuning paramaters below.
    inst:AddComponent("instrument")
	 
	--This is our custom "tokeable" component 
    inst:AddComponent("tokeable")

	--Gives the item a finite number of uses and sets the values for how many uses, what to do when it's used and what to do when it's out of uses.
	--I'm just using the tuning values for the horn for now.
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.HORN_USES/2)
    inst.components.finiteuses:SetUses(TUNING.HORN_USES/2)
    inst.components.finiteuses:SetOnFinished(onfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.TOKE, 1)
	
	--Makes the item something that's equippable.
	inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

	--Just one of the those things you need to run at the very end of your "fn" function.
    return inst
end

--Creates the prefab named "pipe" using the methods/variables defined in the "fn" function and the assets defined in Assets
return Prefab("common/inventory/pipe", fn, assets)

