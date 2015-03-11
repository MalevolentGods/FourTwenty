
--These are basically the custom animations and graphics that we're loading for the mod   
Assets=
{
	Asset("ANIM", "anim/pipe.zip"),
	Asset("ANIM", "anim/horn.zip"),
    Asset("ATLAS", "images/inventoryimages/pipe.xml"),
    Asset("ATLAS", "images/inventoryimages/weed_fresh.xml"),
	Asset("ATLAS", "images/inventoryimages/weed_dried.xml"),
	Asset("ATLAS", "images/inventoryimages/weed_seeds.xml"),
    Asset("ATLAS", "images/inventoryimages/g_house.xml"),
	Asset( "IMAGE", "minimap/g_house.tex" ),
    Asset( "ATLAS", "minimap/g_house.xml" ),
}
    AddMinimapAtlas("minimap/g_house.xml")

--These are all of the prefabs (items) that the mod is going to load. Each of these should have its own file in the scripts/prefabs folder. 
PrefabFiles = 
{
	"g_house",
	"weed_seeds",
	"weed_tree",
	"weed",
	"pipe",
	"horn",
}

--The only purpose of these variables is so that you don't always have to specify GLOBAL when typing the variable name. Instead of GLOBAL.STRINGS.NIGGER="you", you can type STRINGS.NIGGER="you"
Action = GLOBAL.Action
ActionHandler = GLOBAL.ActionHandler
STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH

--These variables set the displayed item name, the recipe description, and the character's speech text when you inspect the item. They could also be defined in the individual prefab files if you want.
STRINGS.NAMES.PIPE = "Wooden Bowl"
STRINGS.RECIPE_DESC.PIPE = "A freshly packed bowl!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.PIPE = "Just like Grandpa used to toke."

STRINGS.NAMES.G_HOUSE = "Advanced Farm"
STRINGS.RECIPE_DESC.G_HOUSE = "I have no idea what it does!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.G_HOUSE = "Your guess is as good as mine."

STRINGS.NAMES.WEED_TREE = "Weed Plant"
STRINGS.RECIPE_DESC.WEED_TREE = "Weeeeeed!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WEED_TREE = "It's flowers are smokable!"

STRINGS.RECIPE_DESC.WEED_SEEDS = "It's a pot seed!"
STRINGS.NAMES.WEED_SEEDS = "Weed Seeds"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WEED_SEEDS = "These are worth their weight in gold!"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.WEED_FRESH = "It's green and sticky. I should dry this first."
STRINGS.NAMES.WEED_FRESH = "Fresh Weed Bud"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.WEED_DRIED = "Look at the trichomes!"
STRINGS.NAMES.WEED_DRIED = "Dried Weed Bud"

--Load the existing drying rack so that we can make changes
AddPrefabPostInit("meatrack", function (inst)
    --Add the weed animation asset
	local assets=
	{
		Asset("ANIM", "anim/weed.zip"),
		Asset("ANIM", "anim/meat_rack_food.zip"),
		
	}
	--Add the weed_dried prefab
	local prefabs =
    {
		"weed",
    }

	local function onstartdrying_mod(inst, dryable)
		inst.AnimState:PlayAnimation("drying_pre")
		inst.AnimState:PushAnimation("drying_loop", true)
		if dryable == "weed_fresh" then
			inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", "humanmeat")
		else
			inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", dryable)
		end
	end

	local function setdone_mod(inst, product)
		inst.AnimState:PlayAnimation("idle_full")
		if product == "weed_dried" then
			inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", "humanmeat_dried")
		else
			inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", product)
		end
	end
	
	inst.components.dryer:SetStartDryingFn(onstartdrying_mod)
	--inst.components.dryer:SetDoneDryingFn(ondonedrying_mod)
    inst.components.dryer:SetContinueDryingFn(onstartdrying_mod)
	inst.components.dryer:SetContinueDoneFn(setdone_mod)
end)

--This variable will ultimately determine whether the weed_tree grows in winter or not. The value is used in the weed_tree.lua prefab file
--local Winter_Grow = (GetModConfigData("W_Grow")=="no")

--The original mod made it so that you could set the difficulty of the recipe in the configuration. It also had craftable seeds. I've just commented all of that out for now. 

--    local b_seeds = (GetModConfigData("b_seeds")=="no")
--    local easy = (GetModConfigData("greenhouserecipe")=="easy")
--    local normal = (GetModConfigData("greenhouserecipe")=="normal")

--   if easy then
--	local g_houserecipe = GLOBAL.Recipe("g_house",
--{ 
--	Ingredient("boards", 3),
--	Ingredient("silk", 3),
--	Ingredient("rope", 1)
--},
--	RECIPETABS.FARM, TECH.NONE, "g_house_placer" )                     
--    g_houserecipe.atlas = "images/inventoryimages/g_house.xml"

--    else if normal then
--    local g_houserecipe = GLOBAL.Recipe("g_house",
--{ 
--    Ingredient("boards", 3),
--    Ingredient("silk", 3),
--    Ingredient("rope", 2),
--    Ingredient("poop", 10)
--},
--    RECIPETABS.FARM, TECH.SCIENCE_ONE, "g_house_placer" )                     
--    g_houserecipe.atlas = "images/inventoryimages/g_house.xml"

