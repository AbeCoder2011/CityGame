extends Node

const BuildingTilemap = preload("res://Assets/tiles.png")

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
		"description": "A small home for one family. Population drops near industry buildings."
	},
	"Double House":{
		"atlas_coords": Vector2i(1,0),
		"cost": 50,
		"description": "A double house containing two families. Population drops near industry buildings."
	},
	"Small Apartment Complex":{
		"atlas_coords": Vector2i(2,0),
		"cost": 125,
		"description": "A small building containing several families in one structure. Population drops near industry buildings."
	},
	"Large Apartment Complex":{
		"atlas_coords": Vector2i(3,0),
		"size": Vector2i(1,2),
		"cost": 350,
		"description": "A large tower providing housing for many families. Population drops near industry buildings."
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
		"cost": 500
	},
	"Small Solar Farm":{
		"atlas_coords": Vector2i(1,4),
		"cost": 700
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



@export var Money = 100.0
@export var Population := 0
