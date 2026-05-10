extends CanvasLayer

# Populate these arrays in the Inspector (index = HP value: 0=dead … 5=full)
@export var hp_textures: Array[Texture2D] = []
# Populate in Inspector (index = rooms cleared: 0=none, 1, 2, 3)
@export var xp_textures: Array[Texture2D] = []

@onready var hp_sprite: Sprite2D = $HP/HpSprite
@onready var xp_sprite: Sprite2D = $XP/XpSprite
@onready var gold_label: Label = $Gold/GoldLabel
@onready var kills_label: Label = $Quota/KillsLabel
@onready var jobs_label: Label = $Quota/JobsLabel
@onready var quota_label: Label = $Quota/QuotaLabel

var _kills: int = 0
var _jobs: int = 0


func _ready() -> void:
	add_to_group("hud")


func update_hp(current_hp: int) -> void:
	var idx = clamp(current_hp, 0, hp_textures.size() - 1)
	if hp_textures.size() > 0:
		hp_sprite.texture = hp_textures[idx]


func update_xp(xp_state: int) -> void:
	var idx = clamp(xp_state, 0, xp_textures.size() - 1)
	if xp_textures.size() > 0:
		xp_sprite.texture = xp_textures[idx]


func update_gold(amount: int) -> void:
	gold_label.text = "$ %d" % amount


func add_kill() -> void:
	_kills += 1
	_refresh_quota()


func add_job() -> void:
	_jobs += 1
	_refresh_quota()


func get_kills() -> int:
	return _kills

func get_jobs() -> int:
	return _jobs


func reset_room_counters() -> void:
	_kills = 0
	_jobs = 0
	_refresh_quota()


func _refresh_quota() -> void:
	kills_label.text = "Kills: %d" % _kills
	jobs_label.text = "Jobs: %d" % _jobs
	var quota = (_jobs * 3) - _kills
	quota_label.text = "Quota: %d" % quota
