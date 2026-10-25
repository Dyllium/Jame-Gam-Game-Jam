extends CanvasModulate

const surfaceY: float = 40
const caveY: float = 50
@export var player: CharacterBody2D
@onready var undergound_cover: TileMapLayer = $"../UndergoundCoverTiles"

func _process(delta: float) -> void:
	if not player:
		return
	
	var player_y = player.global_position.y
	
	if player_y < surfaceY + 20.0:
		visible = false
		undergound_cover.visible= true
	else:
		visible = true
		undergound_cover.visible = false
		var depth_factor = clamp((player_y - surfaceY) / (caveY - surfaceY), 0.0, 1.0)
		
		var cave_color = Color("#0c0c14") 
		
		color = Color.WHITE.lerp(cave_color, depth_factor)
