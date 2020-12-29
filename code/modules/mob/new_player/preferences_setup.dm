/datum/preferences
	//The mob should have a gender you want before running this proc. Will run fine without H
	proc/randomize_appearance_and_body_for(var/mob/living/carbon/human/H)
		var/decl/species/current_species = get_species_by_key(species || GLOB.using_map.default_species)
		gender = pick(current_species.genders)

		h_style = random_hair_style(gender, species)
		f_style = random_facial_hair_style(gender, species)
		if(current_species)
			if(current_species.appearance_flags & HAS_A_SKIN_TONE)
				skin_tone = current_species.get_random_skin_tone() || skin_tone
			if(current_species.appearance_flags & HAS_EYE_COLOR)
				eye_colour = current_species.get_random_eye_color()
			if(current_species.appearance_flags & HAS_SKIN_COLOR)
				skin_colour = current_species.get_random_skin_color()
			if(current_species.appearance_flags & HAS_HAIR_COLOR)
				hair_colour = current_species.get_random_hair_color()
				facial_hair_colour = prob(75) ? hair_colour : current_species.get_random_facial_hair_color()

		if(current_species.appearance_flags & HAS_UNDERWEAR)
			if(all_underwear)
				all_underwear.Cut()
			for(var/datum/category_group/underwear/WRC in GLOB.underwear.categories)
				var/datum/category_item/underwear/WRI = pick(WRC.items)
				all_underwear[WRC.name] = WRI.name

		backpack = decls_repository.get_decl(pick(subtypesof(/decl/backpack_outfit)))
		age = rand(current_species.min_age, current_species.max_age)
		b_type = RANDOM_BLOOD_TYPE
		if(H)
			copy_to(H)

/datum/preferences/proc/dress_preview_mob(var/mob/living/carbon/human/mannequin)
	var/update_icon = FALSE
	copy_to(mannequin, TRUE)

	var/datum/job/previewJob
	if(equip_preview_mob)
		// Determine what job is marked as 'High' priority, and dress them up as such.
		if(GLOB.using_map.default_assistant_title in job_low)
			previewJob = SSjobs.get_by_title(GLOB.using_map.default_assistant_title)
		else
			previewJob = SSjobs.get_by_title(job_high)
	else
		return

	if((equip_preview_mob & EQUIP_PREVIEW_JOB) && previewJob)
		mannequin.job = previewJob.title
		var/datum/mil_branch/branch = mil_branches.get_branch(branches[previewJob.title])
		var/datum/mil_rank/rank = mil_branches.get_rank(branches[previewJob.title], ranks[previewJob.title])
		previewJob.equip_preview(mannequin, player_alt_titles[previewJob.title], branch, rank)
		update_icon = TRUE

	if(!(mannequin.species.appearance_flags && mannequin.species.appearance_flags & HAS_UNDERWEAR))
		if(all_underwear)
			all_underwear.Cut()

	if((equip_preview_mob & EQUIP_PREVIEW_LOADOUT) && !(previewJob && (equip_preview_mob & EQUIP_PREVIEW_JOB) && (previewJob.type == /datum/job/ai || previewJob.type == /datum/job/cyborg)))
		// Equip custom gear loadout, replacing any job items
		var/list/loadout_taken_slots = list()
		for(var/thing in Gear())
			var/datum/gear/G = gear_datums[thing]
			if(G)
				var/permitted = 0
				if(G.allowed_roles && G.allowed_roles.len)
					if(previewJob)
						for(var/job_type in G.allowed_roles)
							if(previewJob.type == job_type)
								permitted = 1
				else
					permitted = 1

				if(G.whitelisted && !(mannequin.species.name in G.whitelisted))
					permitted = 0

				if(!permitted)
					continue

				if(G.slot && G.slot != slot_tie_str && !(G.slot in loadout_taken_slots) && G.spawn_on_mob(mannequin, gear_list[gear_slot][G.display_name]))
					loadout_taken_slots.Add(G.slot)
					update_icon = TRUE

	if(update_icon)
		mannequin.update_icons()

/datum/preferences/proc/update_preview_icon()
	var/mob/living/carbon/human/dummy/mannequin/mannequin = get_mannequin(client_ckey)
	mannequin.delete_inventory(TRUE)
	dress_preview_mob(mannequin)

	update_character_previews(new /mutable_appearance(mannequin))
