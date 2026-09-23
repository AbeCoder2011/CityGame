extends Node2D

signal deselect

var BuildingScene = preload("res://Scenes/building.tscn")
# EXAMPLE: [{"pos":Vector2i(23,33),"name":"Basic House","node":[NODE]}]
var BuildingCollections : Dictionary[Vector2i,Array] = {}
var AllHousingBuildings = []
var AllTrainRelatedBuildings = []
var AllPowerRelatedBuildings = []
var AllFishingBoats = []
var AllFishingDocks = []
var Rails : Dictionary[Vector2i, Node2D] = {}
var DestroyedBuildings = []


var ClaimCollections : Dictionary[String,Dictionary]= {}

var housing_edited = false
var network_inventories  : Array[Array] = []
var global_power = 0
var already_checked_buildings = []
var money_total = 0
var population_total = 0
var station_networks : Array[Array] = []

const SHOP_NAMES = [
	"Small Supermarket", "Large Supermarket", "Electronics Store","Cafe", "Bakery", "Restaurant", "Mall","Lumber Mill","Seafood Market"
]
const HOUSING_NAMES = [
	"Basic House", "Double House", "Small Apartment Complex","Large Apartment Complex", "Mega Apartment Complex","Low-Budget Apartment","Giant Apartment Complex"
]
const POWER_GENERATOR_NAMES = [
	"Thermal Power Plant", "Small Solar Farm", "Nuclear Power Plant", "Large Thermal Power Plant", "Large Solar Farm", "Wind Turbine"
]
const ENTERTAINMENT_NAMES = [
	"Theme Park","Cinema"
]
const FIXED_VALUES = [
	"Pocket Park", "Small Park", "Fountain Park", "Large Park", "Small Wheatfield", "Large Wheatfield", "Small Solar Farm", "Large Solar Farm", "Thermal Power Plant", "Large Thermal Power Plant","Nuclear Power Plant","Cinema","Theme Park","Animal Farm"
]
const MOVABLE_PROPERTIES = ["products","flour","electronics","livestock","meat","ores","gemstones"]
func AddToRemovalList(b:Dictionary):
	DestroyedBuildings.append(b)
	if Rails.has(b["pos"]) and Rails[b["pos"]] == b["node"]:
		Rails.erase(b["pos"])
		for offset in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var neighbor_pos = b["pos"] + offset
			if Rails.has(neighbor_pos):
				Rails[neighbor_pos].UpdateRailSprite()
	Global.Money += Global.BuildingData[b["name"]]["cost"] * 0.5
	$"../UI".UpdateCityStats()

func NewBuilding(nam:String, location:Vector2i,check_unlocks=true):
	var b : Node2D = BuildingScene.instantiate()
	b.position = location * 48
	add_child(b)
	if nam == "Rail":
		Rails[location] = b
	b.init_building(nam,location)
	deselect.connect(b.Deselect)
	var this_b := {"name":nam,"pos":location,"node":b,"claims":{}}
	_add_building_to_collection(this_b)
	if nam in HOUSING_NAMES:
		AllHousingBuildings.append(this_b)
	match nam:
		"Transformator Building":
			AllPowerRelatedBuildings.append(this_b)
		"Train Station","Rail":
			AllTrainRelatedBuildings.append(this_b)
		"Fishing Boat":
			AllFishingBoats.append(this_b)
		"Fishing Dock":
			AllFishingDocks.append(this_b)
	$"..".CheckBuildingUnlocks(GetBuildingAmounts())
	if check_unlocks:
		$"../UI".CheckBuildingUnlocks()
	if nam == "Rail" or nam == "Train Station":
		CalculateStationConnections()
		RecomputeStations()
	#if housing has been edited: recalculate stats etc
	housing_edited = false
	for n in GetRecomputePath(this_b):
		#if n["name"] in HOUSING_NAMES:
			#continue
		match n["name"]:
			"Train Station":
				RecomputeStations()
			"Transformator Building":
				RecomputePower()
			_:
				Recompute(n)
	if housing_edited:
		CalculateHapiness()
		RecomputePopulation()

func DeselectOthers():
	deselect.emit()

