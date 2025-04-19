--local assets =
--{
--    Asset("ANIM", "anim/meat.zip"),
--    Asset("ANIM", "anim/meat_monster.zip"),
--    Asset("ANIM", "anim/meat_small.zip"),
--    Asset("ANIM", "anim/meat_human.zip"),
--    Asset("ANIM", "anim/drumstick.zip"),
--    Asset("ANIM", "anim/fishmeat.zip"),
--    Asset("ANIM", "anim/fishmeat_small.zip"),
--    Asset("ANIM", "anim/meat_rack_food.zip"),
--    Asset("ANIM", "anim/meat_rack_food_tot.zip"),
--    Asset("ANIM", "anim/batwing.zip"),
--    Asset("ANIM", "anim/plant_meat.zip"),
--    Asset("ANIM", "anim/barnacle.zip"),
--}

local assets =
{
	Asset("ANIM",  "anim/weed.zip"),
	Asset("ATLAS", "images/inventoryimages/weed_fresh.xml"),
	Asset("ATLAS", "images/inventoryimages/weed_dried.xml"),
}

-- Load dependent prefabs
local prefabs =
{
	"weed_seeds",
	"spoiled_food",
}
local function common(bank, build, anim, tags, dryable, cookable)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(anim)
    inst.scrapbook_anim = anim

    --inst.pickupsound = "squidgy"

    inst:AddTag("vegetable")
    if tags ~= nil then
        for i, v in ipairs(tags) do
            inst:AddTag(v)
        end
    end

    if dryable ~= nil then
		if dryable.product then
			--dryable (from dryable component) added to pristine state for optimization
			inst:AddTag("dryable")
		end
    end

    if cookable ~= nil then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.VEGGIE


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.VEGGIE

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    if dryable ~= nil and dryable.product ~= nil then
        inst:AddComponent("dryable")
        inst.components.dryable:SetProduct(dryable.product)
        inst.components.dryable:SetDryTime(dryable.time)
		inst.components.dryable:SetBuildFile(dryable.build)
        inst.components.dryable:SetDriedBuildFile(dryable.dried_build)
    end

    if cookable ~= nil then
        inst:AddComponent("cookable")
        inst.components.cookable.product = cookable.product
    end

    MakeHauntableLaunchAndPerish(inst)
    inst:ListenForEvent("spawnedfromhaunt", OnSpawnedFromHaunt)

    return inst
end

local function weed_fresh()
    --selfstacker (from selfstacker component) added to pristine state for optimization
    local inst = common("weed", "weed", "idle_fresh", {"selfstacker"}, { product = "weed_dried", time = TUNING.DRY_FAST })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = -TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_LARGE
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    inst.components.tradable.goldvalue = 0

    inst.components.floater:SetVerticalOffset(0.1)

    inst:AddComponent("selfstacker")

    return inst
end

local function weed_dried()
    local inst = common("weed", "weed", "idle_dried")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.tradable.goldvalue = 5

    inst.components.edible.healthvalue = -TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_LARGE

    inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)

    inst.components.floater:SetVerticalOffset(0.1)

    return inst
end

return Prefab("weed_fresh", weed_fresh, assets, prefabs),
        Prefab("weed_dried", weed_dried, assets)