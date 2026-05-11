extends ILevel

const TILE_CRUMBLING = preload("res://assets/tile_crumbling.png")


@export var ENEMY_SCENE: PackedScene
@export var ALLY_WS_SCENE: PackedScene
@export var SHIELD_ALLY_SCENE: PackedScene
@export var COFFEE_WS_SCENE: PackedScene


@onready var bullets = $Bullets
@onready var player = $Entities/PlayerCharacter
@onready var tilemap: TileMapLayer = $Environment/TileMapLayer

@export var destruction_time_range: Vector2 = Vector2(0.0, 0.10)
@export var tile_destruction_time: float = 0.0
@export var room_x: int = 16
@export var room_y: int = 11
@export var destroy_radius: int = 3
@onready var room_center = Vector2(room_x / 2.0, room_y / 2.0)
@export var room_top_left_offset: Vector2 = Vector2(20, 40)
var destruction_timer: float = 0.0
var time_since_last_destruction: float = 0.0
var is_destroying: bool = false
var current_destruction_time: float = 0.0
var room_origin: Vector2i = Vector2i.ZERO
var room_w: int = 0
var room_h: int = 0
@export var max_destroyed_rings: int = 3
var destroyed_rings: int = 0
var destroyed_tiles: Dictionary = {}
var destruction_complete: bool = false
var _warned_tiles: Dictionary = {}

@export var BASE_XP: int = 100
@export var XP_PER_QUOTA: int = 10

var _wave_manager: WaveManager


func _ready() -> void:
	for child in $Entities.get_children():
		if child is IEnnemy:
			child.set_process(false)
			child.set_physics_process(false)
			child.queue_free()

	var ws = ALLY_WS_SCENE.instantiate()
	ws.ally_scene = SHIELD_ALLY_SCENE
	ws.position = Vector2(550, 330)
	$Entities.add_child(ws)

	if COFFEE_WS_SCENE:
		var coffee_ws = COFFEE_WS_SCENE.instantiate()
		coffee_ws.position = Vector2(3400, 2300)  # TUNABLE
		$Entities.add_child(coffee_ws)

	var wave1 = [
		{"scene": ENEMY_SCENE, "pos": Vector2(3080.174, 2098.125)},
		{"scene": ENEMY_SCENE, "pos": Vector2(3685.557, 2318.04)},
	]
	var wave2 = [
		{"scene": ENEMY_SCENE, "pos": Vector2(3229.054, 2662.879)},
		{"scene": ENEMY_SCENE, "pos": Vector2(3080.174, 2098.125)},
		{"scene": ENEMY_SCENE, "pos": Vector2(3685.557, 2318.04)},
	]

	_wave_manager = WaveManager.new()
	add_child(_wave_manager)
	_wave_manager.waves = [wave1, wave2]
	_wave_manager.kill_registered.connect(_on_kill_registered)
	_wave_manager.all_waves_complete.connect(_on_all_waves_complete)

	var items_node: Node2D = null
	if has_node("Entities/Items"):
		items_node = $Entities/Items
	_wave_manager.start(bullets, $Entities, items_node)


func _process(_delta: float) -> void:
	if destruction_complete:
		return
	if is_destroying:
		destruction_timer += _delta
		if destruction_timer >= current_destruction_time:
			is_destroying = false
			destruction_timer = 0.0
			time_since_last_destruction = 0.0
			destroy_random_tile()
	else:
		time_since_last_destruction += _delta
		if time_since_last_destruction >= tile_destruction_time:
			is_destroying = true
			current_destruction_time = randf_range(destruction_time_range.x, destruction_time_range.y)


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



