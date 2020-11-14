/obj/effect/landmark/stationroom
	var/list/templates = list()
	layer = BULLET_HOLE_LAYER

/obj/effect/landmark/stationroom/New()
	..()
	GLOB.stationroom_landmarks += src

/obj/effect/landmark/stationroom/Destroy()
	if(src in GLOB.stationroom_landmarks)
		GLOB.stationroom_landmarks -= src
	return ..()

/obj/effect/landmark/stationroom/proc/load(template_name)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(!template_name)
		for(var/t in templates)
			if(!SSmapping.station_room_templates[t])
				log_world("Station room spawner placed at ([T.x], [T.y], [T.z]) has invalid ruin name of \"[t]\" in its list")
				templates -= t
		template_name = pickweightAllowZero(templates)
	if(!template_name)
		GLOB.stationroom_landmarks -= src
		qdel(src)
		return FALSE
	var/datum/map_template/template = SSmapping.station_room_templates[template_name]
	if(!template)
		return FALSE
	testing("Room \"[template_name]\" placed at ([T.x], [T.y], [T.z])")
	template.load(T, centered = FALSE)
	template.loaded++
	GLOB.stationroom_landmarks -= src
	qdel(src)
	return TRUE


/obj/effect/landmark/stationroom/constructionstation/station
	templates = list("Default Base Station" = 1)

/obj/effect/landmark/stationroom/constructionstation/asteroid
	templates = list("Default Asteroid" = 1)

/obj/effect/landmark/stationroom/constructionstation/tcommsat
	templates = list("tcomms" = 1)


/obj/effect/landmark/stationroom/constructionstation/station/New()
	. = ..()
	templates = CONFIG_GET(keyed_list/random_station)

/obj/effect/landmark/stationroom/constructionstation/asteroid/New()
	. = ..()
	templates = CONFIG_GET(keyed_list/random_station)

/obj/effect/landmark/stationroom/constructionstation/tcommsat/New()
	. = ..()
	templates = CONFIG_GET(keyed_list/random_station)
