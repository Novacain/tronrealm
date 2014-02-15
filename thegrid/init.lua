-- thegrid 0.2.1 by paramat
-- For latest stable Minetest and back to 0.4.8
-- Depends default
-- License: code WTFPL

-- Parameters

local YMIN = 5000 -- Approximate base of realm
local YMAX = 9000 -- Approximate top of atmosphere
local TERCEN = 7000 -- Terrain centre y, average surface level
local TERSCA = 128 -- Terrain scale in nodes, controls height of mountains
local BLEND = 40 -- Flat to rough blend distance in nodes
local FLATRAD = 345 -- Flat area radius in nodes

-- White grid limits in units of chunk (chunk = 80 nodes)
local WXMIN = -3
local WXMAX = -1
local WZMIN = -3
local WZMAX = -1
-- Orange grid
local OXMIN = -3
local OXMAX = -1
local OZMIN = 0
local OZMAX = 2
-- Blue grid
local BXMIN = 0
local BXMAX = 2
local BZMIN = -3
local BZMAX = -1
-- Green grid
local GXMIN = 0
local GXMAX = 2
local GZMIN = 0
local GZMAX = 2

-- 3D noise for terrain

local np_terrain = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=256, z=512}, -- scale of largest structures
	seed = -230023, -- any number, defines the terrain pattern like a seed growing into a plant
	octaves = 6, -- level of finest detail, 5 = smoother
	persist = 0.63 -- balance of fine detail relative to coarse detail 
}			-- 0.4 = smooth, 0.6 = rough and Minetest default 
			-- 0.67 = science fiction, more overhangs and floating rocks

-- Stuff

thegrid = {}

-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.y < YMIN or maxp.y > YMAX then
		return
	end

	local t1 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	local chux = (x0 + 32) / 80 -- co-ordinates in chunks, chunk zero is x/z = -32 to x/z = 47
	local chuz = (z0 + 32) / 80
	
	print ("[thegrid] chunk minp ("..x0.." "..y0.." "..z0..")")
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	
	local c_air = minetest.get_content_id("air")
	local c_tronstone = minetest.get_content_id("tronblocks:stone")
	local c_tile = minetest.get_content_id("tronblocks:tile")
	local c_tileor = minetest.get_content_id("tronblocks:tile_orange")
	local c_tilebl = minetest.get_content_id("tronblocks:tile_blue")
	local c_tilegr = minetest.get_content_id("tronblocks:tile_green")
					
	local sidelen = x1 - x0 + 1
	local chulens = {x=sidelen, y=sidelen, z=sidelen}
	local minpos = {x=x0, y=y0, z=z0}

	local nvals_terrain = minetest.get_perlin_map(np_terrain, chulens):get3dMap_flat(minpos)

	local ni = 1
	for z = z0, z1 do -- for each xy plane progressing northwards
		for y = y0, y1 do -- for each x row progressing upwards
			local vi = area:index(x0, y, z) -- get voxel index for first node in x row
			for x = x0, x1 do -- for each node do
				local nodrad = math.sqrt((x + 32) ^ 2 + (z + 32) ^ 2) -- centre is at -32 -32
				local grad = (TERCEN - y) / TERSCA
				local namp
				if nodrad > FLATRAD + BLEND then
					namp = 1
				elseif nodrad < FLATRAD then
					namp = 0
				else
					namp = (1 - math.cos((nodrad - FLATRAD) / BLEND * math.pi)) / 2
				end
				local n_terrain = nvals_terrain[ni]
				local density = (n_terrain ^ 2 + n_terrain * 0.5) * namp + grad
				if namp == 0 and y == TERCEN then
					if chux >= WXMIN and chux <= WXMAX and chuz >= WZMIN and chuz <= WZMAX then
						data[vi] = c_tile
					elseif chux >= OXMIN and chux <= OXMAX and chuz >= OZMIN and chuz <= OZMAX then
						data[vi] = c_tileor
					elseif chux >= BXMIN and chux <= BXMAX and chuz >= BZMIN and chuz <= BZMAX then
						data[vi] = c_tilebl
					elseif chux >= GXMIN and chux <= GXMAX and chuz >= GZMIN and chuz <= GZMAX then
						data[vi] = c_tilegr
					else
						data[vi] = c_tronstone
					end
				elseif density >= 0 then
					data[vi] = c_tronstone
				else
					data[vi] = c_air
				end
				ni = ni + 1 -- increment perlinmap noise index
				vi = vi + 1 -- increment voxel index along x row
			end
		end
	end
	
	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)
	local chugent = math.ceil((os.clock() - t1) * 1000)
	print ("[thegrid] "..chugent.." ms")
end)
