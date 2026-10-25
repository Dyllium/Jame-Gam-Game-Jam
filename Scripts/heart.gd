extends TextureRect

@export var fullTexture: Texture2D
@export var emptyTexture: Texture2D

func update_heart(status: int) -> void:
	match status:
		1:
			texture = fullTexture
		0:
			texture = emptyTexture
