--Main mod script
-------------------------
  
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
    --Asset("ATLAS", "images/inventoryimages/g_house.xml"),
	Asset("ATLAS", "images/inventoryimages/solar_dryer.xml"),
	
	--Asset("IMAGE", "minimap/g_house.tex" ),    					--Starting to wonder if you even have to load the tex here, or if the XML is enough.
   -- Asset("ATLAS", "minimap/g_house.xml" ),
	Asset("IMAGE", "minimap/weed_tree.tex" ),
    Asset("ATLAS", "minimap/weed_tree.xml" ),
}


AddMinimapAtlas("minimap/weed_tree.xml")
--AddMinimapAtlas("minimap/g_house.xml")

 
PrefabFiles = 
{
	--"g_house",
	"weed_seeds",
	"weed_tree",
	"weed",
	"pipe",
	"joint",
	"solar_dryer"
}


ACTIONS = GLOBAL.ACTIONS
Action = GLOBAL.Action
ActionHandler = GLOBAL.ActionHandler
STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH
SpawnPrefab = GLOBAL.SpawnPrefab


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
STRINGS.RECIPE_DESC.SOLAR_DRYER = "Solar Dryer!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SOLAR_DYER = "Solar Dryer!"

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

--This variable will ultimately determine whether the weed_tree grows in winter or not. The value is used in the weed_tree.lua prefab file
--local Winter_Grow = (GetModConfigData("W_Grow")=="no")

--Creates the recipe for the Advanced Farm that we're not really using yet.
--local g_houserecipe = Recipe("g_house",
--	{ 
--		Ingredient("boards", 5),
--    	Ingredient("silk", 6),
--    	Ingredient("rope", 4),
--   	Ingredient("poop", 10)
--	},
--   	RECIPETABS.FARM, TECH.SCIENCE_TWO, "g_house_placer" )

--Sets the recipe image for the Advanced Farm that we're not really using
--g_houserecipe.atlas = "images/inventoryimages/g_house.xml" 



local piperecipe = Recipe("pipe", {Ingredient("twigs", 2), Ingredient("weed_fresh", 1,"images/inventoryimages/weed_fresh.xml")}, RECIPETABS.SURVIVAL, TECH.NONE)
piperecipe.atlas = "images/inventoryimages/pipe.xml"

local jointrecipe = Recipe("joint", {Ingredient("papyrus", 1), Ingredient("weed_dried", 2,"images/inventoryimages/weed_dried.xml")}, RECIPETABS.SURVIVAL, TECH.NONE)
jointrecipe.atlas = "images/inventoryimages/joint.xml"

local dehydraterrecipe = Recipe("solar_dryer", {Ingredient("twigs", 3)}, RECIPETABS.SURVIVAL, TECH.NONE, "solar_dryer_placer")
dehydraterrecipe.atlas = "images/inventoryimages/solar_dryer.xml"



local TOKE = Action(3)	
TOKE.str = "Toke"
TOKE.id = "TOKE"
TOKE.fn = function(act)
	
	local stringArray = {}  --Based on Willard's suggestion I've made the speech text for this action random, so this variable is created as an array
	
	--These are the different values in the array, which become the possible things for the character to say when performing this action
	stringArray[1] = "I love smoking in the woods"
	stringArray[2] = "Whooooooaaaaaa..... That's dank shit!"
	stringArray[3] = "It tastes like blueberries."
	stringArray[4] = "It tastes even better when you grow it yourself."
	
	--The value of this variable is a random number. The number in the math.random() function should match the number of stringArray values declared above
	local stringChoice = math.random(4)
	
	--This method makes the person performing the action say the string that matches the value produced by math.random()
	act.doer.components.talker:Say(stringArray[stringChoice])
	act.invobject.components.tokeable:bowlHit(act.doer)
	
	return true
end


AddAction(TOKE)


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

AddAction(DEHYDRATE)





local State = GLOBAL.State
local TimeEvent = GLOBAL.TimeEvent
local EventHandler = GLOBAL.EventHandler
local FRAMES = GLOBAL.FRAMES


