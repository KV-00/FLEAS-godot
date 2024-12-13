extends Button
# variable to set what level the player gets sent to
@export var go_to_level = 0
# initialize tweens
var mouse_over_tween : Tween
var mouse_off_tween : Tween
var pressed_tween : Tween
var gameplay_tween : Tween
var reset_tween : Tween
# variable for the program opening
var opening_finished = false
# variable for if you're in gameplay or not
var in_gameplay = false

func _ready() -> void:
	self.button_down.connect(on_button_down)
	if go_to_level == 0:
		$AnimatedSprite2D.play("level 1")
	if go_to_level == 1:
		$AnimatedSprite2D.play("level 2")
	if go_to_level == 2:
		$AnimatedSprite2D.play("level 3")
	if go_to_level == 3:
		$AnimatedSprite2D.play("level 4")
	gameplay_tween_function()
	await get_tree().create_timer(1).timeout
	reset_tween_function()
	opening_finished = true

func mouse_over_tween_function():
	mouse_over_tween = create_tween()
	mouse_over_tween.tween_property(self, "scale", Vector2(1.1 , 1.1), 0.1).set_trans(Tween.TRANS_LINEAR)

func mouse_off_tween_function():
	mouse_off_tween = create_tween()
	mouse_off_tween.tween_property(self, "scale", Vector2(1.0 , 1.0), 0.1).set_trans(Tween.TRANS_LINEAR)

func pressed_tween_function():
	pressed_tween = create_tween()
	pressed_tween.tween_property(self, "scale", Vector2(0.8 , 0.8), 0.05).set_trans(Tween.TRANS_LINEAR)

func gameplay_tween_function():
	gameplay_tween = create_tween()
	gameplay_tween.tween_property(self, "scale", Vector2(0.0 , 0.0), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	self.disabled = true

func reset_tween_function():
	reset_tween = create_tween()
	reset_tween.tween_property(self, "scale", Vector2(1.0 , 1.0), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	self.disabled = false

func on_button_down():
	SignalBus.emit_signal("switch_level",go_to_level)
	pressed_tween_function()

func _on_button_up() -> void:
	if in_gameplay == false && opening_finished == true:
		mouse_over_tween_function()

func _on_mouse_entered() -> void:
	if in_gameplay == false && opening_finished == true:
		mouse_over_tween_function()

func _on_mouse_exited() -> void:
	if in_gameplay == false && opening_finished == true:
		mouse_off_tween_function()
