--- modworldgenmain.lua ---
------------------------------------------------------
-- Description: Define how weed trees are spawned in the world
------------------------------------------------------

GLOBAL.require("map/terrain")

-- Get target regions and rate from the config
-- TODO: serious refactoring. 
local weed_tree_regions = (GetModConfigData("weed_tree_regions"))
local weed_tree_rate = (GetModConfigData("weed_tree_rate"))

-- Set spawn rates based on mod config
-- TODO: serious refactoring
if weed_tree_regions~=nil then
	if weed_tree_regions == 1 then
		GLOBAL.terrain.rooms.CrappyForest.contents.distributeprefabs.weed_tree = (weed_tree_rate/40)
		GLOBAL.terrain.rooms.Forest.contents.distributeprefabs.weed_tree = (weed_tree_rate/80)
		GLOBAL.terrain.rooms.DeepForest.contents.distributeprefabs.weed_tree = (weed_tree_rate/40)
		GLOBAL.terrain.rooms.CrappyDeepForest.contents.distributeprefabs.weed_tree = (weed_tree_rate/20)
		--GLOBAL.terrain.rooms.BGForest.contents.distributeprefabs.weed_tree = (weed_tree_rate/60)
		print("Spawned Weed Trees in Forest Biomes")
	end
	
	if weed_tree_regions == 2 then
		GLOBAL.terrain.rooms.BGGrass.contents.distributeprefabs.weed_tree = (weed_tree_rate/50)
		GLOBAL.terrain.rooms.Plain.contents.distributeprefabs.weed_tree = (weed_tree_rate/50)
		GLOBAL.terrain.rooms.BarePlain.contents.distributeprefabs.weed_tree = (weed_tree_rate/80)
		GLOBAL.terrain.rooms.BGSavanna.contents.distributeprefabs.weed_tree = (weed_tree_rate/90)
		print("Spawned Weed Trees in Plains and Grass Biomes")
	end
	
	if weed_tree_regions == 3 then
		GLOBAL.terrain.rooms.Marsh.contents.distributeprefabs.weed_tree = (weed_tree_rate/16)
		GLOBAL.terrain.rooms.BGMarsh.contents.distributeprefabs.weed_tree = (weed_tree_rate/16)
		GLOBAL.terrain.rooms.SlightlyMermySwamp.contents.distributeprefabs.weed_tree = (weed_tree_rate/16)
		print("Spawned Weed Trees in the Swamp Biomes")
	end

	if weed_tree_regions == 4 then
		GLOBAL.terrain.rooms.CrappyForest.contents.distributeprefabs.weed_tree = (weed_tree_rate/40)
		GLOBAL.terrain.rooms.Forest.contents.distributeprefabs.weed_tree = (weed_tree_rate/80)
		GLOBAL.terrain.rooms.DeepForest.contents.distributeprefabs.weed_tree = (weed_tree_rate/40)
		GLOBAL.terrain.rooms.CrappyDeepForest.contents.distributeprefabs.weed_tree = (weed_tree_rate/20)
		GLOBAL.terrain.rooms.BGForest.contents.distributeprefabs.weed_tree = (weed_tree_rate/60)
		GLOBAL.terrain.rooms.BGGrass.contents.distributeprefabs.weed_tree = (weed_tree_rate/50)
		GLOBAL.terrain.rooms.Plain.contents.distributeprefabs.weed_tree = (weed_tree_rate/50)
		GLOBAL.terrain.rooms.BarePlain.contents.distributeprefabs.weed_tree = (weed_tree_rate/80)
		GLOBAL.terrain.rooms.BGSavanna.contents.distributeprefabs.weed_tree = (weed_tree_rate/90)
		GLOBAL.terrain.rooms.BGNoise.contents.distributeprefabs.weed_tree = (weed_tree_rate/60)	
		GLOBAL.terrain.rooms.Marsh.contents.distributeprefabs.weed_tree = (weed_tree_rate/16)
		GLOBAL.terrain.rooms.BGMarsh.contents.distributeprefabs.weed_tree = (weed_tree_rate/16)
		GLOBAL.terrain.rooms.SlightlyMermySwamp.contents.distributeprefabs.weed_tree = (weed_tree_rate/16)
		GLOBAL.terrain.rooms.BGDirt.contents.distributeprefabs.weed_tree = (weed_tree_rate/80)
		print("Spawned Weed Trees almost fucking everywhere!")
	end
else
	-- Sanity check you should never need
	print("weed_tree_regions is null")
end

-- Don't spawn on the road, wood floor, carpet, or checker tiles.
-- TODO revisit these filters. 
GLOBAL.terrain.filter.weed_tree = {GLOBAL.GROUND.ROAD, GLOBAL.GROUND.WOODFLOOR, GLOBAL.GROUND.CARPET, GLOBAL.GROUND.CHECKER}




