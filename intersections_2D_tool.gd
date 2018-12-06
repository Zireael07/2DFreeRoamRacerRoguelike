tool
extends "intersections_connect2d.gd"

# class member variables go here, for example:

var helper_line

func _ready():
	helper_line = load("res://Line2D.tscn")

	connect_intersections(1,0)
	connect_intersections(0,2)
	connect_intersections(1,2)
	

func connect_intersections(one, two):
	# call the extended script
	.connect_intersections(one, two)
	
	setup_line_2d()
	
func setup_line_2d():
	var help = helper_line.instance()
	
	help.points = [loc_src_exit, loc_src_extended, loc_dest_extended, loc_dest_exit]
	
	# radius for calculated turns
	var extend_len = Vector2(loc_src_extended-loc_src_exit).length()
	help.vector_factor = ((extend_len/30)-3)*30
	#help.vector_factor = 8*15 # 15 px = 1 m
	
	# looks
	help.width = 10
	help.set_default_color(Color(0.4, 0.5, 1, 0.2))
	
	add_child(help)
