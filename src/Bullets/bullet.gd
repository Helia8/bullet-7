extends Area2D

enum BulletType { 
	PLAYER,
	ENEMY 
	}

enum CollisionLayers {
	PLAYER = 1,
	HOSTILE = 2,
	PLAYER_BULLET = 4,
	WALLS = 8,
	ENEMY_BULLET = 16
}
var direction := Vector2.ZERO
var lifetime := 300
var speed := 500
var damage := 1
var bullet_type: BulletType = BulletType.PLAYER
@export var bullet_textures: Array[Texture2D]


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if bullet_type == BulletType.PLAYER:
		# is player bullet
		collision_layer = CollisionLayers.PLAYER_BULLET
		# can hit ennemies and walls
		collision_mask = CollisionLayers.HOSTILE | CollisionLayers.WALLS
	else:
		# is ennemy bullet
		collision_layer = CollisionLayers.ENEMY_BULLET
		# can hit player and walls
		collision_mask = CollisionLayers.PLAYER | CollisionLayers.WALLS
	if not bullet_textures.is_empty():
		var new_bullet = Sprite2D.new()
		new_bullet.texture = bullet_textures[randi() % bullet_textures.size()]
		add_child(new_bullet)

func _on_body_entered(body: Node2D) -> void:
	# extra checks just in case i messed up the masks 
	if body is IEnnemy:
		body.hit(damage)
	elif body.is_in_group("player"):
		body.hit(damage)
	queue_free()


func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
