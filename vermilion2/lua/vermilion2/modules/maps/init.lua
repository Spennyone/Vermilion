--[[
 Copyright 2014 Ned Hyett, 

 Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 in compliance with the License. You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under the License
 is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 or implied. See the License for the specific language governing permissions and limitations under
 the License.
 
 The right to upload this project to the Steam Workshop (which is operated by Valve Corporation) 
 is reserved by the original copyright holder, regardless of any modifications made to the code,
 resources or related content. The original copyright holder is not affiliated with Valve Corporation
 in any way, nor claims to be so. 
]]

local MODULE = Vermilion:CreateBaseModule()
MODULE.Name = "Maps"
MODULE.ID = "map"
MODULE.Description = "Change the map and other stuff." // <-- put a better description.
MODULE.Author = "Ned"
MODULE.Permissions = {
	"manage_map"
}
MODULE.NetworkStrings = {
	"VGetMapList",
	"VScheduleMapChange",
	"VAbortMapChange",
	"VBroadcastSchedule"
}

MODULE.MapChangeInProgress = false
MODULE.MapChangeIn = nil
MODULE.MapChangeTo = nil
MODULE.MapCache = {}
MODULE.DisplayXPos1 = 0
MODULE.DisplayXPos2 = 0
MODULE.SoundTimer = nil

