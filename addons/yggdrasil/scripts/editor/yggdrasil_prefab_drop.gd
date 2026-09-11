@tool
class_name YggdrasilPrefabDrop
extends Control

signal prefab_dropped(prefab: YggdrasilPrefab)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is YggdrasilPrefab:
		return true
	
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	prefab_dropped.emit(data)

func can_drop_prefab(at_position: Vector2, data: Variant) -> bool:
	return false

func drop_prefab(at_position: Vector2, prefab: YggdrasilPrefab) -> void:
	pass
