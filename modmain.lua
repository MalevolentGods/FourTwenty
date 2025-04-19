--- modmain.lua ---
------------------------------------------------------
-- Description: mod init script
------------------------------------------------------

-- Load custom animations and images/textures  
Assets= 
{
	Asset("ANIM", "anim/weed.zip"),
	Asset("ANIM", "anim/pipe.zip"),
	Asset("ANIM", "anim/joint.zip"),
	Asset("ANIM", "anim/swap_pipe_horn.zip"),
	Asset("ANIM", "anim/swap_joint.zip"),
    Asset("ATLAS", "images/inventoryimages/pipe.xml"),
	Asset("ATLAS", "images/inventoryimages/joint.xml"),
    Asset("ATLAS", "images/inventoryimages/weed_fresh.xml"),
	Asset("ATLAS", "images/inventoryimages/weed_dried.xml"),
	Asset("ATLAS", "images/inventoryimages/weed_seeds.xml"),
	Asset("ATLAS", "images/inventoryimages/solar_dryer.xml"),
	Asset("IMAGE", "minimap/weed_tree.tex" ),
    Asset("ATLAS", "minimap/weed_tree.xml" ),
}

-- Add the weed tree to minimap 
AddMinimapAtlas("minimap/weed_tree.xml")

-- Dependent prefabs 
PrefabFiles = 
{
	"weed_seeds",
	"weed_tree",
	"weed",
	"pipe",
	"joint",
	"solar_dryer"
}

-- Boilerplate global variables
ACTIONS         = GLOBAL.ACTIONS
Action          = GLOBAL.Action
ActionHandler   = GLOBAL.ActionHandler
STRINGS         = GLOBAL.STRINGS
RECIPETABS      = GLOBAL.RECIPETABS
Recipe          = GLOBAL.Recipe
Ingredient      = GLOBAL.Ingredient
TECH            = GLOBAL.TECH
SpawnPrefab     = GLOBAL.SpawnPrefab

-- Custom speech text
STRINGS.NAMES.PIPE = "Wooden Bowl"
STRINGS.RECIPE_DESC.PIPE = "A freshly packed bowl!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.PIPE = "Just like Grandpa used to toke."

STRINGS.NAMES.JOINT = "A Joint"
STRINGS.RECIPE_DESC.JOINT = "Hand-rolled joint"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.JOINT = "I could puff on this all day."

STRINGS.NAMES.G_HOUSE = "Advanced Farm"
STRINGS.RECIPE_DESC.G_HOUSE = "I have no idea what it does!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.G_HOUSE = "Your guess is as good as mine."

STRINGS.NAMES.SOLAR_DRYER = "Solar Dryer"
STRINGS.RECIPE_DESC.SOLAR_DRYER = "Run of the mill solar dryer"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SOLAR_DYER = "Yeah, dry some shit!"

STRINGS.NAMES.WEED_TREE = "Weed Plant"
STRINGS.RECIPE_DESC.WEED_TREE = "Weeeeeed!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WEED_TREE = "It's flowers are smokable!"

STRINGS.RECIPE_DESC.WEED_SEEDS = "I guess it's legal to grow here?"
STRINGS.NAMES.WEED_SEEDS = "Weed Seeds"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WEED_SEEDS = "These are worth their weight in gold!"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.WEED_FRESH = "It's green and sticky. I should dry this first."
STRINGS.NAMES.WEED_FRESH = "Fresh Weed Bud"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.WEED_DRIED = "Look at the trichomes!"
STRINGS.NAMES.WEED_DRIED = "Dried Weed Bud"

-- -- Enable dehydrater if set in the config
-- local enableDryer = (GetModConfigData("enable_dryer"))
-- if enableDryer == 1 then

-- 	-- Define dehydrater recipe
-- 	local dehydraterrecipe = Recipe("solar_dryer", {Ingredient("gears", 2), Ingredient("goldnugget", 3), Ingredient("charcoal", 6)}, RECIPETABS.FARM, TECH.SCIENCE_ONE, "solar_dryer_placer")
-- 	dehydraterrecipe.atlas = "images/inventoryimages/solar_dryer.xml"
	
-- 	-- Define the joint recipe
-- 	local jointrecipe = Recipe("joint", {Ingredient("papyrus", 1), Ingredient("weed_dried", 1,"images/inventoryimages/weed_dried.xml")}, RECIPETABS.SURVIVAL, TECH.NONE)
-- 	jointrecipe.atlas = "images/inventoryimages/joint.xml"
-- else
-- 	-- Define the joint recipe if dryer is disabled
-- 	local jointrecipe = Recipe("joint", {Ingredient("papyrus", 1), Ingredient("honey", 1), Ingredient("weed_fresh", 3,"images/inventoryimages/weed_fresh.xml")}, RECIPETABS.SURVIVAL, TECH.NONE)
-- 	jointrecipe.atlas = "images/inventoryimages/joint.xml"
-- end

