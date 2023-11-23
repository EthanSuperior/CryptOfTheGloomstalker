extends CharacterBody2D

const SPEED = 100.0
var face_direction = Vector2i.UP
var tile_position = Vector2i()
var death_time = SETTINGS.START_PLAY_TIME + Time.get_ticks_msec()
var dark_time = 0
var shadow_start_time = 0
var gold = 0
var looted = false
var light_level = 0
var game_over = false
var map: TileMap
@onready var sprite: AnimatedSprite2D = $Icon
@onready var gold_text = $UI/MarginContainer/HFlowContainer/GoldText
@onready var gradiant: Gradient = $UI/MarginContainer/GradiantBackground.get_texture().get_gradient()
# CHARACTER MOVEMENT
func _enter_tree():
	face_direction = Vector2i.UP
	tile_position = Vector2i()
	death_time = SETTINGS.START_PLAY_TIME + Time.get_ticks_msec()
	dark_time = 0
	shadow_start_time = 0
	gold = 0
	looted = false
	light_level = 0
	game_over = false
func _ready():
	await owner.ready
	map = get_parent().MAP
func _physics_process(delta):
	var direction = 0 if game_over else Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		sprite.play("walk_left" if (direction < 0) else "walk_right")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	direction = 0 if game_over else Input.get_axis("move_up", "move_down")
	if direction:
		velocity.y = direction * SPEED
		sprite.play("walk_backward" if (direction < 0) else "walk_forward")
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	if (!velocity.is_zero_approx()):
		face_direction = Vector2i(velocity.normalized().ceil())
	else: 
		sprite.pause()
		velocity = Vector2()
	move_and_slide()
	tile_position = map.local_to_map(map.to_local(global_position))

# GAME TICK
func _process(delta):
	light_level = max(0, map.get_cell_atlas_coords(SETTINGS.LAY_LIGHT, tile_position).y)
	if game_over: return in_the_shadows(delta)
	if Input.is_action_just_pressed("action"):
		action_key()
	in_the_shadows(delta)
	var time_left = death_time - Time.get_ticks_msec()
	var dark_time_left = SETTINGS.MAX_DARK_TIME * (1+looted) - dark_time
	var color = Color(1, 0.843137, 0, 1)
	if (time_left < 5*SETTINGS.ONE_SEC):
		color = color.lerp(Color.WHITE, (int(time_left)%500)/500.0)
		if (light_level != 0):
			gradiant.colors[1] = color
			gradiant.colors[1].a = .1
		else:
			gradiant.colors[1].r = 0
			gradiant.colors[1].g = 0
			gradiant.colors[1].b = 0
	gold_text.text = '[font_size=60][center][color=%s]GOLD: %d' % [color.to_html(),gold]
	if time_left <= 0: escaped_cave()
	elif dark_time >= SETTINGS.MAX_DARK_TIME * (1+looted): got_eaten()


func in_the_shadows(delta):
	var rgb = 1/(light_level+1)
	sprite.modulate = Color(rgb,1-rgb,1-rgb)
	if light_level != 0 || game_over:
		if(shadow_start_time != 0):
			gradiant.colors[1] = Color.BLACK
			create_tween().tween_method(func(v): gradiant.colors[1].a=v, gradiant.colors[1].a,0, .25)
		shadow_start_time = 0
		dark_time = 0
		looted = 0
		return
	if(shadow_start_time == 0): shadow_start_time = Time.get_ticks_msec()
	dark_time = Time.get_ticks_msec() - shadow_start_time
	gradiant.colors[1].a = (dark_time/((looted + 1) * SETTINGS.MAX_DARK_TIME)) **2
	death_time += SETTINGS.CALC_DEATH_BONUS(delta, dark_time, looted)


func action_key():
	var clicked = get_parent().get_cell_node(tile_position + face_direction, 1)
	if !clicked || clicked.is_open: return
	gold += clicked.OpenChest()
	looted += 1

#GAME OVERS
func escaped_cave():
	gradiant.colors[1].a = 0
	GameOver(" CONGRATS YOU GOT:\n    %d GOLD!!!" % gold, Color.WHITE)
func got_eaten():
	GameOver(" YOU GOT EATEN!\nYOU LOST %d GOLD" % gold, Color.RED)
func GameOver(msg, txtColor):
	game_over = true
	var winPopup: Label = Label.new()  # or Label.new() if using Label
	winPopup.set_text(msg)
	winPopup.scale = Vector2(.60,.60)
	winPopup.modulate = txtColor
	add_child(winPopup)
	winPopup.set_anchors_preset(Control.PRESET_CENTER)
	winPopup.position = winPopup.get_rect().size/-2.0
	get_tree().create_timer(3).timeout.connect(
		func():
			get_tree().change_scene_to_file("res://scenes/Menu.tscn"))

