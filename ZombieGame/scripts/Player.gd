extends KinematicBody2D

export (int) var speed = 100
export (float) var rotation_speed = 3

onready var raycast = $RayCast2D
onready var attack_cooldown = $AttackCooldown
onready var animation_player = $AnimationPlayer

var velocity = Vector2()
var rotation_dir = 0
var is_aiming = false
var is_walking = false
var is_idle = true


func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_player", self)


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func player_walk():
	velocity = Vector2()
	rotation_dir = 0 
	if Input.is_action_pressed("ui_down") and not is_aiming:
		velocity = Vector2(-speed, 0).rotated(rotation) * .5
		walk_anim()
	else:
		is_walking = false
	if Input.is_action_pressed("ui_up") and not is_aiming:
		velocity = Vector2(speed, 0).rotated(rotation)
		walk_anim()
	if Input.is_action_pressed("ui_right") and not is_aiming:
		rotation_dir += 1
	if Input.is_action_pressed("ui_left") and not is_aiming:
		rotation_dir -= 1


func player_aim():
	if Input.is_action_pressed("ui_rightclick"):
		look_at(get_global_mouse_position())
		aim_anim()
		if Input.is_action_just_pressed("shoot"):
			if attack_cooldown.is_stopped():
				player_shoot()
				attack_cooldown.start()
				animation_player.play("muzzle_flash")
	else:
		is_aiming = false


func player_idle():
	if not is_aiming and not is_walking:
		idle_anim()


func player_physics(delta):
	rotation += rotation_dir * rotation_speed * delta
	velocity = move_and_slide(velocity)


func player_shoot():
	var coll = raycast.get_collider()
	if raycast.is_colliding() and coll.has_method("kill"):
		coll.kill()


func kill():
	get_tree().reload_current_scene()


func walk_anim():
	$AnimatedSprite.play("walking")
	is_walking = true
	is_aiming = false
	is_idle = false


func idle_anim():
	$AnimatedSprite.play("idle")
	is_idle = true
	is_aiming = false
	is_walking = false


func aim_anim():
	$AnimatedSprite.play("aiming")
	is_aiming = true
	is_idle = false
	is_walking = false


func _on_MobTimer_timeout():
	get_tree().call_group("zombies", "set_player", self)
	

func _physics_process(delta):
	player_physics(delta)
	player_aim()
	player_walk()
	player_idle()

