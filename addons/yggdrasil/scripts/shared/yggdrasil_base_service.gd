@tool
class_name YggdrasilBaseService
extends RefCounted

var _tree_view: YggdrasilTreeView
var _tree_data: YggdrasilTree
var _scene: PackedScene

func _init(tree_view: YggdrasilTreeView):
	_tree_view = tree_view

func set_scene(scene: PackedScene) -> void:
	_scene = scene
	
func _position(object: Control, position: Vector2):
	object.set_position(position - (object.size / 2) + (_tree_data.size / 2))
