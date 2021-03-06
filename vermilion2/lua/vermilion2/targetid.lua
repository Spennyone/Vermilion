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

Vermilion.TargetID = {}

Vermilion:AddHook("HUDDrawTargetID", "VTargetID", false, function()
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end
	
	if (not trace.Entity:IsPlayer()) then
		return
	end
	
	local MouseX, MouseY = gui.MousePos()
	
	if ( MouseX == 0 && MouseY == 0 ) then
	
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	
	end
	
	local x = MouseX
	local y = MouseY
	
	local caseRank = string.SetChar(trace.Entity:GetNWString("Vermilion_Rank"), 1, string.upper(string.GetChar(trace.Entity:GetNWString("Vermilion_Rank"), 1)))
	
	surface.SetFont( 'DermaDefaultBold' )
	local maxW = math.max(surface.GetTextSize(trace.Entity:GetName()), surface.GetTextSize(tostring(trace.Entity:Health()) .. "%"), surface.GetTextSize(caseRank))
	x = x - ((90 + maxW) / 2)
	y = y + 75
	
	surface.SetDrawColor( 5, 5, 5, 220 )
	surface.DrawRect( x, y, 90 + maxW, 50 )
	surface.DrawOutlinedRect( x, y, 90 + maxW, 50 )
	
	local geoIPData = hook.Run("Vermilion2_TargetIDDataGeoIP", trace.Entity)
	local iconData = hook.Run("Vermilion2_TargetIDDataIcon", trace.Entity)
	
	surface.SetTextColor(Vermilion:GetRankColour(trace.Entity:GetNWString("Vermilion_Rank")))
	surface.SetTextPos(x + 31, y + 3)
	surface.DrawText(trace.Entity:GetName())
	
	surface.SetTextPos(x + 31, y + 18)
	surface.DrawText(caseRank)
	
	surface.SetTextPos(x + 31, y + 33)
	surface.DrawText(tostring(trace.Entity:Health()) .. "%")
	
	
	if(iconData != nil) then
		surface.SetMaterial(iconData)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(x + 5, y + 5, 16, 16)
	end
	y = y + 25
	if(geoIPData != nil) then
		surface.SetMaterial(geoIPData)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(x + 5, y + 5, 16, 11)
	end
	
	return true
end)