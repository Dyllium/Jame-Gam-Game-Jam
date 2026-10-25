extends Node2D

@onready var mineable_tiles: TileMapLayer = $MineableTiles

@export var mapWidth: int = 20
@export var mapHeight: int = 81
@export var noiseThreshold: float = -0.1
@export var surfaceHeight: int = 3

const FLY_ENEMY_SCENE = preload("res://Scenes/fly_enemy.tscn")

var noise = FastNoiseLite.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_caves()
	#spawn_enemies()


func generate_caves() -> void:
	if !mineable_tiles:
		return
		
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.15
	
	mineable_tiles.clear()
	for x in range(mapWidth):
		for y in range(mapHeight):
			var coords = Vector2i(x,y)
			
			if y < surfaceHeight:
				mineable_tiles.set_cell(coords, -1)
			elif y == surfaceHeight:
				mineable_tiles.set_cell(coords, 0, Vector2i(1,0))
			elif y in range(surfaceHeight + 1, 26): #Crust
				var noiseVal = noise.get_noise_2d(x,y)
				
				#Air Tiles
				if noiseVal < noiseThreshold and noiseVal > -0.5:
					mineable_tiles.set_cell(coords, -1)
				#Ore Tiles
				elif noiseVal < -0.5:
					mineable_tiles.set_cell(coords, 0, Vector2i(4,0))
				#Ground Tiles
				else:
					mineable_tiles.set_cell(coords, 0, Vector2i(0,0))
			elif y in range(26, 50): #Mantle
				var noiseVal = noise.get_noise_2d(x,y)
				
				#Air Tiles
				if noiseVal < 0.05 and noiseVal > -0.5:
					mineable_tiles.set_cell(coords, -1)
				#Lava Tiles
				#elif noiseVal < -0.5:
					#mineable_tiles.set_cell(coords, 0, Vector2i(1,1))
				#Ground Tiles
				else:
					mineable_tiles.set_cell(coords, 0, Vector2i(2,0))
			elif y in range(50, 75): #Core
				var noiseVal = noise.get_noise_2d(x,y)
				
				#Air Tiles
				if noiseVal < 0.2 and noiseVal > -0.5:
					mineable_tiles.set_cell(coords, -1)
				else:
					mineable_tiles.set_cell(coords, 0, Vector2i(3,0))
			elif y == 80:
				mineable_tiles.set_cell(coords, 0, Vector2i(3,0))
				
func spawn_enemies() -> void:
	for x in range(mapWidth):
		for y in range(surfaceHeight+ 1, mapHeight):
			var coords = Vector2i(x,y)

			if mineable_tiles.get_cell_source_id(coords) == -1:
				if randf() < 0.02:
					spawn_enemy_at(coords, FLY_ENEMY_SCENE)
		
func spawn_enemy_at(coords: Vector2i, enemy: PackedScene) -> void:
	var enemy_instance = enemy.instantiate()
	
	var pixelPos = mineable_tiles.map_to_local(coords)
	
	enemy_instance.global_position = pixelPos
	get_tree().current_scene.add_child(enemy_instance)