function MODULE:InitServer()
	
	-- The map codes are borrowed from getmaps.lua (garrysmod/lua/menu/getmaps.lua)
	local MapPatterns = {
		[ "^aoc_" ] = "Age of Chivalry",
		[ "^asi-" ] = "Alien Swarm",
		
		[ "lobby" ] = "Alien Swarm",
		
		[ "^ar_" ] = "Counter-Strike",
		[ "^cs_" ] = "Counter-Strike",
		[ "^de_" ] = "Counter-Strike",
		[ "^es_" ] = "Counter-Strike",
		[ "^fy_" ] = "Counter-Strike",
		[ "training1" ] = "Counter-Strike",
		
		[ "^dod_" ] = "Day Of Defeat",
		
		[ "cp_pacentro" ] = "Dino D-Day",
		[ "cp_snowypark" ] = "Dino D-Day",
		[ "cp_troina" ] = "Dino D-Day",
		[ "dm_canyon" ] = "Dino D-Day",
		[ "dm_depot" ] = "Dino D-Day",
		[ "dm_fortress_trex" ] = "Dino D-Day",
		[ "dm_gela_trex" ] = "Dino D-Day",
		[ "dm_hilltop" ] = "Dino D-Day",
		[ "dm_market" ] = "Dino D-Day",
		[ "dm_pacentro" ] = "Dino D-Day",
		[ "dm_snowypark" ] = "Dino D-Day",
		[ "dm_troina" ] = "Dino D-Day",
		[ "koth_hilltop" ] = "Dino D-Day",
		[ "koth_market" ] = "Dino D-Day",
		[ "koth_pacentro" ] = "Dino D-Day",
		[ "koth_snowypark" ] = "Dino D-Day",
		[ "obj_canyon" ] = "Dino D-Day",
		[ "obj_depot" ] = "Dino D-Day",
		[ "obj_fortress" ] = "Dino D-Day",

		[ "de_dam" ] = "DIPRIP",
		[ "dm_city" ] = "DIPRIP",
		[ "dm_refinery" ] = "DIPRIP",
		[ "dm_supermarket" ] = "DIPRIP",
		[ "dm_village" ] = "DIPRIP",
		[ "^ur_" ] = "DIPRIP",

		[ "^dys_" ] = "Dystopia",
		[ "^pb_" ] = "Dystopia",

		[ "credits" ] = "Half-Life 2",
		[ "^d1_" ] = "Half-Life 2",
		[ "^d2_" ] = "Half-Life 2",
		[ "^d3_" ] = "Half-Life 2",
		[ "intro" ] = "Half-Life 2",

		[ "^dm_" ] = "Half-Life 2: Deathmatch",
		[ "halls3" ] = "Half-Life 2: Deathmatch",

		[ "^ep1_" ] = "Half-Life 2: Episode 1",
		[ "^ep2_" ] = "Half-Life 2: Episode 2",
		[ "^ep3_" ] = "Half-Life 2: Episode 3", -- very funny Garry. *clap clap*
		
		[ "d2_lostcoast" ] = "Half-Life 2: Lost Coast",

		[ "^c0a" ] = "Half-Life: Source",
		[ "^c1a" ] = "Half-Life: Source",
		[ "^c2a" ] = "Half-Life: Source",
		[ "^c3a" ] = "Half-Life: Source",
		[ "^c4a" ] = "Half-Life: Source",
		[ "^c5a" ] = "Half-Life: Source",
		[ "^t0a" ] = "Half-Life: Source",

		[ "boot_camp" ] = "Half-Life Deathmatch: Source",
		[ "bounce" ] = "Half-Life Deathmatch: Source",
		[ "crossfire" ] = "Half-Life Deathmatch: Source",
		[ "datacore" ] = "Half-Life Deathmatch: Source",
		[ "frenzy" ] = "Half-Life Deathmatch: Source",
		[ "lambda_bunker" ] = "Half-Life Deathmatch: Source",
		[ "rapidcore" ] = "Half-Life Deathmatch: Source",
		[ "snarkpit" ] = "Half-Life Deathmatch: Source",
		[ "stalkyard" ] = "Half-Life Deathmatch: Source",
		[ "subtransit" ] = "Half-Life Deathmatch: Source",
		[ "undertow" ] = "Half-Life Deathmatch: Source",

		[ "^ins_" ] = "Insurgency",

		[ "^l4d" ] = "Left 4 Dead",

		[ "^c1m" ] = "Left 4 Dead 2",
		[ "^c2m" ] = "Left 4 Dead 2",
		[ "^c3m" ] = "Left 4 Dead 2",
		[ "^c4m" ] = "Left 4 Dead 2",
		[ "^c5m" ] = "Left 4 Dead 2",
		[ "^c6m" ] = "Left 4 Dead 2",
		[ "^c7m" ] = "Left 4 Dead 2",
		[ "^c8m" ] = "Left 4 Dead 2",
		[ "^c9m" ] = "Left 4 Dead 2",
		[ "^c10m" ] = "Left 4 Dead 2",
		[ "^c11m" ] = "Left 4 Dead 2",
		[ "^c12m" ] = "Left 4 Dead 2",
		[ "^c13m" ] = "Left 4 Dead 2",
		[ "curling_stadium" ] = "Left 4 Dead 2",
		[ "tutorial_standards" ] = "Left 4 Dead 2",
		[ "tutorial_standards_vs" ] = "Left 4 Dead 2",

		[ "clocktower" ] = "Nuclear Dawn",
		[ "coast" ] = "Nuclear Dawn",
		[ "downtown" ] = "Nuclear Dawn",
		[ "gate" ] = "Nuclear Dawn",
		[ "hydro" ] = "Nuclear Dawn",
		[ "metro" ] = "Nuclear Dawn",
		[ "metro_training" ] = "Nuclear Dawn",
		[ "oasis" ] = "Nuclear Dawn",
		[ "oilfield" ] = "Nuclear Dawn",
		[ "silo" ] = "Nuclear Dawn",
		[ "sk_metro" ] = "Nuclear Dawn",
		[ "training" ] = "Nuclear Dawn",

		[ "^bt_" ] = "Pirates, Vikings, & Knights II",
		[ "^lts_" ] = "Pirates, Vikings, & Knights II",
		[ "^te_" ] = "Pirates, Vikings, & Knights II",
		[ "^tw_" ] = "Pirates, Vikings, & Knights II",

		[ "^escape_" ] = "Portal",
		[ "^testchmb_" ] = "Portal",

		[ "e1912" ] = "Portal 2",
		[ "^mp_coop_" ] = "Portal 2",
		[ "^sp_a" ] = "Portal 2",

		[ "^arena_" ] = "Team Fortress 2",
		[ "^cp_" ] = "Team Fortress 2",
		[ "^ctf_" ] = "Team Fortress 2",
		[ "itemtest" ] = "Team Fortress 2",
		[ "^koth_" ] = "Team Fortress 2",
		[ "^mvm_" ] = "Team Fortress 2",
		[ "^pl_" ] = "Team Fortress 2",
		[ "^plr_" ] = "Team Fortress 2",
		[ "^sd_" ] = "Team Fortress 2",
		[ "^tc_" ] = "Team Fortress 2",
		[ "^tr_" ] = "Team Fortress 2",
		[ "^rd_" ] = "Team Fortress 2",

		[ "^zpa_" ] = "Zombie Panic! Source",
		[ "^zpl_" ] = "Zombie Panic! Source",
		[ "^zpo_" ] = "Zombie Panic! Source",
		[ "^zps_" ] = "Zombie Panic! Source",

		[ "^achievement_" ] = "Achievement",
		[ "^cinema_" ] = "Cinema",
		[ "^theater_" ] = "Cinema",
		[ "^xc_" ] = "Climb",
		[ "^deathrun_" ] = "Deathrun",
		[ "^dr_" ] = "Deathrun",
		[ "^gmt_" ] = "GMod Tower",
		[ "^jb_" ] = "Jailbreak",
		[ "^ba_jail_" ] = "Jailbreak",
		[ "^mg_" ] = "Minigames",
		[ "^phys_" ] = "Physics Maps",
		[ "^pw_" ] = "Pirate Ship Wars",
		[ "^ph_" ] = "Prop Hunt",
		[ "^rp_" ] = "Roleplay",
		[ "^sb_" ] = "Spacebuild",
		[ "^slender_" ] = "Stop it Slender",
		[ "^gms_" ] = "Stranded",
		[ "^surf_" ] = "Surf",
		[ "^ts_" ] = "The Stalker",
		[ "^zm_" ] = "Zombie Survival",
		[ "^zombiesurvival_" ] = "Zombie Survival",
		[ "^zs_" ] = "Zombie Survival",
	}
	
	-- load in the gamemode ones
	for i,gm in pairs(engine.GetGamemodes()) do
		local Name = gm.title or "Unnamed Gamemode"
		local Maps = string.Split(gm.maps, "|")
		if(Maps && gm.maps != "") then
			for k,pattern in pairs(Maps) do
				MapPatterns[pattern] = Name
			end
		end
	end
	
	local IgnoredMaps = { "background", "^test_", "^styleguide", "^devtest", "sdk_shader_samples", "^vst_", "d2_coast_02", "c4a1y", "d3_c17_02_camera", "ep1_citadel_00_demo", "credits", "intro" }

	local cache = file.Find("maps/*.bsp", "GAME")
	for i,k in pairs(cache) do
		local ignore = false
		for dd,ignoredMap in pairs(IgnoredMaps) do
			if(string.find(k, ignoredMap)) then ignore = true break end
		end
		if(not ignore) then
			local Cat = "Other"
			local lowername = string.lower(k)
			for pattern,category in pairs(MapPatterns) do
				if((string.StartWith(pattern, "^") or string.EndsWith(pattern, "_") or string.EndsWith(pattern, "-")) and string.find(lowername, pattern)) then
					Cat = category
					break
				end
			end
			if(MapPatterns[k]) then Cat = MapPatterns[k] end
			table.insert(MODULE.MapCache, { string.StripExtension(k), Cat })
		end
	end
	
	self:NetHook("VGetMapList", function(vplayer)
		net.Start("VGetMapList")
		net.WriteTable(MODULE.MapCache)
		net.Send(vplayer)
	end)
	
	timer.Create("Vermilion_MapTicker", 1, 0, function()
		if(MODULE.MapChangeInProgress) then
			if(MODULE.MapChangeIn <= 0) then
				MODULE.MapChangeInProgress = false
				MODULE.MapChangeIn = nil
				local to = MODULE.MapChangeTo
				MODULE.MapChangeTo = nil
				RunConsoleCommand("changelevel", to)
				net.Start("VAbortMapChange")
				net.Broadcast()
			else
				MODULE.MapChangeIn = MODULE.MapChangeIn - 1
			end
		end
	end)
	
	self:NetHook("VScheduleMapChange", function(vplayer)
		if(Vermilion:HasPermission(vplayer, "map_management")) then
			if(MODULE.MapChangeInProgress) then
				--Vermilion:SendMessageBox(vplayer, "A map change is already in progress. Abort the map change to change to a new map!")
				return
			end
			MODULE.MapChangeInProgress = true
			MODULE.MapChangeTo = net.ReadString()
			MODULE.MapChangeIn = net.ReadInt(32)
			net.Start("VBroadcastSchedule")
			net.WriteInt(MODULE.MapChangeIn, 32)
			net.WriteString(MODULE.MapChangeTo)
			net.Broadcast()
		end
	end)
	
	self:NetHook("VAbortMapChange", function(vplayer)
		if(vplayer:HasPermission("map_management")) then
			MODULE.MapChangeInProgress = false
			MODULE.MapChangeIn = nil
			MODULE.MapChangeTo = nil
			net.Start("VAbortMapChange")
			net.Broadcast()
		end
	end)
	
