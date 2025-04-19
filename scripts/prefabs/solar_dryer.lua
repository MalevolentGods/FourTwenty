--- solar_dryer.lua ---
------------------------------------------------------
-- Type: Prefab
-- Description: Creates and defines the solar dryer
------------------------------------------------------

-- Not sure why/if this is neccessary
local containers = require "containers"

-- Define custom animations
-- TODO: create custom animations/inventory images
local assets =
{
	--These are the ice box assets. Temporary until custom animations are ready.
	Asset("ANIM", "anim/ice_box.zip"),
	--These are the cookpot assets. Temporary until custom animations are ready.
	Asset("ANIM", "anim/cook_pot.zip"),
}

-- Load dependent prefabs
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

-- Open animation
local function onopen(inst)

	--Copied from icebox prefab
	inst.AnimState:PlayAnimation("open")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")		
end

-- Close animation
local function onclose(inst)

	--Copied from icebox prefab
	inst.AnimState:PlayAnimation("close")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")		
end

-- Check if the item inside dyhadrator is dehydratable and if its already dried (since dried products still have dehydratable tag)
local function itemtest(container, item, slot)
	return item:HasTag("dehydratable") or item:HasTag("dried_product")
end

-- When broken, drop all loot and remove
-- TODO: make it leave SOMETHING behind other than what it contained
local function onhammered(inst, worker)

	--Copied from icebox prefab
	inst.components.lootdropper:DropLoot()
	inst.components.container:DropEverything()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

-- Play hit animation
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

-- Play "start cooking" animation
local function startcookfn(inst)
	inst.AnimState:PlayAnimation("closed")
	--inst.AnimState:PlayAnimation("cooking_loop", true)
	--inst.SoundEmitter:KillSound("snd")
	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
	--inst.Light:Enable(true)
end

-- Play "curently cooking" animation
local function continuecookfn(inst)
	inst.AnimState:PlayAnimation("closed")
	--inst.AnimState:PlayAnimation("cooking_loop", true)
	--play a looping sound
	--inst.Light:Enable(true)
	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
end

-- Play finishing animation
local function donecookfn(inst)
	inst.AnimState:PlayAnimation("closed")
	inst.SoundEmitter:KillSound("snd")
	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish", "snd")
end

-- Play currently done animation
local function continuedonefn(inst)
	inst.AnimState:PlayAnimation("closed")
end

-- Play built animation
local function onbuilt(inst)
	
	--Copied from ice box prefab
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end

-- huh?
local function onfar(inst)
	inst.components.container:Close()
end

-- Define the solar dryer UI (based on cookpot)
local solardryer =
{
	widget =
	{
		-- Position of UI
		slotpos =
		{
			Vector3(0, 64 + 32 + 8 + 4, 0), 
			Vector3(0, 32 + 4, 0),
			Vector3(0, -(32 + 4), 0), 
			Vector3(0, -(64 + 32 + 8 + 4), 0),
		},
		
		-- UI animation
		animbank = "ui_cookpot_1x4",
		animbuild = "ui_cookpot_1x4",

		-- UI position
		pos = Vector3(200, 0, 0),
		side_align_tip = 100,

		-- Button info
		buttoninfo =
		{
			text = "Dry",
			position = Vector3(0, -165, 0),

		},
	},

	-- Allow stacks of mats
	acceptsstacks = false,

	-- Define the type of widget
    type = "cooker",
}

-- Define the widget button action
function solardryer.widget.buttoninfo.fn(inst)

	-- If there's something in the container run the DEHYDRATE action
	if inst.components.container ~= nil then
		BufferedAction(inst.components.container.opener, inst, ACTIONS.DEHYDRATE):Do()

	-- huh?
	elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
		SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.DEHYDRATE.code, inst, ACTIONS.DEHYDRATE.mod_name)
	end
end

function solardryer.widget.buttoninfo.fn(inst, doer)
    if inst.components.container ~= nil then
        BufferedAction(doer, inst, ACTIONS.DEHYDRATE):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.DEYDRATE.code, inst, ACTIONS.DEHYDRATE.mod_name)
    end
end

-- Button is only active the solar dryer is ready to dry (not busy and valid ingredients)
function solardryer.widget.buttoninfo.validfn(inst)
	return inst:HasTag("readytodry")
end

-- Define and create the solar dryer prefab  
local function fn()

	-- Boilerplate
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
 	inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    -- Set the minimap image
    inst.MiniMapEntity:SetIcon("icebox.png")
    
    -- Add the structure tag
    inst:AddTag("structure")
	
	-- Use the icebox animation bank (for now)
    inst.AnimState:SetBank("icebox")
    inst.AnimState:SetBuild("ice_box")
    inst.AnimState:PlayAnimation("closed")

    -- huh?
    MakeSnowCoveredPristine(inst)

    -- Still trying to grok this one. Required for multiplayer.
    if not TheWorld.ismastersim then
        return inst
    end

    -- Still groking this one too
    inst.entity:SetPristine()
	
	-- Make the item a dehydrater and define its animation
	inst:AddComponent("dehydrater")
    inst.components.dehydrater.onstartcooking = startcookfn
    inst.components.dehydrater.oncontinuecooking = continuecookfn
    inst.components.dehydrater.oncontinuedone = continuedonefn
    inst.components.dehydrater.ondonecooking = donecookfn
	
	-- Make the item a container (required for anything that can hold stuff)
    inst:AddComponent("container")

    -- Define open and close animations
	inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    -- Check item validity
	inst.components.container.itemtestfn = itemtest

	-- No ingredient stacks allowed
	--inst.components.container.acceptsstacks = false

	-- Probably not needed
	--inst.components.container.type = "cooker"

	-- Define number of container slots
	inst.components.container:SetNumSlots(4)

	-- Create the widget (ui)
	inst.components.container:WidgetSetup("solar_dryer", solardryer)

 	-- Make structure able to drop loot (contents) when they broken/hammered
    inst:AddComponent("lootdropper")
	
	-- Make structure destroyable by hammer 
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	-- Make structure inspectable and define status
	inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
	
	-- Make structure aware of player proximity and define
	inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerFar(onfar)
	
	-- Still not sure about this one
	MakeSnowCovered(inst)
	
	-- When the onbuilt event is detected, fire the onbuilt function
	inst:ListenForEvent("onbuilt", onbuilt)
	
    return inst
end

-- Return the predefined prefab
return Prefab("common/objects/solar_dryer", fn, assets, prefabs ),
		
		-- Create the item in a closed state (Using ice_box placer animation for now)
		MakePlacer("common/solar_dryer_placer", "icebox", "ice_box", "closed")  