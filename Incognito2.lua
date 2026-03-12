local addonName, Incognito2 = ...

Incognito2 = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

-- Utility Functions

---Prints the desired text if the AddOn is in debugging mode. This is just a wrapper around the standard `print` function.
---@vararg string|number
---@see print
local function DebugPrint(...)
	if Incognito2.db.profile.debug then print(HEIRLOOM_BLUE_COLOR:WrapTextInColorCode("[Incognito2]"), ...) end
end

---Dumps the desired value to the console if the AddOn is in debugging mode. This is just a wrapper around the Blizzard `DevTools_Dump` function.
---@param value any
---@param startKey string
---@see DevTools_Dump
local function DebugDump(value, startKey)
	if Incognito2.db.profile.debug then DevTools_Dump(value, startKey) end
end

---Indicates whether a table contains a specific value or not
---@param tbl table
---@param value any
---@return boolean `true` if the table contains a value that matches the provided one, `false` otherwise
local function ContainsValue(tbl, value)
	if not tbl then return false end
	for entry, _ in pairs(tbl) do
		if strlower(entry) == strlower(value) then
			return true
		end
	end
	return false
end

---Migrates delimited string values for the specified key in all AddOn database profiles to a table.
---This only runs once per profile; the `_inc2Migrated` flag prevents re-migration.
---@param db AceDBObject-3.0 The AceDB database object
---@param key string The key containing a delimited string value in the v1 database structure
---@param delimiter string The delimiting character used in the string (usually a comma)
---@param targetKey? string Optional key for the new table value to create
local function MigrateStringToTable(db, key, delimiter, targetKey)
	local migratedProfiles = 0
	for _, profile in (db.profiles) do
		if not profile._inc2Migrated then
			if type(profile[key]) ~= "string" then return end
			local migrated = {}
			if profile[key] ~= "" then
				for value in string.gmatch(profile[key], "([^" .. delimiter .. "]+)") do
					migrated[value:match("^%s*(.-)%s*$")] = true
				end
			end
			profile[targetKey or key] = migrated
			if targetKey and targetKey ~= key then
				profile[key] = nil
			end
			DebugPrint("Migrated profile database from v1 to v2")
			profile._inc2Migrated = true
			migratedProfiles = migratedProfiles + 1
		end
	end

	if migratedProfiles > 0 then
		print(HEIRLOOM_BLUE_COLOR:WrapTextInColorCode("["..addonName.."]"), "AddOn database structure has been updated. This should not affect any of your profiles' settings.")
	end
end

---Builds an AceConfig object dynamically that contains all values in a list from the specified database property
---@param dbKey string The key in the database for the list to build options for
---@return table args
local function BuildListArgs(dbKey)
	local args = {}
	args["_add"] = {
		order = 1,
		type = "input",
		name = L["list_add"],
		width = "full",
		desc = L["list_add_desc"],
		set = function(_, value)
			value = strtrim(value)
			if value ~= "" then
				if not Incognito2.db.profile[dbKey] then
					Incognito2.db.profile[dbKey] = {}
				end
				Incognito2.db.profile[dbKey][value] = true
				LibStub("AceConfigRegistry-3.0"):NotifyChange("Incognito2 Options")
			end
		end,
		get = function() return "" end,
	}
	local i = 2
	local entries = Incognito2.db.profile[dbKey]
	if entries then
		for name, _ in pairs(entries) do
			local entryName = name
			args["entry_" .. entryName] = {
				order = i,
				type = "execute",
				name = WHITE_FONT_COLOR:WrapTextInColorCode(entryName).."  [X]",
				desc = L["list_remove_desc"],
				width = 0.75,
				func = function()
					Incognito2.db.profile[dbKey][entryName] = nil
					if next(Incognito2.db.profile[dbKey]) == nil then
						Incognito2.db.profile[dbKey] = {}
					end
					LibStub("AceConfigRegistry-3.0"):NotifyChange("Incognito2 Options")
				end,
			}
			i = i + 1
		end
	end
	return args
end

