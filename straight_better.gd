tool
extends "straight2D.gd"

# class member variables go here, for example:
export(int) var width = 70
var inner_first = Vector2(0,0)
var inner_last = Vector2(0,0)
var outer_first = Vector2(0,0)
var outer_last = Vector2(0,0)


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	
	thick = 2
	
	inner_first = first + Vector2(0, -width)
	inner_last = last + Vector2(0, -width)
	outer_first = first + Vector2(0, width)
	outer_last = last + Vector2(0, width) 
	
	# send data on
	var poly = [inner_first, inner_last, outer_last, outer_first]
	
	get_child(0).set_polygon(poly)
	
	
	#pass

func _draw():
	#draw_line(inner_first, inner_last, Color(0,0,0), thick)
	#draw_line(outer_first, outer_last, Color(0,0,0), thick)
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
