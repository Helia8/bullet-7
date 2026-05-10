extends CanvasLayer

@onready var xp_label: Label = $Panel/VBox/XpLabel
@onready var gold_label: Label = $Panel/VBox/GoldLabel


func _ready() -> void:
	$Panel/VBox/RetryButton.pressed.connect(_on_retry_pressed)
	$Panel/VBox/MenuButton.pressed.connect(_on_menu_pressed)


func show_results() -> void:
	visible = true
	xp_label.text = "XP earned: %d" % PlayerData.xp
	gold_label.text = "Gold: %d" % PlayerData.gold


func _on_retry_pressed() -> void:
	get_tree().paused = false
	PlayerData.reset()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_menu_pressed() -> void:
	get_tree().paused = false
	PlayerData.reset()
	get_tree().change_scene_to_file("res://scenes/UI/StartMenu.tscn")
