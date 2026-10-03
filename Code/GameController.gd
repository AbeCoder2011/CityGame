extends Node2D

signal finished

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
var BuildingAmounts := {}

var time : float = 0

func _ready() -> void:
	Global.SetCurrentFrameTime()
	$UI.SetLoadProgress("Setting Values...",0)
	Global.Money = {1:300,2:200,3:100,4:70,5:70}[Global.Difficulty]
	Global.Population = 0
	Global.BuildingUses = {}
	Global.CurrentBuilding = "None"
	Global.LoadAchievementProgress()
	$Autosaver.wait_time = Global.Settings.get("autosave_interval",60)
	$Autosaver.start()
	$Background/Grid.position = (Vector2(Global.GameSettings.get("map_size",20),Global.GameSettings.get("map_size",20)) * 6 * 48 * -1)
	$Background/Grid.region_rect = Rect2(Vector2(0,0),(Vector2(Global.GameSettings.get("map_size",20),Global.GameSettings.get("map_size",20)) * 6 * 48 * 2))
	
	if Global.LoadSettings["load"]:
		
		LoadGame()
		
		await finished
		$"UI".SetLoadProgress("Loading save...",100)
		await get_tree().process_frame
		
		$Areas.GenerateAreas()
		
		await finished
		$"UI".SetLoadProgress("Loading save...",100)
		await get_tree().process_frame
		
		$"Terrain".Generate()
		
		await finished
		$"UI".SetLoadProgress("Generating Terrain...",100)
		await get_tree().process_frame
	else:
		if Global.Difficulty <= 2:
			for n in starter_buildings:
				$Buildings.NewBuilding(n["name"],n["pos"],false)
		
		$Areas.GenerateAreas()
		
		await finished
		$"UI".SetLoadProgress("Placing Areas...",100)
		await get_tree().process_frame
		
		# Find valid non-water seed
		var valid = false
		var s = 0
		while not valid:
			s = randi()
			valid = $Terrain.ValidateSeed(s)
			print(s," is valid ",valid)
		$"Terrain".seed = s
		$"Terrain".Generate()
		
		await finished
		$"UI".SetLoadProgress("Generating Terrain...",100)
		await get_tree().process_frame
		
	$UI.SetLoadProgress("Finishing Up...",0)
	await get_tree().process_frame
	
	UpdateCityStats()
	for n in Global.BuildingData.keys():
		if not UnlockedBuildings.get(n,false):
			UnlockedBuildings[n] = !Global.UnlockRequirements.has(n)
		if UnlockedBuildings[n]:
			$UI.already_unlocked.append(n)
	$UI.SetLoadProgress("Finishing Up...",100)
	await get_tree().process_frame
	$"UI/UI/Fade/Label".hide()
	$"UI/UI/Fade/ProgressBar".hide()
	$"UI/UI/Fade/AnimationPlayer".play("fade_in")
# Time lol
#func _process(delta: float) -> void:
	#time += 100 * delta
	#if time >= 2400:
		#time = 0
	#if time < 800 or time > 1900:
		#modulate = Color(.27,.27,.27)
	#else:
		#modulate = Color(1,1,1)

func UpdateCityStats():
	$UI.UpdateCityStats()

func CheckAchievementProgress(b_amounts : Dictionary,something_happened=false) -> void:
	BuildingAmounts = b_amounts
	var changes = {}
	for n in Global.ACHIEVEMENTS.keys():
		if Global.IsAchievementUnlocked(n):
			continue 
		
		var prog = []
		for p in Global.ACHIEVEMENTS[n]["requirements"]:
			if something_happened or p["type"] == "money":
				prog.append(GetRequirementProgress(p))
		if prog.is_empty():
			continue
		var unlock = true
		for d in prog:
			if d is bool and not d:
				unlock = false
			elif d is bool and d:
				continue
			elif d is int:
				unlock = d
				break
		if not is_same(Global.AchievementProgress.get(n,false),unlock):
			changes[n] = unlock
			
	if not changes.is_empty():
		Global.UpdateAchievementProgress(changes)
		for n in changes.keys():
			$UI.UpdateAchievementProgress(n)
	
	

