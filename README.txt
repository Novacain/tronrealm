tronrealm

In the effort to make a Tron-based world, I created a mod that added Tron-style blocks to the wonderfully voxel world we have. It wasn't long before it was pointed out to me that, although Tron fits well in the world of Minetest, it doesn't fit with the other textures. After a little thought, and seeing another realm mod, I had the idea for this, the Tron realm. It wasn't long before I started modifying the code for nether to see if I could generate a portal to the "Tron realm." Then I mentioned the idea to paramat to see if it was possible to create a flat area inside the realm to be representitive of "the grid." Paramat was the gratious enough to supply an entire mapgen for the realm, which is now used, with slight parameter tweaking. 

each mod is licensed individually

credits go to:

paramat for: thegrid (mapgen)
PilzAdam for: tronportal (based off Nether mod)
Novacain for: tronblocks (the gruntwork to enable a world like this to exist)


As a note, there are a few features that may seem slightly "hacky" that you may want to consider diabling in a public server.

First, tronblocks has the feature that "Tron Stone" yields two nodes when dug. I felt this represented the "resources" of a digital world well. the line is easy to spot in the code of the tronblocks mod if you wish to remove it.

Second, included in the tronportal mod are some crafts that allow glowboxes to be crafted into 20 dyes of the respective color. This is what I see as being a potential problem in servers, as it allows unendless green, blue, orange, and white dyes if you have tronstones and torches. These craft recipes are included near the bottom. I hope I have made this clear enough for you to use it as desired. 

Third, when a portal is generated in the realm, it can destroy some nodes. this can be solved by removing the craft recipe for tronportal:bit. it can then only be obtained by those with "give" or creative, and so can be controlled.
