thegrid 0.2.0 by paramat
For latest stable Minetest back to 0.4.8
Depends default, tronblocks
Licenses: code WTFPL

Fly then teleport to 0 6889 0.
Disable cavegen when you create the world to avoid holes along chunk borders,
or if using Minetest 0.4.9dev use 'is_ground_content = false' to protect a node from cavegen griefing.



Note from Novacain:
if you want to change the grid size, change the numbers poitned out here:

	if chux >= >>-2<< and chux <= 0 and chuz >= >>-2<< and chuz <= 0 then
		data[vi] = c_tile
	elseif chux >= >>-2<< and chux <= 0 and chuz >= 1 and chuz <= >>3<< then
		data[vi] = c_tileor
	elseif chux >= 1 and chux <= >>3<< and chuz >= >>-2<< and chuz <= 0 then
		data[vi] = c_tilebl
	elseif chux >= 1 and chux <= >>3<< and chuz >= 1 and chuz <= >>3<< then
		data[vi] = c_tilegr

increase the positve, and decrease the negative to increase size, and decrease the positive, and increase the negative to decrease size (and for those unfamiliar with math, -2 is less than -1).
changing the other numbers in this segment moves the grid. if you increase the size of the grid, you will also need to change some more code to accomodate for the blending.


for each number you increase the size of the map by, add 120 more to this number. if you feel like decreasing the blend, do not decrease by more than 113 unles you want to risk it cutting into your grid.

		if nodrad > >>345<< + BLEND then
			namp = 1
		elseif nodrad < >>345<< then
			namp = 0
		else
			namp = (nodrad - >>345<<) / BLEND
		end
