extends CharacterBody2D

signal player_died

@export var bullets_path: NodePath
@onready var bullets_container: Node = get_node(bullets_path)
@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var _sprite: Sprite2D = $TempPlayer

@export var speed := 300.0
@export var bullet_scene: PackedScene
@export var fire_rate := 1.0
@export var max_health := 5
var health := 5
var cooldown := 0.0
@export var gold: int = 0


func _ready() -> void:
	add_to_group("player")
	PlayerData.apply_to_player(self)
	_notify_hud_hp()
	_sprite.visible = false


func _process(delta):
	cooldown -= delta

	if Input.is_action_pressed("shoot") and cooldown <= 0:
		shoot()
		cooldown = fire_rate
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	if direction != Vector2.ZERO:
		_anim.play("walk")
		if direction.x != 0:
			_anim.flip_h = direction.x < 0
	else:
		_anim.stop()


func _physics_process(_delta):
	pass


func shoot() -> void:
	print("player pos is ", global_position)
	var bullet: Node = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.direction = compute_direction_vector()
	bullet.bullet_type = bullet.BulletType.PLAYER
	bullets_container.add_child(bullet)


func compute_direction_vector() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	return direction


func hit(damage: int) -> void:
	health -= damage
	_notify_hud_hp()
	if health <= 0:
		die()


func _notify_hud_hp() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_hp(health)


func get_gold() -> int:
	return gold

func add_gold(amount):
	gold += amount
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_gold(gold)

func remove_gold(amount):
	gold = max(gold - amount, 0)
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_gold(gold)

func set_fire_rate(new_fire_rate: float) -> void:
	fire_rate = new_fire_rate
func get_fire_rate() -> float:
	return fire_rate


func die() -> void:
	set_process(false)
	set_physics_process(false)
	player_died.emit()