func GetCollectionPos(pos:Vector2i):
	return Vector2i(floor(Vector2(pos) / 8.0))

func _add_building_to_collection(b:Dictionary):
	#var size = GetSize(nam)
	#var cells = []
	#for x in range(size.x):
		#for y in range(size.y):
			#var cell = GetCollectionPos(pos + Vector2i(x,y))
			#cells.append(cell)
	#for c in cells:
		#if BuildingCollections.get_or_add(GetCollectionPos(pos),[]).has()
	BuildingCollections.get_or_add(GetCollectionPos(b["pos"]),[]).append({"name":b["name"],"pos":b["pos"],"node":b["node"],"claims":b["claims"]})

func _remove_building_from_collection(pos:Vector2i):
	var collection = GetCollectionPos(pos)
	for building in BuildingCollections[collection]:
		if building["pos"] == pos:
			BuildingCollections[collection].erase(building)
			return
	printerr("tried to erase ",pos,", but it was no longer in its collection ")

func _get_nearby_buildings(pos:Vector2i,size:Vector2i,radius:int) -> Array:
	var bottom_left = GetCollectionPos(pos - Vector2i(radius,radius))
	var top_right = GetCollectionPos(pos + Vector2i(radius - 1,radius - 1) + size)
	var seen = []
	for cellx in range(bottom_left.x, top_right.x + 1):
		for celly in range(bottom_left.y, top_right.y + 1):
			if BuildingCollections.has(Vector2i(cellx,celly)):
				for b in BuildingCollections[Vector2i(cellx,celly)]:
					if not b in seen:
						seen.append(b)
						
	return seen

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("move_building") and event.is_pressed():
		pass

func GetRailPath(pos_a: Vector2i, pos_b: Vector2i) -> Array:
	var station_offsets = [Vector2i.LEFT,Vector2i.UP,Vector2i(1,-1),Vector2i(2,0),Vector2i(2,1),Vector2i(1,2),Vector2i(0,2),Vector2i(-1,1)]
	var target_rect = Rect2(pos_b, Vector2(2,2))
	var visited := []
	station_offsets.shuffle()
	for dir in station_offsets:
		var new_pos = pos_a + dir
		if Rails.has(new_pos):
			var route = CheckPath(new_pos, target_rect, visited)
			if not route.is_empty():
				return route
	return []

func CheckPath(pos: Vector2i, target_rect: Rect2, visited: Array) -> Array:
	if pos in visited:
		return []
	visited.append(pos)

	var rail_dirs = [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.UP]

	# if the station is there: Return the stations position
	for dir in rail_dirs:
		if target_rect.has_point(pos + dir):
			return [pos]

	# else: check all rails around and recursively check them too
	for dir in rail_dirs:
		var neighbor = pos + dir
		if Rails.has(neighbor):
			var next_rail = CheckPath(neighbor, target_rect, visited)
			if not next_rail.is_empty():
				var new_path = [pos]
				new_path.append_array(next_rail)
				return new_path

	return []

# --- Helpers -------------------------------------------------

func GetSize(nam) -> Vector2i:
	return Global.BuildingData[nam].get("size",Vector2i(1,1))

func InRange(a:Vector2i, b:Vector2i, sizeA=Vector2i(1,1),sizeB=Vector2i(1,1),rad:int=0) -> bool:
	var recta = Rect2(a - Vector2i(rad,rad),Vector2i(sizeA+Vector2i(rad*2,rad*2)))
	var rectb = Rect2(b,sizeB)
	return recta.intersects(rectb)

func GetBuildingAmounts() -> Dictionary:
	var counts = {}
	for coll in BuildingCollections.values():
		for b in coll:
			counts[b["name"]] = counts.get(b["name"], 0) + 1
	return counts

# Count buildings of given names within radius of pos
func CountNearby(pos:Vector2i, size:Vector2i, names:Array, radius:int, exclude:Array = []) -> int:
	var count = 0
	for b in _get_nearby_buildings(pos,size,radius):
		if b["pos"] == pos or b["name"] in exclude:
			continue
		if names.has(b["name"]) and InRange(pos, b["pos"],size,GetSize(b["name"]),radius):
			count += 1
	return count
