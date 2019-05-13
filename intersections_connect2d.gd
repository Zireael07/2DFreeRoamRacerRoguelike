tool
extends Node2D

# class member variables go here, for example:
	
	
# need to be class-level because draw()
var loc_src_exit = Vector2(0,0)
var loc_dest_exit = Vector2(0,0)

var loc_src_extended = Vector2(0,0)
var loc_dest_extended = Vector2(0,0)

func _ready():
	pass
	

func connect_intersections(one, two):
	print("Connecting intersections " + str(one) + " and " + str(two))
	# catch indices out of range
	if one > get_child_count() -1 or two > get_child_count() -1:
		print("Wrong indices given")
		return false
	
	if not "point_one" in get_child(one) or not "point_one" in get_child(two):
		print("Targets are not intersections?")
		return false
	
	var src_exit = get_src_exit(get_child(one), get_child(two))
	if not src_exit:
		return false
	loc_src_exit = to_local(get_child(one).to_global(src_exit))
	
	var dest_exit = get_dest_exit(get_child(one), get_child(two))
	if not dest_exit:
		return false
	loc_dest_exit = to_local(get_child(two).to_global(dest_exit))
	
	extend_lines(one,two)
	

func extend_lines(one,two):
	#B-A: A->B
	var src_line = loc_src_exit-get_child(one).get_position()
	var extend = 3
	# note: src_line*extend > helper line's vector must be true, otherwise the turns won't work
	loc_src_extended = src_line*extend + get_child(one).get_position()
	
	var dest_line = loc_dest_exit-get_child(two).get_position()
	
	loc_dest_extended = dest_line*extend + get_child(two).get_position()


func _draw():
	draw_line(loc_src_exit, loc_dest_exit, Color(0,1,0, 0.5))

	# test
	#draw_line(get_child(0).get_position(), loc_src_exit, Color(0,0,1))

	draw_circle(loc_src_extended, 1.0, Color(0,0,1))
	draw_circle(loc_dest_extended, 1.0, Color(0,1,0))
	
	draw_line(loc_src_exit, loc_src_extended, Color(0,0,1))
	draw_line(loc_src_extended, loc_dest_extended, Color(0,0,1))
	draw_line(loc_dest_extended, loc_dest_exit, Color(0,1,1))
	
	#var arr = [loc_src_exit, loc_src_extended, loc_dest_extended, loc_dest_exit]
	#draw_polyline(arr, Color(0,0,1))

# assume standard rotation for now
func get_src_exit(src, dest):
	var src_exits = src.open_exits
	
	if src_exits.size() < 0:
		print("Error, no exits left")
		return
	
	# those are global positions
#	print("Positions: " + str(src.get_position()) + " " + str(dest.get_position()))	
#	print("Transform:" + str(src.get_transform()))
	var rel_pos = src.get_transform().xform_inv(dest.get_position())
	print("Relative position: " + str(rel_pos) + " angle " + str(atan2(rel_pos.x, rel_pos.y)))
	
	# exits NEED to be listed CW (right, bottom, top)
	
	#quadrant 1 (we exclude top exit to avoid crossing over)
	if rel_pos.x > 0 and rel_pos.y > 0:
		if src_exits.has(src.point_two):
			src_exits.remove(src_exits.find(src.point_two))
			return src.point_two
		if src_exits.has(src.point_one):
			src_exits.remove(src_exits.find(src.point_one))
			return src.point_one
	# quadrant 2
	# same
	elif rel_pos.x < 0 and rel_pos.y > 0:
		if src_exits.has(src.point_one):
			src_exits.remove(src_exits.find(src.point_one))
			return src.point_one
		elif src_exits.has(src.point_three):
			src_exits.remove(src_exits.find(src.point_three))
			return src.point_three
	# quadrant 3 (exclude bottom exit)
	elif rel_pos.x > 0 and rel_pos.y < 0:
		if src_exits.has(src.point_two):
			src_exits.remove(src_exits.find(src.point_two))
			return src.point_two
		elif src_exits.has(src.point_three):
			src_exits.remove(src_exits.find(src.point_three))
			return src.point_three
	# quadrant 4
	elif rel_pos.x < 0 and rel_pos.y < 0:
		if src_exits.has(src.point_three):
			src_exits.remove(src_exits.find(src.point_three))
			return src.point_three
		if src_exits.has(src.point_one):
			src_exits.remove(src_exits.find(src.point_one))
			return src.point_one

	
	# naive method, sometimes leads to crossing over the intersection itself
