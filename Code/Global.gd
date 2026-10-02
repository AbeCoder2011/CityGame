extends Node

@export var First := true

@export var LoadSettings := {
	"load":true,
}

@export var GameSettings := {}

@export var Difficulty = 3

@export var Zoom := 1.0

var AchievementProgress = {}

const BuildingTilemap = preload("res://Assets/Tilesheets/BuildingTiles/tiles.png")
const IconTilemap = preload("res://Assets/icons.png")


# Tool 0 = Select
#      1 = Draw
#      2 = Erase
@export var Tool := 0

# Name of building that is now being built
@export var CurrentBuilding := "None"

@export var Settings = {}

const AroundTiles = [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]

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
		"description": "One huge building housing an absurd amount of people in a single building. Population drops near industry buildings."
	},
	"Low-Budget Apartment":{
		"atlas_coords": Vector2i(0,1),
		"cost": 400,
		"description": "A low budget building housing many people. Population does not drop near industry buildings, but it has a fixed happiness rate of 50."
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
		"cost": 1000000, #1m
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
		"description": "Breeds livestock for nearby butchers. The meat is probably not organic."
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
	"Lumber Mill":{
		"atlas_coords": Vector2i(7,3),
		"cost": 10000,
		"description": "A place where trees are chopped and sold as furniture. Gains money from nearby population (within [b]four[/b]) tiles. Boosted by all empty forests adjacent",
	},
	"Fishing Hut":{
		"atlas_coords": Vector2i(4,2),
		"cost": 5000,
		"description": "Fishes for various different sea creatures and sells them to nearby population (Within [b]three[/b] tiles). Must be next to water"
	},
	"Seafood Market":{
		"atlas_coords": Vector2i(12,2),
		"cost": 15000,
		"size": Vector2i(2,2),
		"description": "A large market for buying an selling seafood (within [b]four[/b] tiles). Boosted by population within [b]four[/b] tiles."
	},
	"Mall":{
		"atlas_coords": Vector2i(8,2),
		"size": Vector2i(2,2),
		"cost": 200000, # 200k
		"description": "A large mall combining several shops into one huge aircooled building. Earns money from nearby population (within [b]six[/b] tiles), boosted by all shops around (within [b]two[/b] tiles)."
	},
	"Butcher":{
		"atlas_coords": Vector2i(5,3),
		"cost": 50000,
		"description": "Processes livestock from nearby (within [b]four[/b] tiles) animal farms into meat."
	},
	"Ore Extractor":{
		"atlas_coords": Vector2i(10,2),
		"cost": 5000000000,
		"size":Vector2i(2,2),
		"description": "Takes raw gems from nearby mines (within [b]four[/b] tiles) and processes it into gems"
	},
	"Jewlery Store":{
		"atlas_coords": Vector2i(6,3),
		"cost": 5000000000,
		"description": "Sells gems from within [b]five[/b] tiles and sells them to population within [b]five[/b] tiles"
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
		"description": "A few solar panels that produce energy. This energy can be brought to transformator buildings to increase population in your city. Does NOT cause population loss"
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
		"description": "A ton of solar panels placed for optimal power efficiency. Produces large amounts of energy. This energy can be brought to transformator buildings to increase population in your city. Does NOT cause population loss"
	},
	"Wind Turbine":{
		"atlas_coords": Vector2i(7,5),
		"size": Vector2i(1,1),
		"cost": 2000000, #2m
		"forcewater": true,
		"description": "A massive spinning turbine that turns wind into energy. Must be placed on water, but gets worse the more wind turbines there are nearby (within [b]two[/b] tiles)"
	},
	"Transformator Building":{
		"atlas_coords": Vector2i(7,4),
		"cost": 2000,
		"description": "Brings power from nearby power plants and solar farms to the city, giving population (within [b]eight[/b] tiles) a large boost. Collects power from within [b]three[/b] tiles"
	},
	# --- Parks
	"Pocket Park":{
		"atlas_coords": Vector2i(0,6),
		"cost": 1000,
		"description":"A small park cramped between buildings. Has just enough space for a single tree. Boosts population of the buildings around (within [b]seven[/b] tiles)."
	},
	"Small Park":{
		"atlas_coords": Vector2i(1,6),
		"cost": 1500,
		"description":"A small park in the middle of the city. Features a few trees, bushes and paths connecting it all. Boosts population of the buildings around (within [b]seven[/b] tiles)."
	},
	"Fountain Park":{
		"atlas_coords": Vector2i(2,6),
		"cost": 2000,
		"description":"A small park providing relaxation for citizens. Features a small fountain where people can wish. Boosts population of the buildings around (within [b]seven[/b] tiles)."
	},
	"Large Park":{
		"atlas_coords": Vector2i(3,6),
		"size": Vector2i(2,2),
		"cost": 9000,
		"description":"A large park featuring trees, bushes and many paths connecting all parts of the park. Boosts population of the buildings around (within [b]seven[/b] tiles)."
	},
	# --- Nature
	"Small Forest":{
		"atlas_coords": Vector2i(0,8),
		"cost": 1000,
		"description":"A small forest with many trees. What did you expect?"
	},
	"Large Forest":{
		"atlas_coords": Vector2i(1,8),
		"size": Vector2i(2,2),
		"cost": 5000,
		"description":"A huge forest with large, old trees. A rumor says a forest elf lives inside."
	},
	"Large Mountain":{
		"atlas_coords": Vector2i(3,8),
		"size": Vector2i(2,2),
		"cost": 200000000,
		"description":"A huge mountain with snow at the very top. Contains many gemstones, but they are hidden in the rocks..."
	},
	"Small Wheatfield":{
		"atlas_coords": Vector2i(5,8),
		"cost": 1000,
		"description":"A small, wild wheatfield. The wheat can be harvested by mills to create flour."
	},
	"Large Wheatfield":{
		"atlas_coords": Vector2i(6,8),
		"size": Vector2i(2,2),
		"cost": 5000,
		"description":"A Large wheatfield spanning as far as the eye can see. The wheat can be harvested by mills to create flour."
	},
	# --- Production Industry
	"Small Factory":{
		"atlas_coords": Vector2i(0,10),
		"cost": 50000,
		"description":"A small industrial factory producing some food products. Placing it near housing will make their population drop."
	},
	"Large Factory":{
		"atlas_coords": Vector2i(1,10),
		"cost": 250000,
		"size": Vector2i(2,2),
		"description":"A large industrial factory producing many food products. Placing it near housing will make their population drop."
	},
	"Mine":{
		"atlas_coords": Vector2i(0,11),
		"cost": 1000000000, # 1b
		"description": "Mines raw gems from adjacent mountains. (within [b]one[/b] tile)"
	},
	"Fishing Boat":{
		"atlas_coords": Vector2i(0, 3),
		"cost": 1000000, # 1m
		"description": "Fishes up rare fish from the bottom of the ocean. Boosted by empty deep water adjacent. Must be placed on deep water",
		"forcedeepwater": true,
	},
	"Sand Mine":{
		"atlas_coords": Vector2i(3,10),
		"cost": 1000000000000, # 1T
		"description": "A large sand quarry, mining up sand in the nearby desert."
	},
	"Smeltery":{
		"atlas_coords": Vector2i(3,11),
		"cost": 1000000000000, # 1T
		"description": "Smelts sand into silicon."
	},
	"Fishing Dock":{
		"atlas_coords": Vector2i(12,4),
		"cost": 10000000, # 10M
		"forcewater":true,
		"nexttoland":true,
		"description": "Takes fish from all fishing boats on the same body of water within a radius of 15 tiles. Must be placed on water next to land"
	},
	# --- Trains
	"Train Station":{
		"atlas_coords": Vector2i(18,3),
		"cost": 50000000, # <- 50M
		"size": Vector2i(2,2),
		"description":"A train station for transporting goods. Will take items from within [b]four[/b] tiles. Use rails to connect it up to other stations, and those will share resources with this one."
	},
	"Rail":{
		"atlas_coords": Vector2i(19,5),
		"cost": 3000000, # <- 3M
		"can_on_water":true,
		"description":"A rail which trains can ride on. Used to connect Train Stations to each other."
	},
	# --- Entertainment
	"Theme Park":{
		"atlas_coords": Vector2i(18,18),
		"cost": 10000000,
		"size":Vector2(2,2),
		"description":"A theme park for people to enjoy themselves. Give happiness to population within [b]four[/b] tiles",
	},
	"Cinema":{
		"atlas_coords": Vector2i(17,18),
		"cost": 1000000,
		"description":"A small cinema for people to watch movies. Give happiness to population within [b]four[/b] tiles",
	},
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
	"Mill": [{"type":"building_count","building":"Cafe","amount":2}],
	"Bakery": [{"type":"building_count","building":"Mill","amount":1}],
	"Electronics Store": [{"type":"population","amount":100}],
	"Cafe": [{"type":"population","amount":40}],
	"Restaurant":[{"type":"building_count","building":"Cafe","amount":3}],
	"Mall":[{"type":"population","amount":250}],
	"Animal Farm":[{"type":"building_count","building":"Mill","amount":2}],
	"Butcher":[{"type":"building_count","building":"Animal Farm","amount":1}],
	"Lumber Mill":[{"type":"population","amount":150}],
	"Seafood Market":[{"type":"population","amount":40}],
	"Fishing Hut":[{"type":"population","amount":40}],
	"Fishing Dock":[{"type":"building_count","building":"Fishing Boat","amount":1}],
	"Fishing Boat":[{"type":"building_count","building":"Seafood Market","amount":1}],
	
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
 	"Train Station": [{"type":"population","amount":1500}],
 	"Rail": [{"type":"building_count","building":"Train Station","amount":1}],
 	"Mine": [{"type":"building_count","building":"Train Station","amount":3}],
 	"Ore Extractor": [{"type":"building_count","building":"Train Station","amount":3}],
 	"Jewlery Store": [{"type":"building_count","building":"Train Station","amount":3}],
} 
 
