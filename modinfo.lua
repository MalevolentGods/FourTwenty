--- modinfo.lua ---
------------------------------------------------------
-- Description: Defines some basic information about the mod along with any configuration options.
------------------------------------------------------------------------------------------------

-- Mod metadata
name = "FourTwenty"
description = "Finally, a reason to survive in the wilderness."
author = "Malevolent Gods"
version = "1.9.7"

-- TODO: Create forum thread
forumthread = ""

-- Set the mod load priority. Could probably use tuning.
priority = 0.346962880

-- Boilerplate-ish
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false

-- Sane default API. May well change in the future.
api_version = 10

-- Set the mod icon to show in-game
icon_atlas = "FourTwenty.xml"
icon = "FourTwenty.tex"

-- Define the mod's configuration options
configuration_options =
{
	{
		name = "enable_seeds",
		label = "Weed Seeds (beta)",
		options =
		{
			{description = "ENABLE", data = 1},
			{description = "DISABLE", data = 2},
		},
		default = 1,
	},
		{
		name = "enable_dryer",
		label = "Solar Dryer (beta)",
		options =
		{
			{description = "ENABLE", data = 1},
			{description = "DISABLE", data = 2},
		},
		default = 2,
	},
		{
		name = "weed_tree_regions",
		label = "Weed Spawn Regions",
		options =
		{
			{description = "Forests", data = 1},
			{description = "Plains", data = 2},
			{description = "Swamps", data = 3},
			{description = "Everywhere", data = 4},
		},
		default = 4,
	},
	{
		name = "weed_tree_rate",
		label = "Weed Spawn Rate",
		options =
		{
			{description = "Rare", data = 0.2},
			{description = "Uncommon", data = 0.5},
			{description = "Common", data = 1},
			{description = "Plentiful", data = 2},
			{description = "Stonerland", data = 4},
		},
		default = 1,
	},
}