func Count_Terrain_Nearby(pos:Vector2i,size:Vector2i, id:int, radius:int, must_be_empty: bool=false) -> int:
	var count = 0
	for x in range(1 + radius*2):
		for y in range(1 + radius*2):
			if Vector2i(x-radius,y-radius) == Vector2i(0,0):
				continue
			if must_be_empty:
				var tmp = false
				for b in _get_nearby_buildings(pos,size,radius):
					if b["pos"] == (Vector2i(x-radius,y-radius)+pos):
						tmp = true
						break
				if tmp == true:
					continue
			if $"../Terrain".get_tile(Vector2i(x-radius,y-radius)+pos) == id:
				count += 1
	return count

# Calculates how much some property is in the area
func SumProperty(pos:Vector2i, size:Vector2i, names:Array, radius:int, prop:String,exclude:Array = [],reuse_debuff=false,dont_reuse=false) -> float:
	var total = 0.0
	for b in _get_nearby_buildings(pos,size,radius):
		if b["pos"] == pos or b["name"] in exclude:
			continue
		if InRange(pos, b["pos"],size,GetSize(b["name"]),radius):
			if names.has(b["name"]):
				if (reuse_debuff or dont_reuse) and ClaimCollections.get_or_add(prop,{}).keys().has(b["pos"]) and not ClaimCollections[prop][b["pos"]] == pos:
					if not dont_reuse:
						total += floor(b["node"].inputs.get(prop,0) / 2)
						for n in BuildingCollections[GetCollectionPos(pos)]:
							if n["pos"] == pos:
								n["claims"][b["pos"]] = prop
								break
				else:
					if dont_reuse:
						ClaimCollections[prop][b["pos"]] = pos
					for n in BuildingCollections[GetCollectionPos(pos)]:
						if n["pos"] == pos:
							n["claims"][b["pos"]] = prop
							break
					total += b["node"].inputs.get(prop,0)
			if b["name"] == "Train Station":
				for nw in network_inventories:
					if b in nw[0]:
						total += nw[1].get(prop,0.0)
	return total

func SumAllProperties(pos:Vector2i, size:Vector2i, radius:int):
	var properties = {}
	for b in _get_nearby_buildings(pos,size,radius):
		if b["pos"] == pos or b["name"] == "Train Station" or b in already_checked_buildings:
			continue
		if InRange(pos, b["pos"],size,GetSize(b["name"]),radius):
			for n in MOVABLE_PROPERTIES:
				properties[n] = properties.get(n, 0) + b["node"].inputs.get(n,0)
				already_checked_buildings.append(b)
	return properties

func FindConnectedFishingBoats(pos) -> Array:
	var b = flood_fill(pos,[], pos)
	return b.values()

func flood_fill(pos,visited : Array, startingpos) -> Dictionary:
	if pos in visited or not InRange(pos, startingpos, Vector2i(1,1), Vector2i(1,1),15):
		return {}
	var boats := {}
	for n in AllFishingBoats:
		if pos == n["pos"]:
			boats[pos] = n
	for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
		if pos+d in visited:
			continue
		if $"../Terrain".get_tile(pos + d) == 1 or $"../Terrain".get_tile(pos + d) == 7:
			if not pos in visited:
				visited.append(pos)
			var boatss : Dictionary = flood_fill(pos + d,visited, startingpos)
			for n in boatss.keys():
				if n not in boats:
					boats[n] = boatss[n]
	return boats

func IndustryPenalty(pos:Vector2i,size:Vector2i) -> float:
	var thermal = CountNearby(pos,size, ["Thermal Power Plant"], 6)
	var nuclear = CountNearby(pos,size, ["Nuclear Power Plant"], 8)
	var large_thermal = CountNearby(pos,size, ["Large Thermal Power Plant"], 8)
	var sm_factory = CountNearby(pos,size, ["Small Factory"], 8)
	var large_factory = CountNearby(pos,size, ["Large Factory"], 8)
	var exponent = thermal + nuclear + (large_thermal * 2) + sm_factory + (large_factory * 4)
	return 0.7 ** exponent

