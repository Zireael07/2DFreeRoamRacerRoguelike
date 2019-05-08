extends "boid.gd"

# Declare member variables here. Examples:

# FSM
onready var state = CruiseState.new(self)
var prev_state

const STATE_CRUISE = 0
const STATE_OBSTACLE   = 1

signal state_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# fsm
func set_state(new_state):
	# if we need to clean up
	#state.exit()
	prev_state = get_state()
	
	if new_state == STATE_CRUISE:
		state = CruiseState.new(self)
	elif new_state == STATE_OBSTACLE:
		state = ObstacleState.new(self)

	emit_signal("state_changed", self)
	
#	print(get_name() + " setting state to " + str(new_state))

func get_state():
	if state is CruiseState:
		return STATE_CRUISE
	elif state is ObstacleState:
		return STATE_OBSTACLE

# generic
func _physics_process(delta):
	# use states
	state.update(delta)

# states ----------------------------------------------------
class CruiseState:
	var player
	
	func _init(playr):
		player = playr

	func update(delta):
		player.steer = player.match_velocity_length(20)

		# use real velocity to decide
		# _velocity is rotated by parent's rotation, so we use the one that's rotated to fit
		player.velocity = player.get_parent().motion
		
		# shift
		if player.get_parent().has_node("Area2D"):
			if player.get_parent().get_node("Area2D").colliding.size() > 0:
				player.set_state(STATE_OBSTACLE)
		

class ObstacleState:
	var player
	
	func _init(playr):
		player = playr

	func update(delta):
		player.steer = player.match_velocity_length(10)
		
		if player.get_parent().has_node("Area2D"):
			if player.get_parent().get_node("Area2D").colliding.size() > 0:
				# combine two behaviors
				# this is global x degrees, not local
				player.steer += player.align(deg2rad(-45))
			else:
				var align = player.align(deg2rad(0))
				player.steer += align
				if align == Vector2(0,0):
					player.set_state(STATE_CRUISE)
		
		# use real velocity to decide
		# _velocity is rotated by parent's rotation, so we use the one that's rotated to fit
		player.velocity = player.get_parent().motion
		


