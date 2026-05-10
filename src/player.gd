extends CharacterBody2D
@export var bullets_path: NodePath
@onready var bullets_container: Node = get_node(bullets_path)

@export var speed := 300.0
@export var bullet_scene: PackedScene
@export var fire_rate := 1.0
@export var max_health := 100
var health := 100
var cooldown := 0.0
@export var gold: int = 0


func _ready() -> void:
	add_to_group("player")
	health = max_health


func _process(delta):
	cooldown -= delta

	if Input.is_action_pressed("shoot") and cooldown <= 0:
		shoot()
		cooldown = fire_rate
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()


func _physics_process(_delta):
	pass


func shoot() -> void:
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
	print("Player hit! Health: ", health)
	if health <= 0:
		die()


func get_gold() -> int:
	return gold

func add_gold(amount):
	gold += amount
	print("Gold: ", gold)

func remove_gold(amount):
	gold = max(gold - amount, 0)
	print("Gold: ", gold)

func set_fire_rate(new_fire_rate: float) -> void:
	fire_rate = new_fire_rate
func get_fire_rate() -> float:
	return fire_rate


func die() -> void:
	print("Player died!")
	queue_free()
