class_name HealthComponent
extends Node

signal health_changed(current_health: int, max_health: int)
signal died
@export var damageAudioPlayer: AudioStreamPlayer2D
const HURT_SOUNDS: Array[AudioStream] = [
	preload("res://sounds/hurt.wav"),
	preload("res://sounds/hurt2.wav"),
	preload("res://sounds/hurt3.wav"),
	preload("res://sounds/hurt4.wav"),
	preload("res://sounds/hurt5.wav")
]
@export var max_health: int = 5
var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	if current_health <= 0:
		return
	current_health = clampf(current_health - amount, 0, max_health)
	damageAudioPlayer.stream = HURT_SOUNDS.pick_random()
	damageAudioPlayer.pitch_scale = randf_range(0.95, 1.05)
	damageAudioPlayer.play()
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		died.emit()
		return
	print(current_health)
