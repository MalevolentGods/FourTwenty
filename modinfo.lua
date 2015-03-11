
name = "FourTwenty"
description = "Finally, a reason to survive in the wilderness."
author = "Malevolent Gods"
version = "1.3.4"

forumthread = ""
priority = 0.346962880
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false

api_version = 10

icon_atlas = "pipe.xml"
icon = "pipe.tex"

 configuration_options =
{
	{
		name = "weed_tree_regions",
		label = "Weed Tree Regions",
		options =
		{
			{description = "Stone Biomes", data = 1},
			{description = "SBs+Marsh", data = 2},
			{description = "SBs+M+Forrest", data = 3},
			{description = "Everywhere", data = 4},
		},
		default = 4,
	},

	{
		name = "weed_tree_rate",
		label = "Weed Tree Rate",
		options =
		{
			{description = "Default again", data = 1.5},
			{description = "Super Rare", data = 0.3},
			{description = "Rare", data = 0.6},
			{description = "Default", data = 1.4},
			{description = "Common", data = 2.0},
			{description = "Lots!", data = 3.3},
		},
		default = 1.4,
	},
}