#	var dists = []
#	var closest = []
#	for e in src_exits:
#		var dist = e.distance_to(rel_pos)
#		print("Distance: exit: " + str(e) + " " + str(rel_pos) + " dist: " + str(dist))
#		closest.append([dist, e])
#		dists.append(dist)
#
#	dists.sort()
#
#	for t in closest:
#		if t[0] == dists[0]:
#			print("Closest exit is: " + str(t[1]))
#			src_exits.remove(src_exits.find(t[1]))
#			return t[1]
	
	
#	if abs(dest.get_position().x - src.get_position().x) > abs(dest.get_position().y - src.get_position().y):
#		if dest.get_position().y > src.get_position().y:
#			if src_exits.has(src.point_two):
#				print("[src] " + src.get_name() + " " + dest.get_name() + " X rule")
#				src_exits.remove(src_exits.find(src.point_two))
#				return src.point_two
#			else:
#				if src_exits.has(src.point_three):
#					print("[src] " + src.get_name() + " " + dest.get_name() + " X rule alt")
#					src_exits.remove(src_exits.find(src.point_three))
#					return src.point_three
#		else:
#			if src_exits.has(src.point_three):
#			#if dest.get_position().x < src.get_position().x and src_exits.has("two"):
#				print("[src] " + str(src.get_name()) + " " + str(dest.get_name()) + " X rule inv" )
#
#				src_exits.remove(src_exits.find(src.point_three))
#				#src_exits.remove(src_exits.find("two"))
#
#				return src.point_three
#
#			else:
#				if src_exits.has(src.point_one):
#					print("[src] " + str(src.get_name()) + " " + str(dest.get_name()) + " X rule inv alt")
#					src_exits.remove(src_exits.find(src.point_one))
#
#					return src.point_one
#
#	elif dest.get_position().y > src.get_position().y and src_exits.has(src.point_one):
#		print("[src] " + str(src.get_name()) + " " + str(dest.get_name()) + " Y rule")
#
#		src_exits.remove(src_exits.find(src.point_one))
#		#src_exits.remove(src_exits.find("one"))
#
#		return src.point_one
#
#	elif src_exits.has(src.point_three):
	#src_exits.has("three"):
	# else
#		print("[src] " + str(src.get_name()) + " " + str(dest.get_name()) + " Y rule 2")
#
#		src_exits.remove(src_exits.find(src.point_three))
#		#src_exits.remove(src_exits.find("three"))
#		return src.point_three	

# assume standard rotation for now
func get_dest_exit(src, dest): #, dest_exits):
	var dest_exits = dest.open_exits
	
	#print("X abs: " + str(abs(dest.get_position().x - src.get_position().x)))
	#print("Y abs: " + str(abs(dest.get_position().y - src.get_position().y)))
	
	
	if dest_exits.size() < 0:
		print("Error, no exits left")
		return
	
	# those are global positions
#	print("Positions: " + str(src.get_position()) + " " + str(dest.get_position()))	
#	print("Transform:" + str(src.get_transform()))
	var rel_pos = dest.get_transform().xform_inv(src.get_position())
	print("Relative position: " + str(rel_pos) + " angle " + str(atan2(rel_pos.x, rel_pos.y)))
	
	# quadrant 4, exclude bottom exit to avoid crossing over
	if rel_pos.x < 0 and rel_pos.y < 0:
		if dest_exits.has(dest.point_three):
			dest_exits.remove(dest_exits.find(dest.point_three))
			return dest.point_three
		elif dest_exits.has(dest.point_two):
			dest_exits.remove(dest_exits.find(dest.point_two))
			return dest.point_two
	# quadrant 3, same
	elif rel_pos.x > 0 and rel_pos.y < 0:
		if dest_exits.has(dest.point_three):
			dest_exits.remove(dest_exits.find(dest.point_three))
			return dest.point_three
		elif dest_exits.has(dest.point_one):
			dest_exits.remove(dest_exits.find(dest.point_one))
			return dest.point_one
	# quadrant 2
	elif rel_pos.x < 0 and rel_pos.y > 0:
		if dest_exits.has(dest.point_two):
			dest_exits.remove(dest_exits.find(dest.point_two))
			return dest.point_two
		elif dest_exits.has(dest.point_three):
			dest_exits.remove(dest_exits.find(dest.point_three))
			return dest.point_three
	# quadrant 1, same
	elif rel_pos.x > 0 and rel_pos.y > 0:
		if dest_exits.has(dest.point_two):
			dest_exits.remove(dest_exits.find(dest.point_two))
			return dest.point_two
		elif dest_exits.has(dest.point_three):
			dest_exits.remove(dest_exits.find(dest.point_three))
			return dest.point_three
			
	# naive method sometimes leads to crossing over the intersection itself
