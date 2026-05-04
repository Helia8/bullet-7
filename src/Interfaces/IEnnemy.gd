extends CharacterBody2D
class_name IEnnemy


@export var max_health: int
@export var speed: float
@export var bullet_scene: PackedScene
var health := 0
var bullet_container = null
var player_ref: Node2D = null

func set_bullet_container(container):
	bullet_container = container

func _ready() -> void:
	health = max_health


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
