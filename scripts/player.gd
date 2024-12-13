extends CharacterBody2D

# player variables
@export var speed = 200
@export_range(0.0, 1.0) var friction = 0.05
@export_range(0.0 , 1.0) var acceleration = 0.15
@export var gravity = 2250
@export var jump_velocity = -525
@export var ouch = false
@export var allow_movement = false
# game variables
var has_reset = false
var has_died = false
var dupe
var player_count = 1

func _process(_delta) -> void:
	player_count = get_tree().get_nodes_in_group("player").size()
	# handle what happens upon death
	if has_died == true:
		$AnimatedSprite2D.play("ouch")
		player_count = 1
		has_reset = true
	# test player dupes
	dupe = self.duplicate()
	if Input.is_action_just_pressed("ui_test_1") && self.position.y < 900:
		dupe.add_to_group("dupe")
		dupe.position.x += 10
		self.position.x += -10
		self.get_parent().add_child(dupe)
	if self.position.y >= 900:
		player_count -= 1
		if self.is_in_group("dupe"):
			self.queue_free()

# movement and physics
func _physics_process(delta):
	# vertical movement velocity (down)
	if not is_on_floor():
		velocity.y += gravity * delta
	# horizontal movement processing (left, right)
	horizontal_movement()
	# applies movement
	move_and_slide()
	# handles interactions with other objects (bouncing, etc.)
	check_object()

func horizontal_movement():
	# get inputs
	var dir = Input.get_axis("ui_left", "ui_right")
	# change max floor angle so player can better climb walls
	set_floor_max_angle(1.35)
	# move player with acceleration + friction
	if dir != 0 && allow_movement == true:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)

func false_block_action():
	var collision = get_slide_collision(0)
	await get_tree().create_timer(0.05).timeout
	collision.get_collider().emit()

func spikes_action():
	var collision = get_slide_collision(0)
	var knockback_direction = (global_position - collision.get_collider().global_position).normalized()
	velocity = knockback_direction * 800
	ouch = true
	ouchie()

func check_object():
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		# check for objects that aren't spikes
		if !collision.get_collider().is_in_group("spikes"):
			# handle bouncing
			if is_on_floor():
				# play impact animation
				$AnimatedSprite2D.play("impact")
				# make player bounce
				velocity.y = jump_velocity
				# make bounce higher 
				if Input.is_action_pressed("ui_down") && allow_movement == true:
					velocity.y = jump_velocity / 1.75
				# make bounce lower 
				if Input.is_action_pressed("ui_up") && allow_movement == true:
					velocity.y = jump_velocity * 1.75
				# check for false blocks
				if collision.get_collider().is_in_group("false_block"):
					false_block_action()
		# check for spikes
		if collision.get_collider().is_in_group("spikes"):
			spikes_action()

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "impact":
		$AnimatedSprite2D.play("idle")

func _on_hurt_effect_animation_finished() -> void:
	$hurt_effect.visible = false

func ouchie():
	# if player hasn't touched spikes
	if ouch == false:
		$hurt_effect.visible = false
	# if player has touched spikes
	if ouch == true:
		allow_movement = false
		$hurt_effect.visible = true
		$hurt_effect.play("hurt")
		$AnimatedSprite2D.play("ouch")
		ouch = false
		await get_tree().create_timer(0.5).timeout
		allow_movement = true
