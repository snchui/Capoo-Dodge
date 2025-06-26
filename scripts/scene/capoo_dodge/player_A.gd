extends Area2D
signal updata_health(value:int)
signal death

@onready var player_animation = %PlayerAAnimation
@onready var player_collision = %PlayerACollision
@onready var mosquito = %MosquitoAPath

const max_health = 100

var animation_weight = {
	"sleep":0,
	"look":1,
	"emotion":1,
	"dodge-up":2,
	"dodge-down":2,
	"dodge-right":2,
	"dodge-left":2,
	"itch":3,
	"death":4
}

var input_disable:bool
var is_look:bool
var health:int

func _ready() -> void:
	hide()
	player_collision.disabled = true
	input_disable = true
	is_look = false
	health = max_health

func start() -> void:
	show()
	player_collision.disabled = false
	input_disable = false
	health = max_health
	player_animation.play("sleep")

func _process(_delta: float) -> void:
	if not input_disable:
		if Input.is_action_just_pressed("move_up"):
			request_animation("dodge-up")
		if Input.is_action_just_pressed("move_down"):
			request_animation("dodge-down")
		if Input.is_action_just_pressed("move_right"):
			request_animation("dodge-right")
		if Input.is_action_just_pressed("move_left"):
			request_animation("dodge-left")

func request_animation(anim:String) -> bool:
	if animation_weight[anim] > animation_weight[player_animation.animation]:
		player_animation.play(anim)
		match anim:
			"dodge-left":
				player_animation.z_index = 1
			"dodge-right":
				player_animation.z_index = 0
			"dodge-up":
				player_animation.z_index = 1
			"dodge-down":
				player_animation.z_index = 0
		AudioManage.play_sound("capoo-action")
		return true
	else:
		return false

func _on_animation_finished() -> void:
	player_animation.z_index = 0
	if player_animation.animation != "death":
		if health == max_health:
			player_animation.play("look")
		else:
			player_animation.play("emotion")

func _on_body_entered(_body: Node2D) -> void:
	var angle = mosquito.direction.angle() * -180/PI
	print(GlobalManage.get_time(),"[玩家A]触碰到敌人，角度：",angle)
	match player_animation.animation:
		"itch","death":
			return
		"dodge-left":
			if angle < -135.0 or angle > 135.0:
				return
		"dodge-right":
			if angle > -45.0 and angle < 45.0:
				return
		"dodge-up":
			if angle > 45.0 and angle < 135.0:
				return
		"dodge-down":
			if angle > -135.0 and angle < -45.0:
				return

	change_health()
	
func change_health() -> void:
	var new_health = clamp(health - 20,0,max_health)
	print(GlobalManage.get_time(),"[玩家A]血量变化：",health," -> ",new_health)
	health = new_health
	updata_health.emit(health)
	if health == 0:
		print(GlobalManage.get_time(),"[玩家A]角色死亡")
		input_disable = true
		request_animation("death")
		AudioManage.play_sound("capoo-weep")
		await player_animation.animation_finished
		death.emit()
	else:
		request_animation("itch")
		AudioManage.play_sound("capoo-cry")
