--- solar_dryer.lua ---
------------------------------------------------------
-- Type: Prefab
-- Description: Creates and defines the solar dryer
------------------------------------------------------

-- Import the containers component from the base game
local containers = require "containers"

-- Define custom animations
local assets =
{
	--These are the ice box assets. Temporary until custom animations are ready.
	Asset("ANIM", "anim/solar_dryer.zip"),
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

-- When opening the container
local function OnOpen(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

-- When closing the container
local function OnClose(inst)
    if inst.components.container:IsEmpty() then
	    inst.AnimState:PlayAnimation("idle_empty")
	else
		inst.AnimState:PlayAnimation("idle_full")
	end
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")		
end

-- Check if the item inside dyhadrator is dehydratable and if its already dried (since dried products still have dehydratable tag)
local function ItemTest(container, item, slot)
	return item:HasTag("dehydratable") or item:HasTag("dried_product")
end

-- When broken, drop all loot and remove
-- TODO: make it leave SOMETHING behind other than what it contained
local function OnHammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	inst.components.container:DropEverything()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

-- Play hit animation
local function OnHit(inst, worker)
    -- TODO: Come up with different hit animations based on empty/full
	-- inst.AnimState:PlayAnimation("idle_full")
end

--Fetch the status of the drying operation
local function GetStatus(inst)
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
local function StartDry(inst)
	inst.AnimState:PushAnimation("idle_full", true)
	--inst.AnimState:PlayAnimation("cooking_loop", true)
	--inst.SoundEmitter:KillSound("snd")
	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
	--inst.Light:Enable(true)
end

-- Play "curently cooking" animation
local function ContinueDry(inst)
	inst.AnimState:PlayAnimation("idle_full", true)
	--inst.AnimState:PlayAnimation("cooking_loop", true)
	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
end

-- Play finishing animation
local function DoneDry(inst)
	inst.AnimState:PlayAnimation("idle_full")
	inst.SoundEmitter:KillSound("snd")
	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish", "snd")
end

-- Play currently done animation
local function ContinueDoneDry(inst)
	inst.AnimState:PlayAnimation("idle_full")
end

-- Play built animation
local function OnBuilt(inst)
	inst.AnimState:PlayAnimation("idle_empty")
-- 	inst.AnimState:PushAnimation("closed", false)
end

-- When moving away from the dryer, close the container
local function OnFar(inst)
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

	-- Do not allow stacks of mats
	acceptsstacks = false,
    type = "cooker",
}

-- Define the widget button action
function solardryer.widget.buttoninfo.fn(inst)

	-- If there's something in the container run the DEHYDRATE action
	if inst.components.container ~= nil then
		BufferedAction(inst.components.container.opener, inst, ACTIONS.DEHYDRATE):Do()

	-- Something to do with multiplayer
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

-- Save the dryer state (empty or full)
local function onsave(inst, data)
	data.empty = inst.components.container:IsEmpty()
end

-- Load the tree state and play the appropriate animation
local function onload(inst, data)
	if data and data.empty then
		inst.AnimState:PlayAnimation("idle_empty")
	else
		inst.AnimState:PlayAnimation("idle_full")
	end
end

-- Define and create the solar dryer prefab  
local function solar_dryer()

	-- Boilerplate
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
 	inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    -- Set the minimap image
	-- TODO: Create a custom minimap image
    inst.MiniMapEntity:SetIcon("icebox.png")
    
    -- Add the structure tag
    inst:AddTag("structure")
	
    inst.AnimState:SetBank("solar_dryer")
    inst.AnimState:SetBuild("solar_dryer")
    inst.AnimState:PlayAnimation("idle_empty")

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
    inst.components.dehydrater.onstartcooking = StartDry
    inst.components.dehydrater.oncontinuecooking = ContinueDry
    inst.components.dehydrater.oncontinuedone = ContinueDoneDry
    inst.components.dehydrater.ondonecooking = DoneDry
	
	-- Make the item a container (required for anything that can hold stuff)
    inst:AddComponent("container")

    -- Define open and close animations
	inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose

    -- Check item validity
	inst.components.container.itemtestfn = ItemTest

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
	inst.components.workable:SetOnFinishCallback(OnHammered)
	inst.components.workable:SetOnWorkCallback(OnHit)

	-- Make structure inspectable and define status
	inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
	
	-- Make structure aware of player proximity and define
	inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerFar(OnFar)
	
	-- Still not sure about this one
	MakeSnowCovered(inst)
	
	-- When the onbuilt event is detected, fire the onbuilt function
	inst:ListenForEvent("onbuilt", OnBuilt)

	-- Save the dryer state on quit
	inst.OnSave = onsave

	-- Load the dryer state on load
	inst.OnLoad = onload
	
    return inst
end

-- Return the predefined prefab
return Prefab("common/objects/solar_dryer", solar_dryer, assets, prefabs ),
		
		-- Create the item in a closed state
		MakePlacer("common/solar_dryer_placer", "solar_dryer", "solar_dryer", "idle_empty")