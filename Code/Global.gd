extends Node

@export var First := true

@export var LoadSettings := {
	"load":true
}

@export var Difficulty = 3

@export var Zoom := 1.0

const BuildingTilemap = preload("res://Assets/Tilesheets/BuildingTiles/tiles.png")
const IconTilemap = preload("res://Assets/icons.png")

# Tool 0 = Select
#      1 = Draw
#      2 = Erase
@export var Tool := 0

# Name of building that is now being built
@export var CurrentBuilding := "None"

const BuildingData := {
	"None":{
		"atlas_coords": Vector2i(0,12),
		"cost": 0
	},
	# --- Housing
	"Basic House":{
		"atlas_coords": Vector2i(0,0),
		"cost": 20,
		"description": "A small home for one family. Population drops near industry buildings, and increases when supplied with power and nature nearby."
	},
	"Double House":{
		"atlas_coords": Vector2i(1,0),
		"cost": 50,
		"description": "A double house containing two families. Population drops near industry buildings, and increases when supplied with power and nature nearby."
	},
	"Small Apartment Complex":{
		"atlas_coords": Vector2i(2,0),
		"cost": 200,
		"description": "A small building containing several families in one structure. Population drops near industry buildings, and increases when supplied with power and nature nearby."
	},
	"Large Apartment Complex":{
		"atlas_coords": Vector2i(3,0),
		"size": Vector2i(1,2),
		"cost": 1250,
		"description": "A large tower providing housing for many families. Population drops near industry buildings, and increases when supplied with power and nature nearby."
	},
	"Mega Apartment Complex":{
		"atlas_coords": Vector2i(4,0),
		"size": Vector2i(2,2),
		"cost": 6000,
		"description": "Three massive connected skyscrapers packing a huge population into one structure. Population drops near industry buildings."
	},
	"Giant Apartment Complex":{
		"atlas_coords": Vector2i(6,0),
		"size": Vector2i(2,2),
		"cost": 50000,
		"description": "hey kajer"
	},
	"Low-Budget Apartment":{
		"atlas_coords": Vector2i(0,1),
		"cost": 400,
		"description": "A low budget building housing many people. Costs a bit of money each second for maintainance. Population does NOT drop near industry buildings."
	},
	# --- Stores
	"Small Supermarket":{
		"atlas_coords": Vector2i(0,2),
		"cost": 50,
		"description": "Earns money from nearby (within [b]one[/b] tile) population, boosted by nearby products from factories. "
	},
	"Large Supermarket":{
		"atlas_coords": Vector2i(1,2),
		"size": Vector2i(2,2),
		"cost": 400,
		"description": "Earns money from a wider population radius (within [b]three[/b] tiles) than a regular supermarket, boosted by nearby (within [b]six[/b] tiles) products from factories."
	},
	"Restaurant":{
		"atlas_coords": Vector2i(3,3),
		"cost": 12000,
		"description": "Earns money from nearby population (within [b]five[/b] tiles), but only if meat, flour and products are nearby (within [b]four[/b] tiles)."
	},
	"Mill":{
		"atlas_coords": Vector2i(3,2),
		"cost": 5000,
		"description": "Processes wheat for nearby bakeries. Uses wheat from nearby wheatfield (within [b]five[/b] tiles) to create flour."
	},
	"Animal Farm":{
		"atlas_coords": Vector2i(4,3),
		"cost": 75000,
		"description": "Breeds livestock for nearby butchers."
	},
	"Distribution Center":{
		"atlas_coords": Vector2i(4,2),
		"cost": 2000,
		"description": "Collects items / products from adjacent suppliers, then shares them with any other Distribution Center on the map."
	},
	"Electronics Store":{
		"atlas_coords": Vector2i(5,2),
		"cost": 10000,
		"description": "Earns money from population living within its radius (within [b]three[/b] tiles)."
	},
	"Cafe":{
		"atlas_coords": Vector2i(6,2),
		"cost": 500,
		"description": "A cozy cafe where people can enjoy a sip of soda or beer. Earns money from population living within its radius (within [b]two[/b] tiles)."
	},
	"Bakery":{
		"atlas_coords": Vector2i(7,2),
		"cost": 3000,
		"description": "A small bakery baking bread for the nearby people. Earns money from nearby population (within [b]three[/b] tiles), requires flour from nearby mills (within [b]three[/b] tiles)."
	},
	"Mall":{
		"atlas_coords": Vector2i(8,2),
		"size": Vector2i(2,2),
		"cost": 80000,
		"description": "A large mall combining several shops into one huge aircooled building. Earns money from nearby population (within [b]six[/b] tiles), boosted by all shops around (within [b]two[/b] tiles)."
	},
	"Butcher":{
		"atlas_coords": Vector2i(5,3),
		"cost": 50000,
		"description": "Processes livestock from nearby (within [b]four[/b] tiles) animal farms into meat."
	},
	# --- Energy Industry
	"Thermal Power Plant":{
		"atlas_coords": Vector2i(0,4),
		"cost": 30000,
		"description": "A power plant that burns coal to produce energy. This energy can be brought to transformator buildings to increase population in your city."
	},
	"Small Solar Farm":{
		"atlas_coords": Vector2i(1,4),
		"cost": 40000,
		"description": "A few solar panels that produce energy. This energy can be brought to transformator buildings to increase population in your city."
	},
	"Nuclear Power Plant":{
		"atlas_coords": Vector2i(2,4),
		"cost": 90000,
		"description": "A large nuclear power reactor. Generates energy by splitting uranium atoms, and converting its heat into energy. This energy can be brought to transformator buildings to increase population in your city."
	},
	"Large Thermal Power Plant":{
		"atlas_coords": Vector2i(3,4),
		"size": Vector2i(2,2),
		"cost": 130000,
		"description": "A large power plant that burns massive amounts of coal to produce energy. This energy can be brought to transformator buildings to increase population in your city."
	},
	"Large Solar Farm":{
		"atlas_coords": Vector2i(5,4),
		"size": Vector2i(2,2),
		"cost": 180000,
		"description": "A ton of solar panels placed for optimal power efficiency. Produces large amounts of energy. This energy can be brought to transformator buildings to increase population in your city."
	},
	"Transformator Building":{
		"atlas_coords": Vector2i(7,4),
		"cost": 2000,
		"description": "Brings power from nearby power plants and solar farms to the city, giving population (within [b]fifteen[/b] tiles) a large boost. Collects power from within [b]three[/b] tiles"
	},
	# --- Parks
	"Pocket Park":{
		"atlas_coords": Vector2i(0,6),
		"cost": 1000,
		"description":"A small park cramped between buildings. Has just enough space for a single tree. Boosts population of the buildings around."
	},
	"Small Park":{
		"atlas_coords": Vector2i(1,6),
		"cost": 1500,
		"description":"A small park in the middle of the city. Features a few trees, bushes and paths connecting it all. Boosts population of the buildings around."
	},
	"Fountain Park":{
		"atlas_coords": Vector2i(2,6),
		"cost": 2000,
		"description":"A small park providing relaxation for citizens. Features a small fountain where people can wish. Boosts population of the buildings around."
	},
	"Large Park":{
		"atlas_coords": Vector2i(3,6),
		"size": Vector2i(2,2),
		"cost": 9000,
		"description":"A large park featuring trees, bushes and many paths connecting all parts of the park. Boosts population of the buildings around."
	},
	# --- Nature
	"Small Forest":{
		"atlas_coords": Vector2i(0,8),
		"cost": 1000,
		"description":""
	},
	"Large Forest":{
		"atlas_coords": Vector2i(1,8),
		"size": Vector2i(2,2),
		"cost": 5000,
		"description":""
	},
	"Large Mountain":{
		"atlas_coords": Vector2i(3,8),
		"size": Vector2i(2,2),
		"cost": 20000,
		"description":""
	},
	"Small Wheatfield":{
		"atlas_coords": Vector2i(5,8),
		"cost": 2000,
		"description":""
	},
	"Large Wheatfield":{
		"atlas_coords": Vector2i(6,8),
		"size": Vector2i(2,2),
		"cost": 10000,
		"description":""
	},
	# --- Production Industry
	"Small Factory":{
		"atlas_coords": Vector2i(0,10),
		"cost": 50000,
		"description":"A large industrial factory producing various food products. Placing it near housing will make their population drop."
	},
	"Large Factory":{
		"atlas_coords": Vector2i(1,10),
		"cost": 250000,
		"size": Vector2i(2,2),
		"description":""
	},
	# --- Trains
	"Train Station":{
		"atlas_coords": Vector2i(18,3),
		"cost": 50000000, # <- 50M
		"size": Vector2i(2,2),
		"description":"empty"
	},
	"Rail":{
		"atlas_coords": Vector2i(19,5),
		"cost": 3000000, # <- 3M
		"description":"empty"
	}
}

