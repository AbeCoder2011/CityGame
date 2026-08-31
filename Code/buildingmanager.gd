extends Node2D

signal deselect

var BuildingScene = preload("res://Scenes/building.tscn")
# EXAMPLE: [{"pos":Vector2i(23,33),"name":"Basic House","node":[NODE]}]
var Buildings = []
var Rails : Dictionary[Vector2i, Node2D] = {}
var DestroyedBuildings = []

var network_inventories  : Array[Array] = []
var global_power = 0
var already_checked_buildings = []

var station_networks : Array[Array] = []

const SHOP_NAMES = [
	"Small Supermarket", "Large Supermarket", "Electronics Store","Cafe", "Bakery", "Restaurant", "Mall"
]
const HOUSING_NAMES = [
	"Basic House", "Double House", "Small Apartment Complex","Large Apartment Complex", "Mega Apartment Complex","Low-Budget Apartment","Giant Apartment Complex"
]
const POWER_GENERATOR_NAMES = [
	"Thermal Power Plant", "Small Solar Farm", "Nuclear Power Plant", "Large Thermal Power Plant", "Large Solar Farm"
]
const MOVABLE_PROPERTIES = ["products","flour","electronics","livestock","meat"]
func AddToRemovalList(node:Node2D):
	DestroyedBuildings.append(node)
	if Rails.has(node.grid_pos) and Rails[node.grid_pos] == node:
		Rails.erase(node.grid_pos)
		for offset in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var neighbor_pos = node.grid_pos + offset
			if Rails.has(neighbor_pos):
				Rails[neighbor_pos].UpdateRailSprite()
	Global.Money += Global.BuildingData[node.building_name]["cost"] * 0.5
	$"../UI".UpdateCityStats()

func NewBuilding(nam:String, location:Vector2i,check_unlocks=true):
	var b : Node2D = BuildingScene.instantiate()
	b.position = location * 48
	add_child(b)
	if nam == "Rail":
		Rails[location] = b
	b.init_building(nam,location)
	deselect.connect(b.Deselect)
	Buildings.append({"pos":location,"name":nam,"node":b})
	$"..".CheckBuildingUnlocks(GetBuildingAmounts())
	if check_unlocks:
		$"../UI".CheckBuildingUnlocks()
	if nam == "Rail" or nam == "Train Station":
		CalculateStationConnections()
func DeselectOthers():
	deselect.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("move_building") and event.is_pressed():
		pass

# --- Helpers -------------------------------------------------

func GetSize(nam) -> Vector2i:
	return Global.BuildingData[nam].get("size",Vector2i(1,1))

func InRange(a:Vector2i, b:Vector2i, sizeA=Vector2i(1,1),sizeB=Vector2i(1,1),rad=0) -> bool:
	var recta = Rect2(a - Vector2i(rad,rad),Vector2i(sizeA+Vector2i(rad*2,rad*2)))
	var rectb = Rect2(b,sizeB)
	return recta.intersects(rectb)

func GetBuildingAmounts() -> Dictionary:
	var counts = {}
	for b in Buildings:
		counts[b["name"]] = counts.get(b["name"], 0) + 1
	return counts

# Count buildings of given names within radius of pos
func CountNearby(pos:Vector2i, size:Vector2i, names:Array, radius:int, exclude:Array = []) -> int:
	var count = 0
	for b in Buildings:
		if b["pos"] == pos or b["name"] in exclude:
			continue
		if names.has(b["name"]) and InRange(pos, b["pos"],size,GetSize(b["name"]),radius):
			count += 1
	return count

# Calculates how much some property is in the area
func SumProperty(pos:Vector2i, size:Vector2i, names:Array, radius:int, prop:String,exclude:Array = []) -> float:
	var total = 0.0
	for b in Buildings:
		if b["pos"] == pos or b["name"] in exclude:
			continue
		if InRange(pos, b["pos"],size,GetSize(b["name"]),radius):
			if names.has(b["name"]):
				total += b["node"].get(prop)
			if b["name"] == "Train Station":
				for nw in network_inventories:
					if b["pos"] in nw[0]:
						total += nw[1].get(prop,0.0)
	return total

func SumAllProperties(pos:Vector2i, size:Vector2i, radius:int):
	var properties = {}
	for b in Buildings:
		if b["pos"] == pos or b["name"] == "Train Station" or b in already_checked_buildings:
			continue
		if InRange(pos, b["pos"],size,GetSize(b["name"]),radius):
			for n in MOVABLE_PROPERTIES:
				properties[n] = properties.get(n, 0) + b["node"].get(n)
				already_checked_buildings.append(b)
	return properties

