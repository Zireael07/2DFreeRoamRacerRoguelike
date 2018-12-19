extends "vehicle.gd"

# class member variables go here, for example:
# input 
var gas = false
var brake = false
var left = false
var right = false

var brain = null

var path

# Start
func _ready():
	# Top Down Physics
	set_gravity_scale(0.0)
	
	brain = get_node("brain")
	
	path = get_tree().get_nodes_in_group("world")[0].get_node("proc_map/Visualizer").path
	brain.target = path[path.size()-1]

# Fixed Process
func _physics_process(delta):
	# reset input
	var gas = false
	var braking = false
	var left = false
	var right = false
	
	# steering from boid
#	print("Brain steer: " + str(brain.steer))

#	if speed <= 50:
	if brain.steer.y < 0:
		gas = true
	else:
		braking = true
	
	if brain.steer.x < 0:
		left = true
	elif brain.steer.x > 0:
		right = true
		
	
	# drive
#	if (speed <= 80): #250):
#		gas = true
	# Break / Reverse
#	else:
#		braking = true
	
	do_physics(gas, braking, left, right, delta)
