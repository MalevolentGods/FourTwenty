--- weed_tree.lua ---
------------------------------------------------------
-- Type: Prefab
-- Description: Creates and defines the weed plant
------------------------------------------------------

-- Custom animation/textures
local assets=
{
	Asset("ANIM", "anim/weed_tree.zip"),
}

-- Load any prefabs we're going to reference
local prefabs =
{
    	"weed_fresh",
    	"charcoal",
    	"log",
    	"twigs",
    	"ash"
}    

-- Display a growing tree 
local function onregenfn(inst)
	inst.AnimState:PlayAnimation("grow") 
	inst.AnimState:PushAnimation("idle_loop", true)
	inst.Picked = false
	 
end

-- Display a full-grown tree
local function makefullfn(inst)
	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.Picked = false
	 
end

-- Display a picked tree
local function onpickedfn(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
	inst.AnimState:PlayAnimation("pick") 
	inst.AnimState:PushAnimation("idle_barren")
	inst.Picked = true
end

-- Display a barren tree
local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation("idle_barren")
	inst.Picked = true
	 
end

-- Spawn a log when the stump is dug up
local function dug(inst)
	inst.components.lootdropper:SpawnLootPrefab("log")
	inst:Remove()
end

-- Turn the tree into a stump
local function setupstump(inst)
	inst.stump = true
	inst:RemoveComponent("pickable")
	inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(dug)
	inst.AnimState:PlayAnimation("idle_stump")
end

-- When the tree is chopped, drop a log, twigs, and a weed bud, then make a stump
local function chopped(inst, worker)
	
	-- You cant chop a stump, dawg
	if inst.stump then
		return
	end

	-- Only make the axe sound under certain conditions. Not sure why I did this.
	if not worker or (worker and not worker:HasTag("playerghost")) then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
	end

	-- If the tree is burnt, drop charcoal and remove tree
	if inst.burnt then
		inst:RemoveComponent("workable")
		inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
		inst.components.lootdropper:SpawnLootPrefab("charcoal")
		inst.persists = false
		inst.AnimState:PlayAnimation("chop_burnt")
		inst:DoTaskInTime(50*FRAMES, function() inst:Remove() end)
	
	-- If the tree is not burnt, drop the normal loot and leave a stump
	else              
		inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")

		-- Drop standard tree loot
		inst.components.lootdropper:SpawnLootPrefab("log")
		inst.components.lootdropper:SpawnLootPrefab("twigs")
		inst.components.lootdropper:SpawnLootPrefab("twigs")

		-- Only drop a weed bud if the tree was actually ripe
		if inst.components.pickable and inst.components.pickable.canbepicked then
			inst.components.lootdropper:SpawnLootPrefab("weed_fresh")
		end

		-- Create a stump
		setupstump(inst)

		-- Play tree-fall animation
		if inst.Picked == true then
			inst.AnimState:PlayAnimation("fall_barren")
		else
			inst.AnimState:PlayAnimation("fall")
		end		
		inst.AnimState:PushAnimation("idle_stump")
	end

end

-- Chopping animation (tree shake)
local function chop(inst, worker)
	if inst.Picked == true then
		inst.AnimState:PlayAnimation("chop_barren")
	else
		inst.AnimState:PlayAnimation("chop")
	end
	if inst.Picked == true then
		inst.AnimState:PushAnimation("idle_barren", true)
	else
		inst.AnimState:PushAnimation("idle_loop", true)
	end
	if not worker or (worker and not worker:HasTag("playerghost")) then
    	inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")         
    end
end

-- When the tree starts to burn, set the burnt flag and remove the pickable attribute
local function startburn(inst)
	inst.burnt = true
    if inst.components.pickable then
       	inst:RemoveComponent("pickable")
    end
end

-- When the tree has finished burning, make it into a typical burnt tree (or ash if stump)
local function makeburnt(inst)
	inst.burnt = true
	
	inst:RemoveComponent("burnable")
	inst:RemoveComponent("propagator")
	inst:RemoveComponent("pickable")

	if inst.stump then
		inst.components.lootdropper:SpawnLootPrefab("ash")
		inst:Remove()
	else
		inst.AnimState:PlayAnimation("burnt")
		inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    	inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    	inst.components.workable:SetWorkLeft(1)
    end
end

-- Save the tree state (stump or burnt)
local function onsave(inst, data)
	data.stump = inst.stump
	data.burnt = inst.burnt
	data.barren = inst.Picked 
end

-- Load the tree state (stump or burnt)
local function onload(inst, data)
	if data and data.stump then
		setupstump(inst)
	elseif data and data.burnt then
		makeburnt(inst)
	elseif data and data.barren then
		makeemptyfn(inst)
	end
end

-- Create a populated weed tree  
local function full_fn(Sim)
	local inst = CreateEntity()

	-- Still fully groking but it seems boiler plate
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	-- Set clipping
	MakeObstaclePhysics(inst,.5)

	-- Make the tree show up on the minimap and set its icon
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "weed_tree.tex" )
	
	-- Set animation parameters
    inst.AnimState:SetBank("weed_tree")
    inst.AnimState:SetBuild("weed_tree")
    inst.AnimState:PlayAnimation("idle_loop",true)
    inst.AnimState:SetTime(math.random()*2)
    inst.Transform:SetScale(.5,.5,.5)

    -- Still trying to grok this one. Needed for multiplayer.
    if not TheWorld.ismastersim then
		return inst
	end

	-- Not sure about this one yet either
    inst.entity:SetPristine()

    -- Make the tree something pickable
	inst:AddComponent("pickable")
	inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
	
	-- Define what's going to grow and the animations involved
	inst.components.pickable:SetUp("weed_fresh", TUNING.CAVE_BANANA_GROW_TIME) --Just easier than setting by hand. Equals 4 days basically.
	inst.components.pickable.onregenfn = onregenfn
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.makefullfn = makefullfn
	
	-- Spawn un-picked
	inst.Picked = false

	-- Make the tree something that can be chopped
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(chopped)
    inst.components.workable:SetOnWorkCallback(chop)

    -- Give the tree the ability to drop loot
	inst:AddComponent("lootdropper")
    
    -- Make the tree inspectable
	inst:AddComponent("inspectable")    
    
    -- Make the tree burnable  
    MakeMediumBurnable(inst)

    -- I think this makes it growable?
    MakeSmallPropagator(inst)

    -- Make the tree unable to grow in winter
	MakeNoGrowInWinter(inst)

	-- How to burn
    inst.components.burnable:SetOnIgniteFn(startburn)
	inst.components.burnable:SetOnBurntFn(makeburnt)

	-- Save the tree state on save
    inst.OnSave = onsave

    -- Load the tree state on load
    inst.OnLoad = onload
  
    return inst
