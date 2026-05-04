extends CharacterBody2D
class_name IWorker


@export var max_health: int = 100
@export var speed: float = 100.0
var health := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	add_to_group("workers")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func move():
	push_error("IWorker: move() not implemented")

func hit(damage: int):
	push_error("IWorker: hit() not implemented")

func die():
	push_error("IWorker: die() not implemented")