--    else
--    local g_houserecipe = GLOBAL.Recipe("g_house",
--{ 
--    Ingredient("boards", 5),
--    Ingredient("silk", 6),
--    Ingredient("rope", 4),
--    Ingredient("poop", 10)
--},
--   RECIPETABS.FARM, TECH.SCIENCE_TWO, "g_house_placer" )                     
--    g_houserecipe.atlas = "images/inventoryimages/g_house.xml"
--    end
--end

--    if b_seeds then local bananarecipe = nil
--   else
--	local bananarecipe = GLOBAL.Recipe("weed_seeds",
--{ 
--	Ingredient("carrot_seeds", 1),
--	Ingredient("dragonfruit_seeds", 1)
--},
--	RECIPETABS.REFINE, TECH.SCIENCE_ONE )
--	bananarecipe.atlas = "images/inventoryimages/weed_seeds.xml"
--end


--This sets the recipe for the pipe
local piperecipe = Recipe("pipe", {Ingredient("twigs", 2), Ingredient("weed_fresh", 1,"images/inventoryimages/weed_fresh.xml")}, RECIPETABS.SURVIVAL, TECH.NONE)

--I think this sets the icon for the recipe in your display
piperecipe.atlas = "images/inventoryimages/pipe.xml"

--This defines the variable as a new action in the game. The Action() function takes a few different options, but 3 is the best default for reasons I can't remember
local TOKE = Action(3)	

--I think this variable determines what string to show over the mouse button icon when you hover over the item that has this action.  
TOKE.str = "Toke"

--This sets the internal name for this new action
TOKE.id = "TOKE"

--This variable is set to a function containing the actual stuff you want this action to do
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
	--This method executes the function bowlHit() as it's defined in the components/tokeable.lua file using the value of "act.doer" (DST speak for whoever is doing the action)
	act.invobject.components.tokeable:bowlHit(act.doer)
	--Says that this was successfull. You could come up with a way to determine it was unsuccessful if you want and add that as a condition to return false also, but nothing currently checks whether the action was successfull or not so it doesnt matter. 
	return true
end
--This method actually adds the action TOKE that we've defined above into the game. 
AddAction(TOKE)


--More variables for the StateChanges to come. 
--As best as I can tell, state changes are how you communicate things between the client and the server when you're playing DST. I still haven't figured them out entirely, but they were the key to getting the bowl animation to work.
local State = GLOBAL.State
local TimeEvent = GLOBAL.TimeEvent
local EventHandler = GLOBAL.EventHandler
local FRAMES = GLOBAL.FRAMES

--The first "state change" is created as the variable "toke" and the value is set to the method State() and all the crap that it contains
local toke = State({
	name = "toke",
    --not sure what these are for
	tags = { "doing", "playing" },

    --what to do when you enter the "toke" state
	onenter = function(inst)
		inst.components.locomotor:Stop()
		inst.AnimState:Hide("ARM_carry") 
        inst.AnimState:Show("ARM_normal")
		inst.AnimState:PlayAnimation("action_uniqueitem_pre")
		inst.AnimState:PushAnimation("horn", false)
		inst.AnimState:OverrideSymbol("horn01", "horn", "horn01")
			
		if inst.components.inventory.activeitem then
			inst.components.inventory:ReturnActiveItem()
		end
    end,

    --I guess the number of frames of the animation to play? Also the sound to play
	timeline =
    {
        TimeEvent(21*FRAMES, function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
			inst:PerformBufferedAction()
        end),
    },

	--Not really sure yet
    events =
    {
        EventHandler("animqueueover", function(inst)
			if inst.AnimState:AnimDone() then
				inst.sg:GoToState("idle")
			end
        end),
    },

	--What to do when leaving the "toke" state
    onexit = function(inst)
        if inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) then
            inst.AnimState:Show("ARM_carry") 
            inst.AnimState:Hide("ARM_normal")
        end
    end,})
--This method adds the "toke" state to existing bank of character states.
AddStategraphState("wilson", toke)


--I think this is the state that's executed by the client (person who connects to the server) instead of the host (person running the server). If it's a dedicated server then I guess everyone runs this instead of the regular toke.
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
--This method adds the toke_client state to the existing bank of client character states. I think.
AddStategraphState("wilson_client", toke_client)

--This method tells the game to enter the toke state when performing the TOKE action that we defined above.
AddStategraphActionHandler("wilson", ActionHandler(TOKE, "toke"))
--This method tells the game to enter the toke_client state when a connected client performs the TOKE action that we defined above.
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(TOKE, "toke_client"))

--This lets you set conditions under which to run the action. I don't have any conditions set.
local function toking(inst, doer, actions)
	table.insert(actions, GLOBAL.ACTIONS.TOKE)
end
--This method tells the game to add the tokeable component action to the existing list of component actions. The second value has to match the filename in the components directory.
--The ComponentAction is the real guts of the action. It's what the action actually does I guess. The method tokeable:bowlHit we referenced earlier will be defined inside the component action "tokeable"
AddComponentAction("INVENTORY", "tokeable", toking)

