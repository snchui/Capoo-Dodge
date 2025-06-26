extends Sprite2D

@onready var anim = $AnimatedSprite2D

func _ready():
	var tween = create_tween()
	tween.tween_property(self,"position:x",position.x - 500,2.0)
	await anim.animation_finished
	queue_free()
