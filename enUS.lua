local L = LibStub("AceLocale-3.0"):NewLocale("Incognito2", "enUS", true)

if not L then return end

-- Color values from ChatTypeInfo["PARTY"], ChatTypeInfo["RAID"], and ChatTypeInfo["RAID_WARNING"]
local PARTY_CHAT_COLOR = CreateColor(0.66666668653488, 0.66666668653488, 1, 1)
local RAID_CHAT_COLOR = CreateColor(1, 0.49803924560547, 0, 1)
local RAID_WARNING_CHAT_COLOR = CreateColor(1, 0.28235295414925, 0, 1)

L["Loaded"] = "Loaded"

-- Options
L["general_options"] = "General Options"

L["enable"] = "Enable"
L["enable_desc"] = "Enable adding your name to chat messages"

L["name"] = "Name"
L["name_desc"] = "The name to display in your chat messages when enabled"

L["hide_name_for_matching_chars"] = "Incognito2 will not add your name to any of the characters added below"

L["debug"] = "Debug"
L["debug_desc"] = "Enable debugging messages output. You probably don't want to enable this."

-- Chat Options
L["group_chat_options"] = "Group Chat Options"

L["guild"] = "Guild"
L["guild_desc"] = "Guild chat messages ("..GREEN_FONT_COLOR:WrapTextInColorCode("/g").." and "..GREEN_FONT_COLOR:WrapTextInColorCode("/o")..")"

L["party"] = "Party"
L["party_desc"] = "Party chat messages ("..PARTY_CHAT_COLOR:WrapTextInColorCode("/p")..")"

L["raid"] = "Raid"
L["raid_desc"] = "Raid chat messages ("..RAID_CHAT_COLOR:WrapTextInColorCode("/raid").." and "..RAID_WARNING_CHAT_COLOR:WrapTextInColorCode("/raidwarning")..")"

L["instance_chat"] = "Instance"
L["instance_chat_desc"] = "All instance chat messages ("..RAID_CHAT_COLOR:WrapTextInColorCode("/i").."). Examples include Battlegrounds, Arena, Party, Raid, etc."

L["channel_options"] = "Channel Options"
L["channels_desc"] = "Channel number or name. If using name, partial matches also count (ex. "..WHITE_FONT_COLOR:WrapTextInColorCode("\"General\"").." would match to both "..DEFAULT_CHAT_CHANNEL_COLOR:WrapTextInColorCode("General - Stormwind City").." and "..DEFAULT_CHAT_CHANNEL_COLOR:WrapTextInColorCode("General - Silvermoon City")..")"
L["channels_info"] = "Messages to the 'Say' channnel cannot be modified due to limitations set by WoW"

-- Slash command options
L["config"] = "Configuration"
L["config_desc"] = "Open configuration dialog"

L["list_add"] = "Add"
L["list_add_desc"] = "Type a value and press Enter to add it to the list"
L["list_remove_desc"] = "Click to remove"

L["exclude"] = "Exclude"
L["exclude_desc"] = "Add a character to hide your name when sending chat messages from them"
