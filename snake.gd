extends CharacterBody2D

signal timer_run(head: Vector2)
signal outofbounds
signal selfcollide

# grid size: 48x30
const GRID_WIDTH = 48
const GRID_HEGHT = 30
const SCALE = 20 # : 1
const SPEED = 1  # per second

enum Direction { UP, DOWN, LEFT, RIGHT }
var current_dir = Direction.RIGHT
var vector_for = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]
var new_dir = current_dir
var increase = false

var body: Array = []
var bodyTextures = {}

# textures
var preloadedHead: Array[Texture2D] = []
var preloadedTail: Array[Texture2D] = []

func to_direction(vec: Vector2) -> Direction:
	if vec.is_equal_approx(Vector2(1, 0)):
		return Direction.LEFT
	elif vec.is_equal_approx(Vector2(-1, 0)):
		return Direction.RIGHT
	elif vec.is_equal_approx(Vector2(0, -1)):
		return Direction.DOWN
	elif vec.is_equal_approx(Vector2(0, 1)):
		return Direction.UP
	return Direction.UP

func construct_body() -> Area2D:
	var b = Area2D.new()
	
	var collisionRectangle = RectangleShape2D.new()
	collisionRectangle.size = Vector2(20, 20)
	
	var b_collisionShape = CollisionShape2D.new()
	b_collisionShape.shape = collisionRectangle
	
	var b_sprite = Sprite2D.new()
	b_sprite.position = Vector2(10, 10)
	b_sprite.scale = Vector2(0.5, 0.5)
	b_sprite.name = "Sprite"
	
	b.add_child(b_collisionShape)
	b.add_child(b_sprite)
	
	return b

func _ready() -> void:
	preloadedHead.append(load("res://assets/head_up.png"))
	preloadedHead.append(load("res://assets/head_down.png"))
	preloadedHead.append(load("res://assets/head_left.png"))
	preloadedHead.append(load("res://assets/head_right.png"))
	
	preloadedTail.append(load("res://assets/tail_up.png"))
	preloadedTail.append(load("res://assets/tail_down.png"))
	preloadedTail.append(load("res://assets/tail_left.png"))
	preloadedTail.append(load("res://assets/tail_right.png"))
	
	bodyTextures["bottomleft"] = load("res://assets/body_bottomleft.png")
	bodyTextures["bottomright"] = load("res://assets/body_bottomright.png")
	bodyTextures["horizontal"] = load("res://assets/body_horizontal.png")
	bodyTextures["topleft"] = load("res://assets/body_topleft.png")
	bodyTextures["topright"] = load("res://assets/body_topright.png")
	bodyTextures["vertical"] = load("res://assets/body_vertical.png")
	
	# call reset
	reset()