const ORDER = {
 	["Small Wheatfield","Large Wheatfield"]:[5,"Mill"],
 	["Mill"]:[4,"Bakery","Restaurant"],
 	["Animal Farm"]:[4,"Butcher"],
 	["Butcher"]:[4,"Restaurant"],
 	["Thermal Power Plant","Small Solar Farm","Nuclear Power Plant","Large Thermal Power Plant","Large Solar Farm","Wind Turbine"]:[4,"Transformator Building", "Small Factory", "Large Factory"],
 	["Transformator Building"]:[8,"Basic House", "Double House", "Small Apartment Complex","Large Apartment Complex", "Mega Apartment Complex","Low-Budget Apartment","Giant Apartment Complex"],
 	["Pocket Park", "Small Park", "Fountain Park", "Large Park", "Cinema", "Theme Park"]:[7,"Basic House", "Double House", "Small Apartment Complex","Large Apartment Complex", "Mega Apartment Complex","Low-Budget Apartment","Giant Apartment Complex"],
 	["Small Factory","Large Factory"]:[6,"Small Supermarket","Large Supermarket","Restaurant"],
 	["Basic House", "Double House", "Small Apartment Complex","Large Apartment Complex", "Mega Apartment Complex","Low-Budget Apartment","Giant Apartment Complex"]:[6,"Bakery","Mall","Restaurant","Small Supermarket","Large Supermarket","Jewlery Store","Cafe","Electronics Store","Lumber Mill","Fishing Hut","Seafood Market","Mine","Sand Mine"],
 	["Basic House", "Double House", "Small Apartment Complex","Large Apartment Complex", "Mega Apartment Complex","Low-Budget Apartment","Giant Apartment Complex",""]:[1,"Basic House", "Double House", "Small Apartment Complex","Large Apartment Complex", "Mega Apartment Complex","Low-Budget Apartment","Giant Apartment Complex"],
 	["Small Supermarket","Large Supermarket","Electronics Store","Cafe","Bakery","Restaurant","Lumber Mill","Seafood Market"]:[2,"Mall"],
 	["Mine"]:[4,"Ore Extractor"],
 	["Ore Extractor"]:[5,"Jewlery Store"],
 	#["Fishing Boat"]:[100,"Fishing Dock"],
 	["Fishing Hut", "Fishing Dock"]:[4,"Seafood Market"],
  	["Train Station"]:[4,"Bakery","Restaurant","Small Supermarket","Large Supermarket","Butcher","Ore Extractor","Jewlery Store","Lumber Mill"],
  	["Wind Turbine"]:[5,"Wind Turbine"],
  	["Sand Mine"]:[4,"Smeltery"]
}  

