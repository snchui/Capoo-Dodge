extends Node

#信息栏
@onready var health_progress = %HealthProgressBar
@onready var health_label = %HealthLabel
@onready var space_progress = %SpaceProgressBar
@onready var space_label = %SpaceLabel
@onready var level_progress_label = %LevelProgressLabel

#选项菜单
@onready var option = %UI_Option
@onready var option_back_color = %OptionBackColor
@onready var option_list = %OptionList

#游戏结束窗口
@onready var gameover_window = %UI_DeathWindow
@onready var gameove_subtitle = %GameOverSubTitle
@onready var gameover_animation = %GameOverAnimation
@onready var gamepass_window = %UI_GamePassWindow

#视频播放
@onready var video_canvas = %VideoPlayer
@onready var video_player = %VideoStreamPlayer
@onready var transition_color = %TransitionColor
@onready var jump_button = %JumpButton
@onready var current_timer = %ButtonCureentTimer

#音乐播放
@onready var music_player = %BackgroundMusicPlayer

#预载场景
var game_scene = load("res://scenes/levels/capoo-dodge/CapooDodge.tscn")
var setting_scene = load("res://scenes/global-scene/SettingScene.tscn")
var main_scene = load("res://scenes/main-scene/MainScene.tscn")

var player_health:float = 100.0
var space_progress_bar_load:bool = true

var gameover_text = [
	"咖波坏掉惹……",
	"坏坏的猫猫蚊……",
	"从此，咖波不再爱夏天和大西瓜……",
	"咖波碎掉惹……",
	"怎么能欺负猫猫虫……",
	"咖波讨厌猫猫蚊……",
]

var gameover_anim = [
	"cry-start",
	"irriable",
]

var video = {
	"video1":load("res://assets/video/video1.ogv"),
	"video2":load("res://assets/video/video2.ogv"),
	"video3":load("res://assets/video/video3.ogv"),
	"video4":load("res://assets/video/video4.ogv"),
	"video5":load("res://assets/video/video5.ogv"),
	"video6":load("res://assets/video/video6.ogv")
}

var music_resource = {
	"bgm-0":load("res://assets/audio_music/bgm-0.ogg"),
	"bgm-1":load("res://assets/audio_music/bgm-1.ogg"),
	"bgm-2":load("res://assets/audio_music/bgm-2.ogg")
}

#初始化
func _ready() -> void:
	health_progress.value = 0
	space_progress.value = 0
	
	option.hide()
	option_back_color.modulate.a = 0
	option_list.scale = Vector2.ZERO
	gameover_window.scale = Vector2.ZERO
	
	transition_color.modulate.a = 0
	video_canvas.hide()
	video_player.hide()
	jump_button.hide()
	gamepass_window.hide()
	level_progress_label.text = "关卡进度：{level_progress}   流程进度：0%".format({"level_progress":GlobalData.game_data["progress"]["level_progress"]})

#血量变化
func _on_player_updata_health(health:float) -> void:
	player_health = health

#更新
func _process(delta: float) -> void:
	health_label.text = "{health}%".format({"health":int(round(health_progress.value))})
	space_label.text = "{cooldown}%".format({"cooldown":int(round(space_progress.value))})

	#技能条加载动画
	if space_progress_bar_load:
		space_progress.value = lerpf(space_progress.value,space_progress.max_value,delta * 3)

	#血量条变化
	if health_progress.value != player_health:
		health_progress.value = lerpf(health_progress.value,player_health,delta * 3)
		if abs(health_progress.value - player_health) < 0.5:
			health_progress.value = player_health

#弹出选项菜单
func _on_option_button_pressed() -> void:
	print(GlobalManage.get_time(),"[UI-选项]弹出选项菜单栏")
	AudioManage.play_sound("ui-click")
	option.show()
	get_tree().paused = true
	
	var tween = create_tween()
	tween.tween_property(option_back_color,"modulate:a",1.0,0.3)
	tween.parallel().tween_property(option_list,"scale",Vector2(1.0,1.0),0.1)

#继续游戏按钮
func _on_continue_button_pressed() -> void:
	print(GlobalManage.get_time(),"[UI-选项]关闭选项菜单栏")
	AudioManage.play_sound("ui-click")
	get_tree().paused = false
	
	var tween = create_tween()
	tween.tween_property(option_back_color,"modulate:a",0,0.3)
	tween.parallel().tween_property(option_list,"scale",Vector2.ZERO,0.1)
	
	await tween.finished
	option.hide()

