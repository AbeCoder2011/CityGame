@tool
class_name YggdrasilBuilder
extends RefCounted
## A builder for YggdrasilTree that returns YggdrasilTreeView

const Yggdrasil = preload("res://addons/yggdrasil/scripts/shared/yggdrasil.gd")
const DefaultDecorationScene = preload("res://addons/yggdrasil/scenes/shared/yggdrasil_default_node.tscn")
const DefaultNodeScene = preload("res://addons/yggdrasil/scenes/shared/yggdrasil_default_node.tscn")
const DefaultLineScene = preload("res://addons/yggdrasil/scenes/shared/yggdrasil_default_connection.tscn")
const DefaultTooltipScene = preload("res://addons/yggdrasil/scenes/shared/yggdrasil_node_tooltip.tscn")

var _tree: YggdrasilTree

var _tree_view: YggdrasilTreeView
var _parent: Node
var _save_path: String

var _decoration_scene: PackedScene
var _node_scene: PackedScene
var _line_scene: PackedScene
var _tooltip_scene: PackedScene

var _tree_version_mismatch_callback: Callable

var _decoration_created_callback: Callable

var _node_created_callback: Callable
var _node_allocated_callback: Callable
var _node_deallocated_callback: Callable

var _prefab_created_callback: Callable
var _line_created_callback: Callable

var _preallocation_check_callback: Callable
var _allocation_check_callback: Callable
var _deallocation_check_callback: Callable
var _node_refund_check_callback: Callable

func _init(tree_data: YggdrasilTree):
	_tree = tree_data
	_decoration_scene = DefaultDecorationScene
	_node_scene = DefaultNodeScene
	_line_scene = DefaultLineScene
	_tooltip_scene = DefaultTooltipScene

func set_parent(parent: Node) -> YggdrasilBuilder:
	_parent = parent
	return self

func set_save_path(save_path: String) -> YggdrasilBuilder:
	_save_path = save_path
	return self

func set_decoration_scene(decoration_scene: PackedScene) -> YggdrasilBuilder:
	_decoration_scene = decoration_scene
	return self

func set_node_scene(node_scene: PackedScene) -> YggdrasilBuilder:
	_node_scene = node_scene
	return self

func set_line_scene(line_scene: PackedScene) -> YggdrasilBuilder:
	_line_scene = line_scene
	return self

func set_tooltip_scene(tooltip_scene: PackedScene) -> YggdrasilBuilder:
	_tooltip_scene = tooltip_scene
	return self

func tree_version_mismatch_callback(callback: Callable) -> YggdrasilBuilder:
	_tree_version_mismatch_callback = callback
	return self

func decoration_created_callback(callback: Callable) -> YggdrasilBuilder:
	_decoration_created_callback = callback
	return self

func node_created_callback(callback: Callable) -> YggdrasilBuilder:
	_node_created_callback = callback
	return self

func node_allocated_callback(callback: Callable) -> YggdrasilBuilder:
	_node_allocated_callback = callback
	return self

func node_deallocated_callback(callback: Callable) -> YggdrasilBuilder:
	_node_deallocated_callback = callback
	return self

func prefab_created_callback(callback: Callable) -> YggdrasilBuilder:
	_prefab_created_callback = callback
	return self

func line_created_callback(callback: Callable) -> YggdrasilBuilder:
	_line_created_callback = callback
	return self

func preallocation_check_callback(callback: Callable) -> YggdrasilBuilder:
	_preallocation_check_callback = callback
	return self

func allocation_check_callback(callback: Callable) -> YggdrasilBuilder:
	_allocation_check_callback = callback
	return self

func deallocation_check_callback(callback: Callable) -> YggdrasilBuilder:
	_deallocation_check_callback = callback
	return self

func node_refund_check_callback(callback: Callable) -> YggdrasilBuilder:
	_node_refund_check_callback = callback
	return self

func build() -> YggdrasilTreeView:
	if not _parent:
		push_error("YggdrasilBuilder: Parent node not set. Use set_parent() to set a parent before building.")
		return null

	_tree_view = YggdrasilTreeView.new()

	if _tree_version_mismatch_callback:
		_tree_view.tree_version_mismatch.connect(_tree_version_mismatch_callback)

	if _decoration_created_callback:
		_tree_view.decoration_created.connect(_decoration_created_callback)
	
	if _node_created_callback:
		_tree_view.node_created.connect(_node_created_callback)
	if _node_allocated_callback:
		_tree_view.node_allocated.connect(_node_allocated_callback)
	if _node_deallocated_callback:
		_tree_view.node_deallocated.connect(_node_deallocated_callback)
	
	if _prefab_created_callback:
		_tree_view.prefab_created.connect(_prefab_created_callback)
	
	if _line_created_callback:
		_tree_view.line_created.connect(_line_created_callback)

	_tree_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	_parent.add_child(_tree_view)

	if not Engine.is_editor_hint():
		YggdrasilSerializer.load_tree_state(_tree, _save_path)

	_tree_view.load_tree(_tree, _decoration_scene, _node_scene, _line_scene, _tooltip_scene)

	if _preallocation_check_callback:
		_tree_view.allocation_service.preallocation_check = _preallocation_check_callback
	if _allocation_check_callback:
		_tree_view.allocation_service.allocation_check = _allocation_check_callback
	if _deallocation_check_callback:
		_tree_view.allocation_service.deallocation_check = _deallocation_check_callback
	if _node_refund_check_callback:
		_tree_view.allocation_service.refund_check = _node_refund_check_callback

	return _tree_view
