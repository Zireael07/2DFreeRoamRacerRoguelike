tool

extends Node2D

# class member variables go here, for example:
export(int) var radius = 15*15 setget set_radius
export(int) var angle_from = 0 setget set_angle_from
export(int) var angle_to = 90 setget set_angle_to
export(bool) var right = true setget set_right

#export(bool) var snap setget set_snap
#signal enabled_snap

# for debugging
var font
var thick = 2

var points_arc

var last = Vector2(0,0)
var first = Vector2(0,0)
var start_vector = Vector2(0,0)
var end_vector = Vector2(0,0)
var start_ref = Vector2(0,0)
var end_ref = Vector2(0,0)
var relative_end


func _ready():
	#add_to_group("lines", true)
	# signals
	#connect("enabled_snap", self, "on_snap_enabled")
	
	# arc
	points_arc = get_circle_arc(Vector2(0,0), radius, angle_from, angle_to, right)
	
	last = points_arc[points_arc.size()-1]
	first = points_arc[0]
	
	# need relative 
	var global_end = get_global_transform().xform_inv(last)
	var global_start = get_global_transform().xform_inv(first)
	
	relative_end = global_start - global_end
	print("Last relative to start is " + String(relative_end))
	
	# normalizing the vectors solves problems with angle_to()
	var start_axis_2d = -(first-Vector2(0,0)).tangent().normalized()*10
	var end_axis_2d = (last-Vector2(0,0)).tangent().normalized()*10
		
	if not right:
		start_axis_2d = -start_axis_2d
		end_axis_2d = -end_axis_2d
		
	start_vector = ((first+start_axis_2d)-first).normalized()*10
	start_ref = first+start_vector
	#print("[Curve] start_ref: " + str(start_ref))
	end_vector = (last - (last+end_axis_2d)).normalized()*10
	end_ref = last+end_vector
	#print("[Curve] end ref: " + str(end_ref))
	
	#print("[Curve] Start vec: " + str(start_vector) + " end vec " + str(end_vector))
	
	#print(str(first.x) + " " + str(last.x))
	
	# text
	var label = Label.new()
	font = label.get_font("")
	label.free()
	
	#fix issue
	if (get_parent().get_name() == "Placer"):
		#let the placer do its work
		get_parent().place_road()
	
	

func _get_item_rect():
	var x = abs(first.x-last.x)+2
	var y = abs(first.y-last.y)+2
	var edge_l = last.x-1
	var edge_b = last.y-1
	if first.x < last.x:
		edge_l = first.x-1
	if first.y < last.y:
		edge_b = first.y-1
		
	return Rect2(Vector2(edge_l, edge_b), Vector2(x,y))


func _draw():
	draw_circle_arc(Vector2(0,0), points_arc, Color(0,0,1))
	# debugging
	draw_string(font, last, str(angle_to), Color(1,1,1))
	draw_circle(first, 1, Color(0,1,0))
	draw_circle(last, 1, Color(1,0,0))
	
	# circle radius
	draw_line(Vector2(0,0), first, Color(0,0,1))
	draw_line(Vector2(0,0), last, Color(0,0,1))

	# axis
	draw_line(first, start_ref, Color(0,1,1))
	draw_line(last, end_ref, Color(1,0,1))

func draw_circle_arc(center, points_arc, color):
	for index in range(points_arc.size()-1):
		draw_line(points_arc[index], points_arc[index+1], color, thick) #4

func get_circle_arc( center, radius, angle_from, angle_to, right):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points+1):
		if right:
			var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
			var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
			points_arc.push_back( point )
		else:
			var angle_point = angle_from - i*(angle_to-angle_from)/nb_points - 90
			var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
			points_arc.push_back( point )
	
	return points_arc
	


# signals for updating in editor
func set_radius(val):
	radius = val
	points_arc = get_circle_arc(Vector2(0,0), radius, angle_from, angle_to, right)
	last = points_arc[points_arc.size()-1]
	first = points_arc[0]
	#draw_circle_arc(Vector2(0,0), radius, angle_from, angle_to)
	update()
	
func set_angle_from(val):
	angle_from = val
	points_arc = get_circle_arc(Vector2(0,0), radius, angle_from, angle_to, right)
	last = points_arc[points_arc.size()-1]
	first = points_arc[0]
	update()
	
func set_angle_to(val):
	angle_to = val
	points_arc = get_circle_arc(Vector2(0,0), radius, angle_from, angle_to, right)
	last = points_arc[points_arc.size()-1]
	first = points_arc[0]
	update()

func set_right(val):
	right = val
	points_arc = get_circle_arc(Vector2(0,0), radius, angle_from, angle_to, right)
	last = points_arc[points_arc.size()-1]
	first = points_arc[0]
	update()
	