-- Define the joint recipe if dryer is disabled
local seedrecipe = AddRecipe("weed_seeds", {Ingredient("weed_fresh", 4, "images/inventoryimages/weed_fresh.xml")}, RECIPETABS.SURVIVAL, TECH.NONE)
seedrecipe.atlas = "images/inventoryimages/weed_seeds.xml"

-- Define the joint recipe if dryer is disabled
local jointrecipe = AddRecipe("joint", {Ingredient("papyrus", 1), Ingredient("honey", 1), Ingredient("weed_dried", 3,"images/inventoryimages/weed_dried.xml")}, RECIPETABS.SURVIVAL, TECH.NONE)
jointrecipe.atlas = "images/inventoryimages/joint.xml"

-- Define the pipe recipe
local piperecipe = AddRecipe("pipe", {Ingredient("twigs", 3), Ingredient("charcoal", 1), Ingredient("weed_dried", 1,"images/inventoryimages/weed_dried.xml")}, RECIPETABS.SURVIVAL, TECH.NONE)
piperecipe.atlas = "images/inventoryimages/pipe.xml"

-- Create the TOKE action
local TOKE = Action(3)	
TOKE.str = "Toke"
TOKE.id = "TOKE"
TOKE.fn = function(act)

	-- Create an array of speech strings for toking
	local stringArray = {}  
	stringArray[1] = "I love smoking in the woods"
	stringArray[2] = "Whooooooaaaaaa..... That's dank shit!"
	stringArray[3] = "It tastes like blueberries."
	stringArray[4] = "It tastes even better when you grow it yourself."
	
	-- Get a random number for the string choice.
	-- TODO: make the number dynamic based on items in stringArray
	local stringChoice = math.random(4)
	
	--This method makes the person performing the action say the string that matches the value produced by math.random()
	act.doer.components.talker:Say(stringArray[stringChoice])
	act.invobject.components.tokeable:bowlHit(act.doer)
	
	return true
end

-- Add the TOKE action
AddAction(TOKE)
-- Create the DEHYDRATE action
local DEHYDRATE = Action()
DEHYDRATE.str = "Dehydrate"
DEHYDRATE.id = "DEHYDRATE"
DEHYDRATE.fn = function(act)
    if act.target.components.dehydrater ~= nil then
        if act.target.components.dehydrater.cooking then
            --Already cooking
            return true
        end
        local container = act.target.components.container
        if container ~= nil and container:IsOpen() and not container:IsOpenedBy(act.doer) then
            return false, "INUSE"
        elseif not act.target.components.dehydrater:ReadyToStart() then
            return false
        end
		act.target.components.dehydrater:StartDrying()
		return true
    end
end

-- Add the DEHYDRATE action
AddAction(DEHYDRATE)

-- I'm guessing this is boilerplate?
local State = GLOBAL.State
local TimeEvent = GLOBAL.TimeEvent
local EventHandler = GLOBAL.EventHandler
local FRAMES = GLOBAL.FRAMES

-- Define a custom state for toking a pipe
local toke_pipe = State({
	name = "toke_pipe",
	tags = { "doing", "playing" },

	-- Animation to play when the toking begins (based on horn)
	onenter = function(inst)
		inst.components.locomotor:Stop()
		inst.AnimState:Hide("ARM_carry") 
        inst.AnimState:Show("ARM_normal")
		inst.AnimState:PlayAnimation("action_uniqueitem_pre")
		inst.AnimState:PushAnimation("horn", false)
		
		--I tried using the symbol from pipe and swap_pipe but it wasn't working right so I took the modified horn.zip anim that the original Pipe mod author was using and changed it's name to swap_pipe_horn.
		--Unfortunately, I can't change the actual symbol name, so I'm stuck using "horn01" until I can get my own animation working.
		--The sole purpose of this command is to replace the horn symbol (graphic) used in the horn animation with a symbol for the pipe. 
		inst.AnimState:OverrideSymbol("horn01", "swap_pipe_horn", "horn01")

		if inst.components.inventory.activeitem then
			print("returning the active item after toke")
			inst.components.inventory:ReturnActiveItem()
		end
    end,

  	-- Not sure
	timeline =
    	{
        	TimeEvent(21*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
				inst:PerformBufferedAction()
        	end),
    	},

	-- Not sure
    events =
    	{
        	EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
        	end),
    	},

	-- Not sure
    onexit = function(inst)
        	if inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) then
            	inst.AnimState:Show("ARM_carry") 
            	inst.AnimState:Hide("ARM_normal")
        	end
    	end,
})

-- Add the pipe toke state
AddStategraphState("wilson", toke_pipe)

