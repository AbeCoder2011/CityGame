extends Node2D

signal deselect

var BuildingScene = preload("res://Scenes/building.tscn")
# EXAMPLE: [{"pos":Vector2i(23,33),"name":"Basic House","node":[NODE]}]
var Buildings = []

var DestroyedBuildings = []

var distribution_centers_inventory := {}
var global_power = 0
var already_checked_buildings = []
const SHOP_NAMES = [
	"Small Supermarket", "Large Supermarket", "Electronics Store","Cafe", "Bakery", "Restaurant", "Mall"
]
const HOUSING_NAMES = [
	"Basic House", "Double House", "Small Apartment Complex","Large Apartment Complex", "Mega Apartment Complex","Low-Budget Apartment","Giant Apartment Complex"
]
const DC_PROPERTIES = ["products","flour","wheat","electronics","livestock","meat","livestock"]
func AddToRemovalList(node:Node2D):
	DestroyedBuildings.append(node)
	Global.Money += Global.BuildingData[node.building_name]["cost"] * 0.5
	$"../UI".UpdateCityStats()

func NewBuilding(nam:String, location:Vector2i,check_unlocks=true):
	
	var b : Node2D = BuildingScene.instantiate()
	b.init_building(nam)
	b.position = location * 48
	add_child(b)
	deselect.connect(b.Deselect)
	Buildings.append({"pos":location,"name":nam,"node":b})
	$"..".CheckBuildingUnlocks(GetBuildingAmounts())
	if check_unlocks:
		$"../UI".CheckBuildingUnlocks()
	print(Buildings)
func DeselectOthers():
	deselect.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("move_building") and event.is_pressed():
		pass
# --- Helpers -------------------------------------------------

func Dist(a:Vector2i, b:Vector2i) -> float:
	return max(abs(a.x - b.x),abs(a.y - b.y))

func GetBuildingAmounts() -> Dictionary:
	var counts = {}
	for b in Buildings:
		counts[b["name"]] = counts.get(b["name"], 0) + 1
	return counts

# Count buildings of given names within radius of pos
func CountNearby(pos:Vector2i, names:Array, radius:float, exclude:Array = []) -> int:
	var count = 0
	for b in Buildings:
		if b["pos"] == pos or b["name"] in exclude:
			continue
		if names.has(b["name"]) and Dist(pos, b["pos"]) <= radius:
			count += 1
	return count

# Calculates how much some property is in the area
func SumProperty(pos:Vector2i, names:Array, radius:float, prop:String,exclude:Array = []) -> float:
	var total = 0.0
	for b in Buildings:
		if b["pos"] == pos or b["name"] in exclude:
			continue
		if Dist(pos, b["pos"]) <= radius:
			if names.has(b["name"]):
				total += b["node"].get(prop)
			if b["name"] == "Distribution Center":
				total += distribution_centers_inventory.get(prop,0)
	return total

func SumAllProperties(pos:Vector2i, radius:float):
	var properties = {}
	for b in Buildings:
		if b["pos"] == pos or b["name"] == "Distribution Center" or b in already_checked_buildings:
			continue
		if Dist(pos, b["pos"]) <= radius:
			for n in DC_PROPERTIES:
				properties[n] = properties.get(n, 0) + b["node"].get(n)
				already_checked_buildings.append(b)
	return properties

