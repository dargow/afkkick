--[[
Afk tag mod for Minetest by Dargod, fork of GunshipPenguin afkkick mod.

To the extent possible under law, the author(s)
have dedicated all copyright and related and neighboring rights
to this software to the public domain worldwide. This software is
distributed without any warranty.
]]

local MAX_INACTIVE_TIME = 120
local CHECK_INTERVAL = 1

local players = {}
local checkTimer = 0

minetest.register_on_joinplayer(function(player)
	local playerName = player:get_player_name()
	players[playerName] = {
		lastAction = minetest.get_gametime()
	}
end)

minetest.register_on_leaveplayer(function(player)
	local playerName = player:get_player_name()
	players[playerName] = nil
end)

minetest.register_on_chat_message(function(playerName, message)
	players[playerName]["lastAction"] = minetest.get_gametime()
end)

minetest.register_globalstep(function(dtime)
	local currGameTime = minetest.get_gametime()
	
	--Loop through each player in players
	for playerName,_ in pairs(players) do
		local player = minetest.get_player_by_name(playerName)
		if player then
		
			--Check for inactivity once every CHECK_INTERVAL seconds
			checkTimer = checkTimer + dtime
			if checkTimer > CHECK_INTERVAL then
				checkTimer = 0
				
				--Change tag of player if he/she has been inactive for longer than MAX_INACTIVE_TIME seconds
				if minetest.get_modpath("rank") then		
					if players[playerName]["lastAction"] + MAX_INACTIVE_TIME < currGameTime then
 					minetest.get_player_by_name(playerName):set_nametag_attributes({text = "[AFK] " ..rank.getRankName(playerName).. " " ..playerName})
					else minetest.get_player_by_name(playerName):set_nametag_attributes({text = "" ..rank.getRankName(playerName).. " " ..playerName})	
					end
				else
					if players[playerName]["lastAction"] + MAX_INACTIVE_TIME < currGameTime then 
					minetest.get_player_by_name(playerName):set_nametag_attributes({text = "[AFK] " ..playerName})
					--minetest.chat_send_player(playerName, "You have been marked as AFK")
					else minetest.get_player_by_name(playerName):set_nametag_attributes({text = "" ..playerName})
					end
				end
				
			end
			
			--Check if this player is doing an action
			for _,keyPressed in pairs(player:get_player_control()) do
				if keyPressed then
					players[playerName]["lastAction"] = currGameTime
				end
			end
		end
	end
end)
