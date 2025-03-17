-- Module
Incognito2 = LibStub("AceAddon-3.0"):NewAddon("Incognito2", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0");

-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Incognito2", true)

local Options = {
	type = "group",
	get = function(item) return Incognito2.db.profile[item[#item]] end,
	set = function(item, value) Incognito2.db.profile[item[#item]] = value end,
	args = {
        enable = {	
            order = 1,
            type = "toggle",
            name = L["enable"],
            desc = L["enable_desc"],
        },
		name = {
			order = 2,
			type = "input",
			name = L["name"],
			desc = L["name_desc"],
		},
		debug = {
			order = 3,
			type = "toggle",
			name = L["debug"],
			desc = L["debug_desc"],
		},
		guild = {
			order = 4,
			type = "toggle",
			name = L["guild"],
			desc = L["guild_desc"],
		},
		party = {
			order = 5,
			type = "toggle",
			name = L["party"],
			desc = L["party_desc"],
		},
		raid = {
			order = 6,
			type = "toggle",
			name = L["raid"],
			desc = L["raid_desc"],
		},
		instance_chat = {
			order = 7,
			type = "toggle",
			name = L["instance_chat"],
			desc = L["instance_chat_desc"],
		},
		channel = {
			order = 8,
			type = "input",
			name = L["channel"],
			desc = L["channel_desc"],
		},
		hideMatchingCharNames = {
			order = 9,
			type = "input",
			name = L["hideMatchingCharNames"],
			desc = L["hideMatchingCharNames_desc"],
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
	set = function(item, value) Incognito2.db.profile[item[#item]] = value end,
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
				InterfaceOptionsFrame_OpenToCategory(Incognito2.optionFrames.main)
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
	config:RegisterOptionsTable("Incognito2", SlashOptions, SlashCmds)

	local registry = LibStub("AceConfigRegistry-3.0")
	registry:RegisterOptionsTable("Incognito2 Options", Options)
	registry:RegisterOptionsTable("Incognito2 Profiles", profiles);

	local dialog = LibStub("AceConfigDialog-3.0");
	self.optionFrames = {
		main = dialog:AddToBlizOptions(	"Incognito2 Options", "Incognito2"),
		profiles = dialog:AddToBlizOptions(	"Incognito2 Profiles", "Profiles", "Incognito2");
	}

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
        if v == value then
            return true
        end
    end
    return false
end

-- Event Handlers
function Incognito2:SendChatMessage(msg, chatType, lang, channel)
	if self.db.profile.enable and self.db.profile.name and self.db.profile.name ~= "" then
		local hideNameOnChar = containsElement(splitString(self.db.profile.hideMatchingCharNames, ","), character_name)
		self:Safe_Print("Hide name on this character from options: " .. tostring(hideNameOnChar))
		self:Safe_Print("Incognito2 name matches character name: " .. tostring(self.db.profile.name == character_name))
		if not hideNameOnChar and self.db.profile.name ~= character_name then
			if  (self.db.profile.guild and (chatType == "GUILD" or chatType == "OFFICER"))
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