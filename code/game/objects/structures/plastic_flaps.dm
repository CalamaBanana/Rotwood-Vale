/obj/structure/plasticflaps
	name = "iron bars"
	desc = "It seems pretty rusty."
	gender = PLURAL
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	armor = list("blunt" = 100, "slash" = 80, "stab" = 90, "bullet" = 80, "laser" = 80, "energy" = 100, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 50, "acid" = 50) //what?
	density = FALSE
	anchored = TRUE
	CanAtmosPass = ATMOS_PASS_NO

/obj/structure/plasticflaps/opaque
	opacity = TRUE

/obj/structure/plasticflaps/Initialize()
	. = ..()
	alpha = 0
	SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, plane, dir, add_appearance_flags = RESET_ALPHA) //you see mobs under it, but you hit them like they are above it

/obj/structure/plasticflaps/examine(mob/user)
	. = ..()
	if(anchored)
		. += span_notice("[src] are <b>screwed</b> to the floor.")
	else
		. += span_notice("[src] are no longer <i>screwed</i> to the floor, and the flaps can be <b>cut</b> apart.")

/obj/structure/plasticflaps/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	add_fingerprint(user)
	var/action = anchored ? "unscrews [src] from" : "screws [src] to"
	var/uraction = anchored ? "unscrew [src] from " : "screw [src] to"
	user.visible_message(span_warning("[user] [action] the floor."), span_notice("I start to [uraction] the floor..."), span_hear("I hear rustling noises."))
	if(W.use_tool(src, user, 100, volume=100, extra_checks = CALLBACK(src, PROC_REF(check_anchored_state), anchored)))
		setAnchored(!anchored)
		to_chat(user, span_notice("I [anchored ? "unscrew" : "screw"] [src] from the floor."))
		return TRUE
	else
		return TRUE

/obj/structure/plasticflaps/wirecutter_act(mob/living/user, obj/item/W)
	. = ..()
	if(!anchored)
		user.visible_message(span_warning("[user] cuts apart [src]."), span_notice("I start to cut apart [src]."), span_hear("I hear cutting."))
		if(W.use_tool(src, user, 50, volume=100))
			if(anchored)
				return TRUE
			to_chat(user, span_notice("I cut apart [src]."))
			var/obj/item/stack/sheet/plastic/five/P = new(loc)
			P.add_fingerprint(user)
			qdel(src)
		return TRUE

/obj/structure/plasticflaps/proc/check_anchored_state(check_anchored)
	if(anchored != check_anchored)
		return FALSE
	return TRUE

/obj/structure/plasticflaps/CanAStarPass(ID, to_dir, caller)
	if(isliving(caller))
		var/mob/living/M = caller
		if(!M.ventcrawler && M.mob_size != MOB_SIZE_TINY)
			return FALSE
	var/atom/movable/M = caller
	if(M && M.pulling)
		return CanAStarPass(ID, to_dir, M.pulling)
	return TRUE //diseases, stings, etc can pass

/obj/structure/plasticflaps/CanPass(atom/movable/A, turf/T)
	if(istype(A) && (A.pass_flags & PASSGLASS))
		return prob(60)

	var/obj/structure/bed/B = A
	if(istype(A, /obj/structure/bed) && (B.has_buckled_mobs() || B.density))//if it's a bed/chair and is dense or someone is buckled, it will not pass
		return FALSE

	if(istype(A, /obj/structure/closet/cardboard))
		var/obj/structure/closet/cardboard/C = A
		if(C.move_delay)
			return FALSE

	else if(isliving(A)) // You Shall Not Pass!
		var/mob/living/M = A
		if((M.mobility_flags & MOBILITY_STAND) && !M.ventcrawler && M.mob_size != MOB_SIZE_TINY)	//If your not laying down, or a ventcrawler or a small creature, no pass.
			return FALSE
	return ..()

/obj/structure/plasticflaps/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/plastic/five(loc)
	qdel(src)

/obj/structure/plasticflaps/Initialize()
	. = ..()
	air_update_turf(TRUE)

/obj/structure/plasticflaps/Destroy()
	var/atom/oldloc = loc
	. = ..()
	if (oldloc)
		oldloc.air_update_turf(1)