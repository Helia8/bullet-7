extends ILevel

@onready var bullets = $Bullets
@onready var player = $Entities/PlayerCharacter
@onready var tilemap: TileMapLayer = $Environment/TileMapLayer
@export var destruction_time_range: Vector2 = Vector2(0.0, 0.10)
@export var tile_destruction_time: float = 0.0
@export var room_x : int = 16
@export var room_y : int = 11
@export var destroy_radius: int = 3
@onready var room_center = Vector2(room_x / 2.0, room_y / 2.0)
@export var room_top_left_offset: Vector2 = Vector2(20,40)
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for entity in $Entities.get_children():
		if entity is IEnnemy:
			print("setting bullet container for ", entity.name)
			entity.set_bullet_container(bullets)


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	if (cell in destroyed_tiles):
		return false
	var tile_data = tilemap.get_cell_tile_data(cell)
	var a  = tile_data and  tile_data.get_custom_data("ground")
	if a:
		return true
	return false

	

func destroy_tile_in_ring(ring: Array) -> void:
	if ring.size() == 0:
		return
	var tile_to_destroy = [ring[randi() % ring.size()]]
	tilemap.set_cells_terrain_connect(tile_to_destroy, 0, 1, false)
	for tile in tile_to_destroy:
		destroyed_tiles[tile] = true
	var non_destroyed_tiles_in_ring = []
	for tile in ring:
		if not tile in destroyed_tiles:
			non_destroyed_tiles_in_ring.append(tile)
	if non_destroyed_tiles_in_ring.size() == 0:
		destroyed_rings += 1
		if destroyed_rings >= max_destroyed_rings:
			destruction_complete = true
			print("destruction complete")
		else:
			print("ring destroyed, ", max_destroyed_rings - destroyed_rings, " rings left")

func get_cell_ring_depth(cell: Vector2, min_x: int, min_y: int, max_x: int, max_y: int) -> int:
	return min(int(cell.y) - min_y, int(cell.x) - min_x, max_y - int(cell.y), max_x - int(cell.x))

func destroy_random_tile() -> void:
	var map_data = tilemap.get_used_cells()
	var min_x = int(room_top_left_offset.x)
	var min_y = int(room_top_left_offset.y)
	var max_x = 0
	var max_y = 0
	for cell in map_data:
		if cell.x > max_x:
			max_x = cell.x
		if cell.y > max_y:
			max_y = cell.y
	var map_data_2d = []
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
		var filtered_rings = []
		for i in range(rings.size()):
			if ring_depths[i] in touched_ring_depths:
				filtered_rings.append(rings[i])
		rings = filtered_rings

	if rings.size() == 0:
		destruction_complete = true
		print("destruction complete")
		return
	#base 50%, dividide by 2 based on radius size <- bleh fix
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
	print("level 1 started")
	pass
