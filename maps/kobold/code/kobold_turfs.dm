/turf/simulated/floor/planet/sand
	name = "desert"
	icon = 'icons/misc/beach.dmi'
	footstep_sound = "sandstep"
	icon_state = "desert"
	oxygen = MOLES_OXYGEN_NAARVAT
	nitrogen = MOLES_NITROGEN_NAARVAT
	carbon_dioxide = MOLES_CARBONDIOXIDE_NAARVAT
	temperature = TEMPERATURE_NAARVAT

/turf/simulated/floor/planet/sand/rocky
	name = "rocky sand"
	icon = 'icons/turf/smooth/rocky_ash.dmi'
	icon_state = "rockyash"
	desc = "A fine grey ash. Seems to contain medium-sized rocks."
	footstep_sound = "gravelstep"

/turf/simulated/floor/planet/sand/rocky/Initialize()
	. = ..()
	if (prob(20))
		add_overlay("asteroid[rand(0, 9)]", TRUE)