#游戏设置按钮
func _on_setting_button_pressed() -> void:
	print(GlobalManage.get_time(),"[UI-选项]打开设置页面")
	AudioManage.play_sound("ui-click")
	
	var enter_tween = create_tween()
	enter_tween.tween_property(option_back_color,"modulate:a",0,0.3)
	enter_tween.parallel().tween_property(option_list,"scale",Vector2.ZERO,0.1)
	
	await enter_tween.finished
	var setting = setting_scene.instantiate()
	add_child(setting)
	setting.updata_volume.connect(_on_music_volume_change)
	
	await setting.exit
	var exit_tween = create_tween()
	exit_tween.tween_property(option_back_color,"modulate:a",1.0,0.3)
	exit_tween.parallel().tween_property(option_list,"scale",Vector2(1.0,1.0),0.1)

#退出游戏按钮
func _on_exit_button_pressed() -> void:
	print(GlobalManage.get_time(),"[UI]退出游戏")
	AudioManage.play_sound("ui-click")
	get_tree().paused = false
	GlobalManage.play_transition()
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_packed(main_scene)

#重置游戏按钮
func _on_reset_button_pressed() -> void:
	print(GlobalManage.get_time(),"[UI]重置游戏")
	AudioManage.play_sound("ui-click")
	get_tree().paused = false
	GlobalManage.play_transition()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(game_scene)

#玩家死亡信号
func _on_player_death() -> void:
	print(GlobalManage.get_time(),"[UI-游戏结束]弹出游戏结束窗口")
	
	gameover_window.show()
	gameove_subtitle.text = gameover_text.pick_random()
	gameover_animation.animation = gameover_anim.pick_random()
	gameover_animation.play()
	
	AudioManage.play_sound("ui-warning")
	var tween = create_tween()
	tween.tween_property(gameover_window,"scale",Vector2(1.1,1.1),0.1)
	tween.tween_property(gameover_window,"scale",Vector2(1.0,1.0),0.1)
	
	if gameover_animation.animation == "cry-start":
		await gameover_animation.animation_finished
		gameover_animation.play("cry-current")

#技能使用信号
func _on_player_space_skill() -> void:
	var tween = create_tween()
	tween.tween_property(space_progress,"value",0,1.0)
	tween.tween_property(space_progress,"value",100.0,5.0)

#视频播放
func play_video(video_name:String) -> void:
	if not GlobalData.game_data["play_state"]["Capoo_Dodge"][video_name] or not GlobalData.game_data["setting"]["animation_jump"]:
		GlobalData.game_data["play_state"]["Capoo_Dodge"][video_name] = true
		GlobalData.save_data()
		
		print(GlobalManage.get_time(),"[场景]播放视频：",video_name)
		video_canvas.show()
		
		var tween = create_tween()
		tween.tween_property(transition_color,"modulate:a",1.0,1.0)
		
		await tween.finished
		video_player.paused = false
		video_player.show()
		video_player.stream = video[video_name]
		video_player.play()
		
		await video_player.finished
	else:
		video_canvas.show()
		var tween = create_tween()
		tween.tween_property(transition_color,"modulate:a",1.0,1.0)
		tween.tween_property(transition_color,"modulate:a",0,1.0)
		tween.tween_callback(func():video_canvas.hide())

#动画播放结束
func video_play_finished() -> void:
	print(GlobalManage.get_time(),"[场景]视频播放完成")
	video_player.hide()
	var tween = create_tween()
	tween.tween_property(transition_color,"modulate:a",0,1.0)
	await tween.finished
	video_canvas.hide()

#动画跳过按钮显示
func _on_show_jump_button_pressed() -> void:
	if video_player.is_playing():
		current_timer.start()
		jump_button.show()

#隐藏跳过动画按钮
func _on_button_cureent_timer_timeout() -> void:
	jump_button.hide()

#跳过动画
func _on_jump_animation_button_pressed() -> void:
	video_player.paused = true
	video_player.finished.emit()

#更新关卡进度标签
func update_level_progress_label(progress:int) -> void:
	level_progress_label.text = "关卡进度：{level_progress}   流程进度：{progress}%".format({
		"level_progress":GlobalData.game_data["progress"]["level_progress"],
		"progress":progress
		})

#音乐播放
func music_play(music:String) -> void:
	music_player.stream = music_resource[music]
	music_player.volume_linear = GlobalData.game_data["setting"]["music_volume"]
	await get_tree().create_timer(2.0).timeout
	music_player.play()

#音乐循环
func _on_background_music_player_finished() -> void:
	music_player.play()

#音乐音量调整
func _on_music_volume_change(volume:float) -> void:
	music_player.volume_linear = volume

#音乐停止
func music_stop() -> void:
	var tween = create_tween()
	tween.tween_property(music_player,"volume_linear",0,1.0)
	await tween.finished
	music_player.stop()

func show_game_pass_window() -> void:
	gamepass_window.show()