func CalculateStationConnections():
	var stations = []
	var networks : Array[Array] = []
	for n in AllTrainRelatedBuildings:
		if n["name"] == "Train Station":
			stations.append(n)
	for st in stations:
		var connections = [st]
		for dir in [Vector2i.LEFT,Vector2i.UP,Vector2i(1,-1),Vector2i(2,0),Vector2i(2,1),Vector2i(1,2),Vector2i(0,2),Vector2i(-1,1)]:
			connections.append_array(FindNetwork(st["pos"] + dir,stations))
		var double_check = []
		for c in connections:
			if not c in double_check:
				double_check.append(c)
		connections = double_check
		var matched : Array = []
		for netw in networks:
			for c in connections:
				if netw.has(c):
					matched.append(netw)
					break

		if matched.is_empty():
			networks.append(connections)
		else:
			var target = matched[0]
			for c in connections:
				if not target.has(c):
					target.append(c)
			for i in range(1, matched.size()):
				var other = matched[i]
				for c in other:
					if not target.has(c):
						target.append(c)
				networks.erase(other)
	station_networks = networks

func FindNetwork(pos:Vector2i,stations,last_dir:Vector2i = Vector2i.ZERO,searched:Array = []) -> Array:
	if pos in searched:
		return []
	for n in AllTrainRelatedBuildings:
		if n["name"] == "Rail" and n["pos"] == pos:
			var s : Array = []
			if n["node"].bridge_rail == true:
				match n["node"].horizontal_bridge:
					true:
						searched.append(pos)
						print(Vector2i(last_dir.x, 0))
						s.append_array(FindNetwork(pos + Vector2i(last_dir.x, 0),stations,last_dir,searched))
					false:
						searched.append(pos)
						print(Vector2i(0, last_dir.y))
						s.append_array(FindNetwork(pos + Vector2i(0, last_dir.y),stations,last_dir,searched))
				return s
			for dir in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.UP]:
				searched.append(pos)
				s.append_array(FindNetwork(pos + dir,stations,dir,searched))
			return s
		if n["name"] == "Train Station" and Rect2(n["pos"],Vector2(2,2)).has_point(pos):
			return([n])
	return []

func CalculateHapiness():
	var total = 0
	var amount = 0
	for b in AllHousingBuildings:
		total += b["node"].extra_data.get("happiness",0)
		amount += b["node"].inputs.get("population",0)
	if amount == 0:
		Global.Happiness = 100.0
	else:
		Global.Happiness = floor(total / max(amount,1))
	

