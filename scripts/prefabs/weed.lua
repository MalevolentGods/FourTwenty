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
	"weed_seeds",
	"spoiled_food",
	
}    

--This function defines the "fresh" weed prefab. Which is basically the only one we're using now. Eventually there will also be a "dried" weed prefab. This lets you set different things about the weed whether it's fresh or dried. Like if it's edible, or smokeable, or whatever.
local function fresh()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("hybrid_banana")
	inst.AnimState:SetBuild("hybrid_banana")
	inst.AnimState:PlayAnimation("raw")
	inst.Transform:SetScale(3,3,3)    

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
        
	inst:AddComponent("bait")

	inst:AddComponent("cookable")
	inst.components.cookable.product = "weed_seeds"
	
	inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("weed_dried")
    inst.components.dryable:SetDryTime(TUNING.DRY_FAST)

	MakeHauntableLaunchAndPerish(inst)

	return inst
end

--This is just a place holder for the future "dried" weed prefab. It used to be the "cooked" banana prefab, so all the crap inside is still related to bananas and edible options.
local function dried()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("hybrid_banana")
	inst.AnimState:SetBuild("hybrid_banana")
	inst.AnimState:PlayAnimation("cooked")
	inst.Transform:SetScale(3,3,3)

    if not TheWorld.ismastersim then
		return inst
	end

    inst.entity:SetPristine()

	--inst:AddComponent("perishable")
	--inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	--inst.components.perishable:StartPerishing()
	--inst.components.perishable.onperishreplacement = "spoiled_food"

	--inst:AddComponent("edible")
	--inst.components.edible.healthvalue = TUNING.HEALING_MED
	--inst.components.edible.hungervalue = TUNING.CALORIES_MED
	--inst.components.edible.sanityvalue = TUNING.SANITY_MED
	--inst.components.edible.foodtype = FOODTYPE.VEGGIE

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/weed_dried.xml"

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
        
	--inst:AddComponent("bait")

	MakeHauntableLaunchAndPerish(inst)

	return inst
end

--Creates the prefab named "weed" using the methods and variables defined in the "fresh" function using the assets defined in ""assets" and the prefabs defined in "prefabs"
return Prefab( "weed_fresh", fresh, assets, prefabs),
	Prefab( "weed_dried", dried, assets, prefabs)