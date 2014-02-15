-- Minetest 0.4 Mod: tronportal
local TRON_DEPTH = 7001 -- needs to be 1 node above TERCEN

minetest.register_node("tronportal:portal", {
	description = "Tron Portal",
	tiles = {
		"tron_transparent.png",
		"tron_transparent.png",
		"tron_transparent.png",
		"tron_transparent.png",
		{
			name = "tron_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
		{
			name = "tron_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = true,
	walkable = false,
	digable = false,
	pointable = false,
	buildable_to = false,
	drop = "",
	light_source = 5,
	post_effect_color = {a=180, r=128, g=0, b=128},
	alpha = 192,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
		},
	},
	groups = {not_in_creative_inventory=1}
})

local function build_portal(pos, target)
	local p = {x=pos.x-1, y=pos.y-1, z=pos.z}
	local p1 = {x=pos.x-1, y=pos.y-1, z=pos.z}
	local p2 = {x=p1.x+3, y=p1.y+4, z=p1.z}
	for i=1,4 do
		minetest.env:set_node(p, {name="tronblocks:stone"})
		p.y = p.y+1
	end
	for i=1,3 do
		minetest.env:set_node(p, {name="tronblocks:stone"})
		p.x = p.x+1
	end
	for i=1,4 do
		minetest.env:set_node(p, {name="tronblocks:stone"})
		p.y = p.y-1
	end
	for i=1,3 do
		minetest.env:set_node(p, {name="tronblocks:stone"})
		p.x = p.x-1
	end
	for x=p1.x,p2.x do
	for y=p1.y,p2.y do
		p = {x=x, y=y, z=p1.z}
		if not (x == p1.x or x == p2.x or y==p1.y or y==p2.y) then
			minetest.env:set_node(p, {name="tronportal:portal", param2=0})
		end
		local meta = minetest.env:get_meta(p)
		meta:set_string("p1", minetest.pos_to_string(p1))
		meta:set_string("p2", minetest.pos_to_string(p2))
		meta:set_string("target", minetest.pos_to_string(target))
		
		if y ~= p1.y then
			for z=-2,2 do
				if z ~= 0 then
					p.z = p.z+z
					if minetest.registered_nodes[minetest.env:get_node(p).name].is_ground_content then
						minetest.env:remove_node(p)
					end
					p.z = p.z-z
				end
			end
		end
		
	end
	end
end

minetest.register_abm({
	nodenames = {"tronportal:portal"},
	interval = 1,
	chance = 2,
	action = function(pos, node)
		minetest.add_particlespawner(
			32, --amount
			4, --time
			{x=pos.x-0.25, y=pos.y-0.25, z=pos.z-0.25}, --minpos
			{x=pos.x+0.25, y=pos.y+0.25, z=pos.z+0.25}, --maxpos
			{x=-0.8, y=-0.8, z=-0.8}, --minvel
			{x=0.8, y=0.8, z=0.8}, --maxvel
			{x=0,y=0,z=0}, --minacc
			{x=0,y=0,z=0}, --maxacc
			0.5, --minexptime
			1, --maxexptime
			1, --minsize
			2, --maxsize
			false, --collisiondetection
			"tron_particle.png" --texture
		)
		for _,obj in ipairs(minetest.env:get_objects_inside_radius(pos, 1)) do
			if obj:is_player() then
				local meta = minetest.env:get_meta(pos)
				local target = minetest.string_to_pos(meta:get_string("target"))
				if target then
					minetest.after(3, function(obj, pos, target)
						local objpos = obj:getpos()
						objpos.y = objpos.y+0.1 -- Fix some glitches at -8000
						if minetest.env:get_node(objpos).name ~= "tronportal:portal" then
							return
						end
						
						obj:setpos(target)
						
						local function check_and_build_portal(pos, target)
							local n = minetest.env:get_node_or_nil(target)
							if n and n.name ~= "tronportal:portal" then
								build_portal(target, pos)
								minetest.after(2, check_and_build_portal, pos, target)
								minetest.after(4, check_and_build_portal, pos, target)
							elseif not n then
								minetest.after(1, check_and_build_portal, pos, target)
							end
						end
						
						minetest.after(1, check_and_build_portal, pos, target)
						
					end, obj, pos, target)
				end
			end
		end
	end,
})

local function move_check(p1, max, dir)
	local p = {x=p1.x, y=p1.y, z=p1.z}
	local d = math.abs(max-p1[dir]) / (max-p1[dir])
	while p[dir] ~= max do
		p[dir] = p[dir] + d
		if minetest.env:get_node(p).name ~= "tronblocks:stone" then
			return false
		end
	end
	return true
end

local function check_portal(p1, p2)
	if p1.x ~= p2.x then
		if not move_check(p1, p2.x, "x") then
			return false
		end
		if not move_check(p2, p1.x, "x") then
			return false
		end
	elseif p1.z ~= p2.z then
		if not move_check(p1, p2.z, "z") then
			return false
		end
		if not move_check(p2, p1.z, "z") then
			return false
		end
	else
		return false
	end
	
	if not move_check(p1, p2.y, "y") then
		return false
	end
	if not move_check(p2, p1.y, "y") then
		return false
	end
	
	return true
end

local function is_portal(pos)
	for d=-3,3 do
		for y=-4,4 do
			local px = {x=pos.x+d, y=pos.y+y, z=pos.z}
			local pz = {x=pos.x, y=pos.y+y, z=pos.z+d}
			if check_portal(px, {x=px.x+3, y=px.y+4, z=px.z}) then
				return px, {x=px.x+3, y=px.y+4, z=px.z}
			end
			if check_portal(pz, {x=pz.x, y=pz.y+4, z=pz.z+3}) then
				return pz, {x=pz.x, y=pz.y+4, z=pz.z+3}
			end
		end
	end
end

local function make_portal(pos)
	local p1, p2 = is_portal(pos)
	if not p1 or not p2 then
		return false
	end
	
	for d=1,2 do
	for y=p1.y+1,p2.y-1 do
		local p
		if p1.z == p2.z then
			p = {x=p1.x+d, y=y, z=p1.z}
		else
			p = {x=p1.x, y=y, z=p1.z+d}
		end
		if minetest.env:get_node(p).name ~= "air" then
			return false
		end
	end
	end
	
	local param2
	if p1.z == p2.z then param2 = 0 else param2 = 1 end
	
	local target = {x=p1.x, y=p1.y, z=p1.z}
	target.x = target.x + 1
	if target.y > TRON_DEPTH then
		target.y = math.random(-50, 20)
	else
		target.y = TRON_DEPTH - math.random(0, 0)
	end
	
	for d=0,3 do
	for y=p1.y,p2.y do
		local p = {}
		if param2 == 0 then p = {x=p1.x+d, y=y, z=p1.z} else p = {x=p1.x, y=y, z=p1.z+d} end
		if minetest.env:get_node(p).name == "air" then
			minetest.env:set_node(p, {name="tronportal:portal", param2=param2})
		end
		local meta = minetest.env:get_meta(p)
		meta:set_string("p1", minetest.pos_to_string(p1))
		meta:set_string("p2", minetest.pos_to_string(p2))
		meta:set_string("target", minetest.pos_to_string(target))
	end
	end
	return true
end

minetest.register_node(":tronblocks:stone", {
	description = "Tron Stone",
	tiles = {"tronblocks_stone.png"},
	is_ground_content = true,
	sounds = default.node_sound_wood_defaults(),
	groups = {cracky=3,oddly_breakable_by_hand=2},
	light_source = 5,
	drop = "tronblocks:stone 2",
	
	on_destruct = function(pos)
		local meta = minetest.env:get_meta(pos)
		local p1 = minetest.string_to_pos(meta:get_string("p1"))
		local p2 = minetest.string_to_pos(meta:get_string("p2"))
		local target = minetest.string_to_pos(meta:get_string("target"))
		if not p1 or not p2 then
			return
		end
		for x=p1.x,p2.x do
		for y=p1.y,p2.y do
		for z=p1.z,p2.z do
			local nn = minetest.env:get_node({x=x,y=y,z=z}).name
			if nn == "tronblocks:stone" or nn == "tronportal:portal" then
				if nn == "tronportal:portal" then
					minetest.env:remove_node({x=x,y=y,z=z})
				end
				local m = minetest.env:get_meta({x=x,y=y,z=z})
				m:set_string("p1", "")
				m:set_string("p2", "")
				m:set_string("target", "")
			end
		end
		end
		end
		meta = minetest.env:get_meta(target)
		if not meta then
			return
		end
		p1 = minetest.string_to_pos(meta:get_string("p1"))
		p2 = minetest.string_to_pos(meta:get_string("p2"))
		if not p1 or not p2 then
			return
		end
		for x=p1.x,p2.x do
		for y=p1.y,p2.y do
		for z=p1.z,p2.z do
			local nn = minetest.env:get_node({x=x,y=y,z=z}).name
			if nn == "tronblocks:stone" or nn == "tronportal:portal" then
				if nn == "tronportal:portal" then
					minetest.env:remove_node({x=x,y=y,z=z})
				end
				local m = minetest.env:get_meta({x=x,y=y,z=z})
				m:set_string("p1", "")
				m:set_string("p2", "")
				m:set_string("target", "")
			end
		end
		end
		end
	end,
})

minetest.register_craftitem(":tronportal:bit", {
	description = "Bit",
	inventory_image = "tronportal_bit.png",
	on_place = function(stack,_, pt)
		if pt.under and minetest.env:get_node(pt.under).name == "tronblocks:stone" then
			local done = make_portal(pt.under)
			if done and not minetest.setting_getbool("creative_mode") then
				stack:take_item()
			end
		end
		return stack
	end,
})

-- dye recipes "hacks"
minetest.register_craft({
  output = "dye:white 20",
  recipe = {
  {"tronblocks:glow_box"},
  }
})
minetest.register_craft({
  output = "dye:orange 20",
  recipe = {
  {"tronblocks:glow_box_orange"},
  }
})
minetest.register_craft({
  output = "dye:blue 20",
  recipe = {
  {"tronblocks:glow_box_blue"},
  }
})
minetest.register_craft({
  output = "dye:green 20",
  recipe = {
  {"tronblocks:glow_box_green"},
  }
})
--remove in public servers if you want to prevent "portal griefing"
minetest.register_craft({
  output = "tronportal:bit 8",
  recipe = {
  {"tronblocks:stone", "", "tronblocks:stone"},
  }
})
--only need this for the one above it
minetest.register_craft({
  output = "tronblocks:stone 1",
  recipe = {
  {"tronportal:bit", "tronportal:bit"},
  {"tronportal:bit", "tronportal:bit"},
  }
})

local function replace(old, new)
	for i=1,8 do
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = new,
			wherein        = old,
			clust_scarcity = 1,
			clust_num_ores = 1,
			clust_size     = 1,
			height_min     = 5000,
			height_max     = 7000,
		})
	end
end


	minetest.register_ore({
	ore_type       = "scatter",
	ore            = "tronblocks:glow_box",
	wherein        = "tronblocks:stone",
	clust_scarcity = 17*17*17,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = 5000,
	height_max     = 7000,
})
	minetest.register_ore({
	ore_type       = "scatter",
	ore            = "tronblocks:glow_box_orange",
	wherein        = "tronblocks:stone",
	clust_scarcity = 17*17*17,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = 5000,
	height_max     = 7000,
})
	minetest.register_ore({
	ore_type       = "scatter",
	ore            = "tronblocks:glow_box_blue",
	wherein        = "tronblocks:stone",
	clust_scarcity = 17*17*17,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = 5000,
	height_max     = 7000,
})
	minetest.register_ore({
	ore_type       = "scatter",
	ore            = "tronblocks:glow_box_green",
	wherein        = "tronblocks:stone",
	clust_scarcity = 17*17*17,
	clust_num_ores = 5,
	clust_size     = 3,
	height_min     = 5000,
	height_max     = 7000,
})

