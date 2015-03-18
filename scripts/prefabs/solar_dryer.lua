--This script creates and defines the solar_dryer prefab
------------------------------------------------------

local assets =
{

	--These are the ice box assets. Temporary until custom animations are ready.
	Asset("ANIM", "anim/ice_box.zip"),
	--Asset("ANIM", "anim/ui_chest_3x3.zip"),
	
	--These are the cookpot assets. Temporary until custom animations are ready.
	Asset("ANIM", "anim/cook_pot.zip"),
	--Asset("ANIM", "anim/cook_pot_food.zip"),
}

--Load prefabs for all the things that can be dried and their dried counterpart
local prefabs =
{
	"weed_fresh",
	"weed_dried",
	
	--I've disabled all the meat rack's default prefabs for now
	
	--"smallmeat",
	--"smallmeat_dried",
	--"monstermeat",
	--"monstermeat_dried",
	--"humanmeat",
	--"humanmeat_dried",
	--"meat",
	--"meat_dried",
	--"drumstick", -- uses smallmeat_dried
	--"batwing", --uses smallmeat_dried
	--"fish", -- uses smallmeat_dried
	--"froglegs", -- uses smallmeat_dried
	--"eel",

}

--Define animations and actions to perform when item is opened
local function onopen(inst)

	--Copied from icebox prefab
	inst.AnimState:PlayAnimation("open")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")		
	
end

--Define animations and actions to perform when item is closed
local function onclose(inst)

	--Copied from icebox prefab
	inst.AnimState:PlayAnimation("close")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")		
end


--Define animations and actions to perform when broken/hammered
local function onhammered(inst, worker)

	--Copied from icebox prefab
	inst.components.lootdropper:DropLoot()
	inst.components.container:DropEverything()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	
	inst:Remove()
end

 
--Define animations and actions to perform when hit
local function onhit(inst, worker)
	
	--Copied from cookpot prefab.
	--inst.AnimState:PlayAnimation("hit_empty")
	
	--if inst.components.stewer.cooking then
	--	inst.AnimState:PushAnimation("cooking_loop")
	--elseif inst.components.stewer.done then
	--	inst.AnimState:PushAnimation("idle_full")
	--else
	--	inst.AnimState:PushAnimation("idle_empty")
	--end
	
	inst.AnimState:PlayAnimation("hit")
	
end

--Fetch the status of the drying operation
local function getstatus(inst)

	--Copied from meat rack prefab
    if inst.components.dryer and inst.components.dryer:IsDrying() then
        return "DRYING"
    elseif inst.components.dryer and inst.components.dryer:IsDone() then
        return "DONE"
    end
end

--Define animations/actions to run when drying begins.
local function onstartdrying(inst, dryable)

	--Copied from dryer prefab.
    --inst.AnimState:PlayAnimation("drying_pre")
	--inst.AnimState:PushAnimation("drying_loop", true)
	inst.AnimState:PlayAnimation("closed")
	
	--We won't be swapping any symbols so we don't need this.
    --inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", dryable)		
end


--Define animations/actions to run when item is set to a "done" state
local function setdone(inst, product)

	--Copied from dryer prefab.
    --inst.AnimState:PlayAnimation("idle_full")
	inst.AnimState:PlayAnimation("closed")
	
	--We won't be swapping any symbols so we don't need this.
    --inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", product)
end


--Define animations/actions to run when drying completes
local function ondonedrying(inst, product)

	--Copied from dryer prefab.
    --inst.AnimState:PlayAnimation("drying_pst")
	inst.AnimState:PlayAnimation("closed")
	
    local function ondonefn(inst)
        inst:RemoveEventCallback("animover", ondonefn)
        setdone(inst, product)
    end
    inst:ListenForEvent("animover", ondonefn)
end


--Defines animations/actions to perform on harvest. May not really be needed by our item.
local function onharvested(inst)

	--Copied from dryer prefab.
    --inst.AnimState:PlayAnimation("idle_empty")
	inst.AnimState:PlayAnimation("closed")
end

--Define animation to use when structure is actually built (placed)
local function onbuilt(inst)
	
	--Copied from ice box prefab
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end


--This function is where the prefab is actually created and configured. All of the variables and functions defined above will be used here.  
local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
 	inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("icebox.png")
    
    inst:AddTag("structure")

	--Use the icebox animation bank (for now)
    inst.AnimState:SetBank("icebox")
    inst.AnimState:SetBuild("ice_box")
    inst.AnimState:PlayAnimation("closed")

    MakeSnowCoveredPristine(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()
	
	
	--Used container component code from the "cookpot" prefab because I want to use its menu.
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("cookpot")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

	--Make item able to drop loot (contents) when they broken/hammered
    inst:AddComponent("lootdropper")
	
	--Make structure destroyable by hammer 
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	MakeHauntableWork(inst)

	--Used dryer component code from the meat_rack prefab to make our item a dryer. Will replace with new dehydrater component.
	inst:AddComponent("dehydrater")
	inst.components.dehydrater:SetStartDryingFn(onstartdrying)
	inst.components.dehydrater:SetDoneDryingFn(ondonedrying)
	inst.components.dehydrater:SetContinueDryingFn(onstartdrying)
	inst.components.dehydrater:SetContinueDoneFn(setdone)
	inst.components.dehydrater:SetOnHarvestFn(onharvested)

	inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
	
	MakeSnowCovered(inst)
	
	inst:ListenForEvent("onbuilt", onbuilt)
	

	--I'm still not sure how all of the hauntable stuff works but this is where it's defined.
	--Copied from icebox prefab 
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

--Create a prefab using the options defined in the "fn" function
return Prefab("common/objects/solar_dryer", fn, assets, prefabs ),
		
		--Also create a new placer
		--Using ice_box placer animation until custom art is done.
		MakePlacer("common/solar_dryer_placer", "icebox", "ice_box", "closed")  