extends Node

const BuildingTilemap = preload("res://Assets/tiles.png")
const IconTilemap = preload("res://Assets/icons.png")
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("Abe") and event.is_pressed():
		Money += 200
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
		"cost": 125,
		"description": "A small building containing several families in one structure. Population drops near industry buildings, and increases when supplied with power and nature nearby."
	},
	"Large Apartment Complex":{
		"atlas_coords": Vector2i(3,0),
		"size": Vector2i(1,2),
		"cost": 350,
		"description": "A large tower providing housing for many families. Population drops near industry buildings, and increases when supplied with power and nature nearby."
	},
	"Mega Apartment Complex":{
		"atlas_coords": Vector2i(4,0),
		"size": Vector2i(2,2),
		"cost": 550,
		"description": "Three massive connected skyscrapers packing a huge population into one structure. Population drops near industry buildings."
	},
	# --- Stores
	"Small Supermarket":{
		"atlas_coords": Vector2i(0,2),
		"cost": 45,
		"description": "Earns money from nearby population, boosted by nearby distribution centers."
	},
	"Large Supermarket":{
		"atlas_coords": Vector2i(1,2),
		"size": Vector2i(2,2),
		"cost": 200,
		"description": "Earns money from a wider population radius than a regular supermarket, boosted by nearby distribution centers."
	},
	"Restaurant":{
		"atlas_coords": Vector2i(3,3),
		"cost": 350,
		"description": "Earns money from nearby population, but only if meat, flour and products are nearby."
	},
	"Mill":{
		"atlas_coords": Vector2i(3,2),
		"cost": 200,
		"description": "Processes goods for nearby bakeries."
	},
	"Animal Farm":{
		"atlas_coords": Vector2i(4,3),
		"cost": 90,
		"description": "Breeds livestock for nearby butchers."
	},
	"Distribution Center":{
		"atlas_coords": Vector2i(4,2),
		"cost": 100,
		"description": "Collects products from nearby factories to be distributed to supermarkets within a wide range."
	},
	"Electronics Store":{
		"atlas_coords": Vector2i(5,2),
		"cost": 400,
		"description": "Earns money from population living within its radius."
	},
	"Cafe":{
		"atlas_coords": Vector2i(6,2),
		"cost": 80,
		"description": "A cozy cafe where people can enjoy a sip of soda or beer. Earns money from population living within its radius."
	},
	"Bakery":{
		"atlas_coords": Vector2i(7,2),
		"cost": 100,
		"description": "A small bakery baking bread for the nearby people. Earns money from nearby population, requires flour from nearby mills."
	},
	"Mall":{
		"atlas_coords": Vector2i(8,2),
		"size": Vector2i(2,2),
		"cost": 1500,
		"description": "A large mall combining several shops into one huge aircooled building. Earns money from nearby population, boosted by all shops around."
	},
	"Butcher":{
		"atlas_coords": Vector2i(5,3),
		"cost": 150,
		"description": "Processes livestock from nearby animal farms into meat."
	},
	# --- Energy Industry
	"Thermal Power Plant":{
		"atlas_coords": Vector2i(0,4),
		"cost": 500,
		"description": "A power plant that burns coal to produce energy. This energy can be brought to transformator buildings to increase population in your city."
	},
	"Small Solar Farm":{
		"atlas_coords": Vector2i(1,4),
		"cost": 700,
		"description": "A few solar panels that produce energy. This energy can be brought to transformator buildings to increase population in your city."
	},
	"Nuclear Power Plant":{
		"atlas_coords": Vector2i(2,4),
		"cost": 4000
	},
	"Large Thermal Power Plant":{
		"atlas_coords": Vector2i(3,4),
		"size": Vector2i(2,2),
		"cost": 1900
	},
	"Large Solar Farm":{
		"atlas_coords": Vector2i(5,4),
		"size": Vector2i(2,2),
		"cost": 2200
	},
	"Transformator Building":{
		"atlas_coords": Vector2i(7,4),
		"cost": 300
	},
	# --- Parks
	"Pocket Park":{
		"atlas_coords": Vector2i(0,6),
		"cost": 100
	},
	"Small Park":{
		"atlas_coords": Vector2i(1,6),
		"cost": 150
	},
	"Fountain Park":{
		"atlas_coords": Vector2i(2,6),
		"cost": 200
	},
	"Large Park":{
		"atlas_coords": Vector2i(3,6),
		"size": Vector2i(2,2),
		"cost": 900
	},
	# --- Nature
	"Small Forest":{
		"atlas_coords": Vector2i(0,8),
		"cost": 70
	},
	"Large Forest":{
		"atlas_coords": Vector2i(1,8),
		"size": Vector2i(2,2),
		"cost": 250
	},
	"Large Mountain":{
		"atlas_coords": Vector2i(3,8),
		"size": Vector2i(2,2),
		"cost": 1000
	},
	"Small Wheatfield":{
		"atlas_coords": Vector2i(5,8),
		"cost": 50
	},
	"Large Wheatfield":{
		"atlas_coords": Vector2i(6,8),
		"size": Vector2i(2,2),
		"cost": 200
	},
	# --- Production Industry
	"Small Factory":{
		"atlas_coords": Vector2i(0,10),
		"cost": 300
	},
	"Large Factory":{
		"atlas_coords": Vector2i(1,10),
		"cost": 1250,
		"size": Vector2i(2,2),
	},
}

const UnlockRequirements := {
	"Double House": [{"type":"population","amount":20}],
	"Small Apartment Complex": [{"type":"population","amount":50}],
	"Large Apartment Complex": [{"type":"population","amount":150}],
	"Mega Apartment Complex": [{"type":"population","amount":400}],

	"Large Supermarket": [{"type":"building_count","building":"Small Supermarket","amount":3}],
	"Mill": [{"type":"building_count","building":"Small Wheatfield","amount":2}],
	"Bakery": [{"type":"building_count","building":"Mill","amount":1}],
	"Distribution Center": [{"type":"building_count","building":"Small Factory","amount":2}],
	"Electronics Store": [{"type":"population","amount":100}],
	"Cafe": [{"type":"population","amount":30}],
	"Restaurant":[{"type":"building_count","building":"Cafe","amount":3}],
	"Mall":[{"type":"population","amount":250}],
	"Animal Farm":[{"type":"building_count","building":"Mill","amount":2}],
	"Butcher":[{"type":"building_count","building":"Animal Farm","amount":1}],
	"Small Solar Farm": [{"type":"money","amount":1000}],
	"Nuclear Power Plant": [{"type":"population","amount":300}],
	"Large Thermal Power Plant": [{"type":"building_count","building":"Thermal Power Plant","amount":2}],
	"Large Solar Farm": [{"type":"building_count","building":"Small Solar Farm","amount":2}],
	"Transformator Building": [{"type":"building_count","building":"Thermal Power Plant","amount":1}],

	"Small Park": [{"type":"building_count","building":"Pocket Park","amount":2}],
	"Fountain Park": [{"type":"money","amount":500}],
	"Large Park": [{"type":"population","amount":200}],
	"Large Forest": [{"type":"building_count","building":"Small Forest","amount":2}],
	"Large Mountain": [{"type":"money","amount":2000}],
	"Large Wheatfield": [{"type":"building_count","building":"Small Wheatfield","amount":3}],

	"Large Factory": [{"type":"building_count","building":"Small Factory","amount":3}],
}	

@export var Money = 100.0
@export var Population := 0
