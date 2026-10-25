extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true


func _input(event: InputEvent) -> void:
	# Check if the player clicked anywhere with the left mouse button or tapped the screen
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_tree().paused = false
		queue_free()
