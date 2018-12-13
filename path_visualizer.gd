tool
extends Node2D

# class member variables go here, for example:
var path = PoolVector2Array()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass


func _draw():
	for i in range(path.size()-1):
		draw_line(path[i], path[i+1], Color(1,0,0), 3.0)
