extends ILevel

const ENEMY_SCENE = preload("res://scenes/Ennemies/DefaultEnnemy.tscn")
const DOOR_SCENE = preload("res://scenes/Interactables/Door.tscn")
const ALLY_WS_SCENE = preload("res://scenes/Interactables/AllyWorkStation.tscn")
const SHIELD_ALLY_SCENE = preload("res://scenes/Allies/ShieldAlly.tscn")

@onready var bullets = $Bullets
@onready var player = $Entities/PlayerCharacter
const BASE_XP: int = 200
const XP_PER_QUOTA: int = 10

var _wave_manager: WaveManager


func _ready() -> void:
	var door = DOOR_SCENE.instantiate()
	door.next_level = null
	door.position = Vector2(880, 500)
	$Entities.add_child(door)

	var ws1 = ALLY_WS_SCENE.instantiate()
	ws1.ally_scene = SHIELD_ALLY_SCENE
	ws1.position = Vector2(400, 300)
	$Entities.add_child(ws1)

	var ws2 = ALLY_WS_SCENE.instantiate()
	ws2.ally_scene = SHIELD_ALLY_SCENE
	ws2.position = Vector2(700, 300)
	$Entities.add_child(ws2)

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
	var wave3 = [
		{"scene": ENEMY_SCENE, "pos": Vector2(320, 175)},
		{"scene": ENEMY_SCENE, "pos": Vector2(480, 200)},
		{"scene": ENEMY_SCENE, "pos": Vector2(640, 175)},
		{"scene": ENEMY_SCENE, "pos": Vector2(800, 200)},
		{"scene": ENEMY_SCENE, "pos": Vector2(560, 350)},
	]

	_wave_manager = WaveManager.new()
	add_child(_wave_manager)
	_wave_manager.waves = [wave1, wave2, wave3]
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
