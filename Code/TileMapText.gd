@tool
extends RichTextLabel
## A RichTextLabel that understands a custom [tile] tag:
##
##   [tile x=1 y=0 w=16 h=16 f=3.0]res://Assets/Tilesheets/BuildingTiles/tiles.png[/tile]
##
## x, y : tile index in the sheet (default 0)
## w, h : size of one tile in pixels (default 16)
## f    : scale factor of the shown image (default 1.0)
##
## IMPORTANT: set the text through `source_text` (or set_source_text()),
## not through `text`. Godot does not let scripts hook the native `text`
## property, so `source_text` is what gets rewritten into [img] tags.

static var _tile_regex : RegEx
static var _attr_regex : RegEx

## Text containing [tile] tags. Setting this updates the label.
@export_multiline var source_text : String = "":
	set(value):
		source_text = value
		_apply()

## Use nearest-neighbour filtering so pixel art stays crisp when scaled.
@export var pixel_perfect := true:
	set(value):
		pixel_perfect = value
		texture_filter = TEXTURE_FILTER_NEAREST if value else TEXTURE_FILTER_PARENT_NODE


func _init() -> void:
	bbcode_enabled = true


func _ready() -> void:
	if pixel_perfect:
		texture_filter = TEXTURE_FILTER_NEAREST
	_apply()


func set_source_text(value: String) -> void:
	source_text = value


func _apply() -> void:
	text = parse(source_text)


## Rewrites every [tile ...]path[/tile] into a native [img region=...] tag.
## Static, so it can also be used on strings that go into other labels.
static func parse(input: String) -> String:
	if _tile_regex == null:
		_tile_regex = RegEx.new()
		_tile_regex.compile("\\[tile([^\\]]*)\\]\\s*(.*?)\\s*\\[/tile\\]")
		_attr_regex = RegEx.new()
		_attr_regex.compile("(\\w+)\\s*=\\s*(-?[0-9]*\\.?[0-9]+)")

	var out := ""
	var last := 0
	for m in _tile_regex.search_all(input):
		out += input.substr(last, m.get_start() - last)
		out += _build_img(m.get_string(1), m.get_string(2))
		last = m.get_end()
	out += input.substr(last)
	return out


static func _build_img(attr_text: String, path: String) -> String:
	var a := {"x": 0.0, "y": 0.0, "w": 16.0, "h": 16.0, "f": 1.0}
	for m in _attr_regex.search_all(attr_text):
		var key := m.get_string(1).to_lower()
		if a.has(key):
			a[key] = float(m.get_string(2))

	var tw : int = maxi(roundi(a["w"]), 1)
	var th : int = maxi(roundi(a["h"]), 1)
	var rx : int = roundi(a["x"]) * tw
	var ry : int = roundi(a["y"]) * th
	var dw : int = maxi(roundi(tw * a["f"]), 1)
	var dh : int = maxi(roundi(th * a["f"]), 1)

	return "[img region=%d,%d,%d,%d width=%d height=%d]%s[/img]" % [rx, ry, tw, th, dw, dh, path]
