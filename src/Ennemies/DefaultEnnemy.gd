extends IEnnemy

@export var preferred_range: float = 400.0
@export var range_tolerance: float = 60.0
@export var fire_rate: float = 2.0
var cooldown := 0.0
@export var dropped_item_scene: PackedScene
@export var gold_scene: PackedScene
var inv = -1
var _spawning: bool = true

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super()
	player_ref = get_tree().get_first_node_in_group("player")
	_anim.animation_finished.connect(_on_anim_finished)
	_anim.play("spawn")


func _on_anim_finished() -> void:
	if _anim.animation == &"spawn":
		_spawning = false
		_anim.play("walk")


func _process(delta: float) -> void:
	if _spawning:
		return
	cooldown -= delta
	if player_ref == null:
		player_ref = get_tree().get_first_node_in_group("player")
		return
	move()
	if cooldown <= 0:
		shoot()
		cooldown = fire_rate


func move() -> void:

	if player_ref == null:
		velocity = Vector2.ZERO
		return
	var to_player = player_ref.global_position - global_position
	var dist = to_player.length()
	# we try to stay within bullet range of the player
	if dist > preferred_range + range_tolerance:
		# too far of the player, we miss our shoot, move closer
		velocity = to_player.normalized() * speed
	elif dist < preferred_range - range_tolerance:
		# too close, no need to stay there, fall back
		velocity = -to_player.normalized() * speed
	else:
		# in the perfect range, stable movement 
		velocity = Vector2(-to_player.y, to_player.x).normalized() * speed
		velocity *= inv
	move_and_slide()
	if velocity.x != 0:
		_anim.flip_h = velocity.x < 0


func shoot() -> void:
	if player_ref == null or bullet_container == null or bullet_scene == null:
		print("Enemy shoot failed: missing player reference, bullet container, or bullet scene.")
		return
	print("Enemy shooting at player!")
	var random = randi_range(-1,1)
	inv = random

	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = (player_ref.global_position - global_position).normalized()
	bullet.bullet_type = bullet.BulletType.ENEMY
	bullet_container.add_child(bullet)


func hit(damage: int) -> void:
	health -= damage
	if health <= 0:
		die()


func die() -> void:
	died.emit()
	var drop_parent: Node = items if items else get_parent()
	if drop_parent:
		if dropped_item_scene:
			var coffee = dropped_item_scene.instantiate()
			coffee.global_position = global_position + Vector2(-20, 0)
			drop_parent.add_child(coffee)
		if gold_scene:
			var gold = gold_scene.instantiate()
			gold.global_position = global_position + Vector2(20, 0)
			drop_parent.add_child(gold)
	queue_free()
