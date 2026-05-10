extends CanvasLayer


func _ready() -> void:
	$ResumeButton.pressed.connect(_on_resume_pressed)
	$QuitButton.pressed.connect(_on_quit_pressed)


func _on_resume_pressed() -> void:
	var main = get_tree().get_first_node_in_group("main")
	if main:
		main.toggle_pause()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/StartMenu.tscn")
