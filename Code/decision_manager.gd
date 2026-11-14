extends Node2D

var active_decisions := {}

const EXCLUDE_BUILDINGS = ["Rail"]

var time_until_next_decision := 0

var lastID : int

var decision_buffs = []

var buffs = {}

var open_decision

func DecreaseDecisionTime():
	time_until_next_decision -= 1
	if time_until_next_decision <= 0:
		NewDecision()
		time_until_next_decision = randi_range(45,180)
	for n in decision_buffs:
		n["duration"] -= 1
		if n["duration"] <= 0:
			decision_buffs.erase(n)
			UpdateBuffs()
	$"../UI".UpdateIncome()

func UpdateBuffs():
	buffs = {}
	for n in decision_buffs:
		var old = float(buffs.get_or_add(n["name"],1.0))
		buffs[n["name"]] = old + (float(n["value"]) / 100)
	$"../Buildings".RecomputePopulation()

func NewDecision(i : int = 0) -> void:
	if i >= 10:
		return # Could not find any RIP
	var decision = GetEligibleDecision()
	if decision == null:
		# No eligible decisions
		return
	var node = GetRandomBuildingFromType(decision["eligible_buildings"])
	if node == null:
		NewDecision(i + 1) # could not find a valid place for this decision, choose new decision
		return
	var id = GetNextFreeID()
	node.SpawnDecision(id)
	active_decisions[id] = {"data":decision,"node":node}

func GetEligibleDecision():
	var decisions = DecisionData.Data.duplicate().values()
	decisions.shuffle()
	for n in decisions:
		var req = n.get("requirement",[])
		if is_same($"..".GetRequirementProgress(req),true):
			return n

func GetRandomBuildingFromType(type:String):
	var names : Array = []
	var any := false

	match type:
		"all":
			any = true
		"all_housing":
			names = $"../Buildings".HOUSING_NAMES
		"all_hotels":
			names = ["Small Motel", "Small Roadside Hotel", "Medium Hotel", "Large Hotel", "Luxury Hotel", "Large Luxury Hotel"]
		"all_shops":
			names = $"../Buildings".SHOP_NAMES + ["Jewlery Store"]
		"all_power_generators":
			names = $"../Buildings".POWER_GENERATOR_NAMES
		"all_power":
			names = $"../Buildings".POWER_GENERATOR_NAMES + ["Transformator Building"]
		"all_factories":
			names = ["Small Factory", "Large Factory"]
		"all_entertainment":
			names = $"../Buildings".ENTERTAINMENT_NAMES
		"all_parks":
			names = ["Pocket Park", "Small Park", "Fountain Park", "Large Park"]
		"all_nature":
			names = ["Small Forest", "Large Forest", "Large Mountain", "Small Wheatfield", "Large Wheatfield"]
		"all_farms":
			names = ["Small Wheatfield", "Large Wheatfield", "Animal Farm"]
		"all_food":
			names = ["Mill", "Bakery", "Animal Farm", "Butcher", "Restaurant"]
		"all_fishing":
			names = ["Fishing Hut", "Fishing Boat", "Fishing Dock", "Seafood Market"]
		"all_mining":
			names = ["Mine", "Ore Extractor", "Sand Mine", "Smeltery", "Jewlery Store"]
		"all_train_stations":
			names = ["Train Station"]
		"all_metro":
			names = ["Metro Station", "Large Metro Station", "Extra Metro Platform"]
		"all_airport":
			names = ["Airport Terminal", "Air Traffic Control Tower", "Airport Runway"]
		"all_transport":
			names = ["Train Station", "Metro Station", "Large Metro Station", "Airport Terminal"]
		_:
			# If it is not in the above lists, just use the raw name
			if Global.BuildingData.has(type):
				names = [type]
			else:
				printerr("Could not find Building type %s" % type)
				return null

	var destroyed_nodes := []
	for d in $"../Buildings".DestroyedBuildings:
		destroyed_nodes.append(d["node"])

	var candidates := []
	for coll in $"../Buildings".BuildingCollections.values():
		for b in coll:
			if b["node"] in destroyed_nodes:
				continue
			if any:
				if b["name"] in EXCLUDE_BUILDINGS:
					continue
			elif not b["name"] in names:
				continue
			candidates.append(b)

	if candidates.is_empty():
		return null
	return candidates.pick_random()["node"]

func DecisionPressed(id:int):
	$"../UI/UI/Decision".SetDecision(DecisionData.Data.find_key(active_decisions[id]["data"]),active_decisions[id]["data"])
	open_decision = id

func DecisionButtonPressed(id:int):
	Resolve(active_decisions[open_decision]["data"]["options"][id]["effects"])
	active_decisions[open_decision]["node"].HideDecision()
	active_decisions.erase(open_decision)

func GetNextFreeID() -> int:
	if lastID == 0:
		lastID = randi()
	else:
		lastID += 1
	return lastID

func Resolve(outcome:Array):
	for n in outcome:
		match n["name"]:
			"reduce_income":
				decision_buffs.append({"name":"income","value":-n["value"],"duration":n["duration"]})
			"boost_income":
				decision_buffs.append({"name":"income","value":n["value"],"duration":n["duration"]})
			"reduce_population":
				decision_buffs.append({"name":"population","value":-n["value"],"duration":n["duration"]})
			"boost_population":
				decision_buffs.append({"name":"population","value":n["value"],"duration":n["duration"]})
			"happiness_debuff","happiness_boost":
				$"..".AddHappinessDebuff(n["value"],n["duration"],"Unpopular Decision" if n["value"] < 0 else "Popular Decision")
			"increase_building_cost":
				decision_buffs.append({"name":"building_cost","value":n["value"],"duration":n["duration"]})
			"reduce_building_cost":
				decision_buffs.append({"name":"building_cost","value":-n["value"],"duration":n["duration"]})
			"gain_money":
				Global.Money += GetMoneyValue(n["value"])
			"gain_money":
				Global.Money -= GetMoneyValue(n["value"])
			# OTHERS
	UpdateBuffs()

func GetMoneyValue(seconds:int) -> float:
	return Global.Income * seconds * 2
