extends Area2D

# Declare member variables here. Examples:
var colliding = []

var end_pt
var end_pt2
var end2_pt
var end2_pt2


# Called when the node enters the scene tree for the first time.
func _ready():
	update()
	set_physics_process(true)
	#set_process(true)
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	for o in colliding:
#		var shape = o.shape_owner_get_shape(0,0)
#
#		if shape is RectangleShape2D:
#			#print(str(shape.extents))
#
#
##	pass

func _draw():
	for o in colliding:
		var shape = o.shape_owner_get_shape(0,0)

		if shape is RectangleShape2D:
			
			end_pt = to_local(o.get_global_position() - Vector2(shape.extents.x,0))
			end_pt2 = to_local(o.get_global_position() + Vector2(shape.extents.x,0))
			end2_pt = to_local(o.get_global_position() - Vector2(0, shape.extents.y))
			end2_pt2 = to_local(o.get_global_position() + Vector2(0, shape.extents.y))
			
			draw_circle(end_pt, 2.0, Color(0,1,0))
			draw_circle(end_pt2, 2.0, Color(0,1,0))
			draw_circle(end2_pt, 2.0, Color(0,1,0))
			draw_circle(end2_pt2, 2.0, Color(0,1,0))
			
			
			
			
		#print(str(o.get_shape_owners()))
		#if shape is CircleShape2D:
		#var radius = o.shape_owner_get_shape(0,0).radius
		draw_circle(to_local(o.get_global_position()), 2.0, Color(1,0,0))
		#draw_circle(to_local(Vector2(o.get_global_position().x-radius, o.get_global_position().y)), 2.0, Color(0,1,0))

func _physics_process(delta):
	#print(str(colliding))
	update()

func _on_Area2D_body_entered(body):
	#print("Append : " + str(body.get_name()))
	colliding.append(body)
	#pass # Replace with function body.


func _on_Area2D_body_exited(body):
	colliding.remove(colliding.find(body))
	#pass # Replace with function body.
