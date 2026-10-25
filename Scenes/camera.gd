extends Camera2D

var shakeIntensity: float = 0
var activeShakeTime: float = 0

var shakeDecay: float = 5

var shakeTime: float = 0
var shakeTimeSpeed: float = 20

var noise = FastNoiseLite.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if activeShakeTime > 0:
		shakeTime += delta * shakeTimeSpeed
		activeShakeTime -= delta
		
		offset = Vector2(
			noise.get_noise_2d(shakeTime,0) * shakeIntensity,
			noise.get_noise_2d(0, shakeTime) * shakeIntensity
		)
		
		shakeIntensity = max(shakeIntensity - shakeDecay * delta, 0)
	else:
		offset = lerp(offset, Vector2.ZERO, 10.5 * delta)

func screen_shake(intensity: int, time: float):
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	
	shakeIntensity = intensity
	activeShakeTime = time
	shakeTime = 0
