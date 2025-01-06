extends Control

# level variables
@export var level = 0
var last_level = 0
var rotation_amount = 0
# gamestate stuff
var gamestate = 0
# sky sprites
var sky_0 = preload("res://images/sky_0.png")
var sky_1 = preload("res://images/sky_1.png")
var sky_2 = preload("res://images/sky_2.png")
var sky_3 = preload("res://images/sky_3.png")
# vignette colors
var vignette_color_0 = Color(0.8666666666666667, 0.615686274509804, 0.3137254901960784)
var vignette_color_1 = Color(0.8745098039215686, 0.5607843137254902, 0.6705882352941176)
var vignette_color_2 = Color(0.5411764705882353, 0.6039215686274509, 0.7372549019607844)
var vignette_color_3 = Color(0.18823529411764706, 0.023529411764705882, 0.047058823529411764)
# text + button colors
var text_color_0 = Color(0.6666666666666666, 0.43529411764705883, 0.21176470588235294)
var text_color_1 = Color(0.6901960784313725, 0.3803921568627451, 0.4627450980392157)
var text_color_2 = Color(0.3686274509803922, 0.44313725490196076, 0.596078431372549)
var text_color_3 = Color(0.9254901960784314, 0.8156862745098039, 0.8274509803921568)
# level 3 player tint
var level_tint_3 = Color(0.5333333333333333, 0.1843137254901961, 0.1450980392156863)
# initialize sky sprite
var sky = sky_0
# initialize vignette color
var vignette_color = vignette_color_0
# initialize text + button color
var text_color = text_color_0
# initialize the start time
var time_start: int = 0
# best time array
var best_time_array = [0,0,0,0]
# initialize tweens
var bottom_text_tween : Tween
var sky_tween : Tween
var vignette_color_tween : Tween
var text_color_tween : Tween

func _ready() -> void:
	# create global variable for blocks to change animation depending on current level
	SignalBus.add_signal_to_bus("check_level",[{"name": "level", "type": TYPE_INT}])
	# create global variable for buttons to switch to a certain level
	SignalBus.add_signal_to_bus("switch_level",[{"name": "go_to_level", "type": TYPE_INT}])
	SignalBus.connect("switch_level", level_switching_function)
	# create global variable to check if the cursor is currently hovering over a button
	SignalBus.add_signal_to_bus("check_hovering_over_button",[{"name": "hovering_over_button", "type": TYPE_BOOL}])
	# clear the playing space
	$Level.clear()
	# change level assets and colors
	set_level()
	# play the opening animation
	$iris_effect/AnimationPlayer.play("iris_effect")
	# hide the mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta) -> void:
	#print("FPS %d" % Engine.get_frames_per_second())
	# rotate the sky
	$sky.rotation += 0.01 + rotation_amount;
	# fill in the grey borders for when the window is made too wide or tall
	$Vignette/void_fill.scale = DisplayServer.screen_get_size()
	# handle stuff regarding to the game loop
	game_loop()

func set_level():
	if level == 0:
		$Level.current_level = 0
		sky = sky_0
		RenderingServer.set_default_clear_color(vignette_color_0)
		vignette_color = vignette_color_0
		text_color = text_color_0
		$player/AnimatedSprite2D.modulate = Color.WHITE
	elif level == 1:
		$Level.current_level = 1
		sky = sky_1
		RenderingServer.set_default_clear_color(vignette_color_1)
		vignette_color = vignette_color_1
		text_color = text_color_1
		$player/AnimatedSprite2D.modulate = Color.WHITE
	elif level == 2:
		$Level.current_level = 2
		sky = sky_2
		RenderingServer.set_default_clear_color(vignette_color_2)
		vignette_color = vignette_color_2
		text_color = text_color_2
		$player/AnimatedSprite2D.modulate = Color.WHITE
	elif level == 3:
		$Level.current_level = 3
		sky = sky_3
		RenderingServer.set_default_clear_color(vignette_color_3)
		vignette_color = vignette_color_3
		text_color = text_color_3
		$player/AnimatedSprite2D.modulate = level_tint_3
	# change vignette colors
	vignette_color_tween_function()
	# change text + button colors
	text_color_tween_function()
	# place the current level
	$Level.place_level()
	# check the current level
	SignalBus.emit_signal("check_level", level)

func level_switching_function(name:int):
	# set what the last level currently was
	last_level = level
	$sky/sky_transition.texture = sky
	# handle changing the level
	if name == 0:
		level = 0
	elif name == 1:
		level = 1
	elif name == 2:
		level = 2
	elif name == 3:
		level = 3
	# handle resetting the level upon changing levels
	if last_level != level:
		reset()
		# handle the level name appearing
		$bottom_text.visible = true
		# make the bottom text tween reset
		if bottom_text_tween:
			bottom_text_tween.stop()
		# make the bottom text fade out
		bottom_text_tween_function()
		# change sky sprite
		sky_tween_function()
		# change level assets and colors
		set_level()

func get_time():
	# return a best time if on title screen
	if gamestate == 0:
		return best_time_array[level]
	# return gameplay time when in gameplay
	if gamestate == 2:
		return ((Time.get_ticks_msec()/1000) - time_start)

func format_time():
	# convert time
	var time_left = get_time()
	var minute = floor(time_left / 60)
	var second = int(time_left) % 60
	return [minute, second]

