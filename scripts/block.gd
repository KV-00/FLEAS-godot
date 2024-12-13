extends AnimatableBody2D

func _ready() -> void:
	SignalBus.connect("check_level", change_graphics)

func change_graphics(name:int):
	if name == 0:
		$AnimatedSprite2D.play("level 0")
	if name == 1:
		$AnimatedSprite2D.play("level 1")
	if name == 2:
		$AnimatedSprite2D.play("level 2")
	if name == 3:
		$AnimatedSprite2D.play("level 3")
