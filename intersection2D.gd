tool
extends Node2D

# class member variables go here, for example:
# points
var point_one = Vector2(0,10*15) #15 px = 1 m
var point_two = Vector2(10*15,0)
var point_three = Vector2(0,-10*15)

var open_exits = [point_one, point_two, point_three]

# gfx
export(int) var width = 70



func _ready():
	# Called every time the node is added to the scene.
	# Initialization here

	var point_one_in = point_one + Vector2(-width,0)	
	var point_one_out = point_one + Vector2(width, 0)
	
	var point_out_cent = Vector2(width, width)
	
	var point_two_out = point_two + Vector2(0, width)
	var point_two_in = point_two + Vector2(0, -width)
	
	var point_two_cent_in = Vector2(width, -width)
	
	var point_three_out = point_three + Vector2(width, 0)
	var point_three_in = point_three + Vector2(-width, 0)
	
	# send data on
	var poly = [point_one_in, point_one_out, point_out_cent, point_two_out, point_two_in, point_two_cent_in, point_three_out, point_three_in]
	
	get_child(0).set_polygon(poly)
	
	
	#pass

func _draw():
	draw_line(Vector2(0,0), point_one, Color(1,0,0))
	draw_line(Vector2(0,0), point_two, Color(1,0,0))
	draw_line(Vector2(0,0), point_three, Color(1,0,0))


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
