tool
extends "curve.gd"

# class member variables go here, for example:
export(int) var width = 70
var inner_arc = []
var outer_arc = []

var streetlight

func _ready():
	streetlight = preload("res://lamplight.tscn")
	
	#print("Curve ready")
	thick = 1
	
	# arc
	inner_arc = get_circle_arc(Vector2(0,0), radius-width, angle_from, angle_to, right)
	outer_arc = get_circle_arc(Vector2(0,0), radius+width, angle_from, angle_to, right)
	
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	# send data on
	# looks UGLY for some reason even with perfect uvs
#	var uvs = []
#
#	# polygon uvs work differently to 3D uvs
#	# texture is x 128 y 80
#
#	for i in range(inner_arc.size()):
#		# invert because
#		uvs.append(Vector2(0,(128.0-(128.0/32)*i)))
#	for i in range(outer_arc.size()):
#		uvs.append(Vector2(80, (128.0/32)*i))
#
	
	# clear
	get_child(0).get_polygon().resize(0)
	
	# inner arc is a PoolVector2Array and that one doesn't return a ref
	#var inner_arc_inv = inner_arc.invert()
	# polygon's last wants to connect to the first
	inner_arc.invert()
	get_child(0).poly = inner_arc + outer_arc
	#print(get_child(0).poly)

	#get_child(0).set_uv(uvs)
	get_child(0).set_polygon(get_child(0).poly)

	placeStreetlight()
	
	#pass
	
# props
func placeStreetlight():
	var light = streetlight.instance()
	light.set_name("Streetlight")
	add_child(light)
	
	var num = (points_arc.size()/2)
	var center = Vector2(0,0)
	
	var dist = 60
	# B-A: A->B
	var dir = (center-inner_arc[num])
	var offset = dir.normalized() * dist
	
	light.set_position(inner_arc[num]+offset)


func _draw():
	pass
	#draw_circle_arc(Vector2(0,0), inner_arc, Color(0,0,1))
	#draw_circle_arc(Vector2(0,0), outer_arc, Color(0,0,1))


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
