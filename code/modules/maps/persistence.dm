/hook/roundend/proc/savemap()
	if(!current_map || !current_map.persist || !LAZYLEN(current_map.persist_levels))
		return 0
	. = 0

	var/static/dmm_suite/writer = new
	var/dir = "maps/[current_map.path]/"
	var/regex/mapsaveregex = new("[current_map.path]-(\\d+)_.+\\.dmm$")
	var/list/files = flist(dir)
	sortTim(files, /proc/cmp_text_asc)
	var/mfile
	for (var/i in 1 to files.len)
		mfile = files[i]
		if (!mapsaveregex.Find(mfile))
			continue
		var/zlev = mapsaveregex.group[1]
		if(!(zlev in current_map.persist_levels))
			continue
		var/time = world.time

		mfile = "[dir][mfile]"


		if(mfile << writer.write_map(locate(0, 0, zlev), locate(world.maxx, world.maxy, zlev)))
			world << "Failed to save '[mfile]'!"
		else
			world << "Saved level [zlev] in [(world.time - time)/10] seconds."

		.++
		CHECK_TICK