func GetRequirementProgress(d : Dictionary) -> Variant:
	match d["type"]:
		"income":
			return GetValueReached(Global.Income * 2,d["amount"],d.get("exact",false))
		"happiness":
			return GetValueReached(Global.Happiness,d["amount"],d.get("exact",false))
		"money":
			return GetValueReached(Global.Money,d["amount"],d.get("exact",false))
		"population":
			return GetValueReached(Global.Population,d["amount"],d.get("exact",false))
		"building":
			if d.has("name"):
				return GetValueReached(BuildingAmounts.get(d["name"],0),d["amount"],d.get("exact",false))
			return GetValueReached(BuildingAmounts.get("total",0),d["amount"],d.get("exact",false))
		"peak_buildings":
			return GetValueReached($Buildings.PeakBuildings,d["amount"],d.get("exact",false))
		_:
			printerr(d["type"]," is not configured in the achievement checker!")
	return false

# Takes a value and target, returns the percentage of completion, or true if completed, or false if the value is still 0
func GetValueReached(v:float,target:float,exact=false) -> Variant:
	if exact:
		return floor(v) == target
	else:
		if v >= target:
			return true
		else:
			return int(floor(v / target * 100))
	


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
					if current_building_counts["total"] >= r["amount"]:
						UnlockedBuildings[b] = true


# save en load stuff

const SAVE_PATH := "user://saves/"
const SAVE_NAME := "save.tres"
const SAVE_FILE := preload("res://Code/SaveFile.gd")
func SaveGame(autosave=false):
	if autosave and not Global.Settings.get("autosave",true):
		return
	DirAccess.make_dir_absolute(SAVE_PATH)
	var save = {
		"ub": UnlockedBuildings,
		"buildings": $Buildings.BuildingCollections,
		"money":Global.Money,
		"pop":Global.Population,
		"happ":Global.Happiness,
		"uses":Global.BuildingUses,
		"diff":Global.Difficulty,
		"settings":Global.GameSettings,
		"peak":$Buildings.PeakBuildings,
		"open_areas":$Areas.OpenAreas,
		"buildable":BuildableAreas,
		"seed": $"Terrain".seed,
	}
	var resource = SAVE_FILE.new()
	resource.save = save
	ResourceSaver.save(resource, SAVE_PATH + SAVE_NAME)
	print("Game saved succesfully!")

func LoadGame():
	$UI.SetLoadProgress("Loading save...",0)
	await get_tree().process_frame
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
	Global.GameSettings = save.get("settings",{})
	print("Save Settings: ",save.get("settings",{}))
	$"Terrain".seed = save.get("seed", randi())
	UnlockedBuildings = save.get("ub",{})
	$"UI".CheckBuildingUnlocks()
	BuildableAreas = save.get("buildable",[Rect2(-3,-3,6,6)])
	$Areas.OpenAreas = save["open_areas"]
	$Buildings.PeakBuildings = save["peak"]
	var length = len(save["buildings"].values())
	var i = 0.0
	print(length)
	print(i)
	
	for coll in save["buildings"].values():
		var coll_size = len(coll)
		var last = i
		var this_i = 0
		for b in coll:
			$Buildings.NewBuilding(b["name"],b["pos"],false)
			this_i += 1
			$UI.SetLoadProgress("Loading save...",clamp(floor(i/length*100),0,100))
			await Global.CheckFrame()
		i = last
		i += 1.0
		print(i/length)
		
		await get_tree().process_frame
	print("Loaded save!")
	finished.emit()
	

func DeleteSave():
	DirAccess.remove_absolute(SAVE_PATH + SAVE_NAME)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveGame()
#
#func SetLoadProgress(nam:String,prog:int):
	#$UI/Fade/Label.text = nam
	#$UI/Fade/ProgressBar.value = prog
	
	