func bottom_text_tween_function():
	bottom_text_tween = create_tween()
	bottom_text_tween.tween_property($bottom_text, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_delay(1.0)
	await bottom_text_tween.finished
	$bottom_text.visible = false

func sky_tween_function():
	$sky/sky_transition.modulate.a = 1
	$sky/main_sky.texture = sky
	sky_tween = create_tween()
	sky_tween.tween_property($sky/sky_transition, "modulate:a", 0.0, 0.25).set_ease(Tween.EASE_IN)
	

func vignette_color_tween_function():
	vignette_color_tween = create_tween()
	vignette_color_tween.tween_property($Vignette, "modulate", vignette_color, 0.25).set_ease(Tween.EASE_IN)

func text_color_tween_function():
	text_color_tween = create_tween()
	text_color_tween.tween_property($top_text, "modulate", text_color, 0.02).set_ease(Tween.EASE_IN)
	text_color_tween.tween_property($bottom_text, "modulate", text_color, 0.02).set_ease(Tween.EASE_IN)
	text_color_tween.tween_property($button_1, "modulate", text_color, 0.02).set_ease(Tween.EASE_IN)
	text_color_tween.tween_property($button_2, "modulate", text_color, 0.02).set_ease(Tween.EASE_IN)
	text_color_tween.tween_property($button_3, "modulate", text_color, 0.02).set_ease(Tween.EASE_IN)
	text_color_tween.tween_property($button_4, "modulate", text_color, 0.02).set_ease(Tween.EASE_IN)

func reset_tweens():
	$button_1.reset_tween_function()
	$button_2.reset_tween_function()
	$button_3.reset_tween_function()
	$button_4.reset_tween_function()

func reset():
	reset_tweens()
	var current_time = get_time()
	gamestate = 0
	if current_time > best_time_array[level]:
		best_time_array[level] = current_time
	$player.allow_movement = false
	$player.position.x = 400
	$player.position.y = -35
	$player.velocity.x = 0
	$player.velocity.y = 0
	$player.has_reset = true
	rotation_amount = 0
	$Level.rotation = 0
	$Level.clear()
	set_level()

func opening_delay():
	await get_tree().create_timer(1.0).timeout
	$player.allow_movement = true

func death_delay():
	await get_tree().create_timer(0.6).timeout
	$player.allow_movement = true

func game_loop():
	# title screen
	if gamestate == 0:
		# set the top text
		if best_time_array[level] <= 0:
			$top_text.text = "[center][shake rate=10 level=1 connected=1]PRESS THE ARROW KEYS TO PLAY![/shake][/center]"
		if best_time_array[level] > 0:
			$top_text.text = "[center][shake rate=10 level=1 connected=1]BEST TIME : " + "%01d:%02d[/shake][/center]" % format_time()
		# set the bottom text
		if $player.has_reset == false:
			$bottom_text.text = "[center][shake rate=10 level=1 connected=1]A GAME BY: KEVEN VAILLANCOURT[/shake][/center]"
		if $player.has_reset == true && level == 0:
			$bottom_text.text = "[center][shake rate=10 level=1 connected=1]~ LOGO-A-GO-GO ~[/shake][/center]"
		if $player.has_reset == true && level == 1:
			$bottom_text.text = "[center][shake rate=10 level=1 connected=1]~ CLOWN AROUND ~[/shake][/center]"
		if $player.has_reset == true && level == 2:
			$bottom_text.text = "[center][shake rate=10 level=1 connected=1]~ PUP-A-RAMA ~[/shake][/center]"
		if $player.has_reset == true && level == 3:
			$bottom_text.text = "[center][shake rate=10 level=1 connected=1]~ FLEA OR DIE ~[/shake][/center]"
		# set the button's in_gameplay variable to false
		$button_1.in_gameplay = false
		$button_2.in_gameplay = false
		$button_3.in_gameplay = false
		$button_4.in_gameplay = false
		# set delay so player can't move right away upon death
		if $player.has_died == true:
			death_delay()
			$player.has_died = false
		# set a longer delay for the opening so the buttons don't break
		if $player.has_died == false:
			opening_delay()
		$cursor.is_in_gameplay = false
		# start game when player moves
		if $player.allow_movement:
			if Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down") || Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right"):
				gamestate = 1
	# starting the game
	if gamestate == 1:
		# shrink donw the buttons so they don't interfere with gameplay
		$button_1.gameplay_tween_function()
		$button_2.gameplay_tween_function()
		$button_3.gameplay_tween_function()
		$button_4.gameplay_tween_function()
		# set the button's in_gameplay variable to true
		$button_1.in_gameplay = true
		$button_2.in_gameplay = true
		$button_3.in_gameplay = true
		$button_4.in_gameplay = true
		# initialize time as 0 so the timer doesn't start at the best time
		time_start = Time.get_ticks_msec()/1000
		gamestate = 2
	# actual gameplay
	if gamestate == 2:
		$cursor.is_in_gameplay = true
		$Level.rotation += rotation_amount
		rotation_amount += 0.0000025
		$top_text.text = "[center][shake rate=10 level=1 connected=1]TIME : " + "%01d:%02d[/shake][/center]" % format_time()
		$bottom_text.visible = false
	# on player death
	if $player.player_count <= 0:
		$player.has_died = true
		reset()