func reset() -> void:
	for elem in body:
		remove_child(elem["element"])
		elem["element"].queue_free()
	body.clear()
	
	@warning_ignore("integer_division")
	const tailPos = Vector2(floor(GRID_WIDTH / 2) - 1, floor(GRID_HEGHT / 2))
	
	var tail = construct_body()
	var tail_sprite = tail.get_node("Sprite") as Sprite2D
	tail_sprite.texture = preloadedTail[Direction.LEFT]
	tail.position = tailPos * SCALE
	
	body.append({
		"gridPos": tailPos,
		"element": tail
	})
	
	@warning_ignore("integer_division")
	const headPos = Vector2(floor(GRID_WIDTH / 2), floor(GRID_HEGHT / 2))
	
	var head = construct_body()
	var head_sprite = head.get_node("Sprite") as Sprite2D
	head_sprite.texture = preloadedHead[Direction.RIGHT]
	head.position = headPos * SCALE
	
	body.append({
		"gridPos": headPos,
		"element": head
	})
	
	self.add_child(head)
	self.add_child(tail)
	
	new_dir = Direction.RIGHT
	current_dir = new_dir
	
	$Timer.start()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_up") and current_dir != Direction.DOWN:
		new_dir = Direction.UP
	elif Input.is_action_pressed("ui_down") and current_dir != Direction.UP:
		new_dir = Direction.DOWN
	elif Input.is_action_pressed("ui_left") and current_dir != Direction.RIGHT:
		new_dir = Direction.LEFT
	elif Input.is_action_pressed("ui_right") and current_dir != Direction.LEFT:
		new_dir = Direction.RIGHT
	
	# check which texture to render based on the direction 
	## head
	var head_sprite = body[-1]["element"].get_node("Sprite") as Sprite2D
	head_sprite.texture = preloadedHead[current_dir]
	
	## tail
	var diff = (body[1]["gridPos"] - body[0]["gridPos"]) as Vector2
	var tail_direction = to_direction(diff)
	var tail_sprite = body[0]["element"].get_node("Sprite") as Sprite2D
	tail_sprite.texture = preloadedTail[tail_direction]
	
	# body
	for i in range(1, body.size() - 1):
		var diff_back = to_direction(body[i]["gridPos"] - body[i-1]["gridPos"])
		var diff_front = to_direction(body[i]["gridPos"] - body[i+1]["gridPos"])
		var body_texture: Texture2D
		
		if (diff_back == Direction.UP and diff_front == Direction.DOWN) or (diff_back == Direction.DOWN and diff_front == Direction.UP):
			body_texture = bodyTextures["vertical"]
		elif (diff_back == Direction.LEFT and diff_front == Direction.RIGHT) or (diff_back == Direction.RIGHT and diff_front == Direction.LEFT):
			body_texture = bodyTextures["horizontal"]
		elif (diff_back == Direction.LEFT and diff_front == Direction.UP) or (diff_back == Direction.UP and diff_front == Direction.LEFT):
			body_texture = bodyTextures["topleft"]
		elif (diff_back == Direction.RIGHT and diff_front == Direction.UP) or (diff_back == Direction.UP and diff_front == Direction.RIGHT):
			body_texture = bodyTextures["topright"]
		elif (diff_back == Direction.LEFT and diff_front == Direction.DOWN) or (diff_back == Direction.DOWN and diff_front == Direction.LEFT):
			body_texture = bodyTextures["bottomleft"]
		elif (diff_back == Direction.RIGHT and diff_front == Direction.DOWN) or (diff_back == Direction.DOWN and diff_front == Direction.RIGHT):
			body_texture = bodyTextures["bottomright"]
		
		var body_sprite = body[i]["element"].get_node("Sprite") as Sprite2D
		body_sprite.texture = body_texture

func _on_timer_timeout() -> void:
	if current_dir != new_dir:
		current_dir = new_dir

	if not increase:
		# get current positions
		var current_pos = []
		for b in body:
			current_pos.append(b["gridPos"])

		# add new and remove old one position to it
		current_pos.pop_front()
		current_pos.append(current_pos[-1] + vector_for[current_dir])

		# update the list and element position
		for i in body.size():
			body[i]["gridPos"] = current_pos[i]
			body[i]["element"].position = current_pos[i] * SCALE
			
	else:	# add a new element to the grid
		var newPos = body[-1]["gridPos"] + vector_for[current_dir]
		
		var new_head = construct_body()		
		var newHead_sprite = new_head.get_node("Sprite") as Sprite2D
		newHead_sprite.texture = preloadedTail[Direction.LEFT]
		new_head.position = newPos * SCALE

		body.append({
			"gridPos": newPos,
			"element": new_head
		})
		
		self.add_child(new_head)
		
		increase = false
	
	timer_run.emit(body[-1]["gridPos"])
	
	var head = body[-1]["gridPos"]
	if head.x < 0 or head.y < 0 or head.x >= GRID_WIDTH or head.y >= GRID_HEGHT:
		$Timer.stop()
		outofbounds.emit()
	
	# check collision
	for elem in body.slice(0, body.size() - 1):
		if elem["gridPos"] == head:
			selfcollide.emit()
			$Timer.stop()
			break

func _on_apple_eaten() -> void:
	increase = true
