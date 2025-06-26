extends Node
signal exit

@onready var about_menu = %AboutEnum
@onready var about_main = %AboutMain
@onready var about_version = %AboutVersion
@onready var about_return_button = %AboutReturnButton
@onready var about_label = %AboutGame
@onready var credit_label = %CreditList
@onready var update_label = %UpdataLog

func _ready() -> void:
	about_menu.scale = Vector2(1.0,0)
	about_main.scale = Vector2(1.0,0)
	about_version.modulate.a = 0
	about_return_button.scale = Vector2.ZERO
	play_enter_animation()

#关于页面动画播放
func play_enter_animation() -> void:
	print(GlobalManage.get_time(),"[主场景-UI]开始播放关于页面入场动画")
	AudioManage.play_sound("ui-pop")
	var tween = create_tween()
	tween.tween_property(about_menu,"scale",Vector2(1.0,1.0),0.3)
	tween.tween_property(about_main,"scale",Vector2(1.0,1.0),0.2)
	tween.tween_property(about_return_button,"scale",Vector2(1.1,1.1),0.1)
	tween.parallel().tween_property(about_version,"modulate:a",1.0,0.1)
	tween.tween_property(about_return_button,"scale",Vector2(1.0,1.0),0.1)

#退出按钮信号
func play_exit_animation() -> void:
	AudioManage.play_sound("ui-click")
	print(GlobalManage.get_time(),"[主场景-UI]开始播放关于页面出场动画")
	var tween = create_tween()
	tween.tween_property(about_return_button,"scale",Vector2(1.1,1.1),0.1)
	tween.tween_property(about_return_button,"scale",Vector2.ZERO,0.1)
	tween.parallel().tween_property(about_version,"modulate:a",0,0.1)
	tween.tween_property(about_main,"scale",Vector2(1.0,0),0.2)
	tween.tween_property(about_menu,"scale",Vector2(1.0,0),0.3)
	await tween.finished
	exit.emit()
	print(GlobalManage.get_time(),"[关于]已发送退出信号")
	queue_free()

#关于页面切换选项卡
func _on_tab_bar_tab_changed(tab: int) -> void:
	AudioManage.play_sound("ui-page")
	print(GlobalManage.get_time(),"[关于]切换到页面：",tab)
	match tab:
		0:
			about_label.show()
			credit_label.hide()
			update_label.hide()
		1:
			about_label.hide()
			credit_label.show()
			update_label.hide()
		2:
			about_label.hide()
			credit_label.hide()
			update_label.show()
		_:
			push_error(GlobalManage.get_time(),"[主场景-UI]意外的选项卡切换索引")
