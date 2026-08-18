extends Node2D


var terrain_noise := FastNoiseLite.new()
var type_noise := FastNoiseLite.new()

const MAP_RADIUS := 60         # generates a MAP_RADIUS x MAP_RADIUS area centered on 0,0
const CLUSTER_THRESHOLD := -0.4 # higher = fewer, tighter clusters. lower = more coverage
const FILL_CHANCE := 1      # even inside a cluster, skip some tiles to leave gaps

var occupied := {}  # Vector2i -> true, tracks all claimed tiles (including multi-tile footprints)

var UnlockedBuildings := {}

func _ready() -> void:
	UpdateCityStats()
	await get_tree().process_frame
	#GenerateEnvironment()
	for n in Global.BuildingData.keys():
		UnlockedBuildings[n] = Global.UnlockRequirements.has(n)

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
	for r in Global.UnlockRequirements:
		if Global.UnlockedBuildings.get(r, false):
			continue #already unlocked brrrr
		
		
		
