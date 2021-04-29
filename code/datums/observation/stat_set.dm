//	Observer Pattern Implementation: Stat Set
//		Registration type: /mob/living
//
//		Raised when: A /mob/living changes stat, using the set_stat() proc
//
//		Arguments that the called proc should expect:
//			/mob/living/stat_mob: The mob whose stat changed
//			/old_stat: Status before the change.
//			/new_stat: Status after the change.

/decl/observ/stat_set
	name = "Stat Set"
	expected_type = /mob/living

/****************
* Stat Handling *
****************/
/mob/living/set_stat(var/new_stat)
	var/old_stat = stat
	. = ..()
	if(stat != old_stat)
		events_repository.raise_event(/decl/observ/stat_set, src, old_stat, new_stat)
