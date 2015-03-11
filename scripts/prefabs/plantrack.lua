local assets =
{
	Asset("ANIM", "anim/meat_rack.zip"),
	Asset("ANIM", "anim/meat_rack_food.zip"),
	Asset("ANIM", "anim/meat.zip"),

	--Asset("ANIM", "anim/meat_monster.zip"),
	--Asset("ANIM", "anim/meat_small.zip"),
	--Asset("ANIM", "anim/meat_human.zip"),
	--Asset("ANIM", "anim/drumstick.zip"),
	Asset("ANIM", "anim/meat_rack_food.zip"),
    Asset("ANIM", "anim/batwing.zip"),
    Asset("ANIM", "anim/plant_meat.zip"),
    Asset("ANIM", "anim/eel.zip"),
}

local prefabs =
{
	-- everything it can "produce" and might need symbol swaps from
	"smallmeat",
	"smallmeat_dried",
	"monstermeat",
	"monstermeat_dried",
	"humanmeat",
	"humanmeat_dried",
	"meat",
	"meat_dried",
	"drumstick", -- uses smallmeat_dried
	"batwing", --uses smallmeat_dried
	"fish", -- uses smallmeat_dried
	"froglegs", -- uses smallmeat_dried
	"eel",
}

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:Remove()
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
end

local function onhit(inst, worker)
	if inst.components.dryer and inst.components.dryer:IsDrying() then
		inst.AnimState:PlayAnimation("hit_full")
		inst.AnimState:PushAnimation("drying_pre", false)
		inst.AnimState:PushAnimation("drying_loop", true)
	elseif inst.components.dryer and inst.components.dryer:IsDone() then
		inst.AnimState:PlayAnimation("hit_full")
		inst.AnimState:PushAnimation("idle_full", false)
	else
		inst.AnimState:PlayAnimation("hit_empty")
		inst.AnimState:PushAnimation("idle_empty", false)
	end
end

local function getstatus(inst)
    if inst.components.dryer and inst.components.dryer:IsDrying() then
        return "DRYING"
    elseif inst.components.dryer and inst.components.dryer:IsDone() then
        return "DONE"
    end
end

local function onstartdrying(inst, dryable)
    inst.AnimState:PlayAnimation("drying_pre")
	inst.AnimState:PushAnimation("drying_loop", true)
	inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", dryable)
end

local function setdone(inst, product)
    inst.AnimState:PlayAnimation("idle_full")
    inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", product)
end

local function ondonedrying(inst, product)
    inst.AnimState:PlayAnimation("drying_pst")
    local function ondonefn(inst)
        inst:RemoveEventCallback("animover", ondonefn)
        setdone(inst, product)
    end
    inst:ListenForEvent("animover", ondonefn)
end

local function onharvested(inst)
    inst.AnimState:PlayAnimation("idle_empty")
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle_empty", false)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
 	inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("meatrack.png")
    
    inst:AddTag("structure")

    inst.AnimState:SetBank("meat_rack")
    inst.AnimState:SetBuild("meat_rack")
    inst.AnimState:PlayAnimation("idle_empty")

    MakeSnowCoveredPristine(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER) -- should be DRY
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	MakeHauntableWork(inst)

	inst:AddComponent("dryer")
	inst.components.dryer:SetStartDryingFn(onstartdrying)
	inst.components.dryer:SetDoneDryingFn(ondonedrying)
	inst.components.dryer:SetContinueDryingFn(onstartdrying)
	inst.components.dryer:SetContinueDoneFn(setdone)
	inst.components.dryer:SetOnHarvestFn(onharvested)

    inst:AddComponent("inspectable")

    inst.components.inspectable.getstatus = getstatus
	MakeSnowCovered(inst)	
	inst:ListenForEvent("onbuilt", onbuilt)
    return inst
end

return Prefab("common/objects/meatrack", fn, assets, prefabs ),
	   MakePlacer("common/meatrack_placer", "meat_rack", "meat_rack", "idle_empty")