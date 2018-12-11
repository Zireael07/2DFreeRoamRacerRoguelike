tool
extends "intersections2D.gd"

# class member variables go here, for example:
var intersects

var mult = 50

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
				print("Already has edge: " + str(e[0]) + " " + str(e[1]))
			elif edges.has(Vector2(e[1], e[0])):
				print("Already has edge: " + str(e[1]) + " " + str(e[0]))
			else:
				edges.append(e)

	# create the map
	for i in range(0, edges.size()):
		var ed = edges[i]
		print("Connecting intersections for edge: " + str(i) + ". " + str(ed[0]) + " - " + str(ed[1]))
		var p1 = samples[ed[0]]
		var p2 = samples[ed[1]]
		# +1 because of the poisson node that comes first
		connect_intersections(ed[0]+1, ed[1]+1)
	
	
	#pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