---Builds the AceConfig options table dynamically.
---A function is required due to the dynamic nature of the hideMatchingCharNames and channels lists
local function GetOptionsTable()
	return {
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
				}
			},
			hideMatchingCharNamesGroup = {
				order = 2,
				type = "group",
				name = L["hideMatchingCharNames"],
				inline = true,
				args = BuildListArgs("hideMatchingCharNames"),
			},
			chatOptions = {
				order = 3,
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
				}
			},
			channelsGroup = {
				order = 4,
				type = "group",
				name = L["channels"],
				description = L["channels_desc"],
				inline = true,
				args = BuildListArgs("channels"),
			},
			channelInfo = {
				order = 5,
				type = "description",
				name = LEGENDARY_ORANGE_COLOR:WrapTextInColorCode(L["channels_info"])
			},
			debug = {
				order = 6,
				type = "toggle",
				name = L["debug"],
				desc = L["debug_desc"],
			}
		}
	}
end

local Defaults = {
	profile = {
		enable = true,
		name = nil,
		guild = true,
		party = false,
		raid = false,
		instance_chat = false,
		debug = false,
		channels = {},
		hideMatchingCharNames = {},
	},
}

local SlashOptions = {
	type = "group",
	handler = Incognito2,
	get = function(item) return Incognito2.db.profile[item[#item]] end,
	set = function(item, value)
		if strlower(item[#item]) == strlower(L["exclude"]) then
			if not Incognito2.db.profile.hideMatchingCharNames then
				Incognito2.db.profile.hideMatchingCharNames = {}
			end
			if not ContainsValue(Incognito2.db.profile.hideMatchingCharNames, value) then
				Incognito2.db.profile.hideMatchingCharNames[value] = true
			else
				print(PURE_GREEN_COLOR:WrapTextInColorCode("Incognito2: Name already excluded from appearing on character " .. value))
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
function Incognito2:OnInitialize()
	-- Load database
	self.db = LibStub("AceDB-3.0"):New("Incognito2DB", Defaults, "Default")

	-- Migrate legacy comma-separated strings to tables
	MigrateStringToTable(self.db, "hideMatchingCharNames", ",")
	MigrateStringToTable(self.db, "channel", ",", "channels")

	-- Setup config options
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	local config = LibStub("AceConfig-3.0")
	local registry = LibStub("AceConfigRegistry-3.0")

	config:RegisterOptionsTable(addonName, SlashOptions, SlashCmds)
	registry:RegisterOptionsTable("Incognito2 Options", GetOptionsTable)
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

---The function that captures a chat message being sent in order to prepend the specified nickname to the message
---@param msg string The chat message to be sent
---@param chatType "GUILD"|"OFFICER"|"RAID"|"PARTY"|"INSTANCE_CHAT"|"CHANNEL"
---@param lang number The ID number corresponding to the language of the game client
---@param channel string|number The name or ID number of the channel in which the message is sent
function Incognito2:SendChatMessage(msg, chatType, lang, channel)
	if self.db.profile.enable and self.db.profile.name and self.db.profile.name ~= "" then
		local hideNameOnChar = ContainsValue(self.db.profile.hideMatchingCharNames, character_name)
		DebugPrint("Hide name on character: ", hideNameOnChar)
		if not hideNameOnChar and strlower(self.db.profile.name) ~= strlower(character_name) then
			if (self.db.profile.guild and (chatType == "GUILD" or chatType == "OFFICER"))
			or (self.db.profile.raid and chatType == "RAID")
			or (self.db.profile.party and chatType == "PARTY")
			or (self.db.profile.instance_chat and chatType == "INSTANCE_CHAT")
			then
				DebugPrint("Append name to message in chat type:", chatType)
				msg = "(" .. self.db.profile.name .. "): " .. msg
			elseif self.db.profile.channels and next(self.db.profile.channels) and chatType == "CHANNEL" then
				local id, chname = GetChannelName(channel)
				DebugPrint(id, chname)
				for channelMatch, _ in pairs(self.db.profile.channels) do
					if strlower(chname):match(strlower(channelMatch)) or tostring(id) == channelMatch then
						DebugPrint("Append name to message in a channel")
						msg = "(" .. self.db.profile.name .. "): " .. msg
						break
					end
				end
			end
		end
	end

	-- Call original function
	self.hooks[C_ChatInfo].SendChatMessage(msg, chatType, lang, channel)
end
