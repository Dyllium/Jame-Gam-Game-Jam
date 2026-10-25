extends HBoxContainer

@export var heartScene: PackedScene
@onready var healthComponent: HealthComponent = get_tree().get_first_node_in_group("Player").get_node("HealthComponent")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		healthComponent.health_changed.connect(_on_health_changed)
		initialize_hearts(healthComponent.max_health)

func initialize_hearts(max_hp: int) -> void:
	for child in get_children():
		child.queue_free()
		
	var total_hearts = ceili(max_hp / 1)
	for i in range(total_hearts):
		var heart = heartScene.instantiate()
		add_child(heart)

func _on_health_changed(current_health: int, max_health: int) -> void:
	var hearts = get_children()
	for i in range(hearts.size()):
		var heart_value = current_health - (i * 1)
		if heart_value >= 1:
			hearts[i].update_heart(1) # Full
		else:
			hearts[i].update_heart(0) # Empty
