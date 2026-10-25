extends Area2D

@export var bootCosts: Array[int] = [5, 12, 25]
@export var pickaxeCosts: Array[int] = [5, 12, 25]
@onready var shop_label: Label = $ShopLabel
@onready var chaching: AudioStreamPlayer2D = $Chaching

var player: Node2D
var playerInside: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if shop_label:
		shop_label.text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		playerInside = true
		update_shop_text()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		playerInside = false
		player = null
		if shop_label:
			shop_label.text = ""


func _unhandled_input(event: InputEvent) -> void:
	if !playerInside or !player:
		return
		
	if event.is_action_pressed("upgrade_shoes"):
		upgrade_shoes()
		
	if event.is_action_pressed("upgrade_pickaxe"):
		upgrade_pickaxe()


func upgrade_pickaxe() -> void:
	var currentLvl = player.pickaxeLevel
	
	if currentLvl >= 3:
		return
		
	var cost = pickaxeCosts[currentLvl]
	if player.gems >= cost:
		player.gems -= cost
		player.upgrade_pickaxe()
		chaching.play()
		update_shop_text()
	else:
		return

func upgrade_shoes() -> void:
	var currentLvl = player.bootLevel
	
	if currentLvl >= 3:
		return
		
	var cost = bootCosts[currentLvl]
	if player.gems >= cost:
		player.gems -= cost
		player.upgrade_boots()
		chaching.play()
		update_shop_text()
	else:
		return

func update_shop_text() -> void:
	if !shop_label or !player:
		return
	var bootText = ""
	var pickText = ""
	
	if player.bootLevel >= bootCosts.size():
		bootText = "[E] Boots: MAX"
	else:
		var cost = bootCosts[player.bootLevel]
		bootText = "[E] Boots Level " + str(player.bootLevel + 1) + " (" + str(cost) + " Gems)"
	if player.pickaxeLevel >= pickaxeCosts.size():
		pickText = "[Q] Pickaxe: MAX"
	else:
		var cost = pickaxeCosts[player.pickaxeLevel]
		pickText = "[Q] Pickaxe Level " + str(player.pickaxeLevel + 1) + " (" + str(cost) + " Gems)"
	shop_label.text = bootText + "\n" + pickText
