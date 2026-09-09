extends Node2D

signal deselect

var BuildingScene = preload("res://Scenes/building.tscn")
# EXAMPLE: [{"pos":Vector2i(23,33),"name":"Basic House","node":[NODE]}]
var BuildingCollections : Dictionary[Vector2i,Array] = {}
var AllHousingBuildings = []
var AllTrainRelatedBuildings = []
var AllPowerRelatedBuildings = []
var Rails : Dictionary[Vector2i, Node2D] = {}
var DestroyedBuildings = []

var housing_edited = false
var network_inventories  : Array[Array] = []
var global_power = 0
var already_checked_buildings = []
var money_total = 0
var population_total = 0
var station_networks : Array[Array] = []

const SHOP_NAMES = [
	"Small Supermarket", "Large Supermarket", "Electronics Store","Cafe", "Bakery", "Restaurant", "Mall","Lumber Mill"
]
const HOUSING_NAMES = [
	"Basic House", "Double House", "Small Apartment Complex","Large Apartment Complex", "Mega Apartment Complex","Low-Budget Apartment","Giant Apartment Complex"
]
const POWER_GENERATOR_NAMES = [
	"Thermal Power Plant", "Small Solar Farm", "Nuclear Power Plant", "Large Thermal Power Plant", "Large Solar Farm"
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
	_add_building_to_collection(nam,location,b)
	var this_b := {"name":nam,"pos":location,"node":b}
	if nam in HOUSING_NAMES:
		AllHousingBuildings.append(this_b)
	match nam:
		"Transformator Building":
			AllPowerRelatedBuildings.append(this_b)
		"Train Station","Rail":
			AllTrainRelatedBuildings.append(this_b)
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
				Recompute(n["pos"],n["name"],n["node"])
	if housing_edited:
		CalculateHapiness()
		RecomputePopulation()

func DeselectOthers():
	deselect.emit()

func GetCollectionPos(pos:Vector2i):
	return Vector2i(floor(Vector2(pos) / 8.0))

func _add_building_to_collection(nam:String,pos:Vector2i,node:Node2D):
	#var size = GetSize(nam)
	#var cells = []
	#for x in range(size.x):
		#for y in range(size.y):
			#var cell = GetCollectionPos(pos + Vector2i(x,y))
			#cells.append(cell)
	#for c in cells:
		#if BuildingCollections.get_or_add(GetCollectionPos(pos),[]).has()
	BuildingCollections.get_or_add(GetCollectionPos(pos),[]).append({"name":nam,"pos":pos,"node":node})

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
			if Vector2i(x,y) == Vector2i(0,0):
				continue
			if must_be_empty:
				var tmp = false
				for b in _get_nearby_buildings(pos,size,radius):
					if b["pos"] == (Vector2i(x,y)+pos):
						tmp = true
						break
				if tmp == true:
					continue
			if $"../Terrain".get_tile(Vector2i(x,y)+pos) == id:
				count += 1
	return count

# Calculates how much some property is in the area
func SumProperty(pos:Vector2i, size:Vector2i, names:Array, radius:int, prop:String,exclude:Array = [],dont_reuse=false) -> float:
	var total = 0.0
	for b in _get_nearby_buildings(pos,size,radius):
		if b["pos"] == pos or b["name"] in exclude:
			continue
		if InRange(pos, b["pos"],size,GetSize(b["name"]),radius) and (not dont_reuse or not b in already_checked_buildings):
			if names.has(b["name"]):
				total += b["node"].inputs.get(prop,0)
				already_checked_buildings.append(b)
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

func FindNetwork(pos:Vector2i,stations,searched:Array = []) -> Array:
	if pos in searched:
		return []
	for n in AllTrainRelatedBuildings:
		if n["name"] == "Rail" and n["pos"] == pos:
			var s : Array = []
			for dir in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.UP]:
				searched.append(pos)
				s.append_array(FindNetwork(pos + dir,stations,searched))
			return s
		if n["name"] == "Train Station" and Rect2(n["pos"],Vector2(2,2)).has_point(pos):
			return([n])
	return []