func get_ring(depth: int, map_data: Array, evaluate: Callable) -> Array:
	var rows = map_data.size()
	var cols = map_data[0].size() if rows > 0 else 0
	var max_depth = (min(rows, cols) - 1) / 2
	var valid_rings = []
	for d in range(max_depth + 1):
		var ring = []
		for r in range(rows):
			for c in range(cols):
				if min(r, c, rows - 1 - r, cols - 1 - c) == d:
					ring.append(map_data[r][c])
		for v in ring:
			if evaluate.call(v):
				valid_rings.append(ring)
				break
	if depth < valid_rings.size():
		for v in valid_rings[depth]:
			if not evaluate.call(v):
				valid_rings[depth].erase(v)
		return valid_rings[depth]
	return []


func is_not_destroyed_and_ground(cell: Vector2) -> bool:
	if cell in destroyed_tiles or cell in _warned_tiles:
		return false
	var tile_data = tilemap.get_cell_tile_data(cell)
	return tile_data != null and tile_data.get_custom_data("ground")


func destroy_tile_in_ring(ring: Array) -> void:
	if ring.size() == 0:
		return
	var chosen: Vector2 = ring[randi() % ring.size()]

	var sprite := Sprite2D.new()
	sprite.texture = TILE_CRUMBLING
	sprite.hframes = 4
	sprite.frame = 0
	sprite.global_position = tilemap.to_global(tilemap.map_to_local(Vector2i(chosen)))
	sprite.z_index = 3
	add_child(sprite)
	_warned_tiles[chosen] = sprite
	create_tween().tween_property(sprite, "frame", 3, 1.5).from(0)

	var remaining = ring.filter(func(t): return not t in destroyed_tiles and not t in _warned_tiles)
	if remaining.size() == 0:
		destroyed_rings += 1
		if destroyed_rings >= max_destroyed_rings:
			destruction_complete = true

	await get_tree().create_timer(1.5).timeout
	if not is_instance_valid(self):
		return
	tilemap.set_cells_terrain_connect([chosen], 0, 1, false)
	destroyed_tiles[chosen] = true
	_warned_tiles.erase(chosen)
	if is_instance_valid(sprite):
		sprite.queue_free()


func get_cell_ring_depth(cell: Vector2, min_x: int, min_y: int, max_x: int, max_y: int) -> int:
	return min(int(cell.y) - min_y, int(cell.x) - min_x, max_y - int(cell.y), max_x - int(cell.x))


func destroy_random_tile() -> void:
	var map_data = tilemap.get_used_cells()
	var min_x = int(room_top_left_offset.x)
	var min_y = int(room_top_left_offset.y)
	var max_x = 0
	var max_y = 0
	for cell in map_data:
		if cell.x > max_x: max_x = cell.x
		if cell.y > max_y: max_y = cell.y
	var map_data_2d: Array = []
	for y in range(min_y, max_y + 1):
		var row = []
		for x in range(min_x, max_x + 1):
			row.append(Vector2(x, y))
		map_data_2d.append(row)

	var touched_ring_depths = {}
	for tile in destroyed_tiles.keys():
		touched_ring_depths[get_cell_ring_depth(tile, min_x, min_y, max_x, max_y)] = true

	var rings = []
	var ring_depths = []
	for i in range(destroy_radius):
		var ring = get_ring(i, map_data_2d, Callable(self, "is_not_destroyed_and_ground"))
		if ring.size() > 0:
			rings.append(ring)
			ring_depths.append(get_cell_ring_depth(ring[0], min_x, min_y, max_x, max_y))

	if touched_ring_depths.size() >= max_destroyed_rings:
		rings = rings.filter(func(r): return ring_depths[rings.find(r)] in touched_ring_depths)

	if rings.size() == 0:
		destruction_complete = true
		return

	var randint = randi() % 100
	var base_rate = 50
	var snd_rate = base_rate / 2
	if (randint <= base_rate) or rings.size() == 1:
		destroy_tile_in_ring(rings[0])
		return
	var ring_index = 1
	while (randint > base_rate + snd_rate) and ring_index < rings.size() - 1:
		ring_index += 1
		snd_rate += base_rate / 2
	destroy_tile_in_ring(rings[ring_index])


func get_bullet_contained():
	return bullets

func get_player():
	return player

func start_level():
	pass
