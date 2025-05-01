--- pipe.lua ---
------------------------------------------------------
-- Type: prefab
-- Description: This script creates and defines the pipe
------------------------------------------------------


-- Custom animations and inventory image
local assets =
{

  	Asset("ANIM", "anim/pipe.zip"),
   	Asset("ANIM", "anim/swap_pipe.zip"),
   	Asset("ATLAS", "images/inventoryimages/pipe.xml"),
   	Asset("IMAGE", "images/inventoryimages/pipe.tex"),
}

-- Remove the pipe from inventory when it's depleted
local function onfinished(inst)
    inst:Remove()
end

-- Define the pipe prefab
local function fn(Sim)

    -- Boilerplate
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    -- Give it inventory physics?	
	MakeInventoryPhysics(inst)
    
	-- Set the bank to "pipe" (pipe.zip) set the build to "pipe" and play the animation named "idle""
	inst.AnimState:SetBank("pipe")
    inst.AnimState:SetBuild("pipe")
    inst.AnimState:PlayAnimation("idle")

	-- Still trying to grok. Needed for multiplayer.
	if not TheWorld.ismastersim then
		return inst
    end

    -- Still trying to grok this one
    inst.entity:SetPristine()
	
	-- Make the item inspectable
    inst:AddComponent("inspectable")
	
	-- I had to add hunger and health to give the equip-based debuff. 
    -- TODO: figure out a way to make it a debuff over time
	inst:AddComponent("hunger")
	inst:AddComponent("health")
	
	-- Make the item something that can be put in your inventory
	inst:AddComponent("inventoryitem")

    -- Set the item name and image
    inst.components.inventoryitem.imagename = "pipe"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/pipe.xml"
	
	-- Not sure if we still need this but I haven't tested. Might be required for playing horn animation.
    inst:AddTag("pipe")

	-- Same as the tag. Might be neccessary for horn animation and/or HORN tuning paramaters below.
    inst:AddComponent("instrument")
	 
	-- Make the item tokeable (smoke and sanity boost) 
    inst:AddComponent("tokeable")

    -- Define sanity return
    -- TODO: make this configurable and/or revisit for balance
	inst.components.tokeable:SetSanityBoost(10)

	-- Give the item finite uses and define how many
    -- TODO; revisit for balance
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.HORN_USES/4)
    inst.components.finiteuses:SetUses(TUNING.HORN_USES/4)
    inst.components.finiteuses:SetOnFinished(onfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.TOKE, 1)
	
    return inst
end

--Creates the prefab named "pipe" using the methods/variables defined in the "fn" function and the assets defined in Assets
return Prefab("common/inventory/pipe", fn, assets)

