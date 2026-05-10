extends Node2D

const HUD_SCENE = preload("res://scenes/UI/HUD.tscn")
const PAUSE_MENU_SCENE = preload("res://scenes/UI/PauseMenu.tscn")
const WIN_SCREEN_SCENE = preload("res://scenes/UI/WinScreen.tscn")
const LOSE_SCREEN_SCENE = preload("res://scenes/UI/LoseScreen.tscn")

@export var level_scene: PackedScene
@export var levels: Array[PackedScene]

var current_Level: ILevel
var _hud: CanvasLayer
var _pause_menu: CanvasLayer
var _win_screen: CanvasLayer
var _lose_screen: CanvasLayer
var _paused: bool = false


func _ready() -> void:
	add_to_group("main")

	_hud = HUD_SCENE.instantiate()
	add_child(_hud)

	_pause_menu = PAUSE_MENU_SCENE.instantiate()
	_pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_pause_menu)

	_win_screen = WIN_SCREEN_SCENE.instantiate()
	_win_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	_win_screen.visible = false
	add_child(_win_screen)

	_lose_screen = LOSE_SCREEN_SCENE.instantiate()
	_lose_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	_lose_screen.visible = false
	add_child(_lose_screen)

	load_level(level_scene)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not (_win_screen.visible or _lose_screen.visible):
			toggle_pause()


func toggle_pause() -> void:
	_paused = not _paused
	get_tree().paused = _paused
	_pause_menu.visible = _paused


func load_level(scene: PackedScene) -> void:
	if current_Level and is_instance_valid(current_Level):
		var old_player = current_Level.get_player()
		if old_player and is_instance_valid(old_player):
			PlayerData.save_from_player(old_player)
		PlayerData.level_index += 1
		current_Level.queue_free()

	current_Level = scene.instantiate()
	add_child(current_Level)

	var player = current_Level.get_player()
	if player:
		player.player_died.connect(_on_player_died)

	_hud.reset_room_counters()
	_hud.update_hp(PlayerData.health)
	_hud.update_gold(PlayerData.gold)
	_hud.update_xp(PlayerData.level_index)


func show_win_screen() -> void:
	if current_Level and is_instance_valid(current_Level):
		var player = current_Level.get_player()
		if player and is_instance_valid(player):
			PlayerData.save_from_player(player)
	get_tree().paused = true
	_win_screen.show_results()


func _on_player_died() -> void:
	if current_Level and is_instance_valid(current_Level):
		var player = current_Level.get_player()
		if player and is_instance_valid(player):
			PlayerData.save_from_player(player)
	get_tree().paused = true
	_lose_screen.show_results()
