extends AnimatableBody2D

# preload the particle graphics
var particle_1 = preload("res://images/falseBlock_particle_1.png")
var particle_2 = preload("res://images/falseBlock_particle_2.png")
var particle_3 = preload("res://images/falseBlock_particle_3.png")

func _ready() -> void:
	SignalBus.connect("check_level", change_graphics)

func _process(_delta) -> void:
	$GPUParticles2D.set_global_rotation_degrees(0)

func change_graphics(name:int):
	if name == 1:
		$AnimatedSprite2D.play("level 1")
		$GPUParticles2D.set_texture(particle_1)
	if name == 2:
		$AnimatedSprite2D.play("level 2")
		$GPUParticles2D.set_texture(particle_2)
	if name == 3:
		$AnimatedSprite2D.play("level 3")
		$GPUParticles2D.set_texture(particle_3)

func emit():
	$CollisionShape2D.disabled = true
	$AnimatedSprite2D.visible = false
	$GPUParticles2D.emit_particle(Transform2D.IDENTITY, Vector2(15,-130), Color.WHITE, Color.WHITE, $GPUParticles2D.EMIT_FLAG_VELOCITY)
	$GPUParticles2D.emit_particle(Transform2D.IDENTITY, Vector2(-15,-130), Color.WHITE, Color.WHITE, $GPUParticles2D.EMIT_FLAG_VELOCITY)
	$GPUParticles2D.emit_particle(Transform2D.IDENTITY, Vector2(40,-100), Color.WHITE, Color.WHITE, $GPUParticles2D.EMIT_FLAG_VELOCITY)
	$GPUParticles2D.emit_particle(Transform2D.IDENTITY, Vector2(-40,-100), Color.WHITE, Color.WHITE, $GPUParticles2D.EMIT_FLAG_VELOCITY)
	await get_tree().create_timer(5).timeout
	queue_free()
