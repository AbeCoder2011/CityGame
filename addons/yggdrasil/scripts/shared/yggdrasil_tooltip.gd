@tool
class_name YggdrasilTooltip
extends Control

@export var label: RichTextLabel

func _ready() -> void:
	visible = false

func inspect(node: YggdrasilNodeButton) -> void:
	label.text = node.format_tooltip()

func reset() -> void:
	label.text = ""
