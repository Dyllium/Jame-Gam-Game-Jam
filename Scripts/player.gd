extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@export var mineableLayer: TileMapLayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var input_buffer_timer: Timer = $InputBufferTimer
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var pickaxe_pivot: Node2D = $PickaxePivot
@onready var pickaxe_sprite: Sprite2D = $PickaxePivot/Sprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var miningparticles: GPUParticles2D = $PickaxePivot/miningparticles
@onready var camera: Camera2D = $Camera2D
@onready var mine_audio_player: AudioStreamPlayer2D = $MineAudioPlayer

const PICKAXE_1: CompressedTexture2D = preload("res://Assets/Pickaxe1.png")
const PICKAXE_2: CompressedTexture2D = preload("res://Assets/Pickaxe2.png")
const PICKAXE_3: CompressedTexture2D = preload("res://Assets/Pickaxe3.png")

var coyoteTimeActivated: bool = false
var tileHealth: Dictionary = {}
var tilePower: Dictionary = {}

const tileSize: Vector2 = Vector2(16,16)
const tileFallSize: float = 16.0
const SPEED: float = 100
const ACCEL: float = 600
const FRICTION: float = 800
const GRAVITY: float = 980
const JUMP_FORCE: float = 225


var safeTileLimits: Array[int] = [4,6,8,10]
var peakHeight: float = 0
var inAir: bool = false

var gems: int = 0
var pickaxeLevel: int = 0
var bootLevel: int = 0

var miningPower: int = 1

signal gemsChanged(newAmount: int)

func _ready() -> void:
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_health_changed)

func _process(delta: float) -> void:
	var mousePos = get_global_mouse_position()
	pickaxe_pivot.look_at(mousePos)
	if mousePos.x < global_position.x:
		pickaxe_sprite.scale.y = -0.5
	else:
		pickaxe_sprite.scale.y = 0.5
		
	if position.y < 60:
		point_light_2d.enabled = false
	else:
		point_light_2d.enabled = true

func _physics_process(delta: float) -> void:
	#Apply Gravity
	if not is_on_floor():
		if not inAir:
			inAir = true
			peakHeight = global_position.y
		else:
			peakHeight = min(peakHeight, global_position.y)
		
		velocity.y += GRAVITY * delta
		
	else:
		#Fall Damage
		if inAir:
			play_landing_squash()
			check_fall_distance()
			inAir = false
	
	#Get Direction
	var inputDir = Input.get_axis("Left","Right")
	
	if is_on_wall() and velocity.y > 0 and inputDir:
		velocity.y = min(velocity.y, 100)
		peakHeight = global_position.y
		
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("Jump")
		else:
			sprite.play("Jump")
	elif inputDir != 0:
		sprite.play("Side")
		sprite.flip_h = (inputDir < 0)
	else:
		sprite.play("Front")
		sprite.flip_h = false
	#Left/Right Movement
	if inputDir:
		var targetVelocity: Vector2 = Vector2(inputDir * SPEED, 0)
		velocity = velocity.move_toward(targetVelocity, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	#Jump Logic
	if is_on_floor():
		coyoteTimeActivated = false
		coyote_timer.stop()
	else:
		if !coyoteTimeActivated:
			coyote_timer.start()
			coyoteTimeActivated = true
			
	if Input.is_action_just_pressed("Up"):
		input_buffer_timer.start()
	
	if (!input_buffer_timer.is_stopped() and (!coyote_timer.is_stopped() or is_on_floor())) or (!input_buffer_timer.is_stopped()  and is_on_wall()):
		velocity.y = -JUMP_FORCE
		coyoteTimeActivated = false
		coyote_timer.stop()
		input_buffer_timer.stop()
		
	move_and_slide()
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Mine"):
		try_mine()

func try_mine() -> void:
	if !mineableLayer:
		return
	
	var mousePos = get_global_mouse_position()
	if mousePos.distance_to(global_position) > 24:
		print("out of reach")
		return
	
	var localPos = mineableLayer.to_local(mousePos)
	var coords = mineableLayer.local_to_map(localPos)
	
	if mineableLayer.get_cell_source_id(coords) != -1:
		if not tileHealth.has(coords):
			var tileData = mineableLayer.get_cell_tile_data(coords)
			var startingHP = 1
			var startingPower = 1
			if tileData and tileData.get_custom_data("HP") != null and tileData.get_custom_data("Power") != null:
				startingHP = tileData.get_custom_data("HP")
				startingPower = tileData.get_custom_data("Power")
			tileHealth[coords] = startingHP
			tilePower[coords] = startingPower
		if pickaxeLevel >= tilePower[coords]:
			play_pickaxe_swing()
			mine_audio_player.pitch_scale = randf_range(0.9,1.1)
			mine_audio_player.play()
			camera.screen_shake(1,0.05)
			miningparticles.restart()
			tileHealth[coords] -= miningPower
		if tileHealth[coords] <= 0:
			var tileData = mineableLayer.get_cell_tile_data(coords)
			if tileData and tileData.get_custom_data("Gem") == true:
				gems += 1
				gemsChanged.emit(gems)
			mineableLayer.set_cell(coords, -1)
			tileHealth.erase(coords)
	else:
		pass

func _on_died() -> void:
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")

func _health_changed(current_health: int, max_health: int) -> void:
	camera.screen_shake(5,0.1)

func upgrade_pickaxe() -> void:
	pickaxeLevel += 1
	gemsChanged.emit(gems)
	match pickaxeLevel:
		1:
			miningPower = 2
			pickaxe_sprite.texture = PICKAXE_1
		2:
			miningPower = 4
			pickaxe_sprite.texture = PICKAXE_2
		3:
			miningPower = 6
			pickaxe_sprite.texture = PICKAXE_3
func upgrade_boots() -> void:
	bootLevel += 1
	gemsChanged.emit(gems)
	match bootLevel:
		1:
			pass
		2:
			pass
		3:
			pass

func check_fall_distance() -> void:
	var fallDistancePixels = global_position.y - peakHeight
	
	var tilesFallen = int(floor(fallDistancePixels/tileFallSize))
	
	var maxSafeTiles = safeTileLimits[clamp(bootLevel, 0, safeTileLimits.size() - 1)]
	if tilesFallen > maxSafeTiles:
		health_component.take_damage(1)

func play_landing_squash() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.3, 0.7), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

func play_pickaxe_swing() -> void:
	var tween = create_tween()
	tween.tween_property(pickaxe_sprite, "rotation", deg_to_rad(45), 0.05)
	tween.tween_property(pickaxe_sprite, "rotation", deg_to_rad(0), 0.05)
