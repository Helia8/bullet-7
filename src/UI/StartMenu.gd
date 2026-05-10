extends CanvasLayer


func _ready() -> void:
	$PlayButton.pressed.connect(_on_play_pressed)
	$QuitButton.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	PlayerData.reset()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