func CalculateHapiness():
	var total = 0
	var amount = 0
	for b in AllHousingBuildings:
		if b["name"] == "Low-Budget Apartment":
			total += 50 * b["node"].inputs.get("population",0)
		else:
			total += GetHappinessValue(b["pos"],b["name"],b["node"]) * b["node"].inputs.get("population",0)
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
	var around_pop = SumProperty(pos,GetSize(nam),HOUSING_NAMES,1,"population")
	var pop_ratio = float(around_pop) / float(max(my_pop,1))
	var boost = clamp(sqrt(250 / max(float(my_pop), 250)),0.1,1)
	var calc = min(1 / pop_ratio * 4 * boost,1)
	return min(max((base * calc + (entertainment * 4) + (nature / 8)) * industry,0),300)
# --- Tick ------------------------------------------------------

func Tick():
	# --- REMOVE OLD BUILDINGS
	if not DestroyedBuildings.is_empty():
		for n in DestroyedBuildings:
			BuildingCollections[GetCollectionPos(n["pos"])].erase(n)
			if n["name"] in HOUSING_NAMES:
				AllHousingBuildings.erase(n)
			match n["name"]:
				"Transformator Building":
					AllPowerRelatedBuildings.erase(n)
				"Train Station","Rail":
					AllTrainRelatedBuildings.erase(n)
			if is_instance_valid(n):
				n.queue_free()
			housing_edited = false
			Recompute(n["pos"],n["name"],n["node"])
			if housing_edited:
				CalculateHapiness()
				RecomputePopulation()
		DestroyedBuildings.clear()
	# --- COUNT MONEY TOTAL AND ADD TO MONEY
	money_total = 0
	for coll in BuildingCollections.values():
		for b in coll:
			if b["node"].inputs.get("money",0) > 0.0:
				money_total += b["node"].inputs.get("money",0)
				b["node"].display_income(b["node"].inputs.get("money",0))
	Global.Money += money_total * Global.Happiness / 100
	Global.Income = money_total * Global.Happiness / 100
	$"..".UpdateCityStats()
	$"..".CheckBuildingUnlocks(GetBuildingAmounts())
	$"../UI".CheckBuildingUnlocks()
	

func Recompute(pos,nam,node):
	SetValues(node,nam,pos)
	if nam in HOUSING_NAMES:
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
	var affected = []
	for n in Global.ORDER.keys():
		if this_b["name"] in n:
			affected = Global.ORDER[n].duplicate()
	if affected.is_empty():
		return [] if not_self else [this_b]
	var affection_range : int = affected.pop_front()
	
	var next_updates := [] if not_self else [this_b]
	
	for b in _get_nearby_buildings(this_b["pos"],GetSize(this_b["name"]),affection_range):
		var this_nam = b["name"]
		if this_nam in affected:
			if InRange(this_b["pos"],b["pos"],GetSize(this_nam),GetSize(this_nam),affection_range):
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
		var my_power = SumProperty(b["pos"],GetSize(this_nam),["Thermal Power Plant","Small Solar Farm","Nuclear Power Plant","Large Thermal Power Plant","Large Solar Farm"],3,"power",[],true)
		global_power += my_power
	
	for b in AllPowerRelatedBuildings:
		var this_nam = b["name"]
		var my_power = SumProperty(b["pos"],GetSize(this_nam),["Thermal Power Plant","Small Solar Farm","Nuclear Power Plant","Large Thermal Power Plant","Large Solar Farm"],3,"power",[],true)
		b["node"].power = my_power
		b["node"].use_power = true
		Recompute(b["pos"],this_nam,b["node"])

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

func SetValues(node,nam,pos):
	var data : Array = CalculateBuildingOutput(nam,pos)
	var values = data.pop_front()
	if not data == []:
		var extra = data.pop_back()
		node.extra_data = extra
	for n in values.keys():
		node.inputs[n] = values[n]
	node.UpdateData()

