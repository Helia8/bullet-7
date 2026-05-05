extends IAlly

var time_since_last_ability := 0.0
@export var change_direction_interval: float = 2.0
var time_since_last_direction_change: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
var time_in_ability: float = 0.0
var busy : bool = false
func _ready() -> void:
	super()

func hit(damage:int) -> void :
	return
	current_health -= damage
	if current_health <= 0:
		die()


func _process(delta: float) -> void:
	if (busy):
		use_ability(delta)
		return
	time_since_last_ability += delta
	time_since_last_direction_change += delta
	if time_since_last_direction_change >= change_direction_interval:
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		time_since_last_direction_change = 0.0
	move()
	if Input.is_action_pressed("ui_accept") and time_since_last_ability >= cooldown:
		use_ability(delta)
		time_since_last_ability = 0.0
	pass

func move():
	velocity = wander_direction * movement_speed
	move_and_slide()
	
func use_ability(delta: float) -> void:
	time_in_ability += delta
	if time_in_ability >= ability_duration:
		time_in_ability = 0.0
		busy = false
		return

	var player = get_tree().get_nodes_in_group("player")
	var orbit_radius = 150
	if (player.size() > 0):
		var player_obj = player[0]
		var dir = player_obj.compute_direction_vector()
		var p_pos = player_obj.global_position
		var target_pos = p_pos + dir * orbit_radius
		velocity = (target_pos - global_position).normalized() * 500
		busy = true
		position = target_pos
		return
		move_and_slide()

		# establish distance between self and player (R) 
		# when we are within R of the player
		# look where the player is aiming (direction vector)
		# move around in an orbit until our position roughly matches direction vector + R 
		
		
		return
		var distance_to_player = global_position.distance_to(player_obj.global_position)
		if (distance_to_player > orbit_radius):
			# move towards player until we are within orbit radius
			print("going to")
			velocity = (player_obj.global_position - global_position).normalized() * movement_speed
			move_and_slide()
			return
		if (target_pos.distance_to(global_position) > 10): 
			print("orbiting")
			# if we are not close enough to the target position, keep moving in orbit towards it
			velocity = Vector2(p_pos.x + orbit_radius * cos(target_pos.distance_to(global_position)), p_pos.y + orbit_radius * sin(target_pos.distance_to(global_position))) - global_position
			move_and_slide()
			return
		# we are close enough to the target position, stop moving
		velocity = Vector2.ZERO
		move_and_slide()
			
