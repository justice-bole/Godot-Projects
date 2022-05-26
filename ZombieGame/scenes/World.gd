extends Node

export (PackedScene) var Zombie
var score

func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_player", self)
	randomize()
	new_game()


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()


func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()


func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func _on_ScoreTimer_timeout():
	score += 1


func _on_MobTimer_timeout():
	# Choose a random location on Path2D.
	$MobPath/MobSpawnLocation.offset = randi()
	# Create a Mob instance and add it to the scene.
	var mob = Zombie.instance()
	add_child(mob)
	# Set the mob's position to a random location.
	mob.position = $MobPath/MobSpawnLocation.position
