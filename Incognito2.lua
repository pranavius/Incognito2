local addonName = "Incognito2"

-- Module
Incognito2 = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0");

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

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
					name = "|cFFff8000" .. L["hideMatchingCharNames_info"] .. "|r"
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
					name = "|cFFff8000" .. L["channel_info"] .. "|r"
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

local addon_category
local SlashOptions = {
	type = "group",
	handler = Incognito2,
	get = function(item) return Incognito2.db.profile[item[#item]] end,
	set = function(item, value)
		if strlower(item[#item]) == strlower(L["exclude"]) then
			if not Incognito2.db.profile.hideMatchingCharNames or Incognito2.db.profile.hideMatchingCharNames == "" then
				Incognito2.db.profile.hideMatchingCharNames = value
			elseif not containsElement(splitString(Incognito2.db.profile.hideMatchingCharNames, ","), value) then
				Incognito2.db.profile.hideMatchingCharNames = Incognito2.db.profile.hideMatchingCharNames .. "," .. value
			else
				print("|cFF00ff00Incognito2|r: Name already excluded from appearing on character " .. value)
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
			func = function()
				if addon_category and addon_category.ID then
					Settings.OpenToCategory(addon_category.ID)
				else
					self:Safe_Print("Options panel not found")
					Settings.OpenToCategory()
				end
			end,
		},
	},
}

local SlashCmds = {
	"inc",
	"incognito",
};

local character_name
-- Initialization
function Incognito2:OnInitialize()
	-- Load database
	self.db = LibStub("AceDB-3.0"):New("Incognito2DB", Defaults, "Default")

	-- Setup config options
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	local config = LibStub("AceConfig-3.0")
	config:RegisterOptionsTable(addonName, SlashOptions, SlashCmds)

	local registry = LibStub("AceConfigRegistry-3.0")
	registry:RegisterOptionsTable("Incognito2 Options", Options)
	registry:RegisterOptionsTable("Incognito2 Profiles", profiles);

	local dialog = LibStub("AceConfigDialog-3.0");
	self.optionFrames = {
		main = dialog:AddToBlizOptions(	"Incognito2 Options", addonName),
		profiles = dialog:AddToBlizOptions(	"Incognito2 Profiles", "Profiles", addonName);
	}

	addon_category = Settings.RegisterCanvasLayoutCategory(Incognito2.optionFrames.main, addonName)
	Settings.RegisterAddOnCategory(addon_category)

	-- Hook SendChatMessage function
	self:RawHook("SendChatMessage", true)

	-- get current character name
	character_name, _ = UnitName("player")
	
	self:Safe_Print(L["Loaded"])
end

-- Functions
function Incognito2:Safe_Print(msg)
	if self.db.profile.debug then
		self:Print(msg)
	end
end

function splitString(input, separator)
    local result = {}
	if input == nil then
		return result
	end

    for value in string.gmatch(input, "([^" .. separator .. "]+)") do
        table.insert(result, value:match("^%s*(.-)%s*$")) -- Trim spaces
    end
    return result
end

function containsElement(table, value)
    for _, v in ipairs(table) do
        if strlower(v) == strlower(value) then
            return true
        end
    end
    return false
end

-- Event Handlers
function Incognito2:SendChatMessage(msg, chatType, lang, channel)
	if self.db.profile.enable and self.db.profile.name and self.db.profile.name ~= "" then
		local hideNameOnChar = containsElement(splitString(self.db.profile.hideMatchingCharNames, ","), character_name)
		if not hideNameOnChar and strlower(self.db.profile.name) ~= strlower(character_name) then
			if (self.db.profile.guild and (chatType == "GUILD" or chatType == "OFFICER"))
			or (self.db.profile.raid and chatType == "RAID")
			or (self.db.profile.party and chatType == "PARTY")
			or (self.db.profile.instance_chat and chatType == "INSTANCE_CHAT")
			then
				msg = "(" .. self.db.profile.name .. "): " .. msg
			elseif self.db.profile.channel and chatType == "CHANNEL" then
				local id, chname = GetChannelName(channel)
				if strupper(self.db.profile.channel) == strupper(chname) then
					msg = "(" .. self.db.profile.name .. "): " .. msg
				end
			end
		end
	end

	-- Call original function
	self.hooks.SendChatMessage(msg, chatType, language, channel)
end