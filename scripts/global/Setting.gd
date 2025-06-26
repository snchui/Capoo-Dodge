extends Node
signal exit
signal updata_volume(volume:float)

# 主控件
@onready var setting_enum = %SettingEnum
@onready var setting_list = %SettingList
@onready var setting_label = %SettingLabel
@onready var reset_button = %ResetButton
@onready var save_button = %SaveButton
@onready var return_button = %ReturnButton

#音量值文本
@onready var music_tabel = %MusicVolumeTable
@onready var sound_tabel = %SoundVolumeTabel

# 设置选项控件
@onready var attack_lock = %AttackLock
@onready var animation_jump = %AnimationJump
@onready var music_volume = %MusicVolume
@onready var sound_volume = %SoundVolume

func _ready() -> void:
	print(GlobalManage.get_time(), "[设置]场景已加载")
	
	# 设置所有控件的动画初值
	setting_enum.scale = Vector2(1.0, 0)
	setting_list.scale = Vector2(1.0, 0)
	setting_label.modulate.a = 0
	reset_button.scale = Vector2.ZERO
	save_button.scale = Vector2.ZERO
	return_button.scale = Vector2.ZERO
	
	# 读取配置
	load_setting()
	
	# 播放入场动画
	AudioManage.play_sound("ui-pop")
	var tween = create_tween()
	tween.tween_property(setting_enum, "scale", Vector2(1.0, 1.0), 0.3)
	tween.tween_property(setting_list, "scale", Vector2(1.0, 1.0), 0.2)
	tween.tween_property(setting_label, "modulate:a", 1.0, 0.1)
	tween.parallel().tween_property(reset_button, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(reset_button, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(save_button, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(save_button, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(return_button, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(return_button, "scale", Vector2(1.0, 1.0), 0.1)

#音量值显示
func _process(_delta: float) -> void:
	music_tabel.text = str(int(music_volume.value * 100)) + "%"
	sound_tabel.text = str(int(sound_volume.value * 100)) + "%"

#退出动画
func exit_animation() -> void:
	AudioManage.play_sound("ui-click")
	print(GlobalManage.get_time(), "[设置]开始播放出场动画")
	var tween = create_tween()
	tween.tween_property(return_button, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(return_button, "scale", Vector2.ZERO, 0.1)
	tween.tween_property(save_button, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(save_button, "scale", Vector2.ZERO, 0.1)
	tween.tween_property(reset_button, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(reset_button, "scale", Vector2.ZERO, 0.1)
	tween.parallel().tween_property(setting_label, "modulate:a", 0, 0.1)
	tween.tween_property(setting_list, "scale", Vector2(1.0, 0), 0.2)
	tween.tween_property(setting_enum, "scale", Vector2(1.0, 0), 0.3)

	await tween.finished
	exit.emit()
	print(GlobalManage.get_time(), "[设置]退出信号已发送")
	queue_free()

# 读取配置
func load_setting() -> void:
	var config = GlobalData.game_data["setting"]
	print(GlobalManage.get_time(), "[设置]读取配置：", config)
	attack_lock.button_pressed = config["attack_lock"]
	animation_jump.button_pressed = config["animation_jump"]
	music_volume.value = config["music_volume"]
	sound_volume.value = config["sound_volume"]


# 保存配置
func save_setting() -> void:
	var config = {
		"attack_lock": attack_lock.button_pressed,
		"music_volume": music_volume.value,
		"sound_volume": sound_volume.value,
		"animation_jump": animation_jump.button_pressed
	}
	print(GlobalManage.get_time(), "[设置]配置已保存：", config)
	GlobalData.game_data["setting"] = config
	GlobalData.save_data()
	updata_volume.emit(config["music_volume"])
	AudioManage.play_sound("ui-click")
	GlobalManage.show_prompt("设置保存成功")

# 重置配置
func reset_setting() -> void:
	print(GlobalManage.get_time(), "[设置]已重置所有配置")
	GlobalData.reset_data("setting")
	load_setting()
	updata_volume.emit(GlobalData.game_data["setting"]["music_volume"])
	AudioManage.play_sound("ui-click")
	GlobalManage.show_prompt("设置已重置")
