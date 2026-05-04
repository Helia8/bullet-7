extends Node2D

var value: float = 0.0
@export var bar_width: float = 120.0
@export var bar_height: float = 12.0


func _draw() -> void:
	var x := -bar_width / 2.0
	draw_rect(Rect2(x, 0.0, bar_width, bar_height), Color(0.15, 0.15, 0.15, 0.85))
	if value > 0.0:
		draw_rect(Rect2(x, 0.0, bar_width * value, bar_height), Color(0.2, 0.85, 0.2))


func set_value(new_value: float) -> void:
	value = clamp(new_value, 0.0, 1.0)
	queue_redraw()
