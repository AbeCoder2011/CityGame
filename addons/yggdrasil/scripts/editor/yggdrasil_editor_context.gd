@tool
class_name YggdrasilEditorContext
extends PopupMenu

signal new_node(node_type: YggdrasilNode.NodeType)
signal duplicate_node
signal delete_node
signal save_as_prefab
signal save_as_copy
signal make_unique

@export var editor: YggdrasilEditor

@export_group("Shortcuts")
@export var duplicate_shortcut: Shortcut
@export var delete_shortcut: Shortcut

enum MenuOption {
	NEW_NODE_SMALL = 0,
	NEW_NODE_MEDIUM = 1,
	NEW_NODE_LARGE = 2,

	NEW_DECORATION = 1,
	DUPLICATE = 3,
	DELETE = 4,
	SAVE_AS_PREFAB = 6,
	SAVE_AS_COPY = 7,
	MAKE_UNIQUE = 8
}

func init():
	var new_node_submenu = PopupMenu.new()
	new_node_submenu.add_item("Small", MenuOption.NEW_NODE_SMALL)
	new_node_submenu.add_item("Medium", MenuOption.NEW_NODE_MEDIUM)
	new_node_submenu.add_item("Large", MenuOption.NEW_NODE_LARGE)
	new_node_submenu.id_pressed.connect(_on_new_node_selected)

	add_submenu_node_item("New Node", new_node_submenu, 0)
	add_item("New Decoration", MenuOption.NEW_DECORATION)
	add_separator()
	add_item("Duplicate", MenuOption.DUPLICATE)
	set_item_shortcut(MenuOption.DUPLICATE, duplicate_shortcut)
	set_item_disabled(MenuOption.DUPLICATE, true)
	add_item("Delete", MenuOption.DELETE)
	set_item_shortcut(MenuOption.DELETE, delete_shortcut)
	set_item_disabled(MenuOption.DELETE, true)
	add_separator()
	add_item("Save as Prefab", MenuOption.SAVE_AS_PREFAB)
	set_item_tooltip(MenuOption.SAVE_AS_PREFAB, "Saves selected node(s) as prefab(s) that share changes")
	set_item_disabled(MenuOption.SAVE_AS_PREFAB, true)
	add_item("Save as Copy", MenuOption.SAVE_AS_COPY)
	set_item_tooltip(MenuOption.SAVE_AS_COPY, "Saves selected node(s) as unique copies")
	set_item_disabled(MenuOption.SAVE_AS_COPY, true)
	add_item("Make Unique", MenuOption.MAKE_UNIQUE)
	set_item_tooltip(MenuOption.MAKE_UNIQUE, "Makes selected node(s) unique")
	set_item_disabled(MenuOption.MAKE_UNIQUE, true)

	id_pressed.connect(_on_context_menu_selected)

func _on_new_node_selected(id: int):
	new_node.emit(id)

func _on_context_menu_selected(id: int):
	match id:
		MenuOption.NEW_DECORATION:
			new_node.emit(YggdrasilNode.NodeType.DECORATION)
		MenuOption.DUPLICATE:
			duplicate_node.emit()
		MenuOption.DELETE:
			delete_node.emit()
		MenuOption.SAVE_AS_PREFAB:
			save_as_prefab.emit()
		MenuOption.SAVE_AS_COPY:
			save_as_copy.emit()
		MenuOption.MAKE_UNIQUE:
			make_unique.emit()

func update_items(node: YggdrasilNodeButton):
	var has_selection = node != null
	set_item_disabled(MenuOption.DUPLICATE, not has_selection)
	set_item_disabled(MenuOption.DELETE, not has_selection)
	set_item_disabled(MenuOption.SAVE_AS_PREFAB, not has_selection)
	set_item_disabled(MenuOption.SAVE_AS_COPY, not has_selection)
	set_item_disabled(MenuOption.MAKE_UNIQUE, not has_selection or not node.prefab)
