extends "boid.gd"

# Declare member variables here. Examples:

# FSM
onready var state = CruiseState.new(self)

var prev_state

const STATE_CRUISE = 0
const STATE_OBSTACLE   = 1
const STATE_PATH = 2

signal state_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# fsm
func set_state(new_state, param=null):
	# if we need to clean up
	#state.exit()
	prev_state = get_state()
	
	if new_state == STATE_CRUISE:
		state = CruiseState.new(self)
	elif new_state == STATE_OBSTACLE:
		state = ObstacleState.new(self, param)
	elif new_state == STATE_PATH:
		state = PathState.new(self)

	emit_signal("state_changed", self)
	
#	print(get_name() + " setting state to " + str(new_state))

func get_state():
	if state is CruiseState:
		return STATE_CRUISE
	elif state is ObstacleState:
		return STATE_OBSTACLE
	elif state is PathState:
		return STATE_PATH

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
		#if player.get_parent().has_node("Area2D"):
		if player.get_parent().get_node("Area2D").colliding.size() > 0:
			player.set_state(STATE_OBSTACLE, player.get_parent().get_node("Area2D").colliding[0])
		

class ObstacleState:
	var player
	var or_heading
	var collider
	
	func _init(playr, coll):
		player = playr
		# get current heading
		or_heading = player.get_global_rotation()
		#print("Original heading: " + str(or_heading))
		# collider
		collider = coll

	func update(delta):
		# 2 m/s
		player.steer = player.match_velocity_length(30)

		#if player.get_parent().has_node("Area2D"):
		if player.get_parent().get_node("Area2D").colliding.has(collider):
			# combine two behaviors
			# this is global x degrees, not local
			player.steer += player.align(or_heading - deg2rad(25))
		else:
			var align = player.align(or_heading)
			player.steer += align
			if align == Vector2(0,0):
				print("Returning to state: " + str(player.prev_state))
				if player.prev_state == STATE_PATH:
					pass
					# get closest point
					
				player.set_state(player.prev_state)
		
		# use real velocity to decide
		# _velocity is rotated by parent's rotation, so we use the one that's rotated to fit
		player.velocity = player.get_parent().motion
		

class PathState:
	var player
	
	func _init(playr):
		player = playr
		
	func update(delta):
		# marker
		player.marker.set_position(player.to_local(player.target))
	
		# behavior
		# steering behaviors operate in local space
		#steer = seek(to_local(target))
		# keeps enough speed to move while staying on track
		# scale: 30 = 2 m/s
		var spd_steer = player.match_velocity_length(100)
		#print("Steer" + str(spd_steer))
		# the value here (how many car lengths) should probably be speed dependent (15 works fine for speeds < 50)
		var arr = player.arrive(player.to_local(player.target), 25*30)
		#print("Arr" + str(arr))
		#player.steer = arr;
		player.steer = spd_steer + arr;
		#player.steer = Vector2(arr.x, spd_steer.y);
		#print("Post: " + str(player.steer))
		# arrives exactly
	#	steer = arrive(to_local(target), 30*30)

		# use real velocity to decide
		# _velocity is rotated by parent's rotation, so we use the one that's rotated to fit
		player.velocity = player.get_parent().motion

		# shift
		if player.get_parent().get_node("Area2D").colliding.size() > 0:
			var coll = player.get_parent().get_node("Area2D").colliding[0]
			# exclude buildings and other cars
			if not coll.is_in_group("building") and not coll.is_in_group("car"):
				player.set_state(STATE_OBSTACLE, coll)