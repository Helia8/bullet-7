extends IItem

@onready var _sprite: Sprite2D = $GoldSprite
@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var _pickupArea: Area2D = $PickupArea

func _ready() -> void:
	_anim.play("spin")

func pickup(player: Node2D) -> void:
	print("player picked up gold")
	player.add_gold(1)
	queue_free()

func _on_pickup_area_body_entered(body: Node2D):
	if body.is_in_group("player"):
		pickup(body)
