extends Sprite2D

@onready var anim = $AnimatedSprite2D
@onready var exhaust_creat_point = $ExhaustCreatePoint
@onready var timer = $ExhaustTimer

var exhaust_scene = preload("res://scenes/main-scene/ExhaustScene.tscn")
var aim_position:Vector2

#初始化
func _ready():
	print(GlobalManage.get_time(),"[主场景]咖波汽车已加载")
	timer.start(0.5)
	aim_position = Vector2.ZERO

#尾气释放
func _on_exhaust_timer_timeout() -> void:
	var exhaust = exhaust_scene.instantiate()
	exhaust_creat_point.add_child(exhaust)

#更改目标位置
func change_position(input_position):
	aim_position = input_position
	print(GlobalManage.get_time(),"[主场景]已将汽车目标位置设置为:",aim_position)

#更改位置
func _process(delta: float) -> void:
	if position != aim_position:
		position = position.lerp(aim_position,delta)
		if (aim_position - position).length() < 1:
			position = aim_position
