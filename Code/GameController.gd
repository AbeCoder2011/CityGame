extends Node2D

signal finished

var terrain_noise := FastNoiseLite.new()
var type_noise := FastNoiseLite.new()

const AUTOSAVE_INTERVAL := 60.0

var occupied := {}  # Vector2i -> true, tracks all claimed tiles (including multi-tile footprints)
var starter_buildings = [{ "pos": Vector2i(-2, -1), "name": "Basic House"}, { "pos": Vector2i(0, -1), "name": "Basic House"}]

var BuildableAreas := [Rect2(-3,-3,6,6)]

var UnlockedBuildings := {}
var BuildingAmounts := {}

var SaveBuildings := {}


func _ready() -> void:
	$UI.UpdateAchievements()
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
		$"UI".SetLoadProgress("Placing areas...",100)
		await get_tree().process_frame
		
		$"Terrain".Generate()
		
		await finished
		$"UI".SetLoadProgress("Generating Terrain...",100)
		await get_tree().process_frame
		
		SpawnBuildings()
		
		await finished
		$"UI".SetLoadProgress("Spawning Buildings...",100)
		await get_tree().process_frame
		
	else:
		
		if Global.GameSettings.get("hacked",false):
			Global.Money = 1e80
			for n in Global.BuildingData.keys():
				get_node("/root/Main").UnlockedBuildings[n] = true
			get_node("/root/Main/UI").CheckBuildingUnlocks()
		
		if Global.Difficulty <= 2:
			for n in starter_buildings:
				$Buildings.NewBuilding(n["name"],n["pos"],false)
		
		$Areas.GenerateAreas()
		
		await finished
		$"UI".SetLoadProgress("Placing Areas...",100)
		await get_tree().process_frame
		var s = 0
		print(Global.GameSettings)
		if Global.GameSettings.get("seed") == null:
			print("no seed set")
			# Find valid non-water seed
			var valid = false
			while not valid:
				s = randi()
				valid = $Terrain.ValidateSeed(s)
		else:
			s = Global.GameSettings.get("seed",-1)
			print("seed set: ",s)
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
			return GetValueReached(Global.Income * 2,d["amount"],d.get("exact",false),d.get("less",false))
		"happiness":
			return GetValueReached(Global.Happiness,d["amount"],d.get("exact",false),d.get("less",false))
		"money":
			return GetValueReached(Global.Money,d["amount"],d.get("exact",false),d.get("less",false))
		"population":
			return GetValueReached(Global.Population,d["amount"],d.get("exact",false),d.get("less",false))
		"building":
			if d.has("name"):
				return GetValueReached(BuildingAmounts.get(d["name"],0),d["amount"],d.get("exact",false),d.get("less",false))
			return GetValueReached(BuildingAmounts.get("total",0),d["amount"],d.get("exact",false),d.get("less",false))
		"peak_buildings":
			return GetValueReached($Buildings.PeakBuildings,d["amount"],d.get("exact",false),d.get("less",false))
		_:
			printerr(d["type"]," is not configured in the achievement checker!")
	return false

# Takes a value and target, returns the percentage of completion, or true if completed, or false if the value is still 0
func GetValueReached(v:float,target:float,exact=false,less=false) -> Variant:
	if exact:
		return floor(v) == target
	else:
		if (v >= target) or (less and v <= target):
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
	if autosave:
		resource.image = await CaptureCityImage()
		MakeAutosave(resource)
		DeleteOldAutosaves()
	print("Game saved succesfully!")

func MakeAutosave(r:Resource):
	DirAccess.make_dir_absolute("user://autosaves/")
	var time = Time.get_datetime_dict_from_system()
	var string = str(time["year"]) + "-" + str(time["month"]) + "-" + str(time["day"]) + "-" + str(time["hour"]) + "-" + str(time["minute"]) + "-" + str(time["second"])
	ResourceSaver.save(r, "user://autosaves/" + string + ".tres")

