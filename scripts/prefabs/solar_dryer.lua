local assets =
{
	Asset("ANIM", "anim/ice_box.zip"),
	Asset("ANIM", "anim/ui_chest_3x3.zip"),
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
	"weed_fresh",
	"weed_dried",
}

local function onopen(inst)
	inst.AnimState:PlayAnimation("open")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")		
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	inst.components.container:DropEverything()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.components.container:DropEverything()
	inst.AnimState:PushAnimation("closed", false)
	inst.components.container:Close()
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
--	inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", dryable)
end

local function setdone(inst, product)
    inst.AnimState:PlayAnimation("idle_full")
    --inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", product)
end

local function ondonedrying(inst, product)
    inst.AnimState:PlayAnimation("drying_pst")
    local function ondonefn(inst)
        inst:RemoveEventCallback("animover", ondonefn)
        setdone(inst, product)
    end
    inst:ListenForEvent("animover", ondonefn)
end


--this will probably need to go or be changed. may not be needed
local function onharvested(inst)
    inst.AnimState:PlayAnimation("idle_empty")
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
 	inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("icebox.png")
    
    inst:AddTag("structure")

    inst.AnimState:SetBank("icebox")
    inst.AnimState:SetBuild("ice_box")
    inst.AnimState:PlayAnimation("closed")

    MakeSnowCoveredPristine(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()
	
	inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("icebox")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER) -- should be DRY (?? not sure who added this, but for our purpose they might be right. DRY command could activate it once you're done loading.)
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

    inst.components.inspectable.getstatus = getstatus
	
	MakeSnowCovered(inst)	
	inst:ListenForEvent("onbuilt", onbuilt)
		
	inst:AddComponent("hauntable")
	inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
	inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
		local ret = false
        if math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
            if inst.components.container then
                local item = inst.components.container:FindItem(function(item) return not item:HasTag("nosteal") end)
                if item then
                    inst.components.container:DropItem(item)
                    inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
                    ret = true
                end
            end
        end
        if math.random() <= TUNING.HAUNT_CHANCE_RARE then
        	if inst.components.workable then
                inst.components.workable:WorkedBy(haunter, 1)
                inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
                ret = true
            end
        end
        return ret
	end)
    return inst
end

return Prefab("common/objects/solar_dryer", fn, assets, prefabs ),
	   MakePlacer("common/solar_dryer_placer", "icebox", "ice_box", "closed")