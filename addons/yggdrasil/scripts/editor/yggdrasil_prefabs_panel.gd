@tool
class_name PrefabPanelEditor
extends Control

const Yggdrasil = preload("res://addons/yggdrasil/scripts/shared/yggdrasil.gd")
const FuzzySearch = Yggdrasil.FuzzySearch

signal changed

@export var filter: LineEdit
@export var list: ItemList

@export var rename_shortcut: Shortcut
@export var rename_popup: Popup
@export var rename_line_edit: LineEdit
@export var apply_rename_button: Button
@export var cancel_rename_button: Button

const ICON_SIZE = Vector2(64, 64)
const ICON_CENTER_SIZE = Vector2(42, 42)

var editor: YggdrasilEditor

var _icons_cache: Dictionary[String, Texture2D] = {}
var _fuzzy: FuzzySearch = FuzzySearch.new()

func _ready():
	filter.text_changed.connect(_on_filter_text_changed)
	rename_line_edit.text_submitted.connect(_on_rename_submitted)
	apply_rename_button.pressed.connect(_on_apply_rename_pressed)
	cancel_rename_button.pressed.connect(_on_cancel_rename_pressed)

func _shortcut_input(event):
	if not is_visible_in_tree():
		return
	
	if not event.is_echo() and event.pressed:
		if rename_shortcut.matches_event(event):
			var selected = list.get_selected_items()
			if selected.size() == 0:
				return
			
			rename_line_edit.text = list.get_item_text(selected[0])
			rename_popup.popup_centered()
			rename_line_edit.grab_focus()
			rename_line_edit.select_all()
			get_viewport().set_input_as_handled()

func add_prefab(prefab: YggdrasilPrefab, is_copy: bool = false) -> void:
	var icon = null
	if not _icons_cache.has(prefab.reference_id):
		icon = DrawableTexture2D.new()
		icon.setup(ICON_SIZE.x, ICON_SIZE.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color(0, 0, 0, 0))
		
		_generate_icon(icon, prefab)
		
		_icons_cache[prefab.reference_id] = icon
	else:
		icon = _icons_cache[prefab.reference_id]

	var text = ""
	if prefab.node_name.is_empty():
		if is_copy:
			text = "New Copy"
		else:
			text = "New Prefab"
		
		prefab.node_name = text
	else:
		text = prefab.node_name
	
	var id = list.add_item(text, icon)
	list.set_item_metadata(id, prefab)

	if not prefab.icon_changed.is_connected(_on_prefab_icon_changed.bind(id)):
		prefab.name_changed.connect(_on_prefab_name_changed.bind(id))
		prefab.icon_changed.connect(_on_prefab_icon_changed.bind(id))
		prefab.border_changed.connect(_on_prefab_border_changed.bind(id))

func _on_rename_submitted(new_text: String):
	_on_apply_rename_pressed()

func _on_apply_rename_pressed():
	var selected = list.get_selected_items()
	if selected.size() == 0:
		return
	
	var id = selected[0]
	var prefab = list.get_item_metadata(id)
	prefab.set_node_name(rename_line_edit.text)
	list.set_item_text(id, rename_line_edit.text)
	rename_popup.hide()
	changed.emit()

func _on_cancel_rename_pressed():
	rename_popup.hide()

func _on_filter_text_changed(new_text: String):
	list.clear()
	
	var search_text = new_text.strip_edges()
	if search_text.is_empty():
		_refresh_list()
		return

	_fuzzy.set_query(search_text)

	var ids: Array[int] = []
	var id_to_text: Dictionary[int, String] = {}

	var prefabs = editor.tree.prefabs[get_index()]
	for i in range(prefabs.size()):
		var prefab = prefabs[i]
		ids.append(i)
		id_to_text[i] = prefab.node_name

	var targets = PackedStringArray(ids.map(func(id: int) -> String: return id_to_text[id]))
	var results: Array[FuzzySearch.FuzzySearchResult] = []
	_fuzzy.search_all(targets, results)

	var result: Array[int] = []
	for r in results:
		result.append(ids[r.original_index])
	
	for id in result:
		add_prefab(prefabs[id])