func DeleteOldAutosaves():
	var dir := DirAccess.open("user://autosaves/")
	dir.list_dir_begin()
	var files : Array = dir.get_files()
	files.reverse()
	if len(files) > 12:
		var i = 0
		for n in files:
			i += 1
			print("%d: %s" % [i,n])
			if i > 12:
				DirAccess.remove_absolute("user://autosaves/" + n)
		pass # DELETE OLD AUTOSAVES
	

func LoadGame():
	$UI.SetLoadProgress("Loading save...",0)
	await get_tree().process_frame
	var save
	if Global.LoadSettings.get("custom_save") == null:
		if not ResourceLoader.exists(SAVE_PATH + SAVE_NAME):
			print("Savefile not found!")
			finished.emit()
			return
		save = ResourceLoader.load(SAVE_PATH + SAVE_NAME).get("save")
		if save == null:
			print("Savefile not found or null!")
			finished.emit()
			return
	else:
		if not ResourceLoader.exists("user://autosaves/" + str(Global.LoadSettings.get("custom_save"))):
			print("Custom Savefile not found!")
			finished.emit()
			return
		save = ResourceLoader.load("user://autosaves/" + str(Global.LoadSettings.get("custom_save"))).get("save")
		if save == null:
			print("Custom Savefile not found or null!")
			finished.emit()
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
	if Global.GameSettings.get("hacked",false):
		for n in Global.BuildingData.keys():
			get_node("/root/Main").UnlockedBuildings[n] = true
		get_node("/root/Main/UI").CheckBuildingUnlocks()
	$UI/UI/HackedLabel.visible = Global.GameSettings.get("hacked",false)
	BuildableAreas = save.get("buildable",[Rect2(-3,-3,6,6)])
	$Areas.OpenAreas = save["open_areas"]
	$Buildings.PeakBuildings = save["peak"]
	SaveBuildings = save["buildings"]
	print("Loaded save!")
	finished.emit()
	
func SpawnBuildings():
	await get_tree().process_frame
	var length = len(SaveBuildings.values())
	var i = 0.0
	for coll in SaveBuildings.values():
		var coll_size = len(coll)
		var last = i
		var this_i = 0
		for b in coll:
			$Buildings.NewBuilding(b["name"],b["pos"],false)
			this_i += 1
			$UI.SetLoadProgress("Spawning Buildings...",clamp(floor(i/length*100),0,100))
			await Global.CheckFrame()
		i = last
		i += 1.0
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
	
func GetCityRect() -> Rect2:
	var rect := Rect2()
	var empty := true
	for coll in $Buildings.BuildingCollections.values():
		for b in coll:
			var r := Rect2(Vector2(b["pos"]) * 48, Vector2($Buildings.GetSize(b["name"])) * 48)
			if empty:
				rect = r 
			else:
				rect.merge(r)
			empty = false
	if empty:  # default area
		var a : Rect2 = BuildableAreas[0]
		rect = Rect2(a.position * 48, a.size * 48)
	rect = rect.grow(96)  # make it bigger so it is cleaner
	return rect

func CaptureCityImage(img_size := Vector2i(480, 270)) -> Image:
	var city_rect := GetCityRect()

	var new_vp := SubViewport.new()
	new_vp.size = img_size
	new_vp.world_2d = get_viewport().world_2d
	new_vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var camera := Camera2D.new()
	new_vp.add_child(camera)
	add_child(new_vp)

	camera.global_position = city_rect.get_center()
	var z : float = min(img_size.x / city_rect.size.x, img_size.y / city_rect.size.y)
	camera.zoom = Vector2(z, z)

	$Builder/BuildingPreview.hide()  # it lives in the world, so hide it for the capture
	await RenderingServer.frame_post_draw
	var img := new_vp.get_texture().get_image()
	new_vp.queue_free()
	return img
