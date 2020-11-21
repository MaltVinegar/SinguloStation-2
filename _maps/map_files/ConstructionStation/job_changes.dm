#define JOB_MODIFICATION_MAP_NAME "Construction Station"

/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	total_positions = -1
	spawn_positions = -1

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

#undef JOB_MODIFICATION_MAP_NAME