func IndustryPenalty(pos:Vector2i,size:Vector2i) -> float:
	var thermal = CountNearby(pos,size, ["Thermal Power Plant"], 6)
	var nuclear = CountNearby(pos,size, ["Nuclear Power Plant"], 8)
	var large_thermal = CountNearby(pos,size, ["Large Thermal Power Plant"], 8)
	var sm_factory = CountNearby(pos,size, ["Small Factory"], 8)
	var large_factory = CountNearby(pos,size, ["Large Factory"], 8)
	var exponent = thermal + nuclear + (large_thermal * 2) + sm_factory + (large_factory * 4)
	return 0.5 ** exponent

func CalculateStationConnections():
	var stations = []
	var networks : Array[Array] = []
	for n in Buildings:
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
		# find every existing network that overlaps with this station's connections
		var matched : Array = []
		for netw in networks:
			for c in connections:
				if netw.has(c):
					matched.append(netw)
					break

		if matched.is_empty():
			networks.append(connections)
		else:
			# merge everything into the first matched network
			var target = matched[0]
			for c in connections:
				if not target.has(c):
					target.append(c)
			# merge any other matched networks (bridged networks) into target too, then drop them
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
	for n in Buildings:
		if n["name"] == "Rail" and n["pos"] == pos:
			var s : Array = []
			for dir in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.UP]:
				searched.append(pos)
				s.append_array(FindNetwork(pos + dir,stations,searched))
			return s
		if n["name"] == "Train Station" and Rect2(n["pos"],Vector2(2,2)).has_point(pos):
			return([n])
	return []
# --- Tick ------------------------------------------------------

func Tick():
	for n in DestroyedBuildings:
		for i in range(Buildings.size() - 1, -1, -1):
			if Buildings[i]["node"] == n:
				Buildings.remove_at(i)
				break
		if is_instance_valid(n):
			n.queue_free()
	DestroyedBuildings.clear()
	network_inventories = []
	for nw in station_networks:
		var stations := []
		var inv := {}
		for st in nw:
			stations.append(st["pos"])
			var i = SumAllProperties(st["pos"],Vector2i(2,2),4)
			for n in i.keys():
				inv[n] = inv.get(n,0) + i[n]
		network_inventories.append([stations,inv])
	already_checked_buildings = []
	global_power = 0
	for b in Buildings:
		if b["name"] == "Transformator Building":
			global_power += SumProperty(b["pos"],GetSize(b["name"]),["Thermal Power Plant","Small Solar Farm","Nuclear Power Plant","Large Thermal Power Plant","Large Solar Farm"],3,"power")
	var money_total = 0
	var population_total = 0
	for b in Buildings:
		var value : Dictionary = CalculateBuildingOutput(b)
		if value.has("money"):
			b["node"].money = value["money"]
			money_total += value["money"]
			b["node"].display_income(value["money"])
		if value.has("population"):
			b["node"].population = value["population"]
			population_total += value["population"]
		if value.has("products"):
			b["node"].products = value["products"]
		if value.has("wheat"):
			b["node"].wheat = value["wheat"]
		if value.has("flour"):
			b["node"].flour = value["flour"]
		if value.has("power"):
			b["node"].power = value["power"]
		if value.has("livestock"):
			b["node"].livestock = value["livestock"]
		if value.has("meat"):
			b["node"].meat = value["meat"]
		if value.has("nature"):
			b["node"].nature = value["nature"]
		b["node"].UpdateData()
	Global.Money += money_total
	Global.Income = money_total
	Global.Population = population_total
	$"..".UpdateCityStats()
	$"..".CheckBuildingUnlocks(GetBuildingAmounts())
	$"../UI".CheckBuildingUnlocks()
	

