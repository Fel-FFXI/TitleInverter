--[[
* Addons - Copyright (c) 2023 Ashita Development Team
* Contact: https://www.ashitaxi.com/
* Contact: https://discord.gg/Ashita
*
* This file is part of Ashita.
*
* Ashita is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Ashita is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Ashita.  If not, see <https://www.gnu.org/licenses/>.
--]]

addon.name      = 'TitleInverter';	-- The name of the addon.
addon.author    = 'Fel (Byrth)';	-- The name of the addon author.
addon.version   = '1.00';			-- The version of the addon. 
addon.desc      = 'Shows obtained or missing Titles from Title NPCs.';   	-- (Optional) The description of the addon.
addon.link      = 'https://ashitaxi.com/';      							-- (Optional) The link to the addons homepage.

--Original concept/idea from Byrth:
--[[
windower.register_event('incoming chunk', function (id, original, modified, injected, blocked)
    if id == 0x033 and npc_names[windower.ffxi.get_mob_by_id(original:unpack("I",5)).name] then
        print("Inverted NPC")
        local my_string = string.sub(original,1,0x50)
        for i = 0x51,0x68 do
            my_string = my_string..string.char(255 - original:byte(i))
        end
        local flags = original:sub(0x69,0x6C)
        local gil = original:sub(0x6D,0x70)
        return my_string..flags..gil
    end
end)
--]]

require('common');
local chat = require('chat');
local globalEnable = true;

npc_names = {
    ["Tuh Almobankha"] = true,
    ["Moozo-Koozo"] = true,
    ["Styi Palneh"] = true,
    ["Tamba-Namba"] = true,
    ["Bhio Fehriata"] = true,
    ["Cattah Pamjah"] = true,
    ["Burute-Sorute"] = true,
    ["Zuah Lepahnyu"] = true,
    ["Yulon-Polon"] = true,
    ["Willah Maratahya"] = true,
    ["Eron-Tomaron"] = true,
    ["Quntsu-Nointsu"] = true,
    ["Shupah Mujuuk"] = true,
    ["Aligi-Kufongi"] = true,
    ["Koyol-Futenol"] = true,
    ["Debadle-Levadle"] = true
}

ashita.events.register('command', 'command_cb', function (cmd, nType)
    local args = cmd.command:args()
	local command = string.lower(args[1])
    
    if command ~= '/titleinverter' then
        return false
    end
	
	local enabledMsg = chat.color1(2, "Enabled. ")  .. chat.message("NPCs will show missing titles.")
	local disabledMsg = chat.color1(5, "Disabled. ")   .. chat.message("NPCs will show obtained titles.")
	if (#args == 1) then
		globalEnable = not globalEnable;
		print(chat.header(addon.name) .. (globalEnable and enabledMsg or disabledMsg) );
	elseif (#args == 2 and args[2]:any('on')) then
		globalEnable = true;
		print(chat.header(addon.name) .. (globalEnable and enabledMsg or disabledMsg) );
	elseif (#args == 2 and args[2]:any('off')) then
		globalEnable = false;
		print(chat.header(addon.name) .. (globalEnable and enabledMsg or disabledMsg) );
	end
end)


--[[
* event: packet_in
* desc : Event called when the addon is processing incoming packets.
--]]
ashita.events.register('packet_in', 'packet_in_callback1', function (e)
    if (globalEnable and e.id == 0x033) then
		local index = struct.unpack('H', e.data, 0x08+1);
		local name = AshitaCore:GetMemoryManager():GetEntity():GetName(index);
		if npc_names[name] then
			print(chat.header(addon.name) .. chat.color1(3, "Responses from Title NPC are Inverted!"))
			local my_string = string.sub(e.data_modified,1,0x50)
			for i = 0x51,0x68 do
				my_string = my_string..string.char(255 - e.data_modified:byte(i))
			end
			local flags = e.data_modified:sub(0x69,0x6C)
			local gil = e.data_modified:sub(0x6D,0x70)
			e.data_modified = my_string..flags..gil
		end
    end
end);
