extends Node

# 1 - Set Game Variables
var score : int
var game_started : bool = false

# 2 - Grid Variables
var cells : int = 20  # cell count in each row and each column
var cell_size : int = 50

# 3 - Import SnakeSegment Scene
@export var snake_scene : PackedScene

# 4 - Snake Variables
var old_data : Array
var sanake_data : Array
var snake : Array

# 5 - Movement Variable
var start_position = Vector2(9 ,9)
var up = Vector2(0 ,-1)
var down = Vector2(0 ,1)
var left = Vector2(-1 ,0)
var right = Vector2(1 ,0)
var movement_direction : Vector2
var can_move : bool

# 6 - food variables
var food_pos : Vector2
var generate_food : bool = true
 


func _ready():
	new_game()
	
func new_game():
	get_tree().paused = false
	$GameOverMenu.hide()
	get_tree().call_group("segments" ,"queue_free")
	score = 0
	$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
	movement_direction = up
	can_move = true
	generate_snake()
	move_food()
	
func generate_snake():
	old_data.clear()
	sanake_data.clear()
	snake.clear()
	#start with start point ,create tail segments vertically down
	for i in range(5):
		add_segment(start_position + Vector2(0 ,i))
		
func add_segment(pos):
	sanake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0 ,cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)
	
func _process(delta):
	move_snake()
	
func move_snake():
	if can_move:
		#update movement from key press
		if Input.is_action_just_pressed("move_down"):
			movement_direction = down
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_up"):
			movement_direction = up
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_left"):
			movement_direction = left
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_right"):
			movement_direction = right
			can_move = false
			if not game_started:
				start_game()
				
func start_game():
	game_started = true
	$MoveTimer.start()
				
		
func _on_move_timer_timeout():
	#allow snake movement
	can_move = true
	#use snake previous position to move segments
	old_data = [] + sanake_data
	sanake_data[0] += movement_direction
	for i in range(len(sanake_data)):
		#move all segments one by one
		if i > 0:
			sanake_data[i] = old_data[i - 1]
		snake[i].position = ((sanake_data[i] * cell_size) + Vector2(0 ,cell_size)) 
	
	
	check_out_of_bonds()
	check_self_eaten()
	check_food_eaten()

func check_out_of_bonds():
	if sanake_data[0].x < 0 or sanake_data[0].x > cells - 1 or sanake_data[0].y < 0 or sanake_data[0].y > cells - 1:
		end_game()
		
func check_self_eaten():
	for i in range(1 ,len(sanake_data)):
		if sanake_data[0] == sanake_data[i]:
			end_game()
			
			
func check_food_eaten():
	#if snake eats food adda segment , and ove food
	if sanake_data[0] == food_pos:
		score += 1
		$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
		add_segment(old_data[-1])
		move_food()
		
func move_food():
	while generate_food:
		generate_food = false
		food_pos = Vector2(randi_range(0 ,cells -1) ,randi_range(0 ,cells - 1))
		for i in sanake_data:
			if food_pos == i:
				generate_food = true
	$Food.position = (food_pos * cell_size) + Vector2(0 ,cell_size)
	generate_food = true
	
func end_game():
	$GameOverMenu.show()
	$MoveTimer.stop()
	game_started = false
	get_tree().paused = true
	


func _on_game_over_menu_restart():
	new_game()
