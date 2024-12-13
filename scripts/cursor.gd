extends AnimatedSprite2D

var is_in_gameplay = false
var hover_over_button = false

func _process(_delta) -> void:
	var world_coordinates = get_viewport().canvas_transform.affine_inverse() * get_global_mouse_position()
	global_position = world_coordinates
	if is_in_gameplay == false && hover_over_button == false:
		if Input.is_action_pressed("ui_left_click"):
			play("cursor idle held")
		if Input.is_action_just_released("ui_left_click"):
			play("cursor idle released")
	if is_in_gameplay == false && hover_over_button == true:
		if Input.is_action_pressed("ui_left_click"):
			play("cursor click held")
		if Input.is_action_just_released("ui_left_click"):
			play("cursor click released")
	if is_in_gameplay == true && hover_over_button == true:
		play("cursor click pop")
	if is_in_gameplay == true && hover_over_button == false:
		play("cursor idle pop")

func _on_animatable_body_2d_area_entered(area: Area2D):
	if area.is_in_group("button"):
		hover_over_button = true
		play("cursor click")
	else:
		play("cursor idle")

func _on_animatable_body_2d_area_exited(area: Area2D):
	if area.is_in_group("button"):
		hover_over_button = false
		play("cursor idle")

func _on_animation_finished() -> void:
	if animation == "cursor idle pop":
		if is_in_gameplay == true:
			self.visible = false
		if is_in_gameplay == false:
			visible = true
			play_backwards("cursor idle pop")
			await animation_finished
			play("cursor idle")
	if animation == "cursor click pop":
		if is_in_gameplay == true:
			self.visible = false
		if is_in_gameplay == false:
			visible = true
			play_backwards("cursor click pop")
			await animation_finished
			play("cursor click")
