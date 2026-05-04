extends Node2D
class_name IWorkStation


@export var station_texture: Texture2D
@export var interaction_time: float = 3.0
@export var interaction_radius: float = 150.0
@export var reset_on_exit: bool = false

var _progress: float = 0.0
var _player_inside: bool = false


func complete() -> void:
	push_error("IWorkStation: complete() not implemented")
