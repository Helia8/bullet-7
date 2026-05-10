extends ILevel

const ENEMY_SCENE = preload("res://scenes/Ennemies/DefaultEnnemy.tscn")
const DOOR_SCENE = preload("res://scenes/Interactables/Door.tscn")
const ALLY_WS_SCENE = preload("res://scenes/Interactables/AllyWorkStation.tscn")
const SHIELD_ALLY_SCENE = preload("res://scenes/Allies/ShieldAlly.tscn")
const LEVEL_3_SCENE = preload("res://scenes/Levels/level_3.tscn")

@onready var bullets = $Bullets
@onready var player = $Entities/PlayerCharacter

const BASE_XP: int = 150
const XP_PER_QUOTA: int = 10

var _wave_manager: WaveManager


func _ready() -> void:
	for child in $Entities.get_children():
		if child is IEnnemy:
			child.set_process(false)
			child.set_physics_process(false)
			child.queue_free()
	var door = DOOR_SCENE.instantiate()
	door.next_level = LEVEL_3_SCENE
	door.position = Vector2(880, 500)
	$Entities.add_child(door)
	var ws = ALLY_WS_SCENE.instantiate()
	ws.ally_scene = SHIELD_ALLY_SCENE
	ws.position = Vector2(500, 350)
	$Entities.add_child(ws)

	var wave1 = [
		{"scene": ENEMY_SCENE, "pos": Vector2(350, 175)},
		{"scene": ENEMY_SCENE, "pos": Vector2(600, 200)},
		{"scene": ENEMY_SCENE, "pos": Vector2(800, 175)},
	]
	var wave2 = [
		{"scene": ENEMY_SCENE, "pos": Vector2(300, 300)},
		{"scene": ENEMY_SCENE, "pos": Vector2(500, 175)},
		{"scene": ENEMY_SCENE, "pos": Vector2(700, 200)},
		{"scene": ENEMY_SCENE, "pos": Vector2(850, 350)},
	]

	_wave_manager = WaveManager.new()
	add_child(_wave_manager)
	_wave_manager.waves = [wave1, wave2]
	_wave_manager.kill_registered.connect(_on_kill_registered)
	_wave_manager.all_waves_complete.connect(_on_all_waves_complete)
	_wave_manager.start(bullets, $Entities, null)


func _on_kill_registered(_total: int) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.add_kill()


func _on_all_waves_complete() -> void:
	for ws in get_tree().get_nodes_in_group("workstations"):
		ws.queue_free()

	var hud = get_tree().get_first_node_in_group("hud")
	var jobs: int = hud.get_jobs() if hud else 0
	var kills: int = _wave_manager.total_kills
	var quota: int = (jobs * 3) - kills
	PlayerData.xp += BASE_XP + max(quota * XP_PER_QUOTA, 0)
	if hud:
		hud.update_xp(PlayerData.level_index + 1)

	for door in get_tree().get_nodes_in_group("door"):
		door.open()


func get_bullet_contained():
	return bullets

func get_player():
	return player

func start_level():
	pass
