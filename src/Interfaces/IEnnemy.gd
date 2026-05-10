extends CharacterBody2D
class_name IEnnemy

signal died

@export var max_health: int
@export var speed: float
@export var bullet_scene: PackedScene
@export var item_path: NodePath
var health := 0
var bullet_container = null
var player_ref: Node2D = null
var items: Node2D = null

func set_bullet_container(container) -> void:
	bullet_container = container

func set_items_container(container: Node2D) -> void:
	items = container

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	if item_path and not item_path.is_empty():
		items = get_node(item_path)

func _process(delta: float) -> void:
	pass


func move():
	push_error("IEnnemy: move() not implemented")

func shoot():
	push_error("IEnnemy: shoot() not implemented")

func hit(damage: int):
	push_error("IEnnemy: hit() not implemented")

func die():
	push_error("IEnnemy: die() not implemented")