func CalculateBuildingOutput(nam,pos) -> Array:
	match nam:
		"Basic House":
			var power = SumProperty(pos, GetSize(nam),["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(nam), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var penalty = IndustryPenalty(pos,GetSize(nam))
			var population_boost = 2 if power > 2 * (1 + 0.01 * nature) else 1
			return [{"population": 2 * penalty * population_boost * (1 + 0.01 * nature)},{"power":power,"industry":penalty,"nature":nature}]
		"Double House":
			var power = SumProperty(pos, GetSize(nam), ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(nam), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var penalty = IndustryPenalty(pos,GetSize(nam))
			var population_boost = 2 if power > 4 * (1 + 0.01 * nature) else 1
			return [{"population": 4 * penalty * population_boost * (1 + 0.01 * nature)},{"power":power,"industry":penalty,"nature":nature}]
		"Small Apartment Complex":
			var power = SumProperty(pos, GetSize(nam), ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(nam), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var penalty = IndustryPenalty(pos,GetSize(nam))
			var population_boost = 2 if power > 8 * (1 + 0.01 * nature) else 1
			return [{"population": 8 * penalty * population_boost * (1 + 0.01 * nature)},{"power":power,"industry":penalty,"nature":nature}]
		"Large Apartment Complex":
			var power = SumProperty(pos, GetSize(nam), ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(nam), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var penalty = IndustryPenalty(pos,GetSize(nam))
			var population_boost = 2 if power > 24 * (1 + 0.01 * nature) else 1
			return [{"population": 24 * penalty * population_boost * (1 + 0.01 * nature)},{"power":power,"industry":penalty,"nature":nature}]
		"Mega Apartment Complex":
			var power = SumProperty(pos, GetSize(nam), ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(nam), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var penalty = IndustryPenalty(pos,GetSize(nam))
			var population_boost = 2 if power > 64 * (1 + 0.01 * nature) else 1
			return [{"population": 64 * penalty * population_boost * (1 + 0.01 * nature)},{"power":power,"industry":penalty,"nature":nature}]
		"Giant Apartment Complex":
			var power = SumProperty(pos, GetSize(nam), ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(nam), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var penalty = IndustryPenalty(pos,GetSize(nam))
			var population_boost = 2 if power > 256 * (1 + 0.01 * nature) else 1
			return [{"population": 256 * penalty * population_boost * (1 + 0.01 * nature)},{"power":power,"industry":penalty,"nature":nature}]
		"Low-Budget Apartment":
			var power = SumProperty(pos, GetSize(nam), ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(nam), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 16 * (1 + 0.01 * nature) else 1
			return [{"population": 16 * population_boost * (1 + 0.01 * nature)},{"power":power,"nature":nature}]
		"Small Supermarket":
			var pop = SumProperty(pos, GetSize(nam), HOUSING_NAMES, 1, "population")
			var products = SumProperty(pos, GetSize(nam), ["Small Factory","Large Factory"], 6, "products")
			return [{"money": 0.25 * pop * (1 + 0.25 * products)},{"population":pop,"products":products}]

		"Large Supermarket":
			var pop = SumProperty(pos, GetSize(nam), HOUSING_NAMES, 3, "population")
			var products = SumProperty(pos, GetSize(nam), ["Small Factory","Large Factory"], 6, "products")
			return [{"money": 0.25 * pop * (1 + 0.25 * products)},{"population":pop,"products":products}]

		"Mill":
			var wheat = SumProperty(pos, GetSize(nam), ["Small Wheatfield","Large Wheatfield"], 5, "wheat")
			return [{"flour": wheat},{"wheat":wheat}]
		
		"Electronics Store":
			var pop = SumProperty(pos, GetSize(nam), HOUSING_NAMES, 3, "population")
			return [{"money": 0.5 * pop},{"population":pop}]
		
		"Cafe":
			var pop = SumProperty(pos, GetSize(nam), HOUSING_NAMES, 2, "population")
			return [{"money": 0.3 * pop},{"population":pop}]
		
		"Bakery":
			var flour = SumProperty(pos, GetSize(nam), ["Mill"], 3, "flour")
			var pop = SumProperty(pos, GetSize(nam), HOUSING_NAMES, 3, "population")
			return [{"money": (flour/40) * int(log(2*flour+1)) * pop * 0.4},{"population":pop,"flour":flour}]
		"Lumber Mill":
			var sparse_forests = Count_Terrain_Nearby(pos,Vector2i(1,1), 2, 1,true)
			var dense_forests  = Count_Terrain_Nearby(pos,Vector2i(1,1), 3, 1,true)
			var pop = SumProperty(pos, GetSize(nam), HOUSING_NAMES, 4, "population")
			return [{"money": pop * 0.7 * (sparse_forests*0.5 + dense_forests)},{"population":pop,"forests":dense_forests + sparse_forests}]
		"Fishing Hut":
			var water = Count_Terrain_Nearby(pos,Vector2i(1,1),1,1)
			var pop = SumProperty(pos, GetSize(nam), HOUSING_NAMES, 3, "population")
			return [{"money": pop * water},{"population":pop,"water":water}]
		"Transformator Building":
			return [{"power": global_power},{"global_power":global_power}]
		"Thermal Power Plant","Small Solar Farm":
			return [{"power": 9}]
		"Nuclear Power Plant","Large Thermal Power Plant","Large Solar Farm":
			return [{"power": 45}]
		"Small Wheatfield":
			return [{"wheat": 1}]
		
		"Large Wheatfield":
			return [{"wheat": 5}]
 
		"Animal Farm":
			return [{"livestock": 3}]
 
		"Butcher":
			var livestock = SumProperty(pos, GetSize(nam), ["Animal Farm"], 4, "livestock")
			return [{"meat": livestock},{"livestock":livestock}]
 
		"Restaurant":
			var pop = SumProperty(pos, GetSize(nam), HOUSING_NAMES, 5, "population")
			var meat = SumProperty(pos, GetSize(nam), ["Butcher"], 4, "meat")
			var flour = SumProperty(pos, GetSize(nam), ["Mill"], 4, "flour")
			var products = SumProperty(pos, GetSize(nam), ["Small Factory","Large Factory"], 4, "products")
			return [{"money": pop * (min(meat, flour, products) * 0.05) * log(min(meat, flour, products)+1) / log(1.1)},{"population":pop,"products":products,"meat":meat,"flour":flour}]
 
		"Mall":
			var pop = SumProperty(pos, GetSize(nam), HOUSING_NAMES, 6, "population")
			var shops = CountNearby(pos,GetSize(nam), SHOP_NAMES, 2,["Mall"])
			return [{"money": pop * shops},{"population":pop,"shops_nearby":shops}]
		"Small Factory":
			var power = SumProperty(pos,GetSize(nam), POWER_GENERATOR_NAMES, 2, "power")
			return [{"products":power/4+1},{"power_boost":power}]
			
		"Large Factory":
			var power = SumProperty(pos,GetSize(nam), POWER_GENERATOR_NAMES, 4, "power")
			return [{"products":4 + power},{"power_boost":power}]
		"Pocket Park":
			return [{"nature":2}]
		"Small Park":
			return [{"nature":3}]
		"Fountain Park":
			return [{"nature":4}]
		"Large Park":
			return [{"nature":18}]
		"Theme Park":
			return [{"entertainment":5}]
		"Cinema":
			return [{"entertainment":2}]
		"Mine":
			var workpower = SumProperty(pos,GetSize(nam),HOUSING_NAMES,2,"population")
			var mountains = Count_Terrain_Nearby(pos,Vector2i(1,1),4,1)
			return [{"ores":workpower * .1 * mountains},{"population":workpower,"mountains":mountains}]
		"Ore Extractor":
			var ores = SumProperty(pos,GetSize(nam),["Mine"],3,"ores")
			return [{"gemstones":ores * .2},{"ores":ores}]
		"Jewlery Store":
			var gemstones = SumProperty(pos,GetSize(nam),["Ore Extractor"],5,"gemstones")
			var pop = SumProperty(pos,GetSize(nam),HOUSING_NAMES,5,"population")
			return [{"money":gemstones * pop * 10},{"population":pop,"gemstones":gemstones}]
		_:
			return [{}]
	
