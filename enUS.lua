local L = LibStub("AceLocale-3.0"):NewLocale("Incognito2", "enUS", true)

if not L then return end

L["Loaded"] = "Loaded."

-- Options
L["general_options"] = "General Options"

L["enable"] = "Enable"
L["enable_desc"] = "Enable adding your name to chat messages."

L["name"] = "Name"
L["name_desc"] = "The name to display in your chat messages when enabled."

L["hideMatchingCharNames"] = "Hide Name For Matching Characters"
L["hideMatchingCharNames_desc"] = "Incognito2 will not add your name to any of the characters listed."
L["hideMatchingCharNames_info"] = "Names should be separated by commas. By default, Incognito2 hides your name when it matches your current character's name."

L["debug"] = "Debug"
L["debug_desc"] = "Enable debugging messages output. You probably don't want to enable this."

L["no_addon_opts"] = "AddOn options panel not found."

-- Chat Options
L["chat_options"] = "Chat Options"

L["guild"] = "Guild"
L["guild_desc"] = "Add name to guild chat messages (/g and /o)."

L["party"] = "Party"
L["party_desc"] = "Add name to party chat messages (/p)."

L["raid"] = "Raid"
L["raid_desc"] = "Add name to raid chat messages (/raid)."

L["instance_chat"] = "Instance"
L["instance_chat_desc"] = "Add name to instance chat messages, e.g., LFR and battlegrounds (/i)."

L["channel"] = "Channel"
L["channel_desc"] = "Add name to chat messages in this custom channel."
L["channel_info"] = "Messages to the 'Say' channnel cannot be modified due to limitations set by WoW."

-- Slash command options
L["config"] = "Configuration"
L["config_desc"] = "Open configuration dialog."

L["exclude"] = "Exclude"
L["exclude_desc"] = "Add a character to hide your name when sending chat messages from them."