func _on_prefab_name_changed(prefab: YggdrasilPrefab, id: int):
	list.set_item_text(id, prefab.node_name)

func _on_prefab_icon_changed(prefab: YggdrasilPrefab, id: int):
	var icon = DrawableTexture2D.new()
	icon.setup(ICON_SIZE.x, ICON_SIZE.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color(0, 0, 0, 0))
	
	_generate_icon(icon, prefab)

	list.set_item_icon(id, icon)
	_icons_cache[prefab.reference_id] = icon

func _on_prefab_border_changed(prefab: YggdrasilPrefab, id: int):
	var icon = DrawableTexture2D.new()
	icon.setup(ICON_SIZE.x, ICON_SIZE.y, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color(0, 0, 0, 0))
	
	_generate_icon(icon, prefab)

	list.set_item_icon(id, icon)
	_icons_cache[prefab.reference_id] = icon

func _refresh_list():
	for prefab in editor.tree.prefabs[get_index()]:
		add_prefab(prefab)

func _generate_icon(icon: DrawableTexture2D, prefab: YggdrasilPrefab):
	var p = (ICON_SIZE.x - ICON_CENTER_SIZE.x) / 2
	
	if not prefab.icon:
		icon.blit_rect(Rect2(Vector2(p, p), ICON_CENTER_SIZE), Yggdrasil.BlankIcon)
	else:
		if prefab.icon is AtlasTexture:
			var image = Image.create(prefab.icon.region.size.x, prefab.icon.region.size.y, false, Image.FORMAT_RGBA8)
			image.blit_rect(prefab.icon.atlas.get_image(), prefab.icon.region, Vector2i(0, 0))
			
			var image_texture = ImageTexture.create_from_image(image)
			icon.blit_rect(Rect2(Vector2(p, p), ICON_CENTER_SIZE), image_texture)
		else:
			icon.blit_rect(Rect2(Vector2(p, p), ICON_CENTER_SIZE), prefab.icon)
	
	if prefab.border_normal:
		icon.blit_rect(Rect2(Vector2.ZERO, ICON_SIZE), prefab.border_normal)
	
	var mini_icon
	if prefab.reference_id.is_empty():
		mini_icon = EditorInterface.get_editor_theme().get_icon("ActionCopy", Yggdrasil.ICON_THEME)
	else:
		mini_icon = EditorInterface.get_editor_theme().get_icon("ResourcePreloader", Yggdrasil.ICON_THEME)
	
	icon.blit_rect(Rect2i(Vector2i(2, 2), Vector2i(16, 16)), mini_icon)

func get_drag_data(at_position: Vector2) -> Variant:
	var selected = list.get_item_at_position(at_position, true)
	if selected == -1:
		return null
	
	var item = list.get_item_text(selected)
	var prefab = list.get_item_metadata(selected)

	var preview = VBoxContainer.new()
	var node_size: Vector2 = editor.tree.get_node_size(prefab.type)

	var icon = TextureRect.new()
	icon.name = "Icon"
	icon.mouse_filter = MOUSE_FILTER_IGNORE
	if not prefab.icon:
		icon.texture = Yggdrasil.BlankIcon
	else:
		icon.texture = prefab.icon
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = node_size
	preview.add_child(icon)
	
	var border = TextureRect.new()
	border.name = "Border"
	border.mouse_filter = MOUSE_FILTER_IGNORE
	border.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	border.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.add_child(border)

	if prefab.border_normal:
		border.texture = prefab.border_normal
		border.size = node_size * editor.tree.border_scale
		border.set_anchors_and_offsets_preset(PRESET_CENTER, PRESET_MODE_KEEP_SIZE)
	
	var label = Label.new()
	label.text = item
	label.mouse_filter = MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview.add_child(label)

	label.reset_size()
	preview.reset_size()
	preview.offset_transform_enabled = true
	preview.offset_transform_position = Vector2(round(-preview.size.x * 0.5), round(-preview.size.y * 0.5)) + Vector2(-2, 14)
	preview.modulate = Color(1, 1, 1, 0.7)

	set_drag_preview(preview)

	return prefab
