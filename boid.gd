extends "movement_visualizer.gd"

# class member variables go here, for example:
var velocity = Vector2(0,0)
var steer = Vector2(0,0)
var desired = Vector2(0,0)

var max_speed = 500
var max_force = 9
export(Vector2) var target = Vector2(800,700)
var marker 


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	max_speed = get_parent().top_speed
	marker = get_parent().get_node("target_marker")
	marker.set_position(to_local(target))
	
#	pass

func _physics_process(delta):
	# marker
	marker.set_position(to_local(target))
	
	# behavior
	# steering behaviors operate in local space
#	steer = seek(to_local(target))
	steer = arrive(to_local(target), 30*2)
	
	# normal stuff
	velocity += steer
	# don't exceed max speed
	#velocity = velocity.normalized() * max_speed
	velocity = velocity.clamped(max_speed)
	
	
func _draw():
	# multiply for visibility
	draw_vector(steer* 20, Vector2(), colors['GREEN'])
#	draw_vector(desired, Vector2(), colors['WHITE'])
	draw_vector(velocity, Vector2(), colors['WHITE'])

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
	var distance = desired.length()
	#print("Dist: " + str(distance))
	
	if distance < slowing_radius:
		#print("Slowing... " + str(distance/slowing_radius))
		# inside slowing area
		desired = desired.normalized() * max_speed * (distance / slowing_radius)
		
	else:
		#print("Not slowing")
		# outside
		desired = desired.normalized() * max_speed

	# desired minus current vel
	steering = (desired - velocity).clamped(max_force)

	return (steering)