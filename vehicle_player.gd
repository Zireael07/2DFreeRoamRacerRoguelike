extends "vehicle.gd"

# input 
var gas = false
var brake = false
var left = false
var right = false
var joy = Vector2(0,0)

var joy_node

# car size equals 2 m
var car_length = 30


# Start
func _ready():
	# Top Down Physics
	set_gravity_scale(0.0)
	
	# Added steering_damp since it may not be obvious at first glance that
	# you can simply change angular_damp to get the same effect
#	set_angular_damp(steering_damp)

	joy_node = get_tree().get_nodes_in_group("canvas")[0].get_node("virtual_joy")

# Fixed Process
func _physics_process(delta):
	# reset input
	var gas = false
	var braking = false
	var left = false
	var right = false
	var joy = Vector2(0,0)
	
	# input
	joy = joy_node.get_node("Control").val
	
	
	if(Input.is_action_pressed("accelerate")):
		gas = true
	# Break / Reverse
	elif(Input.is_action_pressed("brake")):
		braking = true
	# Steer Left
	if(Input.is_action_pressed("steer_left")):
		left = true
	# Steer Right
	elif(Input.is_action_pressed("steer_right")):
		right = true
	
	do_physics(gas, braking, left, right, joy, delta)

	# display speed
	var vel = get_linear_velocity().length()
	var m_per_s = round(round(vel)/(car_length/2))
	var kph = round(m_per_s*3.6)
	get_parent().get_parent().get_node("CanvasLayer/Control/Label").set_text("Speed : " + str(kph) + " kph " +  str(m_per_s) + " m/s") #str(round(vel)))
