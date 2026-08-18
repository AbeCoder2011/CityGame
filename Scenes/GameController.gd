extends Node2D


var terrain_noise := FastNoiseLite.new()
var type_noise := FastNoiseLite.new()

const MAP_RADIUS := 60         # generates a MAP_RADIUS x MAP_RADIUS area centered on 0,0
const CLUSTER_THRESHOLD := -0.4 # higher = fewer, tighter clusters. lower = more coverage
const FILL_CHANCE := 1      # even inside a cluster, skip some tiles to leave gaps

var occupied := {}  # Vector2i -> true, tracks all claimed tiles (including multi-tile footprints)

var UnlockedBuildings := {}

func _ready() -> void:
	LoadGame()
	_init_autosave()
	UpdateCityStats()
	for n in Global.BuildingData.keys():
		UnlockedBuildings[n] = !Global.UnlockRequirements.has(n)
		if UnlockedBuildings[n]:
			$UI.already_unlocked.append(n)
	await get_tree().process_frame
	#GenerateEnvironment()

func UpdateCityStats():
	$UI.UpdateCityStats()

func GenerateEnvironment():
	terrain_noise.seed = randi()
	terrain_noise.frequency = -0.5   # low frequency = large, smooth clusters
	terrain_noise.noise_type = FastNoiseLite.TYPE_PERLIN

	type_noise.seed = randi()
	type_noise.frequency = 0.15      # higher frequency = variety within a cluster
	type_noise.noise_type = FastNoiseLite.TYPE_PERLIN

	for x in range(1, MAP_RADIUS):
		for y in range(1, MAP_RADIUS):
			var pos := Vector2i(x, y)
			TryPlaceEnvironment(pos)

func TryPlaceEnvironment(pos: Vector2i):
	if occupied.has(pos):
		return

	var cluster_value = terrain_noise.get_noise_2d(pos.x, pos.y)
	if cluster_value < CLUSTER_THRESHOLD:
		return  # not inside a cluster region at all - leave empty for other buildings

	if randf() > FILL_CHANCE:
		return  # inside a cluster, but randomly skip to keep it from being fully solid

	var type_value = type_noise.get_noise_2d(pos.x, pos.y)
	var building_name := ""
	var size := Vector2i(1, 1)

	# Split the cluster into terrain types by noise band + intensity of the cluster itself
	if cluster_value > 0.4:
		# Strongest cluster centers become mountains
		building_name = "Large Mountain"
		size = Vector2i(2, 2)
	elif type_value > 0.25:
		building_name = "Large Forest" if cluster_value > 0.1 else "Small Forest"
		size = Vector2i(2, 2) if building_name == "Large Forest" else Vector2i(1, 1)
	elif type_value < -0.25:
		building_name = "Large Wheatfield" if cluster_value > 0.1 else "Small Wheatfield"
		size = Vector2i(2, 2) if building_name == "Large Wheatfield" else Vector2i(1, 1)
	else:
		return

	if not CanPlace(pos, size):
		return

	ClaimTiles(pos, size)
	$Buildings.NewBuilding(building_name, pos)

func CanPlace(pos: Vector2i, size: Vector2i) -> bool:
	for dx in range(size.x):
		for dy in range(size.y):
			if occupied.has(pos + Vector2i(dx, dy)):
				return false
	return true

func ClaimTiles(pos: Vector2i, size: Vector2i):
	for dx in range(size.x):
		for dy in range(size.y):
			occupied[pos + Vector2i(dx, dy)] = true

func CheckBuildingUnlocks(current_building_counts:Dictionary):
	for b in Global.UnlockRequirements.keys():
		for r in Global.UnlockRequirements[b]:
			if UnlockedBuildings.get(r, false):
				continue #already unlocked brrrr
			match r["type"]:
				"population":
					if Global.Population >= r["amount"]:
						UnlockedBuildings[b] = true
				"money":
					if Global.Money >= r["amount"]:
						UnlockedBuildings[b] = true
				"building_count":
					if current_building_counts.get(r["building"], 0) >= r["amount"]:
						UnlockedBuildings[b] = true
				"total_buildings":
					var total = 0
					for c in current_building_counts.values():
						total += c
					if total >= r["amount"]:
						UnlockedBuildings[b] = true


# save en load stuff

const SAVE_PATH := "user://savegame.json"
const AUTOSAVE_INTERVAL_SEC := 60.0
 
var _autosave_timer: Timer
 
func _init_autosave() -> void:
	_autosave_timer = Timer.new()
	_autosave_timer.wait_time = AUTOSAVE_INTERVAL_SEC
	_autosave_timer.autostart = true
	_autosave_timer.timeout.connect(SaveGame)
	add_child(_autosave_timer)
 
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveGame()
		get_tree().quit()
 
func SaveGame() -> void:
	var buildings_data := []
	for b in $Buildings.Buildings:
		buildings_data.append({
			"name": b["name"],
			"pos_x": b["pos"].x,
			"pos_y": b["pos"].y,
		})
 
	var save_data := {
		"version": 1,
		"money": Global.Money,
		"population": Global.Population,
		"unlocked_buildings": UnlockedBuildings,
		"already_unlocked": $UI.already_unlocked,
		"buildings": buildings_data,
	}
 
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveGame: could not open save file for writing (error %s)" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("Game saved to ", SAVE_PATH)
 
func LoadGame() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("LoadGame: no save file found.")
		return false
 
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("LoadGame: could not open save file for reading (error %s)" % FileAccess.get_open_error())
		return false
	var text := file.get_as_text()
	file.close()
 
	var parsed = JSON.parse_string(text)
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("LoadGame: save file is corrupted or unreadable.")
		return false
 
	# Clear existing buildings before restoring.
	for b in $Buildings.Buildings.duplicate():
		if is_instance_valid(b["node"]):
			b["node"].queue_free()
	$Buildings.Buildings.clear()
	$Buildings.DestroyedBuildings.clear()
 
	Global.Money = parsed.get("money", 100.0)
	Global.Population = parsed.get("population", 0)
 
	var loaded_unlocks = parsed.get("unlocked_buildings", null)
	if loaded_unlocks is Dictionary:
		UnlockedBuildings = loaded_unlocks
 
	for b in parsed.get("buildings", []):
		var pos := Vector2i(int(b["pos_x"]), int(b["pos_y"]))
		$Buildings.NewBuilding(b["name"], pos)
	$UI.already_unlocked = parsed.get("already_unlocked", [])
	UpdateCityStats()
	$UI.CheckBuildingUnlocks()
	print("Game loaded from ", SAVE_PATH)
	return true
 
func HasSaveFile() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
 
func DeleteSave() -> void:
	if HasSaveFile():
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save file deleted.")
 
