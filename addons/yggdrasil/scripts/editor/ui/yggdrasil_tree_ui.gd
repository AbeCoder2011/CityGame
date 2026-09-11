@tool
class_name YggdrasilTreeUI
extends Tree

signal edit_started(item: TreeItem)
signal edit_canceled(item: TreeItem)

@export var rename_shortcut: Shortcut

func init():
	create_item() # root

func _gui_input(event):
	if not is_visible_in_tree():
		return
	
	if event.is_action_released("ui_cancel"):
		if not has_focus():
			return
		
		var selected = get_selected()
		if not selected:
			return
		
		edit_canceled.emit(selected)

func _shortcut_input(event):
	if not is_visible_in_tree():
		return

	if event.is_pressed() and not event.is_echo():
		if rename_shortcut.matches_event(event):
			var selected = get_selected()
			if selected:
				edit_started.emit(selected)
				if get_selected():
					edit_selected(true)
				else:
					selected.select(0)
				get_viewport().set_input_as_handled()
