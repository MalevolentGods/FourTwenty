--- weed_seeds.lua ---
------------------------------------------------------
-- Type: Prefab
-- Description: Creates and defines weed seeds
------------------------------------------------------

-- Not sure if we need this or not or why. I copied from some unrelated prefab.
require "prefabutil"

-- Inventory image
local assets =
{
	Asset("ATLAS", "images/inventoryimages/weed_seeds.xml"),
	Asset("IMAGE", "images/inventoryimages/weed_seeds.tex"),
}

-- Dependent prefabs
local prefabs =
{
	"weed_tree",
} 

-- Test the ground to determine if the seed can be planted where the person is trying to place it
local notags = {'NOBLOCK', 'player', 'FX'}
local function test_ground(inst, pt)

	-- Check the type of ground you're standing on
	local tiletype = GetGroundTypeAtPosition(pt)

	-- Ground is ok if the tile is NOT one of the following types: rocky, road, impassable, underrock, woodloor, carpet, checker or underground
	local ground_OK = tiletype ~= GROUND.ROCKY and tiletype ~= GROUND.ROAD and tiletype ~= GROUND.IMPASSABLE and
	tiletype ~= GROUND.UNDERROCK and tiletype ~= GROUND.WOODFLOOR and 
	tiletype ~= GROUND.CARPET and tiletype ~= GROUND.CHECKER and tiletype < GROUND.UNDERGROUND

	-- If the ground is valid and free of entities, return true
	if ground_OK then

		-- I think this checks the current ground coordinates for exisiting entities
		local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil, notags) -- or we could include a flag to the search?

		-- Set the minimum space between plantings
		local min_spacing = inst.components.deployable.min_spacing or 2

		-- Return false if blah, blah, blah
		for k, v in pairs(ents) do
			if v ~= inst and v.entity:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				if distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing*min_spacing then
					return false
				end
			end
		end
		return true
	end

	-- If ground is not valid, return false
	return false
end

-- Define what to do when the seeds are planted.
local function OnDeploy (inst, pt) 
	local weed_seeds = SpawnPrefab("weed_tree_barren")
	if weed_seeds then
		weed_seeds.Transform:SetPosition(pt.x, pt.y, pt.z)
		--inst.AnimState:PlayAnimation("idle_loop")
		inst.components.stackable:Get():Remove()
		inst.Transform:SetScale(3,3,3)
	end
end

-- Define the weed seeds
local function fn(Sim)

	-- Boilerplate
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()	
	MakeInventoryPhysics(inst)

	-- Define the animation 
	inst.AnimState:SetBank("seeds")
	inst.AnimState:SetBuild("seeds")
	inst.AnimState:SetRayTestOnBB(true)
	inst.AnimState:PlayAnimation("idle")
	
	-- Still trying to grok this one. Required for multiplayer.
    if not TheWorld.ismastersim then
    	return inst
	end

	-- Still groking this one
    inst.entity:SetPristine()

    -- Make the seeds edible and tune
	inst:AddComponent("edible")
	inst.components.edible.foodtype = "SEEDS"
	inst.components.edible.healthvalue = TUNING.HEALING_TINY/2
	inst.components.edible.hungervalue = TUNING.CALORIES_TINY

	-- Make the seeds stackable and set the max size
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	-- Make the seeds tradable
	inst:AddComponent("tradable")

	-- Make the seeds inspectable
	inst:AddComponent("inspectable")

	-- Make the seeds and inventory item and set the image
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/weed_seeds.xml"
	
	-- Make the seeds perishable and tune
	--inst:AddComponent("perishable")
	--inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
	--inst.components.perishable:StartPerishing()
	--inst.components.perishable.onperishreplacement = "spoiled_food"
	
	-- Make the seeds into bait (are you sure about this)
	inst:AddComponent("bait")

	-- Make the seeds deployable and define deployment
	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = OnDeploy

	-- Return the thing
	return inst
end

-- Create a predefined prefab
return Prefab( "common/inventory/weed_seeds", fn, assets),
	MakePlacer( "weed_seeds_placer", "weed_plant", "weed_plant", "placer") 
