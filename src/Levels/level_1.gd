extends ILevel

@onready var bullets = $Bullets
@onready var player = $Entities/PlayerCharacter
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for entity in $Entities.get_children():
		if entity is IEnnemy:
			print("setting bullet container for ", entity.name)
			entity.set_bullet_container(bullets)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_bullet_contained():
	return bullets
	
func get_player():
	return player

func start_level():
	print("level 1 started")
	pass
