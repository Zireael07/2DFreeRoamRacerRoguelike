tool
extends "intersections2D.gd"

# class member variables go here, for example:

#var intersections = []

func _ready():
	var sorted = sort_intersections_distance()
	var initial_int = sorted[0][1]
	print("Initial int" + str(initial_int))
	
	connect_intersections(1,3)
	connect_intersections(1,0)
	connect_intersections(0,3)
	connect_intersections(0,2)

	connect_intersections(2,3)



func connect_intersections(one, two):
	# call the extended script
	.connect_intersections(one, two)

func sort_intersections_distance():
	var dists = []
	var tmp = []
	var closest = []
	for e in get_children():
		var dist = e.position.distance_to(Vector2(0,0))
		print("Distance: exit: " + str(e.get_name()) + " dist: " + str(dist))
		tmp.append([dist, e])
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
