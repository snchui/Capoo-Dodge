extends Node2D
signal updata_progress(value:int)

@onready var progress_timer = %ProgressTimer
@onready var enemy_create_timer = %EnemyCreateTimer
@onready var wait_point = %WaitPoint

@onready var player = %Player
@onready var playerA = %Player_A
@onready var mosquitoA = %MosquitoAPath
@onready var dog = %Dog
@onready var dog_point = %DogPoint
@onready var boss = %Boss
@onready var boss_timer = %BossTimer
@onready var boss_treat_point = %BossTreatPoint

const random_enemy_speed_max = 1000.0
const random_enemy_speed_min = 500.0

var enemy_pool = []
var enemy_scene = load("res://scenes/levels/capoo-dodge/Mosquitto.tscn")
enum screen_edge { up,down,left,right }

var screen_size:Vector2
var boss_action_count:int

func _ready() -> void:
	screen_size = get_viewport().size
	player.position = screen_size/2
	playerA.position = screen_size/2
	dog.hide()
	boss.position = wait_point.position

## 游戏流程A
func level_progress_A() -> void:
	playerA.start()
	dog.show()
	await get_tree().create_timer(2.0).timeout
	mosquitoA.start(wait_point.position)
	GlobalManage.show_prompt("轻推WASD，躲避猫猫蚊的叮咬！")
	await mosquitoA.progress_finished
	free_A_resource()

#游戏流程A-释放A的资源
func free_A_resource() -> void:
	var player_A_bed = playerA.get_node("PlayerABed")
	var tween = create_tween()
	tween.tween_property(player_A_bed,"modulate:a",0,1.0)
	tween.parallel().tween_property(dog,"modulate:a",0,1.0)
	
	await tween.finished
	playerA.queue_free()
	dog.queue_free()
	mosquitoA.queue_free()
	player.show()

#游戏流程-B
func level_progress_B() -> void:
	updata_progress_information(0)
	player.start()
	player.attack_disable = true
	
	progress_timer.start(2.0)
	await progress_timer.timeout
	GlobalManage.show_prompt("按下Space，吸食猫猫蚊的生命值！")
	
	for i in range(3):
		await enemy_create_mod(i)
		updata_progress_information((i + 1) * 20)
	
	enemy_create_timer.start(0.5)
	
	await enemy_create_mod(0)
	enemy_create_timer.wait_time = 0.3
	updata_progress_information(75)
	
	await enemy_create_mod(2)
	enemy_create_timer.wait_time = 0.1
	progress_timer.start(10.0)
	updata_progress_information(90)
	
	await progress_timer.timeout
	updata_progress_information(100)
	enemy_create_timer.stop()
	
	if player.health != 0:
		progress_timer.start(3.0)
	await progress_timer.timeout

#游戏流程-C
func level_progress_C() -> void:
	updata_progress_information(0)
	player.start()
	player.attack_disable = false
	
	progress_timer.start(2.0)
	await progress_timer.timeout
	GlobalManage.show_prompt("按下Shift，打飞猫猫蚊！")
	
	await enemy_create_mod(0)
	updata_progress_information(30)
	enemy_create_timer.start(0.5)
	
	await enemy_create_mod(0)
	updata_progress_information(60)
	enemy_create_timer.wait_time = 0.3
	
	await enemy_create_mod(2)
	updata_progress_information(100)
	enemy_create_timer.stop()
	
	if player.health != 0:
		progress_timer.start(3.0)
	await progress_timer.timeout

#游戏流程-D
func level_progress_D() -> bool:
	player.attack_disable = false
	player.start()
	
	progress_timer.start(2.0)
	await progress_timer.timeout
	GlobalManage.show_prompt("击败巨大猫猫蚊！")
	
	boss.start()
	boss.move_to_position(boss_treat_point.position)
	boss_action_count = 0
	if await boss_action():
		progress_timer.start(3.0)
		await progress_timer.timeout
		return true
	else:
		boss.health = 1
		boss.injure()
		return false

#Boss行动逻辑
func boss_action() -> bool:
	while boss.health != 0:
		boss.request_animation("fly")
		progress_timer.start(1.0)
		await progress_timer.timeout
		await boss_attack_mod(randi_range(0,4))
		boss_action_count += 1
		if boss_action_count >= 30:
			return false

	return true

#Boss攻击
func boss_attack_mod(index:int) -> void:
	match index:
		0:
			boss.updata_direction(Vector2.ZERO)
			boss.move_to_position(boss_treat_point.position)
			await boss.action_finished
			for i in range(50):
				if boss.health == 0:return
				create_enemy("boss-treat")
				boss_timer.start(0.2)
				await boss_timer.timeout
			boss.move_to_position(player.position)
			await boss.action_finished
		1:
			boss.request_animation("angry")
			boss_timer.start(1.0)
			await boss_timer.timeout
			for i in range(5):
				if boss.health == 0:return
				boss.updata_direction(player.position)
				boss.move_to_position(player.position)
				await boss.action_finished
			boss.move_to_random(screen_size)
			await boss.action_finished
		2:
			boss.request_animation("angry")
			for i in range(5):
				if boss.health == 0:return
				boss.move_to_random(screen_size)
				boss.updata_direction(player.position)
				await boss.action_finished
				for n in range(5):
					create_enemy("boss-target")
					boss_timer.start(0.3)
					await boss_timer.timeout
		3:
			boss.request_animation("angry")
			for i in range(5):
				if boss.health == 0:return
				boss.move_to_random(screen_size)
				boss.updata_direction(player.position)
				await boss.action_finished
				for n in range(5):
					for k in range(20):
						create_enemy("boss-around")
					boss_timer.start(0.3)
					await boss_timer.timeout
			boss.move_to_position(player.position)
		4:
			boss.request_animation("angry")
			for i in range(5):
				if boss.health == 0:return
				boss.move_to_random(screen_size)
				boss.updata_direction(player.position)
				for n in range(30):
					for k in range(3):
						create_enemy("boss-sweep")
					boss_timer.start(0.1)
					await boss_timer.timeout
		_:
			push_error(GlobalManage.get_time(),"[游戏]未知的Boss攻击索引：",index)

