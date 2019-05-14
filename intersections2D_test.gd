tool
extends "map2D.gd"

# class member variables go here, for example:

var samples = []
var edges = []

func _ready():
	# setup
	for i in range(0, get_child_count()):
		var pos = get_child(i).position
		samples.append(pos)
	
	
	var sorted = sort_intersections_distance()
	var initial_int = sorted[0][1]
	print("Initial int: " + str(initial_int))

	# for test purposes
	edges = [Vector2(0,1), Vector2(0,2), Vector2(0,3), Vector2(1,3), Vector2(2,3)]

	for i in range(sorted.size()-1):
		auto_connect(sorted[i][1])
	
	# manual		
	#connect_intersections(1,3)
	#connect_intersections(1,0)
	#connect_intersections(0,3)
	#connect_intersections(0,2)
	#connect_intersections(2,3)

	# test
	setup_navi(samples, edges, 1, false)

func connect_intersections(one, two):
	# call the extended script
	.connect_intersections(one, two)

func sort_intersections_distance():
	var dists = []
	var tmp = []
	var closest = []
	for i in range(0, get_child_count()):
		var e = get_child(i)
		var dist = e.position.distance_to(Vector2(0,0))
		print("Distance: exit: " + str(e.get_name()) + " dist: " + str(dist))
		tmp.append([dist, i])
		dists.append(dist)

	dists.sort()

	#print("tmp" + str(tmp))
	# while causes a lockup, whichever way we do it
	#while tmp.size() > 0:
	#	print("Tmp size > 0")
	var max_s = tmp.size()
	#while max_s > 0:
	for i in range(0, max_s):
		#print("Running add, attempt " + str(i))
		#print("tmp: " + str(tmp))
		for t in tmp:
			#print("Check t " + str(t))
			if t[0] == dists[0]:
				closest.append(t)
				tmp.remove(tmp.find(t))
				# key line
				dists.remove(0)
				#print("Adding " + str(t))
	# if it's not empty by now, we have an issue
	#print(tmp)

	print(closest)

	return closest

func auto_connect(initial_int):
	var next_ints = []
	var res = []
	var sorted_n = []
	# to remove properly
	var to_remove = []
	
	print("Auto connecting... " + get_child(initial_int).get_name() + " @ " + str(get_child(initial_int).get_global_position()))

	for e in edges:
		if e.x == initial_int:
			print("Edge with initial int" + str(e) + " other end " + str(e.y))
			var data = [e.y, get_child(e.y).get_global_position()]
			next_ints.append(data)
			#print(data[1].x)
			#TODO: use relative angles?? it has to be robust!
			sorted_n.append(atan2(data[1].y, data[1].x))
			#sorted_n.append(data[1].x)
			# remove from edge list so that we can use the list in other iterations
			to_remove.append(edges.find(e))
		if e.y == initial_int:
			print("Edge with initial int" + str(e) + " other end " + str(e.x))
			var data = [e.x, get_child(e.x).get_global_position()]
			next_ints.append(data)
			#print(data[1].x)
			#sorted_n.append(data[1].x)
			sorted_n.append(atan2(data[1].y, data[1].x))
			# remove from edge list so that we can use the list in other iterations
			to_remove.append(edges.find(e))

	# remove ids to remove
	for i in to_remove:
		edges.remove(i)

	#print(sorted_n)

	# this sorts by natural order (lower value first)
	sorted_n.sort()
	# but we want higher?
	#sorted_n.invert()
	
	print("Sorted: " + str(sorted_n))
	
	for i in range(0, next_ints.size()):
		#print("Attempt " + str(i))
		for d in next_ints:
			#print(str(d) + " " + str(sorted_n[0]))
			# the first part of this needs to match what was used for sorting
			if atan2(d[1].y, d[1].x) == sorted_n[0]:
				next_ints.remove(next_ints.find(d))
				res.append(d)
				sorted_n.remove(0)
		
	#print("Res " + str(res) + " lower y: " + str(res[0]))
	#print("next ints: " + str(next_ints))
	for i in range(0, res.size()):
		var p = res[i]
		print("Intersection " + str(p))
		connect_intersections(initial_int, p[0])
