extends IWorkStation


@onready var _sprite: Sprite2D = $Sprite2D
@onready var _zone: Area2D = $InteractionZone
@onready var _bar: Node2D = $ProgressBarNode


func _ready() -> void:
	if station_texture:
		_sprite.texture = station_texture

	var shape := CircleShape2D.new()
	shape.radius = interaction_radius
	$InteractionZone/InteractionCollision.shape = shape

	_bar.visible = false
	_zone.body_entered.connect(_on_body_entered)
	_zone.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if not _player_inside:
		_progress -= delta / interaction_time
		_progress = maxf(_progress, 0.0)
		_bar.set_value(_progress)
		if _progress <= 0.0:
			_bar.visible = false
		return
	_progress = minf(_progress + delta / interaction_time, 1.0)
	_bar.set_value(_progress)
	if _progress >= 1.0:
		complete()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		_bar.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		if reset_on_exit:
			_progress = 0.0
			_bar.set_value(0.0)


func complete() -> void:
	queue_free()
