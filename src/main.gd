extends Node2D
@export var level_scene: PackedScene 
@export var levels: Array[PackedScene]
var current_Level: ILevel

func _ready():
	load_level(level_scene)

func _process(delta):
	pass


func load_level(scene: PackedScene):
	if current_Level:
		current_Level.queue_free()
	current_Level = scene.instantiate()
	add_child(current_Level)
