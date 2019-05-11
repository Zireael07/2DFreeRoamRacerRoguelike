extends RigidBody2D

# Joystick Deadzone Thresholds
#var stick_min = 0.07 # If the axis is smaller, behave as if it were 0

# Driving Properties
export (int) var acceleration = 18 
export (int) var top_speed = 2000
export (float, 0, 1, 0.001) var drag_coefficient = 0.99 # Recommended: 0.99 - Affects how fast you slow down
#export (float, 0, 10, 0.01) var steering_torque = 3.75 # Affects turning speed
#export (float, 0, 20, 0.1) var steering_damp = 8 # 7 - Affects how fast the torque slows down

# Drifting & Tire Friction
#export (bool) var can_drift = true
#export (float, 0, 1, 0.001) var wheel_grip_sticky = 0.85 # Default drift coef (will stick to road, most of the time)
#export (float, 0, 1, 0.001) var wheel_grip_slippery = 0.99 # Affects how much you "slide"
#export (int) var drift_extremum = 250 # Right velocity higher than this will cause you to slide
#export (int) var drift_asymptote = 20 # During a slide you need to reduce right velocity to this to gain control
#var _drift_factor = wheel_grip_sticky # Determines how much (or little) your vehicle drifts

# mock the 3d physics
var STEER_LIMIT = 1
var STEER_SPEED = 1
#steering
var steer_angle = 0
var steer_target = 0
var predicted_steer = 0

var forward_vec = Vector2(0,0)
var reverse
var speed = 0
var dot

# Vehicle velocity
var _velocity = Vector2(0, 0)

# for visualizing
var steering = Vector2(0,0)
#var target_motion = Vector2(0,0)
var motion = Vector2(0,0)

# test
#var test_spd = 80

# Start
func _ready():
	# Top Down Physics
	set_gravity_scale(0.0)
	
	# Added steering_damp since it may not be obvious at first glance that
	# you can simply change angular_damp to get the same effect
#	set_angular_damp(steering_damp)


# Fixed Process
func _physics_process(delta):
	pass

func do_physics(gas, braking, left, right, joy, delta):
	#print("D: " + str(delta))
	speed = get_linear_velocity().length()
	
	
	# Drag (0 means we will never slow down ever. Like being in space.)
	_velocity *= drag_coefficient
	
	# needed for dot calculations
	forward_vec = Vector2(0,-100)
	
#	# If we can drift
#	if(can_drift):
#		# If we are sticking to the road
#		if(_drift_factor == wheel_grip_sticky):
#			# If we exceed max stick velocity, begin sliding on the road
#			if(get_right_velocity().length() > drift_extremum):
#				_drift_factor = wheel_grip_slippery
#				#print("SLIDING!")
#		# If we are sliding on the road
#		else:
#			# If our side velocity is less than the drift asymptote, begin sticking to the road
#			if(get_right_velocity().length() < drift_asymptote):
#				_drift_factor = wheel_grip_sticky
#				#print("STICKING!")
#
#	# Add drift to velocity
#	_velocity = get_up_velocity() + (get_right_velocity() * _drift_factor)
	
	if joy != Vector2(0,0):
		steer_target = joy.x
	else:
		if (left):
			steer_target = -STEER_LIMIT
		elif (right):
			steer_target = STEER_LIMIT
		else: #if (not left and not right):
			steer_target = 0
	
