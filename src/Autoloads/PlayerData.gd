extends Node

var health: int = 5
var max_health: int = 5
var gold: int = 0
var xp: int = 0
var fire_rate: float = 1.0
var level_index: int = 0

func reset() -> void:
	health = max_health
	gold = 0
	xp = 0
	fire_rate = 1.0
	level_index = 0

func save_from_player(p: Node) -> void:
	health = p.health
	gold = p.gold
	fire_rate = p.fire_rate

func apply_to_player(p: Node) -> void:
	p.health = health
	p.max_health = max_health
	p.gold = gold
	p.fire_rate = fire_rate