const ACHIEVEMENTS = {
	"Avogaadro's dream": {
		"data": {"desc": "Obtain 6.02e23 coins.", "atlas": Vector2(0,0)},
		"requirements": [{"type": "money", "amount": 6.02e23}]
	},
	"Megacorporation": {
		"data": {"desc": "Have 50 buildings.", "atlas": Vector2(1,0)},
		"requirements": [{"type": "building", "amount": 50}]
	},
	"Walmart": {
		"data": {"desc": "Build 50 Large Supermarkets.", "atlas": Vector2(2,0)},
		"requirements": [{"type": "building", "name": "Large Supermarket", "amount": 50}]
	},
	"It's rude to talk about somebody who's listening": {
		"data": {"desc": "Have exactly 666,666 coins.", "atlas": Vector2(3,0)},
		"requirements": [{"type": "money", "amount": 666666, "exact": true}]
	},
	"give a man a fish, he'll be fed for a day": {
		"data": {"desc": "Build 5 Fishing Huts.", "atlas": Vector2(4,0)},
		"requirements": [{"type": "building", "name": "Fishing Hut", "amount": 5}]
	},
	"teach a man to fish, he'll be fed for his life": {
		"data": {"desc": "Build 10 Fishing Huts.", "atlas": Vector2(5,0)},
		"requirements": [{"type": "building", "name": "Fishing Hut", "amount": 10}]
	},
	"teach a man to fish exoticly, he'll be extraordinarily rich": {
		"data": {"desc": "Build 5 Fishing Boats.", "atlas": Vector2(6,0)},
		"requirements": [{"type": "building", "name": "Fishing Boat", "amount": 5}]
	},
	"Money above climate": {
		"data": {"desc": "Build 30 Small Factories.", "atlas": Vector2(7,0)},
		"requirements": [{"type": "building", "name": "Small Factory", "amount": 30}]
	},
	"why": {
		"data": {"desc": "Build 100 Small Supermarkets.", "atlas": Vector2(8,0)},
		"requirements": [{"type": "building", "name": "Small Supermarket", "amount": 100}]
	},
	"easy as pi": {
		"data": {"desc": "Have 314.15Q coins.", "atlas": Vector2(9,0)},
		"requirements": [{"type": "money", "amount": 314.15e15}]
	},
	"WHY": {
		"data": {"desc": "Build 150 Basic Houses.", "atlas": Vector2(10,0)},
		"requirements": [{"type": "building", "name": "Basic House", "amount": 150}]
	},
	"Silicon Valley": {
		"data": {"desc": "Build 4 Smelteries.", "atlas": Vector2(11,0)},
		"requirements": [{"type": "building", "name": "Smeltery", "amount": 4}]
	},
	"Detroit": {
		"data": {"desc": "Reach 1,000 population with happiness below 15.", "atlas": Vector2(12,0)},
		"requirements": [
			{"type": "happiness", "amount": 15, "less": true},
			{"type": "population", "amount": 1000}
		]
	},
	"Fresh Start": {
		"data": {"desc": "Have 1B coins with no buildings.", "atlas": Vector2(13,0)},
		"requirements": [
			{"type": "money", "amount": 1e9},
			{"type": "building", "amount": 0, "exact": true}
		]
	},
	"Minimalist": {
		"data": {"desc": "Reach 1M coins without ever having more than 10 buildings.", "atlas": Vector2(14,0)},
		"requirements": [
			{"type": "money", "amount": 1e6},
			{"type": "peak_buildings", "amount": 10}
		]
	},
	"Ultimate Minimalist": {
		"data": {"desc": "Reach 1M coins without ever having more than 5 buildings.", "atlas": Vector2(15,0)},
		"requirements": [
			{"type": "money", "amount": 1e6},
			{"type": "peak_buildings", "amount": 5}
		]
	},

	"First step to greatness": {
		"data": {"desc": "Build a Small Supermarket.", "atlas": Vector2(5,1)},
		"requirements": [{"type": "building", "name": "Small Supermarket", "amount": 1}]
	},
	"Loaf of bread": {
		"data": {"desc": "Build a Bakery.", "atlas": Vector2(6,1)},
		"requirements": [{"type": "building", "name": "Bakery", "amount": 1}]
	},
	"Steam age": {
		"data": {"desc": "Build 2 Train Stations.", "atlas": Vector2(7,1)},
		"requirements": [{"type": "building", "name": "Train Station", "amount": 2}]
	},
	"Money above happiness": {
		"data": {"desc": "Build a Low-Budget Apartment.", "atlas": Vector2(8,1)},
		"requirements": [{"type": "building", "name": "Low-Budget Apartment", "amount": 1}]
	},
	"Highrise": {
		"data": {"desc": "Build a Large Apartment Complex.", "atlas": Vector2(9,1)},
		"requirements": [{"type": "building", "name": "Large Apartment Complex", "amount": 1}]
	},
	"Not vegetarian": {
		"data": {"desc": "Build an Animal Farm.", "atlas": Vector2(10,1)},
		"requirements": [{"type": "building", "name": "Animal Farm", "amount": 1}]
	},
	"Air Conditioning": {
		"data": {"desc": "Build 4 Malls.", "atlas": Vector2(11,1)},
		"requirements": [{"type": "building", "name": "Mall", "amount": 4}]
	},
	"That reminds me of somthing… ": {
		"data": {"desc": "Build an Ore Extractor.", "atlas": Vector2(12,1)},
		"requirements": [{"type": "building", "name": "Ore Extractor", "amount": 1}]
	},
	"Turns with the wind": {
		"data": {"desc": "Build a Wind Turbine.", "atlas": Vector2(13,1)},
		"requirements": [{"type": "building", "name": "Wind Turbine", "amount": 1}]
	},
	"Nobody likes forests anyway": {
		"data": {"desc": "Build 5 Lumber Mills.", "atlas": Vector2(14,1)},
		"requirements": [{"type": "building", "name": "Lumber Mill", "amount": 5}]
	},
	"Aboslute Cinema": {
		"data": {"desc": "Build a Cinema.", "atlas": Vector2(15,1)},
		"requirements": [{"type": "building", "name": "Cinema", "amount": 1}]
	},
	"Global warming": {
		"data": {"desc": "Build 10 Large Factories.", "atlas": Vector2(11,1)},
		"requirements": [{"type": "building", "name": "Large Factory", "amount": 10}]
	},
	"Gordon Ramsey": {
		"data": {"desc": "Build a Restaurant.", "atlas": Vector2(12,1)},
		"requirements": [{"type": "building", "name": "Restaurant", "amount": 1}]
	},
	"Dessert": {
		"data": {"desc": "Build a Sand Mine.", "atlas": Vector2(13,1)},
		"requirements": [{"type": "building", "name": "Sand Mine", "amount": 1}]
	},
	"Elon Musk": {
		"data": {"desc": "Earn 30K coins per second.", "atlas": Vector2(0,2)},
		"requirements": [{"type": "income", "amount": 30000}]
	},
	"Millionare": {
		"data": {"desc": "Earn 1M coins per second.", "atlas": Vector2(1,2)},
		"requirements": [{"type": "income", "amount": 1e6}]
	},

	"Billionare": {
		"data": {"desc": "Earn 1B coins per second.", "atlas": Vector2(2,2)},
		"requirements": [{"type": "income", "amount": 1e9}]
	},
	"Trillionare": {
		"data": {"desc": "Earn 1T coins per second.", "atlas": Vector2(3,2)},
		"requirements": [{"type": "income", "amount": 1e12}]
	},
	"Quadrillionare": {
		"data": {"desc": "Earn 1Q coins per second.", "atlas": Vector2(4,2)},
		"requirements": [{"type": "income", "amount": 1e15}]
	},
	"Hamlet": {
		"data": {"desc": "Reach 10 citizens.", "atlas": Vector2(0,1)},
		"requirements": [{"type": "population", "amount": 10}]
	},
	"Village": {
		"data": {"desc": "Reach 50 citizens.", "atlas": Vector2(1,1)},
		"requirements": [{"type": "population", "amount": 50}]
	},
	"Town": {
		"data": {"desc": "Reach 100 citizens.", "atlas": Vector2(2,1)},
		"requirements": [{"type": "population", "amount": 100}]
	},
	"City": {
		"data": {"desc": "Reach 5,000 citizens.", "atlas": Vector2(3,1)},
		"requirements": [{"type": "population", "amount": 5000}]
	},
	"Metropolis": {
		"data": {"desc": "Reach 50,000 citizens.", "atlas": Vector2(4,1)},
		"requirements": [{"type": "population", "amount": 50000}]
	},
	"Megalopolis": {
		"data": {"desc": "Reach 200,000 citizens.", "atlas": Vector2(4,1)}, #NEEDS A SPRITE
		"requirements": [{"type": "population", "amount": 200000}]
	}
}
const RailIndexes = {
}
@export var Money := 100.0
@export var Population := 0
@export var Income := 0.0
@export var Happiness := 100.0

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
		for n in Global.BuildingData.keys():
			get_node("/root/Main").UnlockedBuildings[n] = true
		get_node("/root/Main/UI").CheckBuildingUnlocks()

