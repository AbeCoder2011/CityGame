@tool
class_name YggdrasilPrefabsBar
extends TabBar

signal changed

@export var editor: YggdrasilEditor
@export var prefab_panel_scene: PackedScene
@export var splitter: SplitContainer
@export var prefabs_panel: Control

enum TabIndex {
	SMALL_NODES,
	MEDIUM_NODES,
	LARGE_NODES,
	DECORATIONS,
}

var _tab: int = -1

func init():
	tab_selected.connect(_on_tab_selected)

	_add_tab("Small Nodes")
	_add_tab("Medium Nodes")
	_add_tab("Large Nodes")
	_add_tab("Decorations")

func destroy():
	clear_tabs()

func _add_tab(name):
	add_tab(name)
	var panel: PrefabPanelEditor = prefab_panel_scene.instantiate()
	panel.editor = editor
	panel.changed.connect(changed.emit)
	panel.visible = false
	prefabs_panel.add_child(panel)

func _on_tab_selected(tab_index):
	if _tab != -1:
		var prev_panel: PrefabPanelEditor = prefabs_panel.get_child(_tab)
		prev_panel.visible = false

	_tab = tab_index

	if tab_index == -1:
		splitter.collapsed = true
		prefabs_panel.hide()
		return

	var panel: PrefabPanelEditor = prefabs_panel.get_child(tab_index)
	if panel.visible:
		splitter.collapsed = true
		prefabs_panel.hide()
	else:
		splitter.collapsed = false
		prefabs_panel.show()
	
	panel.visible = not panel.visible

func get_panel(node_type: YggdrasilNode.NodeType) -> PrefabPanelEditor:
	return prefabs_panel.get_child(node_type)
