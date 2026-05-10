extends Area2D

@export var closed_texture: Texture2D
@export var open_texture: Texture2D
@export var next_level: PackedScene

var _is_open: bool = false

@onready var _closed_sprite: Sprite2D = $ClosedSprite
@onready var _open_sprite: Sprite2D = $OpenSprite


func _ready() -> void:
	add_to_group("door")
	if closed_texture:
		_closed_sprite.texture = closed_texture
	if open_texture:
		_open_sprite.texture = open_texture
	_open_sprite.visible = false
	body_entered.connect(_on_body_entered)


func open() -> void:
	if _is_open:
		return
	_is_open = true
	_closed_sprite.visible = false
	_open_sprite.visible = true


func _on_body_entered(body: Node2D) -> void:
	if not _is_open:
		return
	if body.is_in_group("player"):
		_go_to_next_level()


func _go_to_next_level() -> void:
	var main = get_tree().get_first_node_in_group("main")
	if not main:
		return
	if next_level == null:
		main.show_win_screen()
	else:
		main.load_level(next_level)