end

-- Create a populated weed tree  
local function barren_fn(Sim)
	local inst = CreateEntity()

	-- Still fully groking but it seems boiler plate
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	-- Set clipping
	MakeObstaclePhysics(inst,.5)

	-- Make the tree show up on the minimap and set its icon
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "weed_tree.tex" )
	
	-- Set animation parameters
    inst.AnimState:SetBank("weed_tree")
    inst.AnimState:SetBuild("weed_tree")
    inst.AnimState:PlayAnimation("idle_barren",true)
    inst.AnimState:SetTime(math.random()*2)
    inst.Transform:SetScale(.5,.5,.5)

    -- Still trying to grok this one. Needed for multiplayer.
    if not TheWorld.ismastersim then
		return inst
	end

    inst:SetPrefabNameOverride("weed_tree")

	-- Not sure about this one yet either
    inst.entity:SetPristine()

    -- Make the tree something pickable
	inst:AddComponent("pickable")
	inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
	
	-- Define what's going to grow and the animations involved
	inst.components.pickable:SetUp("weed_fresh", TUNING.CAVE_BANANA_GROW_TIME/4) --Just easier than setting by hand. Equals 4 days basically.
	inst.components.pickable.onregenfn = onregenfn
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.makefullfn = makefullfn
	
	-- Spawn un-picked
	inst.Picked = true

	-- Make the tree something that can be chopped
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(chopped)
    inst.components.workable:SetOnWorkCallback(chop)

    -- Give the tree the ability to drop loot
	inst:AddComponent("lootdropper")
    
    -- Make the tree inspectable
	inst:AddComponent("inspectable")    
    
    -- Make the tree burnable  
    MakeMediumBurnable(inst)

    -- I think this makes it growable?
    MakeSmallPropagator(inst)

    -- Make the tree unable to grow in winter
	MakeNoGrowInWinter(inst)

	-- How to burn
    inst.components.burnable:SetOnIgniteFn(startburn)
	inst.components.burnable:SetOnBurntFn(makeburnt)

	-- Save the tree state on save
    inst.OnSave = onsave

    -- Load the tree state on load
    inst.OnLoad = onload
  
    return inst
end

-- Return the prefab as defined by its parameters
return Prefab("weed_tree", full_fn, assets, prefabs),
    Prefab("weed_tree_barren", barren_fn, assets, prefabs)
