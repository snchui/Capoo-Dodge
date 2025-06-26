extends Area2D
signal updata_health(value:float)
signal death
signal music_stop
signal space_skill
signal space_lost

@onready var player_animation = %PlayerAnimation
@onready var attack_left = %AttackLeft
@onready var attack_right = %AttackRight
@onready var player_collision = %PlayerShape

const max_health = 100.0
const speed = 600.0

var health:float = max_health
var input_disabled:bool = false
var space_disabled:bool = false
var attack_disable:bool = false
var flip_disabled:bool = false
var animation_lock:bool = false
var space_current:bool = false

#动画权重
var animation_weight = {
	"walk":0,
	"attack":1,
	"space_1":2,
	"space_2":2,
	"injure":3,
	"itch":3,
	"death":4,
}

#初始化
func _ready() -> void:
	hide()
	player_collision.disabled = true
	input_disabled = true
	updata_health.emit(health)
	attack_right.disabled = true
	attack_left.disabled = true

#启用
func start() -> void:
	show()
	health = max_health
	updata_health.emit(health)
	player_collision.disabled = false
	input_disabled = false

#输入处理
func _process(delta: float) -> void:
	if not input_disabled:
		var velocity = Vector2.ZERO
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("attack"):
			attack()
		if Input.is_action_pressed("space"):
			space()
		
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
			position += velocity * delta
			position = position.clamp(Vector2(100,100),get_viewport_rect().size - Vector2(100,100))

		if not animation_lock:
			if velocity.length() > 0:
				player_animation.play("walk")
			else:
				player_animation.stop()

		if not flip_disabled and velocity.x != 0:
			player_animation.flip_h = velocity.x > 0

#动画切换
func request_animation(anim:String) -> bool:
	if animation_weight[anim] >= animation_weight[player_animation.animation]:
		print(GlobalManage.get_time(),"[玩家]播放动画：",anim)
		animation_lock = true
		if player_animation.animation == "space_2":
			space_lost.emit()
		if player_animation.animation == "attack":
			attack_left.call_deferred("set_disabled",true)
			attack_right.call_deferred("set_disabled",true)
		player_animation.play(anim)
		return true
	else:
		return false

#动画播放完成信号
func _on_player_animation_animation_finished() -> void:
	print(GlobalManage.get_time(),"[玩家]接受到动画播放完成信号")
	if player_animation.animation == "space_2":
		space_lost.emit()
	if player_animation.animation != "death":
		player_animation.animation = "walk"
		animation_lock = false
		flip_disabled = false
	attack_left.disabled = true
	attack_right.disabled = true

#技能
func space() -> void:
	if not space_disabled:
		if request_animation("space_1"):
			AudioManage.play_sound("capoo-action")
			space_skill.emit()
			space_current = true
			space_disabled = true
			
			await get_tree().create_timer(1.0).timeout
			space_current = false
			if player_animation.animation != "space_2":
				animation_lock = false
				player_animation.animation = "walk"
			
			await get_tree().create_timer(5.0).timeout
			space_disabled = false

#攻击
func attack() -> void:
	if not animation_lock and not attack_disable:
		AudioManage.play_sound("capoo-swing")
		if request_animation("attack"):
			flip_disabled = GlobalData.game_data["setting"]["attack_lock"]
			if player_animation.flip_h:
				attack_right.disabled = false
			else:
				attack_left.disabled = false

#攻击触发信号
func _on_attack_shape_body_entered(body: Node2D) -> void:
	if body.is_in_group("mosquitto"):
		print(GlobalManage.get_time(),"[玩家]击中敌人")
		AudioManage.play_sound("ui-click")
		body.death(position)
	if body.is_in_group("Boss"):
		print(GlobalManage.get_time(),"[玩家]击中Boss")
		AudioManage.play_sound("ui-click")
		body.injure()

#碰撞信号
func _on_body_entered(body: Node2D) -> void:
	if health != 0:
		print(GlobalManage.get_time(), "[玩家]接收到碰撞信号")
		if not player_animation.animation in ["itch", "injure"]:
			if body.is_in_group("mosquitto"):
				_handle_mosquitto_collision(body)
			elif body.is_in_group("Boss"):
				_handle_boss_collision(body)

#处理猫猫蚊的碰撞事件
func _handle_mosquitto_collision(mosquitto: Node2D) -> void:
	print(GlobalManage.get_time(), "[玩家]触碰到敌人")
	if space_current or player_animation.animation == "space_2":
		change_health(mosquitto.treatment)
		AudioManage.play_sound("ui-click")
		if player_animation.animation != "space_2":
			request_animation("space_2")
		mosquitto.lost(self)
	else:
		change_health(mosquitto.damage)

#处理Boss的碰撞事件
func _handle_boss_collision(boss: Node2D) -> void:
	print(GlobalManage.get_time(), "[玩家]触碰到Boss")
	if space_current:
		change_health(boss.treatment)
	else:
		change_health(boss.damage)
		request_animation("injure")

#血量变化
func change_health(damage:float) -> void:
	if player_animation.animation == "death": return
	var new_health = clamp(health + damage,0,max_health)
	print(GlobalManage.get_time(),"[玩家]血量变化：",health," -> ",new_health)
	if new_health == 0:
		print(GlobalManage.get_time(),"[玩家]角色死亡")
		input_disabled = true
		request_animation("death")
		AudioManage.play_sound("capoo-weep")
		music_stop.emit()
		health = new_health
		updata_health.emit(health)
		await player_animation.animation_finished
		death.emit()
		return
	elif new_health < health:
		request_animation("itch")
		AudioManage.play_sound("capoo-cry")
		
	health = new_health
	updata_health.emit(health)