#	# Steer Left
#	if(left):
#		# TODO: Find a better way to handle this instead of hard-coding the check for Left Stick Axis
#		#var axis = Input.get_joy_axis(0, 0) # Left Stick Axis
#		#if(axis < stick_min):
#		var axis = 1 # Set it to 1 since we are not using the left stick
#
#		set_angular_velocity(-torque * abs(axis))
#
#	# Steer Right
#	elif(right):
#		# TODO: Find a better way to handle this instead of hard-coding the check for Left Stick Axis
#		#var axis = Input.get_joy_axis(0, 0) # Left Stick Axis
#		#if(axis < stick_min):
#		var axis = 1 # Set it to 1 since we are not using the left stick
#
#		set_angular_velocity(torque * abs(axis))
	
	#steering
	if (steer_target < steer_angle):
		steer_angle -= STEER_SPEED*delta
		if (steer_target > steer_angle):
			steer_angle = steer_target
	elif (steer_target > steer_angle):
		steer_angle += STEER_SPEED*delta
		if (steer_target < steer_angle):
			steer_angle = steer_target
	
	# set angular velocity
	# cars don't move if no linear velocity
	if _velocity.length() < 1:
		set_angular_velocity(0)
	else:
		set_angular_velocity(steer_angle)
	
	# visualize the angle
	if has_node("wheel") and has_node("wheel2"):
		get_node("wheel").set_rotation(steer_angle)
		get_node("wheel2").set_rotation(steer_angle)
	
	var dot = get_linear_velocity().rotated(-get_rotation()).dot(forward_vec)
	# Accelerate
	if(gas):
		if has_node("rear light"):
			# visuals
			get_node("rear light").set_modulate(Color8(110,0,0))
		
		var axis = 1 # Set it to 1 since we are not using the trigger
		
		# those result in the velocity being offset from heading (the car accumulates a slide)
		_velocity += get_up() * acceleration * axis
		#_velocity += Vector2(0,-1).rotated(get_rotation()) * acceleration * axis
		#print(str(_velocity))

		# fix the sliding (offset)		
		var angle_to = _velocity.angle_to(get_up())
		if dot < 0 and _velocity.length() > 5:
			angle_to = _velocity.angle_to(-get_up())
		if dot < 0 and _velocity.length() < 5:
			reverse = false
			
		_velocity = _velocity.rotated(angle_to)

	# Break / Reverse
	elif(braking):
		if has_node("rear light"):
			# visuals
			get_node("rear light").set_modulate(Color(1,1,1))
		
		var axis = 1 # Set it to 1 since we are not using the trigger

		# those result in the velocity being offset from heading (the car accumulates a slide)
		_velocity -= get_up() * acceleration * axis
		#_velocity -= Vector2(0,-1).rotated(get_rotation()) * acceleration * axis		
		
		# fix the sliding (offset)
		var angle_to = _velocity.angle_to(get_up())
		reverse = false
		# enable reversing
		if dot < 0 or (dot > 0 and _velocity.length() < 5):
			reverse = true
			angle_to = _velocity.angle_to(-get_up())
		
		_velocity = _velocity.rotated(angle_to)
		
		
	# Prevent exceeding max velocity
	# 
	# This is done by getting a Vector2 that points up 
	# (the vehicle's default forward direction),
	# and rotate it to the same amount our vehicle is rotated.
	# Then we keep the magnitude of that direction which allows
	# us to calculate the max allowed velocity in that direction.
	#var max_speed = (Vector2(0, -1) * top_speed).rotated(get_rotation())
	#var x = clamp(_velocity.x, -abs(max_speed.x), abs(max_speed.x))
	#var y = clamp(_velocity.y, -abs(max_speed.y), abs(max_speed.y))
	#_velocity = Vector2(x, y)
	_velocity = _velocity.clamped(top_speed)
	
	# Torque depends that the vehicle is moving
	#var torque = lerp(0, steering_torque, _velocity.length() / top_speed)
	
	# prevents accumulating slide
	# we weren't recalculating direction if keys weren't pressed
	var dir = get_up()
	if reverse:
#		print("Reverse")
		dir = -get_up()
	
	var angle_to = _velocity.angle_to(dir)
	_velocity = _velocity.rotated(angle_to)
	
	
	# Apply the force
	set_linear_velocity(_velocity)
	
	# for visualizer
	# getting a vector that points right and multiplying it by a factor to make it visible
	steering = (get_angular_velocity() * Vector2(1,0) * 20)  # pink
	# rotating by -get_rot() because it was rotated by get_rot @ line 103
	motion = get_linear_velocity().clamped(300).rotated(-get_rotation()) # yellow
	#target_motion = motion+steering
	
	#reverse
#	dot = get_linear_velocity().rotated(-get_rotation()).dot(forward_vec)
#	print(str(dot))
#	if (dot < 0):
##		print("Reverse")
#		reverse = true
#	else:
#		reverse = false
#
	

# Returns up direction (vehicle's forward direction)
func get_up():
	return Vector2(cos(-get_rotation() + PI/2.0), sin(-get_rotation() - PI/2.0))

# Returns right direction
func get_right():
	return Vector2(cos(-get_rotation()), sin(get_rotation()))

# Returns up velocity (vehicle's forward velocity)
func get_up_velocity():
	return get_up() * _velocity.dot(get_up())

# Returns right velocity
func get_right_velocity():
	return get_right() * _velocity.dot(get_right())


# 3d mockups start here
# basically copy-pasta from the car physics function, to predict steer the NEXT physics tick
func predict_steer(delta, left, right):
	# simplified!!!
	if left:
		steer_angle = steer_angle - STEER_SPEED*delta
		#print("Change by: " + str(STEER_SPEED*delta))
	elif right:
		steer_angle = steer_angle + STEER_SPEED*delta
		#print("Change by: " + str(STEER_SPEED*delta))
	else:
		steer_angle = steer_angle
	
#	if (left):
#		steer_target = -STEER_LIMIT
#	elif (right):
#		steer_target = STEER_LIMIT
#	else: #if (not left and not right):
#		steer_target = 0
#
#
#	if (steer_target < steer_angle):
#		steer_angle -= STEER_SPEED*delta
#		if (steer_target > steer_angle):
#			steer_angle = steer_target
#	elif (steer_target > steer_angle):
#		steer_angle += STEER_SPEED*delta
#		if (steer_target < steer_angle):
#			steer_angle = steer_target
			
	return steer_angle
	
func get_turn_radius(steer):
	# wheelbase is 96+80 = 176px for now
	print("176, steer " + str(steer))
	return (176 / sin(steer))