func CalculateBuildingOutput(b) -> Dictionary:
	var pos = b["pos"]

	match b["name"]:
		"Basic House":
			var power = SumProperty(pos, GetSize(b["name"]),["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(b["name"]), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 2 * (1 + 0.01 * nature) else 1
			return {"population": 2 * IndustryPenalty(pos,GetSize(b["name"])) * population_boost * (1 + 0.01 * nature)}
		"Double House":
			var power = SumProperty(pos, GetSize(b["name"]), ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(b["name"]), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 4 * (1 + 0.01 * nature) else 1
			return {"population": 4 * IndustryPenalty(pos,GetSize(b["name"])) * population_boost * (1 + 0.01 * nature)}
		"Small Apartment Complex":
			var power = SumProperty(pos, GetSize(b["name"]), ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(b["name"]), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 8 * (1 + 0.01 * nature) else 1
			return {"population": 8 * IndustryPenalty(pos,GetSize(b["name"])) * population_boost * (1 + 0.01 * nature)}
		"Large Apartment Complex":
			var power = SumProperty(pos, GetSize(b["name"]), ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(b["name"]), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 24 * (1 + 0.01 * nature) else 1
			return {"population": 24 * IndustryPenalty(pos,GetSize(b["name"])) * population_boost * (1 + 0.01 * nature)}
		"Mega Apartment Complex":
			var power = SumProperty(pos, GetSize(b["name"]), ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(b["name"]), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 64 * (1 + 0.01 * nature) else 1
			return {"population": 64 * IndustryPenalty(pos,GetSize(b["name"])) * population_boost * (1 + 0.01 * nature)}
		"Giant Apartment Complex":
			var power = SumProperty(pos, GetSize(b["name"]), ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(b["name"]), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 256 * (1 + 0.01 * nature) else 1
			return {"population": 256 * IndustryPenalty(pos,GetSize(b["name"])) * population_boost * (1 + 0.01 * nature)}
		"Low-Budget Apartment":
			var power = SumProperty(pos, GetSize(b["name"]), ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, GetSize(b["name"]), ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 8 * (1 + 0.01 * nature) else 1
			return {"population": 8 * population_boost * (1 + 0.01 * nature)}
		"Small Supermarket":
			var pop = SumProperty(pos, GetSize(b["name"]), HOUSING_NAMES, 1, "population")
			var products = SumProperty(pos, GetSize(b["name"]), ["Small Factory","Large Factory"], 6, "products")
			return {"money": 0.25 * pop * (1 + 0.25 * products)}

		"Large Supermarket":
			var pop = SumProperty(pos, GetSize(b["name"]), HOUSING_NAMES, 3, "population")
			var products = SumProperty(pos, GetSize(b["name"]), ["Small Factory","Large Factory"], 6, "products")
			return {"money": 0.25 * pop * (1 + 0.25 * products)}

		"Mill":
			var wheat = SumProperty(pos, GetSize(b["name"]), ["Small Wheatfield","Large Wheatfield"], 5, "wheat")
			return {"flour": wheat}
		
		"Electronics Store":
			return {"money": 0.5 * SumProperty(pos, GetSize(b["name"]), HOUSING_NAMES, 3, "population")}
		
		"Cafe":
			return {"money": 0.3 * SumProperty(pos, GetSize(b["name"]), HOUSING_NAMES, 2, "population")}
		
		"Bakery":
			var flour = SumProperty(pos, GetSize(b["name"]), ["Mill"], 3, "flour")
			var pop = SumProperty(pos, GetSize(b["name"]), HOUSING_NAMES, 3, "population")
			return {"money": (flour/40) * int(log(flour+1)) * pop * 0.4}
		"Transformator Building":
			return {"power": global_power}
		"Thermal Power Plant","Small Solar Farm":
			return {"power": 1}
		"Nuclear Power Plant","Large Thermal Power Plant","Large Solar Farm":
			return {"power": 5}
		"Small Wheatfield":
			return {"wheat": 1}
		
		"Large Wheatfield":
			return {"wheat": 5}
 
		"Animal Farm":
			return {"livestock": 3}
 
		"Butcher":
			var livestock = SumProperty(pos, GetSize(b["name"]), ["Animal Farm"], 4, "livestock")
			return {"meat": livestock}
 
		"Restaurant":
			var pop = SumProperty(pos, GetSize(b["name"]), HOUSING_NAMES, 5, "population")
			var meat = SumProperty(pos, GetSize(b["name"]), ["Butcher"], 4, "meat")
			var flour = SumProperty(pos, GetSize(b["name"]), ["Mill"], 4, "flour")
			var products = SumProperty(pos, GetSize(b["name"]), ["Small Factory","Large Factory"], 4, "products")
			return {"money": (pop * 2) * min(meat, flour, products)}
 
		"Mall":
			var pop = SumProperty(pos, GetSize(b["name"]), HOUSING_NAMES, 6, "population")
			var shops = CountNearby(pos,GetSize(b["name"]), SHOP_NAMES, 2,["Mall"])
			return {"money": pop * shops}
		"Small Factory":
			return {"products":SumProperty(pos,GetSize(b["name"]), POWER_GENERATOR_NAMES, 2, "power")/4+1}
			
		"Large Factory":
			return {"products":4 + (SumProperty(pos,GetSize(b["name"]), POWER_GENERATOR_NAMES, 4, "power"))}
		"Pocket Park":
			return {"nature":2}
		"Small Park":
			return {"nature":3}
		"Fountain Park":
			return {"nature":4}
		"Large Park":
			return {"nature":18}
		_:
			return {}
