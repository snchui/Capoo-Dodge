extends Node
signal exit
signal enter_level
signal play_finished

@onready var level_select_canvas = %LevelSelectCanvas
@onready var level_select_main = %LevelSelectMain
@onready var level_select_label = %LevelSelectLabel
@onready var return_button = %ReturnButton
@onready var animation_node2D = %AnimationNode2D

var capoo_dodge_scene = load("res://scenes/levels/capoo-dodge/CapooDodge.tscn")

#初始化
func _ready() -> void:
	print(GlobalManage.get_time(),"[关卡选择]场景已载入")
	level_select_canvas.scale = Vector2(1.0,0)
	level_select_main.scale = Vector2(1.0,0)
	level_select_label.modulate.a = 0
	return_button.scale = Vector2.ZERO
	animation_node2D.hide()
	
	AudioManage.play_sound("ui-pop")
	var tween = create_tween()
	tween.tween_property(level_select_canvas,"scale",Vector2(1.0,1.0),0.3)
	tween.tween_property(level_select_main,"scale",Vector2(1.0,1.0),0.2)
	tween.tween_callback(animation_node2D.show)
	tween.tween_property(level_select_label,"modulate:a",1.0,0.1)
	tween.parallel().tween_property(return_button,"scale",Vector2(1.1,1.1),0.1)
	tween.tween_property(return_button,"scale",Vector2(1.0,1.0),0.1)

#出场动画
func play_exit_animation() -> void:
	print(GlobalManage.get_time(),"[关卡选择]开始播放出场动画")
	var tween = create_tween()
	tween.tween_property(return_button,"scale",Vector2(1.1,1.1),0.1)
	tween.tween_property(return_button,"scale",Vector2.ZERO,0.1)
	tween.parallel().tween_property(level_select_label,"modulate:a",0,0.1)
	tween.tween_callback(animation_node2D.hide)
	tween.tween_property(level_select_main,"scale",Vector2(1.0,0),0.2)
	tween.tween_property(level_select_canvas,"scale",Vector2(1.0,0),0.3)
	tween.tween_callback(func():play_finished.emit())

#返回按钮
func _on_return_button_pressed() -> void:
	AudioManage.play_sound("ui-click")
	print(GlobalManage.get_time(),"[关卡选择]接受到返回按钮号")
	play_exit_animation()
	await play_finished
	exit.emit()
	print(GlobalManage.get_time(),"[关卡选择]已发送退出信号")
	queue_free()

#关卡1-Capoo Dodge
func _on_level_1_pressed() -> void:
	AudioManage.play_sound("ui-click")
	print(GlobalManage.get_time(),"[关卡选择]准备加载关卡1")
	play_exit_animation()
	await play_finished
	enter_level.emit()
	GlobalManage.play_transition()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(capoo_dodge_scene)
