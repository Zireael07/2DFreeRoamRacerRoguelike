extends Node2D

# GDquest colors
var colors = {
	WHITE = Color(1.0, 1.0, 1.0),
	YELLOW = Color(1.0, .757, .027),
	GREEN = Color(.282, .757, .255),
	BLUE = Color(.098, .463, .824),
	PINK = Color(.914, .118, .388),
	RED = Color(1.0, 0, 0)
}

const WIDTH = 4

const MUL = 1

var parent = null


func _ready():
	parent = get_parent()
	set_physics_process(true)
	update()


func _draw():
	if parent == null:
		print("No parent!")
		return
	
	if "target_dir" in parent:
		draw_vector(parent.target_dir, Vector2(), colors['BLUE'])
		
	#print(str(parent.target_motion))
	#draw_vector(parent.target_motion, Vector2(), colors['GREEN'])
	#print(str(parent.steering))
	draw_vector(parent.steering * 5, Vector2(), colors['PINK'])
	#print(str(parent.motion))
	draw_vector(parent.motion, Vector2(), colors['YELLOW'])
	
	draw_vector(parent.forward_vec, Vector2(), colors['WHITE'])
	
	if "angle" in parent:
		# this takes degrees
		draw_circle_arc_poly(Vector2(), 100, -90, -90-rad2deg(parent.angle), colors['RED'])


func draw_vector(vector, offset, _color):
	if vector == Vector2():
		return
	draw_line(offset * MUL, vector * MUL, _color, WIDTH)

	var dir = vector.normalized()
	# prevent errors with very short vectors
	if vector.length() > 5:
		draw_triangle_equilateral(vector * MUL, dir, 10, _color)
	draw_circle(offset, 6, _color)


func draw_triangle_equilateral(center=Vector2(), direction=Vector2(), radius=50, _color=WHITE):
	var point_1 = center + direction * radius
	var point_2 = center + direction.rotated(2*PI/3) * radius
	var point_3 = center + direction.rotated(4*PI/3) * radius

	var points = PoolVector2Array([point_1, point_2, point_3])
	draw_polygon(points, PoolColorArray([_color]))


func _physics_process(delta):
	update()

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(nb_points+1):
		var angle_point = angle_from + i*(angle_to-angle_from)/nb_points
		points_arc.push_back(center + Vector2( cos( deg2rad(angle_point) ), sin( deg2rad(angle_point) ) ) * radius)
	
	draw_polygon(points_arc, colors)