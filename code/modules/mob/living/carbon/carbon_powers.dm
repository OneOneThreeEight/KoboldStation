//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()

	set category = "Abilities"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(B && B.host_brain)
		to_chat(src, "<span class='danger'>You withdraw your probosci, releasing control of [B.host_brain]</span>")

		B.detatch()

		verbs -= /mob/living/carbon/proc/release_control
		verbs -= /mob/living/carbon/proc/punish_host
		verbs -= /mob/living/carbon/proc/spawn_larvae

	else
		to_chat(src, "<span class='danger'>ERROR NO BORER OR BRAINMOB DETECTED IN THIS MOB, THIS IS A BUG !</span>")

//Brain slug proc for tormenting the host.
/mob/living/carbon/proc/punish_host()
	set category = "Abilities"
	set name = "Torment host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.host_brain.ckey)
		to_chat(src, "<span class='warning'>You send a punishing spike of psychic agony lancing into your host's brain.</span>")

		if (!can_feel_pain())
			to_chat(B.host_brain, "<span class='warning'>You feel a strange sensation as a foreign influence prods your mind.</span>")
			to_chat(src, "<span class='warning'>It doesn't seem to be as effective as you hoped.</span>")
		else
			to_chat(B.host_brain, "<span class='danger'><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></span>")