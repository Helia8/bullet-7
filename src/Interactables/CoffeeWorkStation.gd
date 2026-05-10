extends DefaultWorkStation

const COFFEE_SCENE = preload("res://scenes/items/coffee_item.tscn")


func complete() -> void:
	var coffee = COFFEE_SCENE.instantiate()
	coffee.global_position = global_position
	get_parent().add_child(coffee)
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.add_job()
	queue_free()