-- Define a custom state for smoking a joint
local toke_joint = State({
	name = "toke_joint", 
	tags = { "doing", "playing" },
	
	-- Animation to play when smoking begins 
	onenter = function(inst)
		inst.components.locomotor:Stop()
		inst.AnimState:Hide("ARM_carry") 
        inst.AnimState:Show("ARM_normal")
		inst.AnimState:PlayAnimation("action_uniqueitem_pre")
		inst.AnimState:PushAnimation("horn", false)
		
		--TODO: Joint animation still doesnt look right
		inst.AnimState:OverrideSymbol("horn01", "swap_joint", "joint")

		-- I guess return the thing to your hand?
		if inst.components.inventory.activeitem then
			inst.components.inventory:ReturnActiveItem()
		end
    end,

  	-- Not sure
	timeline =
    	{
        	TimeEvent(21*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
				inst:PerformBufferedAction()
        	end),
    	},

	-- Not sure
    events =
    	{
        	EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
        	end),
    	},

	-- Not sure	
    onexit = function(inst)
        	if inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) then
            	inst.AnimState:Show("ARM_carry") 
            	inst.AnimState:Hide("ARM_normal")
        	end
    	end,
})

-- Add the joint toking state
AddStategraphState("wilson", toke_joint)

-- Define a client toking. I cant rememember but I'm sure this is for multiplayer
local toke_client = State({
    	name = "toke_client",
    	tags = { "doing", "playing" },

    	-- Buffer toking action and set a timeout
    	onenter = function(inst)
        	inst.components.locomotor:Stop()
        	inst.AnimState:PlayAnimation("action_uniqueitem_pre")
        	inst.AnimState:PushAnimation("action_uniqueitem_lag", false)
        	inst:PerformPreviewBufferedAction()
        	inst.sg:SetTimeout(TIMEOUT)
    	end,

    	-- Not sure. Multiplayer related
    	onupdate = function(inst)
        	if inst:HasTag("doing") then
            		if inst.entity:FlattenMovementPrediction() then
                		inst.sg:GoToState("idle", "noanim")
            		end
        	elseif inst.bufferedaction == nil then
            		inst.sg:GoToState("idle")
        	end
    	end,

    	-- What to do if the action times out
    	ontimeout = function(inst)
        	inst:ClearBufferedAction()
        	inst.sg:GoToState("idle")
    	end,
})

-- Add the client toking state
AddStategraphState("wilson_client", toke_client)

-- If object is a pipe then do toke_pipe. Likewise for the joint.
AddStategraphActionHandler("wilson", ActionHandler(TOKE, function(inst, action)
    if action.invobject then
        if action.invobject:HasTag("pipe") then
            return "toke_pipe"
        elseif action.invobject:HasTag("joint") then
            return "toke_joint"
        end
    end
end)
)

-- Add the TOKE action handler
AddStategraphActionHandler("wilson_client", ActionHandler(TOKE, "toke_client"))

-- Add the TOKE action
local function toking(inst, doer, actions)
	table.insert(actions, ACTIONS.TOKE)
end

-- Add the DEHYDRATE action if the target is a dehydratable dehydrater
local function dehydratable(inst, doer, target, actions)
    if target:HasTag("dehydrater") and inst:HasTag("dehydratable") then
        table.insert(actions, ACTIONS.DEHYDRATE)
    end
end

-- Add the RUMMAGE action of the target has the readytodry or donedrying tags.
-- TODO: figure out why this is needed.
local function dehydrater(inst, doer, actions, right)
    if inst:HasTag("readytodry") or inst:HasTag("donedrying") then
        table.insert(actions, ACTIONS.RUMMAGE)
    end
end

-- Add base component actions to our custom components
AddComponentAction("INVENTORY", "tokeable", toking)
AddComponentAction("USEITEM", "dehydratable", dehydratable)
AddComponentAction("SCENE", "dehydrater", dehydrater)

-- Not sure but I'm sure its importnatn
local containers = GLOBAL.require("containers")
local Vector3 = GLOBAL.Vector3
local oldwidgetsetup = containers.widgetsetup

-- Set widget params for the dehydrater (really really seems redundant)
local dryerparam = 
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
		},
	},
	acceptsstacks = false,
    type = "cooker",
}

-- Check if item is dehydratable or already dried (sure this isn't redundant with component code??)
function dryerparam.itemtestfn(container, item, slot)
    return item:HasTag("dehydratable") or item:HasTag("dried_product")
end

-- Define widget button info (again seems redundant with component code)
function dryerparam.widget.buttoninfo.fn(inst)
	if inst.components.container ~= nil then
		GLOBAL.BufferedAction(inst.components.container.opener, inst, ACTIONS.DEHYDRATE):Do()
	elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
		GLOBAL.SendRPCToServer(GLOBAL.RPC.DoWidgetButtonAction, ACTIONS.DEHYDRATE.code, inst, ACTIONS.DEHYDRATE.mod_name)
	end
end
function dryerparam.widget.buttoninfo.validfn(inst)
	return inst:HasTag("readytodry")
end

-- wtf is this hideous wax??	
containers.widgetsetup = function(container, prefab, data)
    if not prefab and container.inst.prefab == "solar_dryer" then
        prefab = "solar_dryer"
		print("making prefab = solar_dryer")
		data = dryerparam
		print(data)
		print("endofdata")
   end
    oldwidgetsetup(container, prefab, data)
end
