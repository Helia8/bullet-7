extends Area2D

@export var closed_texture: Texture2D
@export var open_texture: Texture2D
@export var next_level: PackedScene

var _is_open: bool = false

@onready var _closed_sprite: Sprite2D = $ClosedSprite
@onready var _open_sprite: Sprite2D = $OpenSprite


func _ready() -> void:
	if closed_texture:
		_closed_sprite.texture = closed_texture
	if open_texture:
		_open_sprite.texture = open_texture
	_open_sprite.visible = false
	body_entered.connect(_on_body_entered)


func _process(_delta: float) -> void:
	var no_enemies = get_tree().get_nodes_in_group("enemies").is_empty()
	if no_enemies != _is_open:
		_is_open = no_enemies
		_closed_sprite.visible = not _is_open
		_open_sprite.visible = _is_open


func _on_body_entered(body: Node2D) -> void:
	if not _is_open:
		return
	if body.is_in_group("player"):
		_go_to_next_level()


func _go_to_next_level() -> void:
	if next_level == null:
		return
	var main = get_tree().get_first_node_in_group("main")
	if main:
		main.load_level(next_level)
