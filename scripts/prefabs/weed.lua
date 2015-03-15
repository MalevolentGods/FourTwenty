--This script creates and defines the weed_fresh and weed_dried prefabs
---------------------------------------------------------------------------


--These are basically the custom animations and graphics that we're loading for the prefab
local assets=
{
	Asset("ANIM", "anim/weed.zip"),
	Asset("ATLAS", "images/inventoryimages/weed_fresh.xml"),
	Asset("ATLAS", "images/inventoryimages/weed_dried.xml"),
}

--Loads any custom prefabs we're going to reference
local prefabs =
{
	"weed_seeds",		--Need this in order to turn weed into weed_seeds
	"spoiled_food", 	--Need this in order to make weed into something spoiled.
	
}    

--This function defines the "fresh" weed prefab.
local function fresh()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("weed")
	inst.AnimState:SetBuild("weed")
	inst.AnimState:PlayAnimation("idle_fresh")
	inst.Transform:SetScale(1.5,1.5,1.5)    --This will probably need to be changed now that animations have been updated.

    if not TheWorld.ismastersim then
		return inst
	end

    inst.entity:SetPristine()

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("edible")
	inst.components.edible.hungervalue = TUNING.CALORIES_MED
	inst.components.edible.foodtype = FOODTYPE.VEGGIE
	

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/weed_fresh.xml"

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
        
	inst:AddComponent("cookable")
	inst.components.cookable.product = "weed_seeds"
	
	inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("weed_dried")
    inst.components.dryable:SetDryTime(TUNING.DRY_FAST)

	MakeHauntableLaunchAndPerish(inst)

	return inst
end

local function dried()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("weed")
	inst.AnimState:SetBuild("weed")
	inst.AnimState:PlayAnimation("idle_dried")
	inst.Transform:SetScale(.5,.5,.5)  --This will probably need to be changed now that animations have been updated. 

    if not TheWorld.ismastersim then
		return inst
	end

    inst.entity:SetPristine()

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/weed_dried.xml"

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)

	MakeHauntableLaunchAndPerish(inst)

	return inst
end

--Creates the prefabs named "weed_fresh" and weed_dried using the crap defined in the "fresh" and "dried" functions along with all the other crap above. 
return Prefab( "weed_fresh", fresh, assets, prefabs),
	Prefab( "weed_dried", dried, assets, prefabs)
