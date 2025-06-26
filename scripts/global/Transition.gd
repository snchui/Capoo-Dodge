extends Node

@onready var control = %Control
@onready var back_color = %BackColor
@onready var main_ground = %MainGround
@onready var progress_bar = %TextureProgressBar
@onready var progress_label = %ProgressLabel
@onready var capoo = %Capoo

var animation:String

func _ready() -> void:
	back_color.modulate.a = 0
	main_ground.modulate.a = 0
	animation = "animation" + str(int(randi() % 4))
	capoo.animation = animation
	progress_bar.value = 0
	
	var tween = create_tween()
	tween.tween_property(back_color,"modulate:a",1.0,0.9)
	tween.tween_property(main_ground,"modulate:a",1.0,0.1)
	tween.parallel().tween_property(progress_bar,"value",34,0.1)
	tween.parallel().tween_callback(func():capoo.play())
	tween.tween_interval(0.7)
	tween.tween_property(progress_bar,"value",72,0.2)
	tween.tween_property(progress_bar,"value",100,0.5)
	tween.tween_property(control,"modulate:a",0,0.5)
	tween.parallel().tween_property(capoo,"modulate:a",0,0.3)
	tween.tween_callback(queue_free)

func _process(_delta: float) -> void:
	progress_label.text = str(int(round(progress_bar.value))) + "%"
