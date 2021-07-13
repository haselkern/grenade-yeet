# grenade-yeet

A mod for [Factorio](https://factorio.com/). Instead of placing grenades and other explosives on the ground, inserters will yeet them into the distance. Guaranteed fun and occasional mayhem. Find more information and images on the [Factorio Mod Portal](https://mods.factorio.com/mod/grenade-yeet).

The code for the mod inside the `grenade-yeet` folder is only around 100 lines including lots of comments. It should be easy to understand for beginners, which includes myself as this is my first Factorio mod.

---

When creating a new release you have to bump the version number in `info.json`, write a changelog in `changelog.txt` and then run `make` to build a zip file that is ready for upload. This requires [jq](https://stedolan.github.io/jq/) to be installed. Make sure to test the zip once before uploading!
