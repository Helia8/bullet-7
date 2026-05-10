extends DefaultWorkStation

@export var ally_scene: PackedScene


func _ready() -> void:
	super()


func complete() -> void:
	if ally_scene:
		var ally = ally_scene.instantiate()
		ally.global_position = global_position
		get_parent().add_child(ally)
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.add_job()
	queue_free()
