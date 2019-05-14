tool
extends "map2D.gd"

# class member variables go here, for example:
var intersects

var mult = 25 #50

var samples = []
var edges = []

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	intersects = preload("res://intersection2D.tscn")
	
	samples = get_node("triangulate/Poisson2D").samples

	for i in range(0, get_node("triangulate/Poisson2D").samples.size()-1):
		var p = get_node("triangulate/Poisson2D").samples[i]
		var intersection = intersects.instance()
		intersection.set_position(Vector2(p[0]*mult, p[1]*mult))
		intersection.set_name("intersection" + str(i))
		add_child(intersection)
		
		#intersection.set_owner(self)
		
		#print("Added intersection")

	# get the triangulation
	var tris = get_node("triangulate").tris

	for t in tris:
		#var poly = []
		#print("Edges: " + str(t.get_edges()))
		for e in t.get_edges():
#			print(str(e))
			if edges.has(Vector2(e[0], e[1])):
				pass
				#print("Already has edge: " + str(e[0]) + " " + str(e[1]))
			elif edges.has(Vector2(e[1], e[0])):
				pass
				#print("Already has edge: " + str(e[1]) + " " + str(e[0]))
			else:
				edges.append(e)

	# create the map
	var sorted = sort_intersections_distance()
	
	auto_connect(sorted[0][1])
	auto_connect(sorted[1][1])
	auto_connect(sorted[2][1])
	auto_connect(sorted[3][1])
	auto_connect(sorted[4][1])
	auto_connect(sorted[5][1])
	auto_connect(sorted[6][1])
	auto_connect(sorted[7][1])
	auto_connect(sorted[8][1])
	auto_connect(sorted[9][1])
	auto_connect(sorted[10][1])
	auto_connect(sorted[11][1])
	
	#for i in range(0, sorted.size()):
	#	auto_connect(sorted[i][1])
	
	
#	for i in range(0, edges.size()):
#		var ed = edges[i]
#		print("Connecting intersections for edge: " + str(i) + ". " + str(ed[0]) + " - " + str(ed[1]))
#		var p1 = samples[ed[0]]
#		var p2 = samples[ed[1]]
#		# +1 because of the poisson node that comes first
#		connect_intersections(ed[0]+1, ed[1]+1)
	
	#setup_navi(samples, edges, mult)
	
func sort_intersections_distance():
	var dists = []
	var tmp = []
	var closest = []
	# we exclude the poisson node
	for i in range(1, get_child_count()):
		var e = get_child(i)
		#print(e,get_name() + " " + str(e.get_global_position()))
		var dist = e.global_position.distance_to(Vector2(0,0))
		#print("Distance: exit: " + str(e.get_name()) + " dist: " + str(dist))
		# because we want intersection id (edge id), not child index
		# and they are not the same because of the poisson node coming first
		tmp.append([dist, i-1])
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
	print("Auto connecting... " + get_child(initial_int+1).get_name() + " @ " + str(get_child(initial_int+1).get_global_position()))
	
	
	var next_ints = []
	var res = []
	var sorted_n = []
	# to remove properly
	var to_remove = []

	for e in edges:
		# the poisson node throws the calculations off a bit
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

	# debug
	


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
		# poisson throws us off a bit
		connect_intersections(initial_int+1, p[0]+1)