#敌人生成模式
func enemy_create_mod(index:int) -> void:
	print(GlobalManage.get_time(),"[游戏]敌人生成模式：",index)
	match index:
		0:
			var wait_time = [3.0,3.0,3.0,2.0,2.0,2.0,1.0,1.0,1.0,1.0,1.0]
			for i in range(wait_time.size()):
				create_enemy("target")
				progress_timer.start(wait_time[i])
				await progress_timer.timeout
		1:
			var enemy_create_number = [3,3,3,3,3,5,5,5,5,5,7,7,7,7,7,9,9,9,9,9]
			for i in range(enemy_create_number.size()):
				for n in range(enemy_create_number[i]):
					create_enemy("target")
				progress_timer.start(3.0)
				await progress_timer.timeout
		2:
			var enemy_create_number = [5,5,5,7,7,7,9,9,9]
			for i in range(enemy_create_number.size()):
				for n in range(enemy_create_number[i]):
					progress_timer.start(0.3)
					await progress_timer.timeout
					create_enemy("target")
				progress_timer.start(3.0)
				await progress_timer.timeout

#获取对象
func get_enemy() -> Node:
	var enemy:Node
	
	for i in range(enemy_pool.size()):
		if not enemy_pool[i].is_inscreen:
			enemy = enemy_pool[i]
			break
	
	if not enemy:
		enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.position = wait_point.position
		enemy_pool.append(enemy)
		print(GlobalManage.get_time(),"[游戏]对象池新建对象：",enemy_pool.size())
	
	enemy.is_inscreen = true
	return enemy

#敌人生成
func create_enemy(type:String) -> void:
	if player.health != 0 and boss.health != 0:
		var enemy = get_enemy()
		match type:
			"random":
				enemy.position = get_edge_random_position()
				enemy.move_direction = get_random_direction(enemy.position)
			"target":
				enemy.position = get_edge_random_position()
				enemy.move_direction = get_player_direction(enemy.position)
			"boss-treat":
				enemy.position = get_boss_random_position()
				enemy.move_direction = get_player_direction(enemy.position)
			"boss-target":
				enemy.position = boss.get_enemy_create_point()
				enemy.move_direction = get_player_direction(enemy.position)
				enemy.move_velocity = 500
			"boss-around":
				enemy.position = boss.get_enemy_create_point()
				enemy.move_direction = get_random_direction(enemy.position)
			"boss-sweep":
				enemy.position = boss.get_enemy_create_point()
				enemy.move_direction = get_player_direction(enemy.position)
				enemy.move_direction.x += randf_range(-400,400)
				enemy.move_direction.y += randf_range(-400,400)
			_:
				push_error(GlobalManage.get_time(),"[游戏]未知的敌人生成类型：",type)
				enemy._ready()
				return

		enemy.move_velocity += randf_range(random_enemy_speed_min,random_enemy_speed_max)
		enemy.custom_ready()

#随机位置：屏幕边缘
func get_edge_random_position() -> Vector2:
	var random_position:Vector2
	var edge = screen_edge.values().pick_random()
	match edge:
		screen_edge.up:
			random_position = Vector2(randf_range(0,screen_size.x),0)
		screen_edge.down:
			random_position = Vector2(randf_range(0,screen_size.x),screen_size.y)
		screen_edge.left:
			random_position = Vector2(0,randf_range(0,screen_size.y))
		screen_edge.right:
			random_position = Vector2(screen_size.x,randf_range(0,screen_size.x))
			
	return random_position

#随机位置：Boss附近
func get_boss_random_position() -> Vector2:
	var random_position:Vector2
	var edge = screen_edge.values().pick_random()
	match edge:
		screen_edge.up:
			random_position = Vector2(randf_range(screen_size.x * 0.6,screen_size.x),0)
		screen_edge.down:
			random_position = Vector2(randf_range(screen_size.x * 0.6,screen_size.x),screen_size.y)
		screen_edge.left,screen_edge.right:
			random_position = Vector2(screen_size.x,randf_range(0,screen_size.x))
			
	return random_position

#随机方向
func get_random_direction(enemy_position:Vector2) -> Vector2:
	return Vector2(randf_range(1,screen_size.x),randf_range(1,screen_size.y)) - enemy_position

#玩家方向
func get_player_direction(enemy_position:Vector2) -> Vector2:
	return player.position - enemy_position

#生成随机敌人
func _on_enemy_create_timer_timeout() -> void:
	create_enemy("random")

#游戏流程更新
func updata_progress_information(progress:int) -> void:
	updata_progress.emit(progress)
