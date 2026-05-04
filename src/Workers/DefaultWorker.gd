extends IWorker

@export var change_direction_interval: float = 2.0
var time_since_last_direction_change: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_since_last_direction_change += delta
	if time_since_last_direction_change >= change_direction_interval:
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		time_since_last_direction_change = 0.0
	move()
	pass

func move():
	velocity = wander_direction * speed
	move_and_slide()
	
