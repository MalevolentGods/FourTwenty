--- weed.lua ---
------------------------------------------------------
-- Type: Prefab
-- Description: Creates and defines the fresh and dried versions of the weed bud
---------------------------------------------------------------------------


-- Load custom animation for weed bud and fresh/dried inventory images
local assets =
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
-- local enableSeeds = (GetModConfigData("enable_seeds", modname))

-- Define the fresh weed bud
local function fresh()

	-- Boilerplate
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- Give it inventory physics?
	MakeInventoryPhysics(inst)

    inst:AddTag("dryable")

	-- Define the animation
	inst.AnimState:SetBank("weed")
	inst.AnimState:SetBuild("weed")
	inst.AnimState:PlayAnimation("idle_fresh")
	inst.Transform:SetScale(1,1,1)    --This will probably need to be changed now that animations have been updated.

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
	inst.components.edible.healthvalue = 0
	inst.components.edible.hungervalue = TUNING.CALORIES_MED/3
	inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
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

	-- Fire can spread to and from this
	MakeSmallPropagator(inst)

	-- Make the fresh bud dehydratable
	inst:AddComponent("dehydratable")
    inst.components.dehydratable:SetProduct("weed_dried")
    inst.components.dehydratable:SetDryTime(TUNING.BASE_COOK_TIME*3)

    -- Make the fresh bud dryable as well so that it works on a drying rack
    inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("weed_dried")
    inst.components.dryable:SetDryTime(TUNING.DRY_FAST/5)

	-- Return the thing
	return inst
end

-- Define the dried weed bud
local function dried()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("weed")
	inst.AnimState:SetBuild("weed")
	inst.AnimState:PlayAnimation("idle_dried")
	inst.Transform:SetScale(1,1,1)  --This will probably need to be changed now that animations have been updated.

	-- Add the dried_product tag (so it can't be placed back in a dehydrator)
	inst:AddTag("dried_product")

    if not TheWorld.ismastersim then
		return inst
	end
    inst.entity:SetPristine()

    -- Alow the item to be stacked and define max size
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	-- Make the item detectable
	inst:AddComponent("inspectable")

	-- Make it an inventory item and define the image
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/weed_dried.xml"

	-- Make the item burnable
	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)

	MakeHauntableLaunchAndPerish(inst)

	return inst
end

-- Creates the prefabs named "weed_fresh" and weed_dried using the crap defined in the "fresh" and "dried" functions along with all the other crap above.
return Prefab( "weed_fresh", fresh, assets, prefabs), Prefab( "weed_dried", dried, assets, prefabs)

