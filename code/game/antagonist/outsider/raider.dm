var/datum/antagonist/raider/raiders

/datum/antagonist/raider
	id = MODE_RAIDER
	role_text = "Raider"
	role_text_plural = "Raiders"
	bantype = "raider"
	antag_indicator = "mutineer"
	landmark_id = "voxstart"
	welcome_text = "Use :H to talk on your encrypted channel."
	flags = ANTAG_OVERRIDE_JOB | ANTAG_CLEAR_EQUIPMENT | ANTAG_CHOOSE_NAME | ANTAG_VOTABLE | ANTAG_SET_APPEARANCE | ANTAG_HAS_LEADER
	antaghud_indicator = "hudmutineer"

	hard_cap = 6
	hard_cap_round = 10
	initial_spawn_req = 4
	initial_spawn_target = 6

	faction = "syndicate"

	id_type = /obj/item/weapon/card/id/syndicate

	var/list/raider_guns = list(
		/obj/item/weapon/gun/energy/rifle/laser,
		/obj/item/weapon/gun/energy/rifle/laser/xray,
		/obj/item/weapon/gun/energy/rifle/icelance,
		/obj/item/weapon/gun/energy/retro,
		/obj/item/weapon/gun/energy/xray,
		/obj/item/weapon/gun/energy/mindflayer,
		/obj/item/weapon/gun/energy/toxgun,
		/obj/item/weapon/gun/energy/stunrevolver,
		/obj/item/weapon/gun/energy/rifle/ionrifle,
		/obj/item/weapon/gun/energy/taser,
		/obj/item/weapon/gun/energy/crossbow/largecrossbow,
		/obj/item/weapon/gun/launcher/crossbow,
		/obj/item/weapon/gun/launcher/grenade,
		/obj/item/weapon/gun/launcher/pneumatic,
		/obj/item/weapon/gun/projectile/automatic/mini_uzi,
		/obj/item/weapon/gun/projectile/automatic/c20r,
		/obj/item/weapon/gun/projectile/automatic/wt550,
		/obj/item/weapon/gun/projectile/automatic/rifle/sts35,
		/obj/item/weapon/gun/projectile/automatic/tommygun,
		/obj/item/weapon/gun/projectile/automatic/x9,
		/obj/item/weapon/gun/projectile/silenced,
		/obj/item/weapon/gun/projectile/shotgun/pump,
		/obj/item/weapon/gun/projectile/shotgun/pump/combat,
		/obj/item/weapon/gun/projectile/shotgun/doublebarrel,
		/obj/item/weapon/gun/projectile/shotgun/doublebarrel/pellet,
		/obj/item/weapon/gun/projectile/shotgun/doublebarrel/sawn,
		/obj/item/weapon/gun/projectile/shotgun/pump/rifle,
		/obj/item/weapon/gun/projectile/colt,
		/obj/item/weapon/gun/projectile/sec,
		/obj/item/weapon/gun/projectile/pistol,
		/obj/item/weapon/gun/projectile/deagle,
		/obj/item/weapon/gun/projectile/revolver,
		/obj/item/weapon/gun/projectile/revolver/deckard,
		/obj/item/weapon/gun/projectile/revolver/derringer,
		/obj/item/weapon/gun/projectile/revolver/lemat,
		/obj/item/weapon/gun/projectile/contender,
		/obj/item/weapon/gun/projectile/pirate,
		/obj/item/weapon/gun/projectile/tanto,
		/obj/item/weapon/gun/projectile/shotgun/pump/rifle/vintage
		)


	var/list/raider_holster = list(
		/obj/item/clothing/accessory/holster/armpit,
		/obj/item/clothing/accessory/holster/waist,
		/obj/item/clothing/accessory/holster/hip
		)

/datum/antagonist/raider/New()
	..()
	raiders = src

/datum/antagonist/raider/update_access(var/mob/living/player)
	for(var/obj/item/weapon/storage/wallet/W in player.contents)
		for(var/obj/item/weapon/card/id/id in W.contents)
			id.name = "[player.real_name]'s Passport"
			id.registered_name = player.real_name
			W.name = "[initial(W.name)] ([id.name])"

/datum/antagonist/raider/proc/is_raider_crew_safe()

	if(!current_antagonists || current_antagonists.len == 0)
		return 0

	for(var/datum/mind/player in current_antagonists)
		if(!player.current || get_area(player.current) != locate(/area/skipjack_station/start))
			return 0
	return 1

