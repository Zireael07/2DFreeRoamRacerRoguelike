tool
extends "intersections_connect2d.gd"

# class member variables go here, for example:

var straight
var curve 

#var intersections = []

func _ready():
	straight = load("res://Road2D_straight.tscn")
	curve = load("res://Road2DPolygon.tscn")
	
	#pass

func connect_intersections(one, two):
	# call the extended script
	.connect_intersections(one, two)

	var corner_points = get_corner_points(one, two, loc_src_extended, loc_dest_extended, loc_src_extended.distance_to(loc_src_exit))
	
	var intersect = get_intersection(corner_points[0], corner_points[1], loc_src_extended)
	if intersect:
		var data = get_arc_angle(intersect, corner_points[0], corner_points[1])
#		print("Data: " + str(data))
#
		calculate_turn(one, two, data, corner_points[0])

	intersect = get_intersection(corner_points[2], corner_points[3], loc_dest_extended)
	if intersect:
		var data = get_arc_angle(intersect, corner_points[2], corner_points[3])
		
		calculate_turn(one, two, data, corner_points[2])
	

		place_straight(corner_points[1], corner_points[3])

func get_corner_points(one, two, loc_src_extended, loc_dest_extended, dist):
	var corners = []
	
	# B-A = A-> B
	var vec_back = get_child(one).get_position() - loc_src_extended
	vec_back = vec_back.normalized()*dist # x units away
	
	var corner_back = loc_src_extended + vec_back
	corners.append(corner_back)
	
	var vec_forw = loc_dest_extended - loc_src_extended
	vec_forw = vec_forw.normalized()*dist # x units away
	
	var corner_forw = loc_src_extended + vec_forw
	corners.append(corner_forw)
	
	# the destinations
	# B-A = A-> B
	vec_back = get_child(two).get_position() - loc_dest_extended
	vec_back = vec_back.normalized()*dist # x units away
	
	corner_back = loc_dest_extended + vec_back
	corners.append(corner_back)
	
	vec_forw = loc_src_extended - loc_dest_extended
	vec_forw = vec_forw.normalized()*dist # x units away
	
	corner_forw = loc_dest_extended + vec_forw
	corners.append(corner_forw)

	
	return corners

func get_tangents(corner1, corner2, extended):
	var tang = (corner1-extended).tangent()
	var tang2 = (corner2-extended).tangent()
	
	# extend them
	var tang_factor = 20 # 10 is too little for some turns
	tang = tang*tang_factor
	tang2 = tang2*tang_factor

	return [tang, tang2]
	
func get_intersection(corner1, corner2, extended):

	var tangs = get_tangents(corner1, corner2, extended)

	var start = corner1 + tangs[0]
	
	var end = corner1-tangs[0]
	
	var start_b = corner2 + tangs[1]

	var end_b = corner2 - tangs[1]
	
	var inters = Geometry.segment_intersects_segment_2d(start, end, start_b, end_b)
	
	if inters:
		return inters
	else:
		return null

func get_arc_angles(center_point, start_point, end_point, angle0):
	var angles = []
	
	# angle between line from center point to angle0 and from center point to start point
	var angle1 = rad2deg((angle0-center_point).angle_to(start_point-center_point))
	#angle1 = int(angle1)
	print("Angle one: " + str(angle1))
	
	# equivalent angle for the end point
	var angle2 = rad2deg((angle0-center_point).angle_to(end_point-center_point))
	#angle2 = int(angle2)
	print("Angle two: " + str(angle2))
	
	var arc = angle1-angle2
	print("Arc is " + str(arc))
	
	angles = [angle1, angle2]
	
	return angles


func get_arc_angle(inters, corner1, corner2):
	# radius = line from intersection to corner point
	var radius = inters.distance_to(corner1)
	
	# the point to which 0 degrees corresponds
	var angle0 = inters+Vector2(radius,0)

	
	var angles = get_arc_angles(inters, corner1, corner2, angle0)

	#var points_arc = get_circle_arc(inters, radius, angles[1], angles[1]+(angles[0]-angles[1]), true)
	var points_arc = get_circle_arc(inters, radius, angles[0], angles[1], true)
	
	var end_point = points_arc[points_arc.size()-1]
	
	return [radius, angles[0], angles[1], end_point]

# from maths
func get_circle_arc( center, radius, angle_from, angle_to, right ):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points+1):
		if right:
			var angle_point = angle_from + i*(angle_to-angle_from)/nb_points #- 90
			var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
			points_arc.push_back( point )
		else:
			var angle_point = angle_from - i*(angle_to-angle_from)/nb_points #- 90
			var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
			points_arc.push_back( point )
	
	return points_arc

func calculate_turn(one, two, data, loc):
	var radius = data[0]
	var start_angle = data[1] + 90
	var end_angle = data[2] + 90

	var turn = set_curved_road(radius, start_angle, end_angle)
	
	turn.set_position(loc)

func set_curved_road(radius, start_angle, end_angle):
	var curved_road = curve.instance()
	
	curved_road.get_child(0).get_child(0).angle_from = start_angle
	curved_road.get_child(0).get_child(0).angle_to = end_angle
	curved_road.get_child(0).get_child(0).radius = radius
	
	add_child(curved_road)
	
	return curved_road

func place_straight(start, end):

	var straight_road = straight.instance()
	
	var dist = start.distance_to(end)
	straight_road.length = dist
	straight_road.set_name("Road_instance 0")
	
	
	add_child(straight_road)
	
	# place
	straight_road.set_position(start)
	
	# rotate
	straight_road.look_at(end)

# debugging
func draw_circle_arc(center, radius, angle_from, angle_to, right, clr):
	var points_arc = get_circle_arc(center, radius, angle_from, angle_to, right)
	
	for index in range(points_arc.size()-1):
		draw_line(points_arc[index], points_arc[index+1], clr, 5)
	
func _draw():

	#for i in range(intersections.size()):
	#	draw_circle(intersections[i], 5, Color(1,0,1))
	
#	for i in range(corner_points.size()):
#		draw_circle(corner_points[i], 5, Color(0,1,0))
#
#	draw_circle_arc(intersections[0], intersections[0].distance_to(corner_points[0]), data[1], data[2], true, Color(1,0,1))

	pass