end

function MODULE:InitClient()

	self:NetHook("VGetMapList", function()
		local panel = Vermilion.Menu.Pages["map"].Panel
		local map_list = panel.MapList
		if(IsValid(map_list)) then
			local maps = net.ReadTable()
			for i,k in pairs(maps) do
				local ln = map_list:AddLine(k[1], k[2])
				
				ln.OldCursorMoved = ln.OnCursorMoved
				ln.OldCursorEntered = ln.OnCursorEntered
				ln.OldCursorExited = ln.OnCursorExited
				
				function ln:OnCursorEntered()
					panel.PreviewPanel:SetVisible(true)
					panel.PreviewPanel.HtmlView:OpenURL("asset://mapimage/" .. self:GetValue(1))
					
					if(self.OldCursorEntered) then self:OldCursorEntered() end
				end
				
				function ln:OnCursorExited()
					panel.PreviewPanel:SetVisible(false)
					
					if(self.OldCursorExited) then self:OldCursorExited() end
				end
				
				function ln:OnCursorMoved(x,y)
					if(IsValid(panel.PreviewPanel)) then
						local x, y = input.GetCursorPos()
						panel.PreviewPanel:SetPos(x - 275, y - 202)
					end
					
					if(self.OldCursorMoved) then self:OldCursorMoved(x,y) end
				end
			end
		end
	end)
	
	self:NetHook("VBroadcastSchedule", function()
		MODULE.MapChangeInProgress = true
		MODULE.MapChangeIn = net.ReadInt(32) + VToolkit.TimeDiff
		MODULE.MapChangeTo = net.ReadString()
		MODULE.HasMap = file.Exists("maps/" .. MODULE.MapChangeTo .. ".bsp", "GAME")
	end)
	
	self:NetHook("VAbortMapChange", function()
		MODULE.MapChangeInProgress = false
		MODULE.MapChangeIn = nil
		MODULE.MapChangeTo = nil
		MODULE.HasMap = nil
	end)
	
	timer.Create("Vermilion_MapTicker", 1, 0, function()
		if(MODULE.MapChangeInProgress) then
			if(MODULE.MapChangeIn <= 0) then
				MODULE.MapChangeInProgress = false
				MODULE.MapChangeIn = nil
				MODULE.MapChangeTo = nil
			else
				MODULE.MapChangeIn = MODULE.MapChangeIn - 1
			end
		end
	end)
	
	self:AddHook("HUDPaint", function()
		if(MODULE.MapChangeInProgress) then
			if(MODULE.SoundTimer != MODULE.MapChangeIn) then
				local tr = MODULE.MapChangeIn
				if(Vermilion:GetModule("sound") != nil) then
					if(tr == 180) then
						Vermilion:PlaySound("npc/overwatch/cityvoice/fcitadel_3minutestosingularity.wav", "MapChange")
					elseif(tr == 120) then
						Vermilion:PlaySound("npc/overwatch/cityvoice/fcitadel_2minutestosingularity.wav", "MapChange")
					elseif(tr == 60) then
						Vermilion:PlaySound("npc/overwatch/cityvoice/fcitadel_1minutetosingularity.wav", "MapChange")
					elseif(tr == 45) then
						Vermilion:PlaySound("npc/overwatch/cityvoice/fcitadel_45sectosingularity.wav", "MapChange")
					elseif(tr == 30) then
						Vermilion:PlaySound("npc/overwatch/cityvoice/fcitadel_30sectosingularity.wav", "MapChange")
					elseif(tr == 15) then
						Vermilion:PlaySound("npc/overwatch/cityvoice/fcitadel_15sectosingularity.wav", "MapChange")
					elseif(tr == 10) then
						Vermilion:PlaySound("npc/overwatch/cityvoice/fcitadel_10sectosingularity.wav", "MapChange")
					end
				end
				MODULE.SoundTimer = MODULE.MapChangeIn
			end
			local time = string.FormattedTime(MODULE.MapChangeIn)
			local strh = tostring(time.h)
			if(time.h < 10) then
				strh = "0" .. tostring(time.h)
			end
			local strm = tostring(time.m)
			if(time.m < 10) then
				strm = "0" .. tostring(time.m)
			end
			local strs = tostring(time.s)
			if(time.s < 10) then
				strs = "0" .. tostring(time.s)
			end
			time = strh .. ":" .. strm .. ":" .. strs
			local col = nil
			if(MODULE.MapChangeIn > 10) then
				col = Color(0, 0, 0, 255)
			elseif((MODULE.MapChangeIn) % 2 == 0 or (MODULE.MapChangeIn) % 60 == 0 or ((MODULE.MapChangeIn) % 5 == 0 and (MODULE.MapChangeIn) > 10 and (MODULE.MapChangeIn) < 30)) then
				col = Color(255, 0, 0, 255)
			else
				col = Color(0, 0, 0, 255)
			end
			if(time == nil) then
				return
			end
			local w,h = draw.WordBox( 8, ScrW() - MODULE.DisplayXPos1 - 10, 10, "Server is changing level to " .. tostring(MODULE.MapChangeTo) .. " in ".. time, "Default", col, Color(255, 255, 255, 255))
			MODULE.DisplayXPos1 = w
			
			if(not MODULE.HasMap and os.time() % 2 == 0) then
				local w1,h1 = draw.WordBox( 8, ScrW() - MODULE.DisplayXPos2 - 10, h + 20, "Warning: you do not have this map!", "Default", Color(255, 0, 0, 255), Color(255, 255, 255, 255))
				MODULE.DisplayXPos2 = w1
			end
		end
	end)
	
	Vermilion.Menu:AddCategory("Server Settings", 2)

	Vermilion.Menu:AddPage({
			ID = "map",
			Name = "Change Map",
			Order = 10,
			Category = "Server Settings",
			Size = { 780, 560 },
			Conditional = function(vplayer)
				return Vermilion:HasPermission("manage_map")
			end,
			Builder = function(panel)
				panel.PreviewPanel = VToolkit:CreatePreviewPanel("html", panel)
			
				local mapList = VToolkit:CreateList({ "Name", "Game" }, false)
				mapList:SetParent(panel)
				mapList:SetPos(10, 30)
				mapList:SetSize(450, 520)
				panel.MapList = mapList
				
				local mapHeader = VToolkit:CreateHeaderLabel(mapList, "Maps")
				mapHeader:SetParent(panel)
				
				VToolkit:CreateSearchBox(mapList)
				
				local times = {
					{ "Immediately", 0, 0 },
					{ "In 30 seconds", 1, 30 },
					{ "In 1 minute", 2, 60 },
					{ "In 2 minutes", 3, 60 * 2 },
					{ "In 3 minutes", 4, 60 * 3 },
					{ "In 4 minutes", 5, 60 * 4 },
					{ "In 5 minutes", 6, 60 * 5 },
					{ "In 10 minutes", 7, 60 * 10 },
					{ "In 15 minutes", 8, 60 * 15 },
					{ "In 20 minutes", 9, 60 * 20 },
					{ "In 30 minutes", 10, 60 * 30 },
					{ "In 45 minutes", 11, 60 * 45 },
					{ "In 1 hour", 12, 60 * 60 },
					{ "In 2 hours", 13, 60 * 60 * 2 },
					{ "In 3 hours", 14, 60 * 60 * 3 },
					{ "In 4 hours", 15, 60 * 60 * 4 },
					{ "In 5 hours", 16, 60 * 60 * 5 },
					{ "In 10 hours", 17, 60 * 60 * 10 },
					{ "In 15 hours", 18, 60 * 60 * 15 },
					{ "In 20 hours", 19, 60 * 60 * 20 },
					{ "In 1 day", 20, 60 * 60 * 24 }
				}
					
				local timeDelayComboBox = VToolkit:CreateComboBox()
				timeDelayComboBox:SetText("Time Delay")
				timeDelayComboBox.OnSelect = function(panel, index, value, data)
					timeDelayComboBox.Vermilion_Value = value
				end
				for k,v in ipairs(times) do
					timeDelayComboBox:AddChoice(v[1]);
				end
				timeDelayComboBox:ChooseOption(times[1][1])
				timeDelayComboBox:SetDark(true)
				timeDelayComboBox:SetParent(panel)
				timeDelayComboBox:SetPos(470, 120)
				timeDelayComboBox:SetSize(300, 25)
				
				
				local changeTimeHeader = VToolkit:CreateHeaderLabel(timeDelayComboBox, "Change to the selected map:")
				changeTimeHeader:SetParent(panel)
				
				local currentMapLabel = VToolkit:CreateHeaderLabel(timeDelayComboBox, "Current Map:")
				local cmx, cmy = currentMapLabel:GetPos()
				currentMapLabel:SetPos(cmx, 30)
				currentMapLabel:SetParent(panel)
				
				local currentMap = VToolkit:CreateHeaderLabel(timeDelayComboBox, game.GetMap())
				local cmx1, cmy1 = currentMap:GetPos()
				currentMap:SetPos(cmx1, 50)
				currentMap:SetParent(panel)
				
				
				
				local changeMapButton = VToolkit:CreateButton("GO!", function(self)
					if(table.Count(mapList:GetSelected()) == 0) then
						VToolkit:CreateErrorDialog("Must select a map to change to!")
						return
					end
					net.Start("VScheduleMapChange")
					net.WriteString(mapList:GetSelected()[1]:GetValue(1))
					for i,k in pairs(times) do
						if(k[1] == timeDelayComboBox.Vermilion_Value) then
							net.WriteInt(k[3], 32) -- client sends a delay instead of the time the map should change due to timezone interference.
							break
						end
					end
					net.SendToServer()
				end)
				changeMapButton:SetPos(582.5, 170)
				changeMapButton:SetSize(75, 25)
				changeMapButton:SetParent(panel)
				
				
				local abortLevelChangeButton = VToolkit:CreateButton("Abort Level Change", function(self)
					VToolkit:CreateConfirmDialog("Are you sure you want to abort the level change?", function()
						net.Start("VAbortMapChange")
						net.SendToServer()
					end)
				end)
				abortLevelChangeButton:SetPos(557.5, 220)
				abortLevelChangeButton:SetSize(120, 30)
				abortLevelChangeButton:SetParent(panel)
			end,
			Updater = function(panel)
				if(table.Count(panel.MapList:GetLines()) == 0) then
					net.Start("VGetMapList")
					net.SendToServer()
				end
				panel.MapList:SetVisible(true)
			end,
			Destroyer = function(panel)
				panel.MapList:SetVisible(false)
			end
		})
end

Vermilion:RegisterModule(MODULE)