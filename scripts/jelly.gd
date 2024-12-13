extends AnimatableBody2D

func _ready() -> void:
	SignalBus.connect("check_level", change_graphics)

func change_graphics(name:int):
	if name == 2:
		$AnimatedSprite2D.play("level 2")
