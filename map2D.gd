tool
extends "intersections2D.gd"

# Declare member variables here. Examples:
# navigation
var ast = null
var nav = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup_navi(samples, edges, mult=1, poisson=false):
	setup_neighbors(samples, edges, mult)
	
	nav = AStar.new()
	var pts = []
	var begin_id = 0
	
	var roads_start_id = samples.size()-1 + 1
	print("Roads_start_id " + str(roads_start_id))
	
	var path_look = {}
	
	for i in range(roads_start_id, roads_start_id+5): #samples.size()-1):
		var data = setup_nav_astar(pts, i, begin_id, poisson)
		#print('Begin: ' + str(begin_id) + " end: " + str(data[0]) + " inters: " + str(data[1]))
		#path_data.append([data[1], [begin_id, data[0]]])
		if data:
			path_look[data[2]] = [begin_id, data[0]]
			# just in case, map inverse too
			path_look[[data[2][1], data[2][0]]] = [data[0], begin_id]

			# increment begin_id
			begin_id = data[1]+1

	print(path_look)
	
	if path_look.size() > 0:
		# test (get path_look entry at id x)
		var test = path_look[path_look.keys()[1]]
		#print("Test: " + str(test))
		var nav_path = nav.get_point_path(test[0], test[1])
	#	print("Nav path: " + str(nav_path))
		
		var nav_path2d = PoolVector2Array()
		for i in range(nav_path.size()):
			# put in a 2d equivalent
			nav_path2d.append(_3tov2(nav_path[i]))
	
		# visualize
		var node = Node2D.new()
		var script = load("res://path_visualizer.gd")
		node.set_script(script)
		add_child(node)
		node.set_name("Visualizer")
		
		node.path = nav_path2d
	#	print(str(node.path))
		node.update()
	
	

#-------------------------
# Distance map

func setup_neighbors(samples, edges, mult=1):
	# we'll use AStar to have an easy map of neighbors
	ast = AStar.new()
	for i in range(0,samples.size()-1):
		ast.add_point(i, Vector3(samples[i][0]*mult, 0, samples[i][1]*mult))

	for i in range(0, edges.size()):
		var ed = edges[i]
		ast.connect_points(ed[0], ed[1])

# yes it could be more efficient I guess
func bfs_distances(start):
	# keep track of all visited nodes
	#var explored = []
	var distance = {}
	distance[start] = 0

	# keep track of nodes to be checked
	var queue = [start]

	# keep looping until there are nodes still to be checked
	while queue:
		# pop shallowest node (first node) from queue
		var node = queue.pop_front()
		#print("Visiting... " + str(node))

		var neighbours = ast.get_point_connections(node)
		# add neighbours of node to queue
		for neighbour in neighbours:
			# if not visited
			#if not explored.has(neighbour):
			if not distance.has(neighbour):
				queue.append(neighbour)
				distance[neighbour] = 1 + distance[node]


	return distance

# ----------------

func _3tov2(vec3):
	return Vector2(vec3.x, vec3.z)

func _posto3d(pos):
	return Vector3(pos.x, 0, pos.y)

func setup_nav_astar(pts, i, begin_id, poisson=true):
	#print(get_child(i).get_name())
	
	# extract intersection id's
	var sub = get_child(i).get_name().substr(5, 3)
	var nrs = sub.split("-")
	
	var ret = []
	if poisson:
		for i in nrs:
			# because of the poisson node that comes first
			ret.append(int(i)-1)
	else:
		ret = nrs
	
	print(get_child(i).get_name() + " real numbers: " + str(ret))
	
	if not get_child(i).has_node("Road_instance 0"):
		return
	if not get_child(i).has_node("Road_instance 1"):
		return
		
	var turn1 = get_child(i).get_node("Road_instance 0").get_child(0).get_child(0)
	var turn2 = get_child(i).get_node("Road_instance 1").get_child(0).get_child(0)

	#print("Straight points_arc: " + str(get_child(i).get_node("Spatial0").get_child(0).points_arc))
	#print("Turn 1 points_arc: " + str(turn1.points_arc))
	#print("Turn 2 points_arc: " + str(turn2.points_arc))

	#print("Turn 1 global pos: " + str(turn1.get_global_transform().origin))
	#print("Turn 2 global pos: " + str(turn2.get_global_transform().origin))

	# from local to global
	for i in range(0,turn1.points_arc.size()):
		var p = turn1.points_arc[i]
		# Astar wants 3d points
		pts.append(_posto3d(turn1.to_global(p)))
	
	#print(pts)
	for i in range(0,turn2.points_arc.size()):
		var p = turn2.points_arc[i]
		pts.append(_posto3d(turn2.to_global(p)))
		
	#print("With turn2: " + str(pts))
	
	# add pts to nav (road-level AStar)
	for i in range(pts.size()):
		nav.add_point(i, pts[i])

	#print(nav.get_points())

	# connect the points
	var turn1_end = begin_id + turn1.points_arc.size()-1
	# because of i+1
	for i in range(begin_id, turn1_end):
		nav.connect_points(i, i+1)

	var turn2_end = begin_id + turn1.points_arc.size()+turn2.points_arc.size()-1
	for i in range(begin_id + turn1.points_arc.size(), turn2_end):
		nav.connect_points(i, i+1)

	# because turn 2 is inverted
	# connect the endpoints
	nav.connect_points(turn1_end, turn2_end)
	# full path
	var endpoint_id = begin_id + turn1.points_arc.size() # beginning of turn2
	
	var last_id = turn2_end
	
	# turn1
	#var endpoint_id = turn1_end
	#print("Endpoint id " + str(endpoint_id))
	#print("Test: " + str(nav.get_point_path(begin_id, endpoint_id)))
	# turn2 only
	#print("Test 2: " + str(nav.get_point_path(begin_id + turn1.points_arc.size(), turn2_end)))

	# road's end, list end, intersections
	return [endpoint_id, last_id, ret]

