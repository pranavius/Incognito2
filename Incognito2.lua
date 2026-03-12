local addonName, Incognito2 = ...

Incognito2 = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

-- Utility Functions

local function DebugPrint(...)
	if Incognito2.db.profile.debug then print(HEIRLOOM_BLUE_COLOR:WrapTextInColorCode("[Incognito2]"), ...) end
end

local function DebugDump(value, startKey)
	if Incognito2.db.profile.debug then DevTools_Dump(value, startKey) end
end

local function SplitString(input, separator)
    local result = {}
	if input == nil then
		return result
	end

    for value in string.gmatch(input, "([^" .. separator .. "]+)") do
        table.insert(result, value:match("^%s*(.-)%s*$")) -- Trim spaces
    end
    return result
end

local function ContainsElement(table, value)
    for _, v in ipairs(table) do
        if strlower(v) == strlower(value) then
            return true
        end
    end
    return false
end

local Options = {
	type = "group",
	name = addonName,
	get = function(item) return Incognito2.db.profile[item[#item]] end,
	set = function(item, value) Incognito2.db.profile[item[#item]] = value end,
	args = {
		options = {
			order = 1,
			type = "group",
			name = L["general_options"],
			inline = true,
			get = function(item) return Incognito2.db.profile[item[#item]] end,
			set = function(item, value) Incognito2.db.profile[item[#item]] = value end,
			args = {
				enable = {	
					order = 1,
					type = "toggle",
					width = "full",
					name = L["enable"],
					desc = L["enable_desc"],
				},
				name = {
					order = 2,
					type = "input",
					name = L["name"],
					desc = L["name_desc"],
				},
				hideMatchingCharNames = {
					order = 3,
					type = "input",
					width = "full",
					name = L["hideMatchingCharNames"],
					desc = L["hideMatchingCharNames_desc"],
				},
				hideMatchingCharNamesInfo = {
					order = 4,
					type = "description",
					name = LEGENDARY_ORANGE_COLOR:WrapTextInColorCode(L["hideMatchingCharNames_info"])
				},
				empty = {
					order = 5,
					type = "description",
					name = " "
				}
			}
		},
		chatOptions = {
			order = 2,
			type = "group",
			name = L["chat_options"],
			inline = true,
			get = function(item) return Incognito2.db.profile[item[#item]] end,
			set = function(item, value) Incognito2.db.profile[item[#item]] = value end,
			args = {
				guild = {
					order = 1,
					type = "toggle",
					width = "full",
					name = L["guild"],
					desc = L["guild_desc"],
				},
				party = {
					order = 2,
					type = "toggle",
					width = "full",
					name = L["party"],
					desc = L["party_desc"],
				},
				raid = {
					order = 3,
					type = "toggle",
					width = "full",
					name = L["raid"],
					desc = L["raid_desc"],
				},
				instance_chat = {
					order = 4,
					type = "toggle",
					width = "full",
					name = L["instance_chat"],
					desc = L["instance_chat_desc"],
				},
				channel = {
					order = 5,
					type = "input",
					name = L["channel"],
					desc = L["channel_desc"],
				},
				channelInfo = {
					order = 6,
					type = "description",
					name = LEGENDARY_ORANGE_COLOR:WrapTextInColorCode(L["channel_info"])
				},
				empty = {
					order = 7,
					type = "description",
					name = " "
				}
			}
		},
		debug = {
			order = 3,
			type = "toggle",
			name = L["debug"],
			desc = L["debug_desc"],
		}
	}
}

local Defaults = {
	profile = {
		enable = true,
        name = nil,
		guild = true,
		party = false,
		raid = false,
		instance_chat = false,
		debug = false,
		channel = nil,
		hideMatchingCharNames = nil,
	},
}

local SlashOptions = {
	type = "group",
	handler = Incognito2,
	get = function(item) return Incognito2.db.profile[item[#item]] end,
	set = function(item, value)
		if strlower(item[#item]) == strlower(L["exclude"]) then
			if not Incognito2.db.profile.hideMatchingCharNames or Incognito2.db.profile.hideMatchingCharNames == "" then
				Incognito2.db.profile.hideMatchingCharNames = value
			elseif not ContainsElement(SplitString(Incognito2.db.profile.hideMatchingCharNames, ","), value) then
				Incognito2.db.profile.hideMatchingCharNames = Incognito2.db.profile.hideMatchingCharNames .. "," .. value
			else
				print(PURE_GREEN_COLOR:WrapTextInColorCode("Incognito2: Name already excluded from appearing on character ".. value))
			end
		else
			Incognito2.db.profile[item[#item]] = value
		end
	end,
	args = {
		enable = {
			type = "toggle",
			name = L["enable"],
			desc = L["enable_desc"],
		},
		name = {
			type = "input",
			name = L["name"],
			desc = L["name_desc"],
		},
		exclude = {
			type = "input",
			name = L["exclude"],
			desc = L["exclude_desc"],
		},
		config = {
			type = "execute",
			name = L["config"],
			desc = L["config_desc"],
			func = function() Settings.OpenToCategory(Incognito2.categoryID) end,
		},
	},
}

local SlashCmds = { "inc", "incognito" }

local character_name
-- Initialization
function Incognito2:OnInitialize()
	-- Load database
	self.db = LibStub("AceDB-3.0"):New("Incognito2DB", Defaults, "Default")

	-- Setup config options
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	local config = LibStub("AceConfig-3.0")
	local registry = LibStub("AceConfigRegistry-3.0")

	config:RegisterOptionsTable(addonName, SlashOptions, SlashCmds)
	registry:RegisterOptionsTable("Incognito2 Options", Options)
	registry:RegisterOptionsTable("Incognito2 Profiles", profiles)
	_, self.categoryID = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Incognito2 Options", addonName)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Incognito2 Profiles", "Profiles", addonName)

	-- Hook SendChatMessage function
	self:RawHook(C_ChatInfo, "SendChatMessage", "SendChatMessage", true)

	character_name, _ = UnitName("player")
	DebugPrint("Character name:", character_name)
	
	DebugPrint(L["Loaded"])
	DebugDump(self.db.profile)
end

-- Event Handlers
function Incognito2:SendChatMessage(msg, chatType, lang, channel)
	if self.db.profile.enable and self.db.profile.name and self.db.profile.name ~= "" then
		local hideNameOnChar = ContainsElement(SplitString(self.db.profile.hideMatchingCharNames, ","), character_name)
		DebugPrint("Hide name on character: ", hideNameOnChar)
		if not hideNameOnChar and strlower(self.db.profile.name) ~= strlower(character_name) then
			if (self.db.profile.guild and (chatType == "GUILD" or chatType == "OFFICER"))
			or (self.db.profile.raid and chatType == "RAID")
			or (self.db.profile.party and chatType == "PARTY")
			or (self.db.profile.instance_chat and chatType == "INSTANCE_CHAT")
			then
				DebugPrint("Append name to message in chat type:", chatType)
				msg = "(" .. self.db.profile.name .. "): " .. msg
			elseif self.db.profile.channel and chatType == "CHANNEL" then
				local id, chname = GetChannelName(channel)
				DebugPrint(id, chname)
				if strlower(chname):match(strlower(self.db.profile.channel)) or tostring(id) == self.db.profile.channel then
					DebugPrint("Append name to message in a channel")
					msg = "(" .. self.db.profile.name .. "): " .. msg
				end
			end
		end
	end

	-- Call original function
	self.hooks[C_ChatInfo].SendChatMessage(msg, chatType, lang, channel)
end