local toke_pipe = State({

	name = "toke_pipe",
    
	tags = { "doing", "playing" },

    
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

   
	timeline =
    	{
        	TimeEvent(21*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
				inst:PerformBufferedAction()
        	end),
    	},

	
    events =
    	{
        	EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
        	end),
    	},

	
    onexit = function(inst)
        	if inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) then
            	inst.AnimState:Show("ARM_carry") 
            	inst.AnimState:Hide("ARM_normal")
        	end
    	end,
})


AddStategraphState("wilson", toke_pipe)


local toke_joint = State({

	name = "toke_joint",
  
	tags = { "doing", "playing" },

  
	onenter = function(inst)
		inst.components.locomotor:Stop()
		inst.AnimState:Hide("ARM_carry") 
        inst.AnimState:Show("ARM_normal")
		inst.AnimState:PlayAnimation("action_uniqueitem_pre")
		inst.AnimState:PushAnimation("horn", false)
		

		--Joint animation still doesnt look right
		inst.AnimState:OverrideSymbol("horn01", "swap_joint", "joint")

		if inst.components.inventory.activeitem then
			inst.components.inventory:ReturnActiveItem()
		end
    end,

  
	timeline =
    	{
        	TimeEvent(21*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
				inst:PerformBufferedAction()
        	end),
    	},

	
    events =
    	{
        	EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
        	end),
    	},

	
    onexit = function(inst)
        	if inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) then
            	inst.AnimState:Show("ARM_carry") 
            	inst.AnimState:Hide("ARM_normal")
        	end
    	end,
})


AddStategraphState("wilson", toke_joint)


local toke_client = State({

    	name = "toke_client",
    	tags = { "doing", "playing" },

    	onenter = function(inst)
        	inst.components.locomotor:Stop()
        	inst.AnimState:PlayAnimation("action_uniqueitem_pre")
        	inst.AnimState:PushAnimation("action_uniqueitem_lag", false)
        	inst:PerformPreviewBufferedAction()
        	inst.sg:SetTimeout(TIMEOUT)
    	end,

    	onupdate = function(inst)
        	if inst:HasTag("doing") then
            		if inst.entity:FlattenMovementPrediction() then
                		inst.sg:GoToState("idle", "noanim")
            		end
        	elseif inst.bufferedaction == nil then
            		inst.sg:GoToState("idle")
        	end
    	end,

    	ontimeout = function(inst)
        	inst:ClearBufferedAction()
        	inst.sg:GoToState("idle")
    	end,
})


AddStategraphState("wilson_client", toke_client)

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


AddStategraphActionHandler("wilson_client", ActionHandler(TOKE, "toke_client"))


local function toking(inst, doer, actions)
	table.insert(actions, ACTIONS.TOKE)
end

local function dehydratable(inst, doer, target, actions)
    if target:HasTag("dehydrater") and inst:HasTag("dehydratable") then
        table.insert(actions, ACTIONS.DEHYDRATE)
    end
end

local function dehydrater(inst, doer, actions, right)
    if inst:HasTag("readytodry") or inst:HasTag("donedrying") then
        table.insert(actions, ACTIONS.RUMMAGE)
    end
end


AddComponentAction("INVENTORY", "tokeable", toking)

AddComponentAction("USEITEM", "dehydratable", dehydratable)

AddComponentAction("SCENE", "dehydrater", dehydrater)


--AddPrefabPostInit("berries", function(inst)
--	inst:AddComponent("dehydratable")
--    inst.components.dehydratable:SetProduct("weed_dried")
--    inst.components.dehydratable:SetDryTime(TUNING.BASE_COOK_TIME)
--end)

local containers = GLOBAL.require("containers")
local Vector3 = GLOBAL.Vector3
local oldwidgetsetup = containers.widgetsetup

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

function dryerparam.itemtestfn(container, item, slot)
    return item:HasTag("dehydratable") or item:HasTag("dried_product")
end

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
