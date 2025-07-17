extends Control
signal play_finish

#咖波汽车
@onready var capoo_car = %CapooCar
@onready var car_wait_point = %CarWaitPoint
@onready var car_enter_point = %CarEnterPoint

#UI
@onready var UI = %UI
@onready var continue_button = %Continue
@onready var main_menu = %MainEnum
@onready var main_list = %MainList
@onready var message_window = %MessageWindow
@onready var enter_button = %EnterButton
@onready var cancel_button = %CancelButton

@onready var music = %BackGroundMusic

#场景预载
const level_select_scene := preload("res://scenes/main-scene/LevelSelectScene.tscn")
const setting_scene := preload("res://scenes/global-scene/SettingScene.tscn")
const about_scene := preload("res://scenes/main-scene/AboutScene.tscn")

var level := {
	"Capoo Dodge":load("res://scenes/levels/capoo-dodge/CapooDodge.tscn")
}

#预处理
func _ready():
	print(GlobalManage.get_time(),"[主场景]已加载主场景")
	capoo_car.change_position(car_wait_point.position)

	#给所有控件设定动画初值
	main_menu.scale = Vector2(1.0,0)
	main_menu.show()
	message_window.scale = Vector2.ZERO
	message_window.hide()
	cancel_button.scale = Vector2.ZERO
	enter_button.scale = Vector2.ZERO
	for child in main_list.get_children():
		var button = child.get_child(0)
		button.scale = Vector2.ZERO

	play_enter_animation()

	music.volume_linear = GlobalData.game_data["setting"]["music_volume"]
	music.play()

# 主菜单入场动画
func play_enter_animation() -> void:
	print(GlobalManage.get_time(),"[主场景]播放主菜单入场动画")
	AudioManage.play_sound("ui-pop")
	
	if GlobalData.game_data["progress"]["level"]:
		continue_button.show()
	else:
		continue_button.hide()
	
	var tween = create_tween()
	tween.tween_property(main_menu, "scale", Vector2(1.0, 1.0), 0.3)
	await tween.finished
	
	for child in  main_list.get_children():
		var button = child.get_child(0)
		if button.is_visible_in_tree:
			var button_tween = create_tween()
			button_tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
			button_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
			await get_tree().create_timer(0.1).timeout

# 主菜单出场动画
func play_exit_animation() -> void:
	print(GlobalManage.get_time(),"[主场景]播放主菜单出场动画")
	var children = main_list.get_children()
	children = children.duplicate()
	children.reverse()
	
	for child in children:
		var button = child.get_child(0)
		if button.is_visible_in_tree:
			var button_tween = create_tween()
			button_tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
			button_tween.tween_property(button, "scale", Vector2.ZERO, 0.1)
			await get_tree().create_timer(0.1).timeout
	
	await get_tree().create_timer(0.1).timeout
	var menu_tween = create_tween()
	menu_tween.tween_property(main_menu, "scale", Vector2(1.0, 0), 0.3)
	await menu_tween.finished
	play_finish.emit()

#开始游戏按钮信号
func _on_start_button_pressed() -> void:
	print(GlobalManage.get_time(),"[主场景]接受到开始游戏按钮信号")
	AudioManage.play_sound("ui-click")
	play_exit_animation()
	await play_finish
	if GlobalData.game_data["progress"]["level"]:
		message_window.show()
		AudioManage.play_sound("ui-warning")
		var tween = create_tween()
		tween.tween_property(message_window,"scale",Vector2(1.1,1.1),0.1)
		tween.tween_property(message_window,"scale",Vector2(1.0,1.0),0.1)
		tween.tween_property(cancel_button,"scale",Vector2(1.1,1.1),0.1)
		tween.tween_property(cancel_button,"scale",Vector2(1.0,1.0),0.1)
		tween.tween_property(enter_button,"scale",Vector2(1.1,1.1),0.1)
		tween.tween_property(enter_button,"scale",Vector2(1.0,1.0),0.1)
	else:
		open_level_select()

#消息弹窗-取消
func _on_cancel_button_pressed() -> void:
	AudioManage.play_sound("ui-click")
	print(GlobalManage.get_time(),"[主场景]取消了存档覆盖")
	var tween = create_tween()
	tween.tween_property(message_window,"scale",Vector2(1.1,1.1),0.1)
	tween.tween_property(message_window,"scale",Vector2.ZERO,0.1)
	await tween.finished
	cancel_button.scale = Vector2.ZERO
	enter_button.scale = Vector2.ZERO
	play_enter_animation()

#消息弹窗-确定
func _on_enter_button_pressed() -> void:
	AudioManage.play_sound("ui-click")
	print(GlobalManage.get_time(),"[主场景]确定了存档覆盖")
	GlobalData.game_data["progress"] = {
		"level":null,
		"level_progress":null,
	}
	GlobalData.save_data()
	
	var tween = create_tween()
	tween.tween_property(message_window,"scale",Vector2(1.1,1.1),0.1)
	tween.tween_property(message_window,"scale",Vector2.ZERO,0.1)
	
	await tween.finished
	cancel_button.scale = Vector2.ZERO
	enter_button.scale = Vector2.ZERO
	open_level_select()

#继续游戏按钮
func _on_continue_button_pressed() -> void:
	var game_progress = GlobalData.game_data["progress"]
	print(GlobalManage.get_time(),"[主场景]继续游戏：",game_progress)
	GlobalManage.play_transition()
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(level[game_progress["level"]])

#打开关卡选择页面
func open_level_select() -> void:
	print(GlobalManage.get_time(),"[主场景]打开场景：关卡选择")
	var level_select = level_select_scene.instantiate()
	add_child(level_select)
	level_select.enter_level.connect(_on_car_enter_level)
	
	await  level_select.exit
	play_enter_animation()

#设置页面按钮信号
func _on_setting_button_pressed() -> void:
	AudioManage.play_sound("ui-click")
	print(GlobalManage.get_time(),"[主场景]打开场景：设置")
	play_exit_animation()
	await play_finish
	var setting = setting_scene.instantiate()
	add_child(setting)
	setting.updata_volume.connect(_on_updata_music_volume)
	
	await setting.exit
	play_enter_animation()

#关于按钮信号
func _on_about_button_pressed() -> void:
	AudioManage.play_sound("ui-click")
	print(GlobalManage.get_time(),"[主场景]打开场景：关于")
	play_exit_animation()
	await play_finish
	var about = about_scene.instantiate()
	add_child(about)
	
	await about.exit
	play_enter_animation()

#测试按钮信号
func _on_test_button_pressed() -> void:
	UI.play_start_animation(true)

#进入关卡时改变汽车位置
func _on_car_enter_level() -> void:
	capoo_car.change_position(car_enter_point.position)

#更新音乐音量
func _on_updata_music_volume(volume) -> void:
	music.volume_linear = volume

#循环播放音乐
func _on_back_ground_music_finished() -> void:
	music.play()