@export var BuildingUses := {}

const UnlockRequirements := {
	"Double House": [{"type":"population","amount":10}],
	"Small Apartment Complex": [{"type":"population","amount":40}],
	"Large Apartment Complex": [{"type":"population","amount":150}],
	"Mega Apartment Complex": [{"type":"population","amount":400}],
	"Giant Apartment Complex": [{"type":"population","amount":1000}],
	"Low-Budget Apartment": [{"type":"population","amount":80}],
	
	"Large Supermarket": [{"type":"building_count","building":"Small Supermarket","amount":3}],
	"Mill": [{"type":"building_count","building":"Small Wheatfield","amount":2}],
	"Bakery": [{"type":"building_count","building":"Mill","amount":1}],
	"Distribution Center": [{"type":"building_count","building":"Small Factory","amount":2}],
	"Electronics Store": [{"type":"population","amount":100}],
	"Cafe": [{"type":"population","amount":40}],
	"Restaurant":[{"type":"building_count","building":"Cafe","amount":3}],
	"Mall":[{"type":"population","amount":250}],
	"Animal Farm":[{"type":"building_count","building":"Mill","amount":2}],
	"Butcher":[{"type":"building_count","building":"Animal Farm","amount":1}],
	"Small Solar Farm": [{"type":"money","amount":1000}],
	"Nuclear Power Plant": [{"type":"population","amount":300}],
	"Large Thermal Power Plant": [{"type":"building_count","building":"Thermal Power Plant","amount":2}],
	"Large Solar Farm": [{"type":"building_count","building":"Small Solar Farm","amount":2}],

	"Small Park": [{"type":"building_count","building":"Pocket Park","amount":2}],
	"Fountain Park": [{"type":"money","amount":500}],
	"Large Park": [{"type":"population","amount":200}],
	"Large Forest": [{"type":"building_count","building":"Small Forest","amount":2}],
	"Large Mountain": [{"type":"money","amount":2000}],
	"Large Wheatfield": [{"type":"building_count","building":"Small Wheatfield","amount":3}],

	"Large Factory": [{"type":"building_count","building":"Small Factory","amount":3}],
}	

const RailIndexes = {
	
}
@export var Money := 100.0
@export var Population := 0
@export var Income := 0.0

func GetBuildingCost(nam) -> int:
	var base = BuildingData[nam]["cost"]
	if nam == "Rail":
		return base
	var mult = BuildingUses.get_or_add(nam,0)
	var increase : float = {1:1.05,2:1.1,3:1.3,4:1.4,5:1.5}[Difficulty]
	return base * (increase ** mult)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("Abe") and event.is_pressed():
		Money *= 1.5

func GetBigNumber(i:float) -> String:
	if i >= 1000000:
		var big = Big.new(i)
		return(big.toMetricSymbol())
	elif i >= 1000:
		var base = floor(i / 1000)
		return(str(int(base)) + "," + ("%03d" % (int(i) % 1000)))
	else:
		if int(i) == i:
			return(str(int(i)))
		else:
			return(str(i))
			
