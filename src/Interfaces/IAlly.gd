extends CharacterBody2D
class_name IAlly

@export var max_health: int = 5
@export var cooldown: float = 5.0
@export var ability_duration: float = 3.0
@export var movement_speed: float = 100.0
var current_health: int

func _ready() -> void:
    current_health = max_health

func hit(damage: int) -> void :
    push_error("IAlly: hit() method not implemented")

func use_ability(delta: float) -> void :
    push_error("IAlly: use_ability() method not implemented")

func move() -> void :
    push_error("IAlly: move() method not implemented")

func die() -> void :
    push_error("IAlly: die() method not implemented")