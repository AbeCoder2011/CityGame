@tool
class_name InspectorTextureInput
extends Control

signal texture_dropped(path: String)

@export var title: String
@export var title_label: Label
@export var texture_rect: TextureRect
@export var load_button: Button
@export var clear_button: Button
@export var empty_label: Label

func _enter_tree():
	title_label.text = title

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary:
		return data.has("type") and data["type"] == "files"

	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var file = data["files"][0]
	if file and ResourceLoader.exists(file, "Texture2D"):
		texture_dropped.emit(file)
