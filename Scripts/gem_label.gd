extends Label

@export var player: CharacterBody2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.gemsChanged.connect(_on_gems_changed)
	text = str(player.gems)


func _on_gems_changed(new_amount: int) -> void:
	text = str(new_amount)
