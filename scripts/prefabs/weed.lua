--- weed.lua ---
------------------------------------------------------
-- Type: Prefab
-- Description: Creates and defines the fresh and dried versions of the weed bud
---------------------------------------------------------------------------


-- Load custom animation for weed bud and fresh/dried inventory images
local assets=
{
	Asset("ANIM", "anim/weed.zip"),
	Asset("ATLAS", "images/inventoryimages/weed_fresh.xml"),
	Asset("ATLAS", "images/inventoryimages/weed_dried.xml"),
}

-- Load dependent prefabs
local prefabs =
{
	"weed_seeds",		
	"spoiled_food", 		
}

-- Check if seeds are enabled in mod config
local modname = KnownModIndex:GetModActualName("FourTwenty")
local enableSeeds = (GetModConfigData("enable_seeds", modname))

-- Define the fresh weed bud
local function fresh()

	-- Boilerplate
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- Give it inventory physics?
	MakeInventoryPhysics(inst)

	-- Define the animation
	inst.AnimState:SetBank("weed")
	inst.AnimState:SetBuild("weed")
	inst.AnimState:PlayAnimation("idle_fresh")
	inst.Transform:SetScale(1.5,1.5,1.5)    --This will probably need to be changed now that animations have been updated.

	-- Still trying to grok this one. Required for multiplayer.
    if not TheWorld.ismastersim then
		return inst
	end

	-- Not sure about this one either.
    inst.entity:SetPristine()

    -- Make the fresh bud perishable and tune.
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	-- Make the fresh bud edible and define nutrition
	inst:AddComponent("edible")
	inst.components.edible.hungervalue = TUNING.CALORIES_MED/3
	inst.components.edible.foodtype = FOODTYPE.VEGGIE
	
	-- Make the fresh bud stackable and define
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	-- Make the item inspectable
	inst:AddComponent("inspectable")

	-- Make the item something that can go in the inventory and set the image
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/weed_fresh.xml"

	--Make the item burnable
	MakeSmallBurnable(inst)

	-- Still not sure about this one.
	MakeSmallPropagator(inst)
    
	inst:AddComponent("cookable")
	inst.components.cookable.product = "weed_dried"
	
	-- Make the fresh bud dehydratable and define
	inst:AddComponent("dehydratable")
    inst.components.dehydratable:SetProduct("weed_dried")
    inst.components.dehydratable:SetDryTime(TUNING.BASE_COOK_TIME*3)

	-- Still trying to grok this one	
	MakeHauntableLaunchAndPerish(inst)

	-- Return the thing
	return inst
end

-- Define the dried weed bud
local function dried()

	-- Boilerplate
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)

	-- Define the animations
	inst.AnimState:SetBank("weed")
	inst.AnimState:SetBuild("weed")
	inst.AnimState:PlayAnimation("idle_dried")
	inst.Transform:SetScale(.5,.5,.5)  --This will probably need to be changed now that animations have been updated. 

	-- Still trying to grok this one
    if not TheWorld.ismastersim then
		return inst
	end

	-- And this one too
    inst.entity:SetPristine()

    -- Alow the item to be stacked and define max size
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	-- Make the item detectable
	inst:AddComponent("inspectable")

	-- Make it an inventory item and define the image
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/weed_dried.xml"
	
	-- Add the dried_product tag (so it can't be placed back in a dehydrator)
	inst:AddTag("dried_product")

	-- Make the item burnable
	MakeSmallBurnable(inst)

	-- Not sure if this is neccessary for this item
	MakeSmallPropagator(inst)

	-- Not sure about this one either
	MakeHauntableLaunchAndPerish(inst)

	-- Return the thing
	return inst
end

-- Creates the prefabs named "weed_fresh" and weed_dried using the crap defined in the "fresh" and "dried" functions along with all the other crap above. 
return Prefab( "weed_fresh", fresh, assets, prefabs),
	Prefab( "weed_dried", dried, assets, prefabs)
