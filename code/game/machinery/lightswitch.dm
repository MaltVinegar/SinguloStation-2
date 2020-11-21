/// The light switch. Can have multiple per area.
/obj/machinery/light_switch
	name = "light switch"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	desc = "Make dark."
	power_channel = AREA_USAGE_LIGHT
	var/construction_step = 3
	/// Set this to a string, path, or area instance to control that area
	/// instead of the switch's location.
	var/area/area = null

/obj/machinery/light_switch/Initialize()
	. = ..()
	if(istext(area))
		area = text2path(area)
	if(ispath(area))
		area = GLOB.areas_by_type[area]
	if(!area)
		area = get_area(src)

	if(!name)
		name = "light switch ([area.name])"

	update_icon()

/obj/machinery/light_switch/update_icon()
	if(stat & NOPOWER)
		icon_state = "light-p"
	else if(construction_step == 0 || construction_step == 1)
		icon_state = "light-p"
	else if (construction_step == 2)
		icon_state = "light0"
	else
		if(area.lightswitch)
			icon_state = "light1"
		else
			icon_state = "light0"

/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	. += "It is [area.lightswitch ? "on" : "off"]."

/obj/machinery/light_switch/attackby(obj/item/W, mob/living/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		var/obj/item/wrench/T = W
		if(construction_step == 0)
			to_chat(user, "<span class='notice'>You begin to remove \the [src] frame from the wall...</span>")
			if(T.use_tool(src, user, 40))
				user.visible_message("<span class='notice'>[user] removes \the [src] frame from the wall.</span>", "<span class='notice'>You remove \the [src] frame from the wall.</span>")
				T.play_tool_sound(src)
				new /obj/item/wallframe/light_switch(get_turf(user))
				qdel(src)
		return
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		var/obj/item/screwdriver/T = W
		switch(construction_step)
			if(0)
				construction_step += 1
				user.visible_message("<span class='notice'>[user] screws \the [src] frame into place.</span>", "<span class='notice'>You screw \the [src] frame into place.</span>")
			if(1)
				construction_step -= 1
				user.visible_message("<span class='notice'>[user] unscrews \the [src] frame.</span>", "<span class='notice'>You unscrew \the [src] frame.</span>")
			if(2)
				construction_step += 1
				user.visible_message("<span class='notice'>[user] finishes the \the [src] frame.</span>", "<span class='notice'>You finish \the [src] frame.</span>")
			if(3)
				construction_step -= 1
				user.visible_message("<span class='notice'>[user] opens the \the [src]'s cover.</span>", "<span class='notice'>You open \the [src]'s cover.</span>")
		T.play_tool_sound(src)
		update_icon()
		return
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		var/obj/item/wirecutters/T = W
		switch(construction_step)
			if(0)
				to_chat(user, "<span class='warning'>There are no wires to cut!</span>")
			if(1)
				to_chat(user, "<span class='warning'>There are no wires to cut!</span>")
			if(2)
				construction_step -= 1
				user.visible_message("<span class='notice'>[user] cuts \the [src]'s wires.</span>", "<span class='notice'>You cut \the [src]'s wires.</span>")
				new /obj/item/stack/cable_coil(get_turf(user), 5)
				T.play_tool_sound(src)
			if(3)
				to_chat(user, "<span class='warning'>The wires must be exposed to do this!</span>")
		update_icon()
		return
	if(istype(W, /obj/item/stack/cable_coil/))
		var/obj/item/stack/cable_coil/T = W
		switch(construction_step)
			if(0)
				to_chat(user, "<span class='warning'>\The [src] frame must be secured first!</span>")
			if(1)
				if(T.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need at least 5 cable peices to do this!</span>")
				else
					to_chat(user, "<span class='notice'>You begin to wire \the [src]...</span>")
					if(T.use_tool(src, user, 30))
						user.visible_message("<span class='notice'>[user] adds wire to \the [src].</span>", "<span class='notice'>You add wires to \the [src].</span>")
						T.amount -= 5
						construction_step += 1
						T.play_tool_sound(src)
						return
			if(2)
				to_chat(user, "<span class='warning'>\The [src] already has wires!</span>")
			if(3)
				to_chat(user, "<span class='warning'>\The [src] already has wires!</span>")
		update_icon()
		return
	return ..()

/obj/machinery/light_switch/interact(mob/user)
	. = ..()
	if(construction_step == 3)
		area.lightswitch = !area.lightswitch
		area.update_icon()
		for(var/obj/machinery/light_switch/L in area)
			L.update_icon()
		area.power_change()
	else
		to_chat(user, "<span class='warning'>The light switch must be complete to do this!</span>")

/obj/machinery/light_switch/power_change()
	if(area == get_area(src))
		if(powered(AREA_USAGE_LIGHT))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER

		update_icon()

/obj/machinery/light_switch/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(stat & (BROKEN|NOPOWER)))
		power_change()