#	var dists = []
#	var closest = []
#	for e in dest_exits:
#		var dist = e.distance_to(rel_pos)
#		print("Distance: exit: " + str(e) + " " + str(rel_pos) + " dist: " + str(dist))
#		closest.append([dist, e])
#		dists.append(dist)
#
#	dists.sort()
#
#	for t in closest:
#		if t[0] == dists[0]:
#			print("Closest exit is: " + str(t[1]))
#			dest_exits.remove(dest_exits.find(t[1]))
#			return t[1]
	
#	if abs(dest.get_position().x - src.get_position().x) > abs(dest.get_position().y - src.get_position().y):
#		if dest.get_position().y > src.get_position().y:
#			if dest_exits.has(dest.point_three):
#				print("[dest] " + src.get_name() + " " + dest.get_name() + " X rule a)")
#				dest_exits.remove(dest_exits.find(dest.point_three))
#
#				return dest.point_three
#		else:
#			if dest_exits.has(dest.point_one):
#				print("[dest] " + src.get_name() + " " + dest.get_name() + " X rule b)")
#				dest_exits.remove(dest_exits.find(dest.point_one))
#				return dest.point_one
#			else:
#				print("[dest] " + src.get_name() + " " + dest.get_name() + " X rule b) alt")
#				dest_exits.remove(dest_exits.find(dest.point_three))
#				return dest.point_three
#
#
#		if dest_exits.has(dest.point_three):
#		#if dest.get_position().x < src.get_position().x and dest_exits.has("one"):
#			print("[dest] " + str(src.get_name()) + " " + str(dest.get_name()) + " X rule")
#
#			dest_exits.remove(dest_exits.find(dest.point_three))
#			#dest_exits.remove(dest_exits.find("three"))
#
#			return dest.point_three
#
#		else:
#			print("[dest] " + src.get_name() + " " + dest.get_name() + " replacement for X rule")
#
#			dest_exits.remove(dest_exits.find(dest.point_one))
#			#dest_exits.remove(dest_exits.find("one"))
#
#			return dest.point_one
			
		#dest_exits.remove(dest_exits.find("one"))
		
		#return dest.point_one
	
#	elif dest.get_position().y > src.get_position().y:
#		if dest_exits.has(dest.point_three):
#		#if dest_exits.has("three"):
#			print("[dest] " + str(src.get_name()) + " " + str(dest.get_name()) + " Y rule")
#
#			dest_exits.remove(dest_exits.find(dest.point_three))
#			#dest_exits.remove(dest_exits.find("three"))
#
#			return dest.point_three
#
#		else:
#			print("[dest] " + src.get_name() + " " + dest.get_name() + " replacement for Y rule")
#
#			dest_exits.remove(dest_exits.find(dest.point_two))
#			#dest_exits.remove(dest_exits.find("two"))
#
#			return dest.point_two
#
#	elif dest_exits.has(dest.point_one):	
#	#elif dest_exits.has("one"):
#	#else:
#		print("[dest] " + str(src.get_name()) + " " + str(dest.get_name()) + " Y rule 2")
#
#		dest_exits.remove(dest_exits.find(dest.point_one))
#		#dest_exits.remove(dest_exits.find("one"))
#
#		return dest.point_one
