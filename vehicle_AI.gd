extends "vehicle.gd"

# class member variables go here, for example:
# input 
var gas = false
var brake = false
var left = false
var right = false

# Start
func _ready():
	# Top Down Physics
	set_gravity_scale(0.0)

# Fixed Process
func _physics_process(delta):
	# reset input
	var gas = false
	var braking = false
	var left = false
	var right = false
	
	
	# drive
	if (speed <= 250):
		gas = true
	# Break / Reverse
	else:
		braking = true
	# Steer Left
	#if(Input.is_action_pressed("steer_left")):
	#	left = true
	# Steer Right
	#elif(Input.is_action_pressed("steer_right")):
	#	right = true
	
	do_physics(gas, braking, left, right, delta)