/datum/antagonist/raider/equip(var/mob/living/carbon/human/player)

	if(!..())
		return 0

	for (var/obj/item/I in player)
		if (istype(I, /obj/item/weapon/implant))
			continue
		player.drop_from_inventory(I)
		if(I.loc != player)
			qdel(I)

	if(player.species && player.species.get_bodytype() == "Vox")
		equip_vox(player)
	else
		player.preEquipOutfit(/datum/outfit/admin/syndicate/raider, FALSE)
		player.equipOutfit(/datum/outfit/admin/syndicate/raider, FALSE)
		player.force_update_limbs()
		player.update_eyes()
		player.regenerate_icons()
		equip_weapons(player)

	//Try to equip it, del if we fail.
	var/obj/item/device/contract_uplink/new_uplink = new()
	if (!player.equip_to_appropriate_slot(new_uplink))
		qdel(new_uplink)

	give_codewords(player)

	return 1

/datum/antagonist/raider/proc/equip_weapons(var/mob/living/carbon/human/player)
	var/new_gun = pick(raider_guns)
	var/new_holster = pick(raider_holster) //raiders don't start with any backpacks, so let's be nice and give them a holster if they can use it.
	var/turf/T = get_turf(player)

	var/obj/item/primary = new new_gun(T)
	var/obj/item/clothing/accessory/holster/holster = null

	//Give some of the raiders a pirate gun as a secondary
	if(prob(60))
		var/obj/item/secondary = new /obj/item/weapon/gun/projectile/pirate(T)
		if(!(primary.slot_flags & SLOT_HOLSTER))
			holster = new new_holster(T)
			holster.holstered = secondary
			secondary.forceMove(holster)
		else
			player.equip_to_slot_or_del(secondary, slot_belt)

	if(primary.slot_flags & SLOT_HOLSTER)
		holster = new new_holster(T)
		holster.holstered = primary
		primary.forceMove(holster)
	else if(!player.belt && (primary.slot_flags & SLOT_BELT))
		player.equip_to_slot_or_del(primary, slot_belt)
	else if(!player.back && (primary.slot_flags & SLOT_BACK))
		player.equip_to_slot_or_del(primary, slot_back)
	else
		player.put_in_any_hand_if_possible(primary)

	//If they got a projectile gun, give them a little bit of spare ammo
	equip_ammo(player, primary)

	if(holster)
		var/obj/item/clothing/under/uniform = player.w_uniform
		if(istype(uniform) && uniform.can_attach_accessory(holster))
			uniform.attackby(holster, player)
		else
			player.put_in_any_hand_if_possible(holster)

/datum/antagonist/raider/proc/equip_ammo(var/mob/living/carbon/human/player, var/obj/item/weapon/gun/gun)
	if(istype(gun, /obj/item/weapon/gun/projectile))
		var/obj/item/weapon/gun/projectile/bullet_thrower = gun
		if(bullet_thrower.magazine_type)
			player.equip_to_slot_or_del(new bullet_thrower.magazine_type(player), slot_l_store)
			if(prob(20)) //don't want to give them too much
				player.equip_to_slot_or_del(new bullet_thrower.magazine_type(player), slot_r_store)
		else if(bullet_thrower.ammo_type)
			var/obj/item/weapon/storage/box/ammobox = new(get_turf(player.loc))
			for(var/i in 1 to rand(3,5) + rand(0,2))
				new bullet_thrower.ammo_type(ammobox)
			player.put_in_any_hand_if_possible(ammobox)
		return
	if(istype(gun, /obj/item/weapon/gun/launcher/grenade))
		var/list/grenades = list(
			/obj/item/weapon/grenade/empgrenade,
			/obj/item/weapon/grenade/smokebomb,
			/obj/item/weapon/grenade/flashbang
			)
		var/obj/item/weapon/storage/box/ammobox = new(get_turf(player.loc))
		for(var/i in 1 to 7)
			var/grenade_type = pick(grenades)
			new grenade_type(ammobox)
		player.put_in_any_hand_if_possible(ammobox)

/datum/antagonist/raider/proc/equip_vox(var/mob/living/carbon/human/player)

	var/uniform_type = pick(list(/obj/item/clothing/under/vox/vox_robes,/obj/item/clothing/under/vox/vox_casual))

	player.equip_to_slot_or_del(new uniform_type(player), slot_w_uniform)
	player.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/vox(player), slot_shoes) // REPLACE THESE WITH CODED VOX ALTERNATIVES.
	player.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow/vox(player), slot_gloves) // AS ABOVE.
	player.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/swat/vox(player), slot_wear_mask)
	player.equip_to_slot_or_del(new /obj/item/weapon/tank/nitrogen(player), slot_back)
	player.equip_to_slot_or_del(new /obj/item/device/flashlight(player), slot_r_store)

	player.internal = locate(/obj/item/weapon/tank) in player.contents
	if(istype(player.internal,/obj/item/weapon/tank) && player.internals)
		player.internals.icon_state = "internal1"

	return 1
