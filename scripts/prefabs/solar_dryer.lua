--This script creates and defines the solar_dryer prefab
------------------------------------------------------
local containers = require "containers"

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
	
	inst.AnimState:PlayAnimation("hit")
	
end

--Fetch the status of the drying operation
local function getstatus(inst)

	--Copied from the cookpot prefab
	if inst.components.dehydrater.cooking and inst.components.dehydrater:GetTimeToDry() > 15 then
		return "COOKING_LONG"
	elseif inst.components.dehydrater.cooking then
		return "COOKING_SHORT"
	elseif inst.components.dehydrater.done then
		return "DONE"
	else
		return "EMPTY"
	end
end

--Define animations/actions to run when drying begins.
local function startcookfn(inst)

	inst.AnimState:PlayAnimation("closed")
	--inst.AnimState:PlayAnimation("cooking_loop", true)
	--inst.SoundEmitter:KillSound("snd")
	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
	--inst.Light:Enable(true)
end

local function continuecookfn(inst)

	inst.AnimState:PlayAnimation("closed")
	--inst.AnimState:PlayAnimation("cooking_loop", true)
	--play a looping sound
	--inst.Light:Enable(true)

	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
end

--Define animations/actions to run when drying completes
local function donecookfn(inst)

	inst.AnimState:PlayAnimation("closed")
	inst.SoundEmitter:KillSound("snd")
	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish", "snd")
end

local function continuedonefn(inst)
	inst.AnimState:PlayAnimation("closed")
end



--Define animation to use when structure is actually built (placed)
local function onbuilt(inst)
	
	--Copied from ice box prefab
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end

local function onfar(inst)
	inst.components.container:Close()
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
	
	
	inst:AddComponent("dehydrater")
    inst.components.dehydrater.onstartcooking = startcookfn
    inst.components.dehydrater.oncontinuecooking = continuecookfn
    inst.components.dehydrater.oncontinuedone = continuedonefn
    inst.components.dehydrater.ondonecooking = donecookfn
	
	--Used container component code from the "cookpot" prefab because I want to use its menu.
    inst:AddComponent("container")
    local widgetdata =
	{
		widget =
		{
			slotpos =
			{
				Vector3(0, 64 + 32 + 8 + 4, 0), 
				Vector3(0, 32 + 4, 0),
				Vector3(0, -(32 + 4), 0), 
				Vector3(0, -(64 + 32 + 8 + 4), 0),
			},
			animbank = "ui_cookpot_1x4",
			animbuild = "ui_cookpot_1x4",
			pos = Vector3(200, 0, 0),
			side_align_tip = 100,
			buttoninfo =
			{
				text = "Dry",
				position = Vector3(0, -165, 0),
			}
		},
		acceptsstacks = false,
		type = "cooker",
	}

	function widgetdata.itemtestfn(container, item, slot)
		return inst.components.dehydrater:ItemTest(item)
	end

	function widgetdata.widget.buttoninfo.fn(inst)
		if inst.components.container ~= nil then
			BufferedAction(inst.components.container.opener, inst, ACTIONS.DEHYDRATE):Do()
		elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
			SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.DEHYDRATE.code, inst, ACTIONS.DEHYDRATE.mod_name)
		end
	end

	function widgetdata.widget.buttoninfo.validfn(inst)
		return inst.components.dehydrater:ReadyToStart()
	end
	inst.components.container:WidgetSetup("solar_dryer", widgetdata)

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


	inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
	
	inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerFar(onfar)
	
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