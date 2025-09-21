extends Node2D

var gameover = false
var gameoverScene: Node2D

func _ready() -> void:
	gameoverScene = load("res://gameover.tscn").instantiate()

func _process(_delta: float) -> void:
	# write score to element
	var ScoreElement = $Panel/ColorRect/Score
	ScoreElement.text = str($"Playable area/Rectangle/Snake".body.size() - 2)
	
	if gameover and Input.is_action_just_pressed("game_reset"):
		gameover = false
		self.remove_child(gameoverScene)
		$"Playable area/Rectangle/Snake".reset()

func _on_snake_timer_run(head: Vector2) -> void:
	$"Playable area/Rectangle/Apple".check_eaten(head)

func _on_snake_gameover() -> void:
	gameover = true
	self.add_child(gameoverScene)
