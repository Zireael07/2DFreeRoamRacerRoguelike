extends "movement_visualizer.gd"

# class member variables go here, for example:
var velocity = Vector2(0,0)
var steer = Vector2(0,0)
var desired = Vector2(0,0)

var dist = 0.0


var max_speed = 500
var max_force = 9
export(Vector2) var target = Vector2(800,700)
var marker 

var lane_change_deg = 20
var lane_change_dist_factor = 1
var loc_tg

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	max_speed = 200 # speed limit   #get_parent().top_speed
	marker = get_parent().get_node("target_marker")
	
	# test changing lanes
	
	loc_tg = (get_parent().forward_vec*lane_change_dist_factor).rotated(deg2rad(lane_change_deg))
	target = to_global(loc_tg)
	marker.set_position(loc_tg)
	
	#var loc_tg2 = (get_parent().forward_vec*2).rotated(deg2rad(-30))
	#ult_tg = loc_tg+loc_tg2
	
	# test normal driving
	#marker.set_position(to_local(target))
	
#	pass

func _physics_process(delta):	
	# marker
	marker.set_position(to_local(target))
	
	# behavior
	# steering behaviors operate in local space
	steer = seek(to_local(target))
	# keeps enough speed to move while staying on track
	#steer = arrive(to_local(target), 4*30)
	# arrives exactly
#	steer = arrive(to_local(target), 30*30)

	# use real velocity to decide
	# _velocity is rotated by parent's rotation, so we use the one that's rotated to fitt
	velocity = get_parent().motion

	
	# normal stuff
#	velocity += steer
	# don't exceed max speed
	#velocity = velocity.normalized() * max_speed
#	velocity = velocity.clamped(max_speed)
	
	
func _draw():
	# multiply for visibility
	draw_vector(steer* 10, Vector2(), colors['GREEN'])
#	draw_vector(desired, Vector2(), colors['WHITE'])
#	draw_vector(velocity, Vector2(), colors['RED'])

# ------------------------------------------
# steering behaviors
func seek(target):
	# make the code universal
	# can be passed both a vector2 or a node
	if not typeof(target) == TYPE_VECTOR2:
		if "position" in target:
			# steering behaviors operate in local space
			target = to_local(target.get_global_position())
	
#	print("tg: " + str(target))
#	print("position: " + str(get_global_position()))
	
	var steering = Vector2(0,0)
	#print("Tg: " + str(target_obj.get_position()) + " " + str(get_position()))
	
	desired = target - get_position()
	dist = desired.length()
#	print("des: " + str(desired))
	desired = desired.normalized() * max_speed
	#print("max speed des: " + str(desired))
	#print("vel " + str(velocity))
	# desired minus current vel
	steering = (desired - velocity).clamped(max_force)
	#print(str(steering))
	#steering = steering.clamped(max_force)
	#print(str(steering))
	
	return(steering)

func arrive(target, slowing_radius):
	var steering = Vector2(0,0)
	#print("Arrive @: " + str(target) + " " + str(get_position()))

	desired = target - get_position()
	#print("Desired " + str(desired))
	dist = desired.length()
	#print("Dist: " + str(distance))
	
	if dist < slowing_radius:
#		print("Slowing... " + str(dist/slowing_radius))
		# inside slowing area
		desired = desired.normalized() * max_speed * (dist / slowing_radius)
		
	else:
		#print("Not slowing")
		# outside
		desired = desired.normalized() * max_speed

	# desired minus current vel
	steering = (desired - velocity).clamped(max_force)

	return (steering)