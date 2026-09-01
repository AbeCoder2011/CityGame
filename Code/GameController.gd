extends Node2D


var terrain_noise := FastNoiseLite.new()
var type_noise := FastNoiseLite.new()

const MAP_RADIUS := 60         # generates a MAP_RADIUS x MAP_RADIUS area centered on 0,0
const CLUSTER_THRESHOLD := -0.4 # higher = fewer, tighter clusters. lower = more coverage
const FILL_CHANCE := 1      # even inside a cluster, skip some tiles to leave gaps
const AUTOSAVE_INTERVAL := 60.0

var occupied := {}  # Vector2i -> true, tracks all claimed tiles (including multi-tile footprints)
var starter_buildings = [{ "pos": Vector2i(-2, -1), "name": "Basic House"}, { "pos": Vector2i(0, -1), "name": "Basic House"}]

var BuildableAreas := [Rect2(-3,-3,6,6)]

var UnlockedBuildings := {}

func _ready() -> void:
	Global.Money = {1:300,2:200,3:100,4:70,5:70}[Global.Difficulty]
	Global.Population = 0
	Global.BuildingUses = {}
	Global.CurrentBuilding = "None"
	$Autosaver.wait_time = AUTOSAVE_INTERVAL
	$Autosaver.start()
	if Global.LoadSettings["load"]:
		LoadGame()
	else:
		if Global.Difficulty <= 2:
			for n in starter_buildings:
				$Buildings.NewBuilding(n["name"],n["pos"],false)
		$Areas.GenerateAreas()
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

const SAVE_PATH := "user://saves/"
const SAVE_NAME := "save.tres"
const SAVE_FILE := preload("res://Code/SaveFile.gd")
func SaveGame():
	DirAccess.make_dir_absolute(SAVE_PATH)
	var save = {
		"ub": UnlockedBuildings,
		"buildings": $Buildings.Buildings,
		"money":Global.Money,
		"pop":Global.Population,
		"happ":Global.Happiness,
		"uses":Global.BuildingUses,
		"diff":Global.Difficulty,
		"open_areas":$Areas.OpenAreas,
		"unlocks":UnlockedBuildings,
		"buildable":BuildableAreas,
		"seed": $"Terrain".seed,
	}
	var resource = SAVE_FILE.new()
	resource.save = save
	ResourceSaver.save(resource, SAVE_PATH + SAVE_NAME)
	print("Game saved succesfully!")

func LoadGame():
	if not ResourceLoader.exists(SAVE_PATH + SAVE_NAME):
		print("Savefile not found!")
		return
	var save = ResourceLoader.load(SAVE_PATH + SAVE_NAME).get("save")
	if save == null:
		print("Savefile not found or null!")
		return
	Global.Money = save["money"]
	Global.Population = save["pop"]
	Global.Happiness = save["happ"]
	Global.BuildingUses = save["uses"]
	Global.Difficulty = save["diff"]
	$"Terrain".seed = save.get("seed", randi())
	UnlockedBuildings = save["ub"]
	BuildableAreas = save.get("buildable",[Rect2(-3,-3,6,6)])
	UnlockedBuildings = save.get("unlocks",{})
	$Areas.OpenAreas = save["open_areas"]
	$Areas.GenerateAreas()
	$"Terrain".Generate()
	for n in save["buildings"]:
		$Buildings.NewBuilding(n["name"],n["pos"],false)
	print("Loaded save!")

func DeleteSave():
	DirAccess.remove_absolute(SAVE_PATH + SAVE_NAME)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveGame()