func GetHappinessValue(pos:Vector2i,nam:String,node:Node2D) -> int:
	var base = 100
	var entertainment = SumProperty(pos,GetSize(nam),ENTERTAINMENT_NAMES,4,"entertainment")
	var nature = SumProperty(pos, GetSize(nam), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
	var industry = IndustryPenalty(pos,GetSize(nam))
	var my_pop = max(node.inputs.get("population",0),1)
	var around_pop = SumProperty(pos,GetSize(nam),HOUSING_NAMES,1,"population",[],false,false)
	var pop_ratio = float(around_pop) / float(max(my_pop,1))
	var boost = clamp(8 / my_pop,.4,4)
	var calc = min(1 / pop_ratio * boost,1)
	return min(max((base * calc + (entertainment * 4) + (nature / 8)) * industry,0),300)
# --- Tick ------------------------------------------------------

func Tick():
	# --- REMOVE OLD BUILDINGS
	if not DestroyedBuildings.is_empty():
		for n in DestroyedBuildings:
			BuildingCollections[GetCollectionPos(n["pos"])].erase(n)
			for claim in n["claims"].keys():
				ClaimCollections.get(n["claims"][claim],{}).erase(claim)
			if n["name"] in HOUSING_NAMES:
				AllHousingBuildings.erase(n)
			match n["name"]:
				"Transformator Building":
					AllPowerRelatedBuildings.erase(n)
				"Train Station","Rail":
					AllTrainRelatedBuildings.erase(n)
				"Fishing Boat":
					AllFishingBoats.erase(n)
				"Fishing Dock":
					AllFishingDocks.erase(n)
			if is_instance_valid(n):
				n.queue_free()
			housing_edited = false
			for b in GetRecomputePath(n,true):
				match b["name"]:
					"Train Station":
						RecomputeStations()
					"Transformator Building":
						RecomputePower()
					_:
						Recompute(b)
			if housing_edited:
				CalculateHapiness()
				RecomputePopulation()
		DestroyedBuildings.clear()
	# --- COUNT MONEY TOTAL AND ADD TO MONEY
	money_total = 0
	var disable_income_popup = Global.Settings.get("disable_income_popup",false)
	for coll in BuildingCollections.values():
		for b in coll:
			if b["node"].inputs.get("money",0) > 0.0:
				money_total += b["node"].inputs.get("money",0)
				if not disable_income_popup:
					b["node"].display_income(b["node"].inputs.get("money",0))
	Global.Money += money_total * Global.Happiness / 100
	Global.Income = money_total * Global.Happiness / 100
	$"..".UpdateCityStats()
	$"..".CheckBuildingUnlocks(GetBuildingAmounts())
	$"../UI".CheckBuildingUnlocks()
	

func Recompute(b:Dictionary):
	SetValues(b)
	if b["name"] in HOUSING_NAMES:
		housing_edited = true

func RecomputeStations():
	network_inventories = []
	already_checked_buildings = []
	for nw in station_networks:
		var stations := []
		var inv := {}
		for st in nw:
			stations.append(st)
			var i = SumAllProperties(st["pos"],Vector2i(2,2),4)
			for n in i.keys():
				inv[n] = inv.get(n,0) + i[n]
		network_inventories.append([stations,inv])

func GetRecomputePath(this_b:Dictionary,not_self = false,dont_recompute_stations=false) -> Array:
	var affection_range : int = 0
	var affected = []
	for n in Global.ORDER.keys():
		if this_b["name"] in n:
			var values = Global.ORDER[n].duplicate()
			var rangee = values.pop_front()
			affected.append_array(values)
			if affection_range < rangee:
				affection_range = rangee
	if affected.is_empty():
		return [] if not_self else [this_b]
	
	var next_updates := [] if not_self else [this_b]
	
	if this_b["name"] == "Fishing Boat":
		for n in AllFishingBoats:
			next_updates.append(n)
		for n in AllFishingDocks:
			next_updates.append(n)
	
	for b in _get_nearby_buildings(this_b["pos"],GetSize(this_b["name"]),affection_range):
		var this_nam = b["name"]
		if this_nam in affected:
			if InRange(this_b["pos"],b["pos"],GetSize(this_nam),GetSize(this_nam),affection_range):
				if b["name"] == "Wind Turbine" or (b["name"] in HOUSING_NAMES and this_b["name"] in HOUSING_NAMES):
					next_updates.append(b)
				else:
					for n in GetRecomputePath(b,false,true):
						if next_updates.has(n):
							next_updates.erase(n)
						next_updates.append(n)
		if this_nam == "Train Station" and not dont_recompute_stations:
			for nw in station_networks:
				for st in nw:
					next_updates.append(st)
					for n in GetStationRecomputePath(st["pos"]):
						if next_updates.has(n):
							next_updates.erase(n)
						next_updates.append(n)
	return next_updates

func GetStationRecomputePath(pos:Vector2i) -> Array:
	var next_updates := []
	for nw in station_networks:
		for st in nw:
			var affected = []
			for n in Global.ORDER.keys():
				if "Train Station" in n:
					affected = Global.ORDER[n].duplicate()
			var affection_range : int = affected.pop_front()
			for b in _get_nearby_buildings(pos,GetSize("Train Station"),affection_range):
				var this_nam = b["name"]
				if this_nam in affected:
					if InRange(pos,b["pos"],GetSize(this_nam),GetSize("Train Station"),affection_range):
						for n in GetRecomputePath(b,false,true):
							if next_updates.has(n):
								next_updates.erase(n)
							next_updates.append(n)
	return next_updates

func RecomputePower():
	# --- Global Power Recompute
	already_checked_buildings = []
	global_power = 0
	for b in AllPowerRelatedBuildings:
		var this_nam = b["name"]
		var my_power = SumProperty(b["pos"],GetSize(this_nam),POWER_GENERATOR_NAMES,3,"power",[],false,true)
		global_power += my_power
	
	for b in AllPowerRelatedBuildings:
		var this_nam = b["name"]
		var my_power = SumProperty(b["pos"],GetSize(this_nam),POWER_GENERATOR_NAMES,3,"power",[],false,true)
		b["node"].power = my_power
		b["node"].use_power = true
		Recompute(b)

func RecomputePopulation():
	population_total = 0
	for b in AllHousingBuildings:
		if b["name"] in HOUSING_NAMES:
			population_total += b["node"].inputs.get("population",0)
	Global.Population = population_total
	
# --- Building Values Recompute
	#already_checked_buildings = []
	#money_total = 0	
	#population_total = 0
	#for b in Buildings:
		#if not b["name"] in FIXED_VALUES:
			#SetValues(b)
	#Global.Income = money_total * Global.Happiness / 100
	#Global.Population = population_total
	#$"..".UpdateCityStats()
	#$"..".CheckBuildingUnlocks(GetBuildingAmounts())
	#$"../UI".CheckBuildingUnlocks()

func SetValues(b:Dictionary):
	var data : Array = CalculateBuildingOutput(b["name"],b["pos"],b["node"])
	var values = data.pop_front()
	if not data == []:
		var extra = data.pop_back()
		b["node"].extra_data = extra
	for n in values.keys():
		b["node"].inputs[n] = values[n]
	b["node"].Claims = b["claims"]
	b["node"].UpdateData()

func CalculateBuildingOutput(nam,pos,node) -> Array:
	var size = GetSize(nam)
	match nam:
		"Basic House":
			var power = SumProperty(pos, size,["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, size, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var penalty = IndustryPenalty(pos,size)
			var population_boost = 2 if power > 2 * (1 + 0.01 * nature) else 1
			var pop = 2 * penalty * population_boost * (1 + 0.01 * nature)
			var happiness = GetHappinessValue(pos,nam,node) * pop
			return [{"population": pop},{"base_pop":2,"power_boost":power,"power_boost_mult":population_boost,"industry":penalty,"nature":nature,"happiness":happiness}]
		"Double House":
			var power = SumProperty(pos, size, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, size, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var penalty = IndustryPenalty(pos,size)
			var population_boost = 2 if power > 4 * (1 + 0.01 * nature) else 1
			var pop = 4 * penalty * population_boost * (1 + 0.01 * nature)
			var happiness = GetHappinessValue(pos,nam,node) * pop
			return [{"population": pop},{"base_pop":4,"power_boost":power,"power_boost_mult":population_boost,"industry":penalty,"nature":nature,"happiness":happiness}]
		"Small Apartment Complex":
			var power = SumProperty(pos, size, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, size, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var penalty = IndustryPenalty(pos,size)
			var population_boost = 2 if power > 8 * (1 + 0.01 * nature) else 1
			var pop = 8 * penalty * population_boost * (1 + 0.01 * nature)
			var happiness = GetHappinessValue(pos,nam,node) * pop
			return [{"population": pop},{"base_pop":8,"power_boost":power,"power_boost_mult":population_boost,"industry":penalty,"nature":nature,"happiness":happiness}]
		"Large Apartment Complex":
			var power = SumProperty(pos, size, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, size, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var penalty = IndustryPenalty(pos,size)
			var population_boost = 2 if power > 24 * (1 + 0.01 * nature) else 1
			var pop = 24 * penalty * population_boost * (1 + 0.01 * nature)
			var happiness = GetHappinessValue(pos,nam,node) * pop
			return [{"population": pop},{"base_pop":24,"power_boost":power,"power_boost_mult":population_boost,"industry":penalty,"nature":nature,"happiness":happiness}]
		"Mega Apartment Complex":
			var power = SumProperty(pos, size, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, size, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var penalty = IndustryPenalty(pos,size)
			var population_boost = 2 if power > 64 * (1 + 0.01 * nature) else 1
			var pop = 64 * penalty * population_boost * (1 + 0.01 * nature)
			var happiness = GetHappinessValue(pos,nam,node) * pop
			return [{"population": pop},{"base_pop":64,"power_boost":power,"power_boost_mult":population_boost,"industry":penalty,"nature":nature,"happiness":happiness}]
		"Giant Apartment Complex":
			var power = SumProperty(pos, size, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, size, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var penalty = IndustryPenalty(pos,size)
			var population_boost = 2 if power > 256 * (1 + 0.01 * nature) else 1
			var pop = 256 * penalty * population_boost * (1 + 0.01 * nature)
			var happiness = GetHappinessValue(pos,nam,node) * pop
			return [{"population": pop},{"base_pop":256,"power_boost":power,"power_boost_mult":population_boost,"industry":penalty,"nature":nature,"happiness":happiness}]
		"Low-Budget Apartment":
			var power = SumProperty(pos, size, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, size, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 16 * (1 + 0.01 * nature) else 1
			var pop = 16 * population_boost * (1 + 0.01 * nature)
			var happiness = 50 * pop
			return [{"population": pop},{"base_pop":16,"power_boost":power,"power_boost_mult":population_boost,"nature":nature,"happiness":happiness}]
		"Small Supermarket":
			var pop = SumProperty(pos, size, HOUSING_NAMES, 1, "population")
			var products = SumProperty(pos, size, ["Small Factory","Large Factory"], 6, "products",[],true)
			return [{"money": 0.5 * pop * (1 + 0.25 * products)},{"population":pop,"products":products}]

		"Large Supermarket":
			var pop = SumProperty(pos, size, HOUSING_NAMES, 3, "population")
			var products = SumProperty(pos, size, ["Small Factory","Large Factory"], 6, "products",[],true)
			return [{"money": 0.75 * pop * (1 + 0.25 * products)},{"population":pop,"products":products}]

		"Mill":
			var wheat = Count_Terrain_Nearby(pos, Vector2i(1, 1), 5, 5)
			return [{"flour": wheat},{"wheat":wheat}]
		
		"Electronics Store":
			var pop = SumProperty(pos, size, HOUSING_NAMES, 3, "population")
			return [{"money": 0.5 * pop},{"population":pop}]
		
		"Cafe":
			var pop = SumProperty(pos, size, HOUSING_NAMES, 2, "population")
			return [{"money": 0.3 * pop},{"population":pop}]
		
		"Bakery":
			var flour = SumProperty(pos, size, ["Mill"], 3, "flour",[],true)
			var pop = SumProperty(pos, size, HOUSING_NAMES, 3, "population")
			return [{"money": (flour/40) * int(log(4*flour+1)) * pop * 0.2},{"population":pop,"flour":flour}]
		"Lumber Mill":
			var sparse_forests = Count_Terrain_Nearby(pos,size, 2, 1,true)
			var dense_forests  = Count_Terrain_Nearby(pos,size, 3, 1,true)
			var pop = SumProperty(pos, size, HOUSING_NAMES, 4, "population")
			return [{"money": pop * 0.7 * (sparse_forests*0.5 + dense_forests)},{"population":pop,"forests":dense_forests + sparse_forests}]
		"Fishing Hut":
			var water = Count_Terrain_Nearby(pos,size,1,1)
			var pop = SumProperty(pos, size, HOUSING_NAMES, 2, "population")
			return [{"fish": floor(pop / 8.0) * water},{"population":pop,"water":water}]
		"Seafood Market":
			var fish = SumProperty(pos,Vector2i(2,2),["Fishing Hut"],4,"fish")
			var rarefish = SumProperty(pos,Vector2i(2,2),["Fishing Dock"],4,"exoticfish")
			var pop = SumProperty(pos, Vector2i(2,2), HOUSING_NAMES,4,"population")
			return [{"money":pop*floor(log(fish+1)) + pop*floor(log(rarefish*10+1)*rarefish*0.2)}]
		"Transformator Building":
			return [{"power": global_power},{"global_power":global_power}]
		"Thermal Power Plant","Small Solar Farm":
			return [{"power": 9}]
		"Nuclear Power Plant","Large Thermal Power Plant","Large Solar Farm":
			return [{"power": 45}]
		"Wind Turbine":
			return [{"power": int(floor(200.0 / (2 ** CountNearby(pos, size,["Wind Turbine"],2))))}]
		"Small Wheatfield":
			return [{"wheat": 1}]
		
		"Large Wheatfield":
			return [{"wheat": 5}]
 
		"Animal Farm":
			return [{"livestock": 3}]
 
		"Butcher":
			var livestock = SumProperty(pos, size, ["Animal Farm"], 4, "livestock",[],true)
			return [{"meat": livestock},{"livestock":livestock}]
 
		"Restaurant":
			var pop = SumProperty(pos, size, HOUSING_NAMES, 5, "population")
			var meat = SumProperty(pos, size, ["Butcher"], 4, "meat",[],true)
			var flour = SumProperty(pos, size, ["Mill"], 4, "flour",[],true)
			var products = SumProperty(pos, size, ["Small Factory","Large Factory"], 4, "products",[],true)
			return [{"money": pop * (min(meat, flour, products) * 0.05) * log(min(meat, flour, products)+1) / log(1.1)},{"population":pop,"products":products,"meat":meat,"flour":flour}]
 		
		"Mall":
			var pop = SumProperty(pos, size, HOUSING_NAMES, 6, "population")
			var shops = CountNearby(pos,size, SHOP_NAMES, 2,["Mall"])
			return [{"money": pop * shops},{"population":pop,"shops_nearby":shops}]
		"Small Factory":
			var power = SumProperty(pos,size, POWER_GENERATOR_NAMES, 2, "power")
			return [{"products":max(4*log(power+1),1)},{"power_boost":power}]
			
		"Large Factory":
			var power = SumProperty(pos,size, POWER_GENERATOR_NAMES, 4, "power")
			return [{"products":max(18*log(power+1),1)},{"power_boost":power}]
		"Pocket Park":
			return [{"nature":2}]
		"Small Park":
			return [{"nature":3}]
		"Fountain Park":
			return [{"nature":4}]
		"Large Park":
			return [{"nature":18}]
		"Theme Park":
			return [{"entertainment":12}]
		"Cinema":
			return [{"entertainment":2}]
		"Mine":
			var workpower = SumProperty(pos,size,HOUSING_NAMES,2,"population")
			var mountains = Count_Terrain_Nearby(pos,size,4,1)
			return [{"ores":workpower * .1 * mountains},{"population":workpower,"mountains":mountains}]
		"Ore Extractor":
			var ores = SumProperty(pos,size,["Mine"],3,"ores",[],true)
			return [{"gemstones":ores * .2},{"ores":ores}]
		"Sand Mine":
			var desert = Count_Terrain_Nearby(pos,size,6,4,true)
			var population = SumProperty(pos,size,HOUSING_NAMES,2,"population")
			var boost = 1 if population >= 16 else 0
			return [{"sand": boost * desert},{"desert":desert,"population":population,"gets_pop_boost":boost == 1}]
		"Smeltery":
			var sand = SumProperty(pos,size,["Sand Mine"],4,"sand",[],true)
			var power = SumProperty(pos,size, POWER_GENERATOR_NAMES, 2, "power")
			return [{"silicon":sand * max(log(power+1),1)},{"sand":sand}]
		"Jewlery Store":
			var gemstones = SumProperty(pos,size,["Ore Extractor"],5,"gemstones",[],true)
			var pop = SumProperty(pos,size,HOUSING_NAMES,5,"population")
			return [{"money":gemstones * pop * 10},{"population":pop,"gemstones":gemstones}]
		"Fishing Dock":
			var boats = FindConnectedFishingBoats(pos)
			var fish = 0
			for b in boats:
				if ClaimCollections.get("exoticfish",{}).get(b["pos"]) != null:
					break
				ClaimCollections.get("exoticfish",{})[b["pos"]] = pos
				for n in BuildingCollections[GetCollectionPos(pos)]:
					if n["pos"] == pos:
						n["claims"][b["pos"]] = "exoticfish"
						break
				var my_fish = Count_Terrain_Nearby(b["pos"],Vector2(1,1),7,1,true)
				fish += my_fish
				
				b["node"].extra_data = {"deep_water":my_fish}
				
			return [{"exoticfish":fish}]
		_:
			return [{}]
	
