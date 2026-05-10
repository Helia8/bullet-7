extends IItem

@onready var _sprite: Sprite2D = $PowerupCoffeeSprite
@onready var _pickupArea: Area2D = $PickupArea

func pickup(player: Node2D) -> void:
    print("player picked up coffee")
    var fire_rate = player.get_fire_rate()
    fire_rate *= 0.5
    player.set_fire_rate(fire_rate)
    queue_free()


func _on_pickup_area_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        pickup(body)