func IndustryPenalty(pos:Vector2i) -> float:
	var thermal = CountNearby(pos, ["Thermal Power Plant"], 6)
	var nuclear = CountNearby(pos, ["Nuclear Power Plant"], 8)
	var large_thermal = CountNearby(pos, ["Large Thermal Power Plant"], 8)
	var sm_factory = CountNearby(pos, ["Small Factory"], 8)
	var large_factory = CountNearby(pos, ["Large Factory"], 8)
	var exponent = thermal + nuclear + (large_thermal * 2) + sm_factory + (large_factory * 4)
	return 0.5 ** exponent

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
	already_checked_buildings = []
	distribution_centers_inventory = {}
	global_power = 0
	for b in Buildings:
		#if b["name"] == "Distribution Center":
			#var inv = SumAllProperties(b["pos"],1)
			#for n in inv.keys():
				#distribution_centers_inventory.set(n,inv[n] + distribution_centers_inventory.get(n,0))
		if b["name"] == "Transformator Building":
			global_power += SumProperty(b["pos"],["Thermal Power Plant","Small Solar Farm","Nuclear Power Plant","Large Thermal Power Plant","Large Solar Farm"],3,"power")
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
	money_total -= Global.Loans
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
			var power = SumProperty(pos, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 2 * (1 + 0.01 * nature) else 1
			return {"population": 2 * IndustryPenalty(pos) * population_boost * (1 + 0.01 * nature)}
		"Double House":
			var power = SumProperty(pos, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 4 * (1 + 0.01 * nature) else 1
			return {"population": 4 * IndustryPenalty(pos) * population_boost * (1 + 0.01 * nature)}
		"Small Apartment Complex":
			var power = SumProperty(pos, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 8 * (1 + 0.01 * nature) else 1
			return {"population": 8 * IndustryPenalty(pos) * population_boost * (1 + 0.01 * nature)}
		"Large Apartment Complex":
			var power = SumProperty(pos, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 24 * (1 + 0.01 * nature) else 1
			return {"population": 24 * IndustryPenalty(pos) * population_boost * (1 + 0.01 * nature)}
		"Mega Apartment Complex":
			var power = SumProperty(pos, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 64 * (1 + 0.01 * nature) else 1
			return {"population": 64 * IndustryPenalty(pos) * population_boost * (1 + 0.01 * nature)}
		"Giant Apartment Complex":
			var power = SumProperty(pos, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 256 * (1 + 0.01 * nature) else 1
			return {"population": 256 * IndustryPenalty(pos) * population_boost * (1 + 0.01 * nature)}
		"Low-Budget Apartment":
			var power = SumProperty(pos, ["Transformator Building"], 8, "power")
			var nature = SumProperty(pos, ["Pocket Park","Small Park","Fountain Park","Large Park"], 7, "nature")
			var population_boost = 2 if power > 8 * (1 + 0.01 * nature) else 1
			return {"population": 8 * population_boost * (1 + 0.01 * nature)}
		"Small Supermarket":
			var pop = SumProperty(pos, HOUSING_NAMES, 1, "population")
			var products = SumProperty(pos, ["Distribution Center"], 6, "products")
			return {"money": 0.25 * pop * (1 + 0.25 * products)}

		"Large Supermarket":
			var pop = SumProperty(pos, HOUSING_NAMES, 3, "population")
			var products = SumProperty(pos, ["Distribution Center"], 6, "products")
			return {"money": 0.25 * pop * (1 + 0.25 * products)}

		"Mill":
			var wheat = SumProperty(pos, ["Small Wheatfield","Large Wheatfield"], 5, "wheat")
			return {"flour": wheat}

		"Distribution Center":
			return SumAllProperties(b["pos"],1)
		
		"Electronics Store":
			return {"money": 0.5 * SumProperty(pos, HOUSING_NAMES, 3, "population")}
		
		"Cafe":
			return {"money": 0.3 * SumProperty(pos, HOUSING_NAMES, 2, "population")}
		
		"Bakery":
			var flour = SumProperty(pos, ["Mill"], 3, "flour")
			var pop = SumProperty(pos, HOUSING_NAMES, 3, "population")
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
			var livestock = SumProperty(pos, ["Animal Farm"], 4, "livestock")
			return {"meat": livestock}
 
		"Restaurant":
			var pop = SumProperty(pos, HOUSING_NAMES, 5, "population")
			var meat = SumProperty(pos, ["Butcher"], 4, "meat")
			var flour = SumProperty(pos, ["Mill"], 4, "flour")
			var products = SumProperty(pos, ["Small Factory","Large Factory"], 4, "products")
			return {"money": (pop * 2) * min(meat, flour, products)}
 
		"Mall":
			var pop = SumProperty(pos, HOUSING_NAMES, 6, "population")
			var shops = CountNearby(pos, SHOP_NAMES, 2,["Mall"])
			return {"money": pop * shops}
		"Small Factory":
			return {"products":1}
			
		"Large Factory":
			return {"products":4}
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
