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
---@param startKey? string
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
	DebugPrint("Migrating string value to table for key", key)
	local migratedProfiles = 0
	for _, profile in pairs(db.profiles) do
		if not profile._inc2Migrated then
			if type(profile[key]) ~= "string" then return end
			if profile[key] == nil then
				profile[targetKey or key] = {}
			else
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
	local argsCounter = CreateCounter()
	if dbKey == "channels" then
		args["channels_desc"] = {
			order = argsCounter(),
			type = "description",
			name = DARKYELLOW_FONT_COLOR:WrapTextInColorCode(L["channels_desc"])
		}
	end
	args["_add"] = {
		order = argsCounter(),
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
	local entries = Incognito2.db.profile[dbKey]
	if entries then
		for name, _ in pairs(entries) do
			local entryName = name
			args["entry_" .. entryName] = {
				order = argsCounter(),
				type = "execute",
				name = entryName,
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
		end
	end
	return args
end

---Builds the AceConfig options table dynamically.
---A function is required due to the dynamic nature of the hideMatchingCharNames and channels lists
local function GetOptionsTable()
	local argsCounter = CreateCounter()
	return {
		type = "group",
		name = addonName,
		get = function(item) return Incognito2.db.profile[item[#item]] end,
		set = function(item, value) Incognito2.db.profile[item[#item]] = value end,
		args = {
			options = {
				order = argsCounter(),
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
				order = argsCounter(),
				type = "group",
				name = L["hide_name_for_matching_chars"],
				inline = true,
				args = BuildListArgs("hideMatchingCharNames"),
			},
			chatOptions = {
				order = argsCounter(),
				type = "group",
				name = L["group_chat_options"],
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
				order = argsCounter(),
				type = "group",
				name = L["channel_options"],
				inline = true,
				args = BuildListArgs("channels"),
			},
			channelInfo = {
				order = argsCounter(),
				type = "description",
				name = DIM_RED_FONT_COLOR:WrapTextInColorCode(L["channels_info"])
			},
			debug = {
				order = argsCounter(),
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
		_inc2Migrated = false
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

	character_name, _ = UnitName("player")
	DebugPrint("Character name:", character_name)

	-- Hook each chat frame edit box to pre-modify text before it is sent.
	-- Avoids tainting C_ChatInfo.SendChatMessage (triggering ADDON_ACTION_FORBIDDEN during combat and M+)
	for i = 1, NUM_CHAT_WINDOWS do
		local editBox = _G["ChatFrame" .. i .. "EditBox"]
		if editBox then
			editBox:HookScript("OnKeyDown", function(box, key)
				if key == "ENTER" or key == "NUMPADENTER" then
					Incognito2:PreprocessChatMessage(box)
				end
			end)
		end
	end

	DebugPrint(L["Loaded"])
end

---Pre-modifies the text in a chat edit box to prepend the configured nickname before the message is sent.
---@param editBox table The chat frame edit box that is about to send a message
function Incognito2:PreprocessChatMessage(editBox)
	if not (self.db.profile.enable and self.db.profile.name and self.db.profile.name ~= "") then return end

	local hideNameOnChar = ContainsValue(self.db.profile.hideMatchingCharNames, character_name)
	DebugPrint("Hide name on character: ", hideNameOnChar)
	if hideNameOnChar or strlower(self.db.profile.name) == strlower(character_name) then return end

	local text = editBox:GetText()
	if not text or text == "" then return end
	-- IMPORTANT: Do not modify slash commands
	if text:sub(1, 1) == "/" then return end

	local chatType = editBox:GetAttribute("chatType")
	if not chatType then return end
	chatType = strupper(chatType)

	local newText = text

	if (self.db.profile.guild and (chatType == "GUILD" or chatType == "OFFICER"))
	or (self.db.profile.raid and chatType == "RAID")
	or (self.db.profile.party and chatType == "PARTY")
	or (self.db.profile.instance_chat and chatType == "INSTANCE_CHAT")
	then
		DebugPrint("Append name to message in chat type:", chatType)
		newText = "(" .. self.db.profile.name .. "): " .. text
	elseif self.db.profile.channels and next(self.db.profile.channels) and chatType == "CHANNEL" then
		local channelTarget = editBox:GetAttribute("channelTarget")
		DebugPrint("Channel target:", channelTarget)
		if channelTarget then
			local info = C_ChatInfo.GetChannelInfoFromIdentifier(tostring(channelTarget))
			DebugPrint("Channel info:", info and info.name, info and info.localID)
			if info then
				for channelMatch, _ in pairs(self.db.profile.channels) do
					if strlower(info.name):match(strlower(channelMatch)) or tostring(info.localID) == channelMatch then
						DebugPrint("Append name to message in a channel")
						newText = "(" .. self.db.profile.name .. "): " .. text
						break
					end
				end
			end
		end
	end

	if newText ~= text then
		editBox:SetText(newText)
		editBox:SetCursorPosition(#newText)
	end
end