func GetBigNumber(i:float) -> String:
	if i >= 1000000:
		var big = Big.new(i)
		match Settings.get("number_notation"):
			1:
				return(big.toMetricName())
			2:
				return(big.toScientific())
			_:
				return(big.toMetricSymbol())
	elif i >= 1000:
		var base = floor(i / 1000)
		return(str(int(base)) + "," + ("%03d" % (int(i) % 1000)))
	else:
		if int(i) == i:
			return(str(int(i)))
		else:
			return(str(snapped(i,0.5)))

func UpdateAchievementProgress(Changes:Dictionary):
	LoadAchievementProgress()
	for n in Changes.keys():
		AchievementProgress[n] = Changes[n]
	SaveAchievementProgress()

func IsAchievementUnlocked(nam:String) -> bool:
	if AchievementProgress.get(nam,false) is bool and AchievementProgress.get(nam,false):
		return true
	return false

func GetAchievementProgress(nam:String) -> Variant:
	return AchievementProgress.get(nam,false)

func SaveAchievementProgress():
	var new = SaveFile.new()
	new.save = AchievementProgress
	ResourceSaver.save(new,"user://achievements.tres")

func LoadAchievementProgress():
	if FileAccess.file_exists("user://achievements.tres"):
		AchievementProgress = ResourceLoader.load("user://achievements.tres").save
	else:
		AchievementProgress = {}
