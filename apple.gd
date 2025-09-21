extends Area2D

# grid size: 48x30
const GRID_WIDTH = 48
const GRID_HEGHT = 30
const SCALE = 20 # : 1

var pos = Vector2(0, 0)

signal eaten

func reposition():
	pos.x = randi_range(0, GRID_WIDTH - 1)
	pos.y = randi_range(0, GRID_HEGHT - 1)
	position = pos * SCALE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reposition()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func check_eaten(head: Vector2) -> void:
	if (head == pos):
		eaten.emit()
		reposition()
