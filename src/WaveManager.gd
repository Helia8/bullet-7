extends Node
class_name WaveManager

signal all_waves_complete
signal kill_registered(total_kills: int)

#  wave = {scene: PackedScene, pos: Vector2}
var waves: Array = []
var current_wave_index: int = -1
var enemies_alive: int = 0
var total_kills: int = 0

@export var between_wave_delay: float = 3.0 

var bullet_container: Node = null
var entities_container: Node = null
var items_container: Node = null

var _waiting_next_wave: bool = false
var _wave_timer: float = 0.0
var _started: bool = false


func start(bullets: Node, entities: Node, items: Node) -> void:
	bullet_container = bullets
	entities_container = entities
	items_container = items
	_spawn_next_wave()


func _process(delta: float) -> void:
	if not _started:
		return
	if _waiting_next_wave:
		_wave_timer -= delta
		if _wave_timer <= 0.0:
			_waiting_next_wave = false
			_spawn_next_wave()


func _spawn_next_wave() -> void:
	current_wave_index += 1
	if current_wave_index >= waves.size():
		all_waves_complete.emit()
		return

	_started = true
	var wave: Array = waves[current_wave_index]
	enemies_alive = wave.size()

	for entry in wave:
		var enemy: IEnnemy = entry["scene"].instantiate()
		enemy.global_position = entry["pos"]
		entities_container.add_child(enemy)
		enemy.set_bullet_container(bullet_container)
		if items_container:
			enemy.set_items_container(items_container)
		enemy.died.connect(_on_enemy_died)


func _on_enemy_died() -> void:
	enemies_alive -= 1
	total_kills += 1
	kill_registered.emit(total_kills)
	if enemies_alive <= 0:
		if current_wave_index >= waves.size() - 1:
			all_waves_complete.emit()
		else:
			_waiting_next_wave = true
			_wave_timer = between_wave_delay
