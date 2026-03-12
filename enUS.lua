local L = LibStub("AceLocale-3.0"):NewLocale("Incognito2", "enUS", true)

if not L then return end

L["Loaded"] = "Loaded"

-- Options
L["general_options"] = "General Options"

L["enable"] = "Enable"
L["enable_desc"] = "Enable adding your name to chat messages."

L["name"] = "Name"
L["name_desc"] = "The name to display in your chat messages when enabled."

L["hideMatchingCharNames"] = "Hide Name For Matching Characters"
L["hideMatchingCharNames_desc"] = "Incognito2 will not add your name to any of the characters listed."

L["debug"] = "Debug"
L["debug_desc"] = "Enable debugging messages output. You probably don't want to enable this."

L["no_addon_opts"] = "AddOn options panel not found."

-- Chat Options
L["chat_options"] = "Chat Options"

L["guild"] = "Guild"
L["guild_desc"] = "Guild chat messages (/g and /o)."

L["party"] = "Party"
L["party_desc"] = "Party chat messages (/p)."

L["raid"] = "Raid"
L["raid_desc"] = "Raid chat messages (/raid and /raidwarning)."

L["instance_chat"] = "Instance"
L["instance_chat_desc"] = "All instance chat messages (/i). Examples include Battlegrounds, Arena, Party, Raid, etc."

L["channels"] = "Channels"
L["channels_desc"] = "Channel number or name. If using name, partial matches also count (ex. Adding \"General\" to the list would match to both \"General: Stormwind City\" and \"General: Silvermoon City\")"
L["channels_info"] = "Messages to the 'Say' channnel cannot be modified due to limitations set by WoW."

-- Slash command options
L["config"] = "Configuration"
L["config_desc"] = "Open configuration dialog."

L["list_add"] = "Add"
L["list_add_desc"] = "Type a value and press Enter to add it to the list."
L["list_remove_desc"] = "Click to remove this entry."

L["exclude"] = "Exclude"
L["exclude_desc"] = "Add a character to hide your name when sending chat messages from them."
