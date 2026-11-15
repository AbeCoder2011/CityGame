extends Node

const Data = {
	"Factory Strike":{
		"desc":"The people at the factory striked! They want more money for their dangerous work.",
		"options":[
			{"name":"Give them a raise","effects":[{"name":"reduce_income","value":5,"duration":300}]},
			{"name":"Tell them to keep working","effects":[{"name":"happiness_debuff","value":-30,"duration":600}]},
		],
		"eligible_buildings":"all_factories",
		"requirement":{"type":"population","amount":50},
	},
	"Homeless on the Street":{
		"desc":"Families are sleeping in doorways near your houses. Families are starting to complain.",
		"options":[
			{"name":"Build a shelter","effects":[{"name":"reduce_income","value":20,"duration":300}]},
			{"name":"Move them along","effects":[{"name":"happiness_debuff","value":-20,"duration":600}]},
			{"name":"Hand out food","effects":[{"name":"lose_money","value":30}]},
		],
		"eligible_buildings":"all_housing",
		"requirement":{"type":"population","amount":50},
	},
	"Noisy Neighbours":{
		"desc":"Someone throws a party every night. The whole street hasn't slept in days.",
		"options":[
			{"name":"Enforce quiet hours","effects":[{"name":"happiness_boost","value":10,"duration":600},{"name":"reduce_income","value":5,"duration":300}]},
			{"name":"Let them party","effects":[{"name":"happiness_debuff","value":-10,"duration":600},{"name":"boost_income","value":10,"duration":300}]},
		],
		"eligible_buildings":"all_housing",
		"requirement":{"type":"population","amount":30},
	},
	"Rent Protest":{
		"desc":"Teenagers march with signs reading 'Homes, not profits'. The landlords are not amused.",
		"options":[
			{"name":"Freeze the rents","effects":[{"name":"reduce_income","value":10,"duration":600},{"name":"happiness_boost","value":15,"duration":600}]},
			{"name":"Let rents rise","effects":[{"name":"boost_income","value":10,"duration":300},{"name":"happiness_debuff","value":-20,"duration":600}]},
		],
		"eligible_buildings":"all_housing",
		"requirement":{"type":"population","amount":100},
	},
	"Broken Elevator":{
		"desc":"The elevator in the tower has been stuck for a week. Grandma is not climbing 30 floors again.",
		"options":[
			{"name":"Pay for a quick repair","effects":[{"name":"lose_money","value":60}]},
			{"name":"Wait for the contractor","effects":[{"name":"reduce_population","value":15,"duration":600}]},
		],
		"eligible_buildings":"Large Apartment Complex",
		"requirement":{"type":"building","name":"Large Apartment Complex","amount":1},
	},
	"Stray Dogs":{
		"desc":"A pack of stray dogs has taken over the alley behind the houses. Kids love them. Parents don't.",
		"options":[
			{"name":"Build a pound","effects":[{"name":"lose_money","value":45}]},
			{"name":"Adopt them as mascots","effects":[{"name":"happiness_boost","value":10,"duration":600},{"name":"reduce_income","value":5,"duration":300}]},
		],
		"eligible_buildings":"all_housing",
		"requirement":{"type":"population","amount":40},
	},
	"New Arrivals":{
		"desc":"A group of newcomers wants to settle in your city. They are hard workers, but housing is tight.",
		"options":[
			{"name":"Welcome them","effects":[{"name":"boost_population","value":10,"duration":600},{"name":"increase_building_cost","value":10,"duration":300}]},
			{"name":"Turn them away","effects":[{"name":"happiness_boost","value":5,"duration":300}]},
		],
		"eligible_buildings":"all_housing",
		"requirement":{"type":"population","amount":500},
	},
	"Heatwave":{
		"desc":"The sun is merciless. Citizens are melting, and the ice cream stands have run dry.",
		"options":[
			{"name":"Open public fountains","effects":[{"name":"lose_money","value":40},{"name":"happiness_boost","value":15,"duration":300}]},
			{"name":"Tell them to stay inside","effects":[{"name":"reduce_income","value":20,"duration":300}]},
		],
		"eligible_buildings":"all",
		"requirement":{"type":"population","amount":200},
	},
	"Street Musician":{
		"desc":"A violinist has set up on a busy corner. Some call it art, but others find it disturbing.",
		"options":[
			{"name":"Give them a stage","effects":[{"name":"happiness_boost","value":10,"duration":300}]},
			{"name":"Charge a busking fee","effects":[{"name":"gain_money","value":10}]},
		],
		"eligible_buildings":"all",
		"requirement":{"type":"population","amount":20},
	},
	"Mayor's Statue":{
		"desc":"Some admirers want to raise a golden statue of you in the main square.",
		"options":[
			{"name":"Commission the statue","effects":[{"name":"lose_money","value":120},{"name":"happiness_boost","value":20,"duration":900}]},
			{"name":"Decline, politely","effects":[{"name":"happiness_boost","value":5,"duration":300}]},
		],
		"eligible_buildings":"all",
		"requirement":{"type":"population","amount":300},
	},
	"Buried Treasure":{
		"desc":"Workers digging a foundation hit something metal. It seems to be of great value.",
		"options":[
			{"name":"Sell it quickly","effects":[{"name":"gain_money","value":90}]},
			{"name":"Open a museum","effects":[{"name":"boost_income","value":15,"duration":900}]},
		],
		"eligible_buildings":"all",
		"requirement":{"type":"population","amount":100},
	},
	"Power Outage":{
		"desc":"The transformator is humming ominously, and then the lights go out across the street.",
		"options":[
			{"name":"Call in an emergency crew","effects":[{"name":"lose_money","value":75}]},
			{"name":"Wait it out","effects":[{"name":"reduce_population","value":20,"duration":300},{"name":"happiness_debuff","value":-15,"duration":300}]},
		],
		"eligible_buildings":"Transformator Building",
		"requirement":{"type":"building","name":"Transformator Building","amount":1},
	},
	"Smog Complaints":{
		"desc":"The coal plant paints the sky grey. Your citizens are coughing, and they have started to notice.",
		"options":[
			{"name":"Install filters","effects":[{"name":"lose_money","value":100}]},
			{"name":"Pay for ad campaigns","effects":[{"name":"reduce_income","value":10,"duration":300},{"name":"happiness_boost","value":5,"duration":300}]},
			{"name":"Ignore them","effects":[{"name":"reduce_population","value":15,"duration":600}]},
		],
		"eligible_buildings":"Thermal Power Plant",
		"requirement":{"type":"building","name":"Thermal Power Plant","amount":1},
	},
	"Solar Subsidy":{
		"desc":"A green foundation offers cash for your solar farm. It is a good deal, almost too good to be true.",
		"options":[
			{"name":"Accept the grant","effects":[{"name":"gain_money","value":60},{"name":"increase_building_cost","value":5,"duration":600}]},
			{"name":"Stay independent","effects":[{"name":"happiness_boost","value":5,"duration":600}]},
		],
		"eligible_buildings":"all_power_generators",
		"requirement":{"type":"building","name":"Small Solar Farm","amount":1},
	},
	"Reactor Inspection":{
		"desc":"International inspectors arrive at the nuclear plant with clipboards and very serious faces.",
		"options":[
			{"name":"Cooperate fully","effects":[{"name":"reduce_income","value":10,"duration":300},{"name":"happiness_boost","value":10,"duration":900}]},
			{"name":"Stall for time","effects":[{"name":"happiness_debuff","value":-25,"duration":900}]},
		],
		"eligible_buildings":"Nuclear Power Plant",
		"requirement":{"type":"building","name":"Nuclear Power Plant","amount":1},
	},
	"Birds vs Turbines":{
		"desc":"Bird watchers are chaining themselves to your wind turbines. One of them brought a banner.",
		"options":[
			{"name":"Shut the turbine down","effects":[{"name":"reduce_income","value":10,"duration":300},{"name":"happiness_boost","value":10,"duration":600}]},
			{"name":"Keep spinning","effects":[{"name":"happiness_debuff","value":-10,"duration":600}]},
		],
		"eligible_buildings":"Wind Turbine",
		"requirement":{"type":"building","name":"Wind Turbine","amount":1},
	},
	"Overgrown Park":{
		"desc":"Nobody has trimmed the park in months. The bushes are getting to creepy heights.",
		"options":[
			{"name":"Hire gardeners","effects":[{"name":"lose_money","value":30},{"name":"happiness_boost","value":10,"duration":600}]},
			{"name":"Call it rewilding","effects":[{"name":"boost_population","value":5,"duration":600},{"name":"happiness_debuff","value":-10,"duration":300}]},
		],
		"eligible_buildings":"all_parks",
		"requirement":{"type":"population","amount":80},
	},
	"Concert in the Park":{
		"desc":"A band wants to play a free show in your park. Expect crowds, confetti and a lot of litter.",
		"options":[
			{"name":"Host and sponsor it","effects":[{"name":"lose_money","value":90},{"name":"happiness_boost","value":25,"duration":600}]},
			{"name":"Rent the space to vendors","effects":[{"name":"gain_money","value":45},{"name":"happiness_debuff","value":-10,"duration":300}]},
		],
		"eligible_buildings":"all_parks",
		"requirement":{"type":"population","amount":200},
	},
	"Blockbuster Premiere":{
		"desc":"The biggest movie of the year is coming to your cinema. The queue already wraps around the block.",
		"options":[
			{"name":"Raise ticket prices","effects":[{"name":"boost_income","value":20,"duration":300},{"name":"happiness_debuff","value":-10,"duration":300}]},
			{"name":"Offer free screenings","effects":[{"name":"reduce_income","value":10,"duration":600},{"name":"happiness_boost","value":20,"duration":600}]},
		],
		"eligible_buildings":"Cinema",
		"requirement":{"type":"building","name":"Cinema","amount":1},
	},
	"Rollercoaster Malfunction":{
		"desc":"The big coaster stopped halfway up the loop. Riders are hanging upside down and are not very happy about it.",
		"options":[
			{"name":"Close the park for repairs","effects":[{"name":"reduce_income","value":15,"duration":300},{"name":"happiness_boost","value":10,"duration":600}]},
			{"name":"Keep the park open","effects":[{"name":"happiness_debuff","value":-25,"duration":600}]},
		],
		"eligible_buildings":"Theme Park",
		"requirement":{"type":"building","name":"Theme Park","amount":1},
	},
	"Flour Shortage":{
		"desc":"The bakery's flour delivery is late. Without flour, there won't be enough croissants.",
		"options":[
			{"name":"Pay a premium for emergency flour","effects":[{"name":"lose_money","value":60}]},
			{"name":"Bake with what you have","effects":[{"name":"reduce_income","value":40,"duration":300}]},
		],
		"eligible_buildings":"Bakery",
		"requirement":{"type":"building","name":"Bakery","amount":1},
	},
	"Mill Fire":{
		"desc":"Someone smoked a cigarette next to a pile of hay. The old mill is on fire, and the smoke can be seen from miles away.",
		"options":[
			{"name":"Call the fire brigade","effects":[{"name":"lose_money","value":50}]},
			{"name":"Let it burn out","effects":[{"name":"reduce_income","value":30,"duration":600},{"name":"happiness_debuff","value":-15,"duration":300}]},
		],
		"eligible_buildings":"Mill",
		"requirement":{"type":"building","name":"Mill","amount":1},
	},
	"Animal Rights Protest":{
		"desc":"Protesters gather outside the butcher with signs and very mad faces.",
		"options":[
			{"name":"Offer a plant-based menu","effects":[{"name":"reduce_income","value":10,"duration":600},{"name":"happiness_boost","value":10,"duration":600}]},
			{"name":"Ignore the protest","effects":[{"name":"happiness_debuff","value":-15,"duration":600}]},
		],
		"eligible_buildings":"Butcher",
		"requirement":{"type":"building","name":"Butcher","amount":1},
	},
	"Livestock Outbreak":{
		"desc":"The pigs are sneezing. The inspector says its bird flu.",
		"options":[
			{"name":"Vaccinate the herd","effects":[{"name":"lose_money","value":70}]},
			{"name":"Cull the sick animals","effects":[{"name":"reduce_income","value":25,"duration":300},{"name":"happiness_debuff","value":-10,"duration":300}]},
		],
		"eligible_buildings":"Animal Farm",
		"requirement":{"type":"building","name":"Animal Farm","amount":1},
	},
	"Dry Season":{
		"desc":"It hasn't rained in weeks, and the wheat is starting to get dangerously dry.",
		"options":[
			{"name":"Dig irrigation channels","effects":[{"name":"lose_money","value":70},{"name":"boost_income","value":10,"duration":600}]},
			{"name":"Pray for rain","effects":[{"name":"reduce_income","value":15,"duration":600}]},
		],
		"eligible_buildings":"all_farms",
		"requirement":{"type":"population","amount":100},
	},
	"Food Critic":{
		"desc":"A famous critic sits at your table with a notebook. The kitchen is stressed and doesn't know what to do.",
		"options":[
			{"name":"Serve the finest ingredients","effects":[{"name":"lose_money","value":60},{"name":"boost_income","value":30,"duration":600}]},
			{"name":"Treat them like any guest","effects":[{"name":"happiness_debuff","value":-5,"duration":300}]},
		],
		"eligible_buildings":"Restaurant",
		"requirement":{"type":"building","name":"Restaurant","amount":1},
	},
	"Sale Day":{
		"desc":"A shop owner wants to run the biggest sale the city has ever seen. Everything must go!",
		"options":[
			{"name":"Approve the sale","effects":[{"name":"reduce_income","value":20,"duration":120},{"name":"boost_income","value":10,"duration":600}]},
			{"name":"Keep prices as they are","effects":[{"name":"boost_income","value":5,"duration":300}]},
		],
		"eligible_buildings":"all_shops",
		"requirement":{"type":"population","amount":60},
	},
	"Shoplifters":{
		"desc":"Things keep disappearing from the shelves. The security cameras keep looking away at the wrong time.",
		"options":[
			{"name":"Hire security guards","effects":[{"name":"reduce_income","value":10,"duration":600}]},
			{"name":"Accept the losses","effects":[{"name":"lose_money","value":100}]},
		],
		"eligible_buildings":"Mall",
		"requirement":{"type":"building","name":"Mall","amount":1},
	},
	"Poetry Night":{
		"desc":"The cafe owner wants to host a poetry night. Some poetry is better than others.",
		"options":[
			{"name":"Let the poets in","effects":[{"name":"boost_income","value":15,"duration":300},{"name":"happiness_boost","value":5,"duration":300}]},
			{"name":"Keep it a quiet cafe","effects":[{"name":"gain_money","value":10}]},
		],
		"eligible_buildings":"Cafe",
		"requirement":{"type":"building","name":"Cafe","amount":1},
	},
	"Large Phone Release":{
		"desc":"The new phone launches tomorrow. People are already camping outside the electronics store.",
		"options":[
			{"name":"Stock up big","effects":[{"name":"lose_money","value":80},{"name":"boost_income","value":40,"duration":300}]},
			{"name":"Order a normal amount","effects":[{"name":"boost_income","value":10,"duration":300}]},
		],
		"eligible_buildings":"Electronics Store",
		"requirement":{"type":"building","name":"Electronics Store","amount":1},
	},
	"Tax Inspector":{
		"desc":"A man in a grey suit asks to show your bookkeeping. He smiles, knowing he has you in a corner.",
		"options":[
			{"name":"Show him your bookkeeping","effects":[{"name":"lose_money","value":40}]},
			{"name":"Hire a clever accountant","effects":[{"name":"reduce_income","value":10,"duration":600}]},
		],
		"eligible_buildings":"all_shops",
		"requirement":{"type":"population","amount":150},
	},
	"Forest Protest":{
		"desc":"Lumberjacks are going to chop down the oldest tree in the forest. A protest group is chained to it.",
		"options":[
			{"name":"Spare the tree","effects":[{"name":"reduce_income","value":10,"duration":300},{"name":"happiness_boost","value":10,"duration":600}]},
			{"name":"Chop it down","effects":[{"name":"boost_income","value":15,"duration":300},{"name":"happiness_debuff","value":-15,"duration":600}]},
		],
		"eligible_buildings":"Lumber Mill",
		"requirement":{"type":"building","name":"Lumber Mill","amount":1},
	},
	"Empty Nets":{
		"desc":"The fishermen return with almost nothing. The sea seems emptier than ever.",
		"options":[
			{"name":"Fish further out","effects":[{"name":"lose_money","value":30},{"name":"boost_income","value":10,"duration":300}]},
			{"name":"Let the water recover","effects":[{"name":"reduce_income","value":15,"duration":300},{"name":"happiness_boost","value":5,"duration":1200}]},
		],
		"eligible_buildings":"Fishing Hut",
		"requirement":{"type":"building","name":"Fishing Hut","amount":1},
	},
	"Storm at Sea":{
		"desc":"Dark clouds roll in over the deep water. The captain says its just a bit of wind, but your weather app says otherwise.",
		"options":[
			{"name":"Stay in port","effects":[{"name":"reduce_income","value":20,"duration":300}]},
			{"name":"Brave the storm","effects":[{"name":"gain_money","value":60},{"name":"happiness_debuff","value":-10,"duration":300}]},
		],
		"eligible_buildings":"Fishing Boat",
		"requirement":{"type":"building","name":"Fishing Boat","amount":1},
	},
	"Rare Catch":{
		"desc":"A fisherman catches a fish nobody recognizes. It seems to be really rare and really expensive",
		"options":[
			{"name":"Auction it off","effects":[{"name":"gain_money","value":90}]},
			{"name":"Serve it at the market","effects":[{"name":"happiness_boost","value":15,"duration":600},{"name":"boost_income","value":10,"duration":300}]},
		],
		"eligible_buildings":"Seafood Market",
		"requirement":{"type":"building","name":"Seafood Market","amount":1},
	},
	"Possible Mine Collapse":{
		"desc":"A tunnel creaks and dust rains from the ceiling. The miners are refusing to enter.",
		"options":[
			{"name":"Evacuate and reinforce","effects":[{"name":"lose_money","value":80},{"name":"happiness_boost","value":10,"duration":600}]},
			{"name":"Dig deeper anyway","effects":[{"name":"boost_income","value":20,"duration":300},{"name":"happiness_debuff","value":-25,"duration":600}]},
		],
		"eligible_buildings":"Mine",
		"requirement":{"type":"building","name":"Mine","amount":1},
	},
	"Gem Discovery":{
		"desc":"The extractor spits out a gemstone the size of a fist. Everyone is afraid to touch it.",
		"options":[
			{"name":"Sell it right away","effects":[{"name":"gain_money","value":120}]},
			{"name":"Hold it for the jewelry stores","effects":[{"name":"boost_income","value":20,"duration":600}]},
		],
		"eligible_buildings":"Ore Extractor",
		"requirement":{"type":"building","name":"Ore Extractor","amount":1},
	},
	"Jewelry Heist":{
		"desc":"The night guard saw three people in black walk in during midnight. He thought it was the owner of the store.",
		"options":[
			{"name":"Upgrade the security","effects":[{"name":"lose_money","value":100},{"name":"boost_income","value":10,"duration":900}]},
			{"name":"File an insurance claim","effects":[{"name":"reduce_income","value":25,"duration":300}]},
		],
		"eligible_buildings":"Jewlery Store",
		"requirement":{"type":"building","name":"Jewlery Store","amount":1},
	},
	"Dust Storm":{
		"desc":"The desert wind is picking up, and the workers are starting to complain about jammed drills.",
		"options":[
			{"name":"Halt operations","effects":[{"name":"reduce_income","value":20,"duration":300}]},
			{"name":"Mine through the storm","effects":[{"name":"lose_money","value":50},{"name":"boost_income","value":15,"duration":300}]},
		],
		"eligible_buildings":"Sand Mine",
		"requirement":{"type":"building","name":"Sand Mine","amount":1},
	},
	"Furnace Overheat":{
		"desc":"The smeltery's furnace is running hotter than the safety protocol allows. Luckily, the safety protocol has some wiggleroom.",
		"options":[
			{"name":"Cool it down","effects":[{"name":"reduce_income","value":15,"duration":300}]},
			{"name":"Keep on smelting","effects":[{"name":"boost_income","value":30,"duration":300},{"name":"happiness_debuff","value":-20,"duration":600}]},
		],
		"eligible_buildings":"Smeltery",
		"requirement":{"type":"building","name":"Smeltery","amount":1},
	},
	"Pollution Inspection":{
		"desc":"Officials are measuring the air outside the factory. Their data is concerning, to say the least.",
		"options":[
			{"name":"Invest in cleaner machines","effects":[{"name":"lose_money","value":120},{"name":"boost_population","value":10,"duration":900}]},
			{"name":"Pay the fine","effects":[{"name":"lose_money","value":40},{"name":"happiness_debuff","value":-10,"duration":600}]},
		],
		"eligible_buildings":"all_factories",
		"requirement":{"type":"population","amount":150},
	},
	"Automation Offer":{
		"desc":"A salesman is promising robots for your factories. The workers aren't as happy about the offer.",
		"options":[
			{"name":"Buy the robots","effects":[{"name":"lose_money","value":150},{"name":"boost_income","value":25,"duration":900},{"name":"happiness_debuff","value":-15,"duration":900}]},
			{"name":"Keep the workers","effects":[{"name":"happiness_boost","value":10,"duration":600}]},
		],
		"eligible_buildings":"Large Factory",
		"requirement":{"type":"building","name":"Large Factory","amount":1},
	},
	"Delayed Trains":{
		"desc":"The commuter trains are late again. Workers are rolling with their eyes, desperate to get to work.",
		"options":[
			{"name":"Purchase extra trains","effects":[{"name":"lose_money","value":100}]},
			{"name":"Blame the weather","effects":[{"name":"happiness_debuff","value":-15,"duration":600},{"name":"reduce_income","value":10,"duration":300}]},
		],
		"eligible_buildings":"all_train_stations",
		"requirement":{"type":"building","name":"Train Station","amount":1},
	},
	"Rush Hour":{
		"desc":"The metro platform is packed to the brim, and nobody is smiling.",
		"options":[
			{"name":"Run extra trains","effects":[{"name":"lose_money","value":80},{"name":"boost_income","value":10,"duration":600}]},
			{"name":"Limit entry to the platform","effects":[{"name":"happiness_debuff","value":-15,"duration":300}]},
		],
		"eligible_buildings":"all_metro",
		"requirement":{"type":"building","name":"Metro Station","amount":1},
	},
	"Tourist Surge":{
		"desc":"A viral video put your city on the map. Suitcases are rolling through the terminal as we speak.",
		"options":[
			{"name":"Launch a tourism campaign","effects":[{"name":"lose_money","value":100},{"name":"boost_income","value":25,"duration":900}]},
			{"name":"Let it fade naturally","effects":[{"name":"boost_income","value":5,"duration":300}]},
		],
		"eligible_buildings":"Airport Terminal",
		"requirement":{"type":"building","name":"Airport Terminal","amount":1},
	},
	"Noise Complaints":{
		"desc":"Planes are taking off right above the rooftops. Nearby residents have started to write complaints, some nicer than others.",
		"options":[
			{"name":"Ban night flights","effects":[{"name":"reduce_income","value":15,"duration":600},{"name":"happiness_boost","value":15,"duration":600}]},
			{"name":"Offer soundproof windows","effects":[{"name":"lose_money","value":90}]},
		],
		"eligible_buildings":"Airport Runway",
		"requirement":{"type":"building","name":"Airport Runway","amount":1},
	},
	"Staff Shortage":{
		"desc":"Half the air traffic controllers called in sick. The rest is very tired, and wants to go home.",
		"options":[
			{"name":"Pay overtime","effects":[{"name":"lose_money","value":70}]},
			{"name":"Cut some flights","effects":[{"name":"reduce_income","value":20,"duration":300}]},
		],
		"eligible_buildings":"Air Traffic Control Tower",
		"requirement":{"type":"building","name":"Air Traffic Control Tower","amount":1},
	},
	"VIP Guest":{
		"desc":"A celebrity has booked a suite at your hotel. Their request list is two pages long, and other guests in the hotel are prohibited.",
		"options":[
			{"name":"Grant every request","effects":[{"name":"lose_money","value":60},{"name":"boost_income","value":25,"duration":600}]},
			{"name":"Treat them like everyone else","effects":[{"name":"happiness_boost","value":5,"duration":300}]},
		],
		"eligible_buildings":"all_hotels",
		"requirement":{"type":"population","amount":10000},
	},
	"Lost Wallet":{
		"desc":"Someone found a wallet on the street. Inside are a few coins and a photo of a very cute dog.",
		"options":[
			{"name":"Keep the coins","effects":[{"name":"gain_money","value":15}]},
			{"name":"Return it to the owner","effects":[{"name":"happiness_boost","value":5,"duration":300}]},
		],
		"eligible_buildings":"all",
		"requirement":{"type":"population","amount":10},
	},
	"Pothole Problem":{
		"desc":"A pothole on Main Street broke down, and a biker fell in.",
		"options":[
			{"name":"Fill the hole with concrete","effects":[{"name":"lose_money","value":20}]},
			{"name":"Put some traffic cones around","effects":[{"name":"happiness_debuff","value":-5,"duration":120}]},
		],
		"eligible_buildings":"all",
		"requirement":{"type":"population","amount":20},
	},
	"Garage Sale":{
		"desc":"Someone is selling books and old Pokémon cards in their garage.",
		"options":[
			{"name":"Buy some for profit","effects":[{"name":"gain_money","value":12}]},
			{"name":"Buy him out","effects":[{"name":"lose_money","value":8},{"name":"happiness_boost","value":8,"duration":300}]},
			{"name":"Organize a monthly flea market","effects":[{"name":"boost_income","value":5,"duration":1800},{"name":"happiness_boost","value":5,"duration":1800},{"name":"lose_money","value":200}]},
		],
		"eligible_buildings":"all_housing",
		"requirement":{"type":"population","amount":15},
	},
	"Lemonade Stand":{
		"desc":"A kid opened a lemonade stand. It is way overpriced with way too much sugar.",
		"options":[
			{"name":"Buy a cup","effects":[{"name":"lose_money","value":3},{"name":"happiness_boost","value":5,"duration":300}]},
			{"name":"Tax the stand","effects":[{"name":"gain_money","value":6},{"name":"happiness_debuff","value":-15,"duration":120}]},
		],
		"eligible_buildings":"all",
		"requirement":{"type":"population","amount":10},
	},
	"Leaky Roof":{
		"desc":"The ceiling is dripping. One family has put a bucket in the living room, but now the bucket is full.",
		"options":[
			{"name":"Fix the roof","effects":[{"name":"lose_money","value":25}]},
			{"name":"Buy more buckets","effects":[{"name":"lose_money","value":5},{"name":"happiness_debuff","value":-10,"duration":300}]},
		],
		"eligible_buildings":"all_housing",
		"requirement":{"type":"population","amount":20},
	},
	"Bake Sale":{
		"desc":"The school is holding a bake sale. Some cookies look better than others.",
		"options":[
			{"name":"Buy everything","effects":[{"name":"lose_money","value":15},{"name":"happiness_boost","value":10,"duration":300}]},
			{"name":"Just one cookie","effects":[{"name":"lose_money","value":2},{"name":"happiness_boost","value":3,"duration":300}]},
			{"name":"No cookies for me","effects":[{"name":"happiness_debuff","value":-15,"duration":300}]},
		],
		"eligible_buildings":"all_housing",
		"requirement":{"type":"population","amount":20},
	},
	"Community Garden":{
		"desc":"The neighbours want to turn an empty lot into a garden. They have plans featuring tomatoes.",
		"options":[
			{"name":"Say yes","effects":[{"name":"lose_money","value":25},{"name":"boost_population","value":5,"duration":600}]},
			{"name":"Keep the lot empty","effects":[{"name":"boost_income","value":3,"duration":300}]},
		],
		"eligible_buildings":"all_housing",
		"requirement":{"type":"population","amount":40},
	},
	"Graffiti Artist":{
		"desc":"Someone painted a giant mural on the wall of the bakery. Nobody knows who did it, but it looks really good.",
		"options":[
			{"name":"Keep the mural","effects":[{"name":"happiness_boost","value":8,"duration":600},{"name":"reduce_income","value":15,"duration":120}]},
			{"name":"Paint over it","effects":[{"name":"lose_money","value":10}]},
		],
		"eligible_buildings":"Bakery",
		"requirement":{"type":"population","amount":30},
	},
	"Garbage Strike":{
		"desc":"The garbage collectors went home. The bins are overflowing, and the streets are starting to smell.",
		"options":[
			{"name":"Pay them more","effects":[{"name":"reduce_income","value":10,"duration":300}]},
			{"name":"Wait for the end of the strike","effects":[{"name":"happiness_debuff","value":-30,"duration":600}]},
		],
		"eligible_buildings":"all_housing",
		"requirement":{"type":"population","amount":50},
	},
	"Free Wifi":{
		"desc":"A citizen wants free wifi in the main square. Everyone will stare at their phones, but they'll be smiling.",
		"options":[
			{"name":"Set it up","effects":[{"name":"lose_money","value":30},{"name":"happiness_boost","value":12,"duration":600}]},
			{"name":"Say no","effects":[{"name":"happiness_debuff","value":-5,"duration":300}]},
		],
		"eligible_buildings":"Cafe",
		"requirement":{"type":"population","amount":60},
	},
	"Street Parade":{
		"desc":"Someone wants to hold a parade. There will be drums, balloons and a man in a giant duck costume.",
		"options":[
			{"name":"Pay for it","effects":[{"name":"lose_money","value":25},{"name":"happiness_boost","value":15,"duration":300}]},
			{"name":"Let the duck pay","effects":[{"name":"gain_money","value":10},{"name":"happiness_boost","value":3,"duration":300}]},
		],
		"eligible_buildings":"all",
		"requirement":{"type":"population","amount":40},
	},
	"Cold Snap":{
		"desc":"It's freezing! Everyone is wearing three scarves, and the fountain froze up completely.",
		"options":[
			{"name":"Hand out hot cocoa","effects":[{"name":"lose_money","value":15},{"name":"happiness_boost","value":10,"duration":300}]},
			{"name":"Tell everyone to stay inside","effects":[{"name":"reduce_income","value":8,"duration":300}]},
		],
		"eligible_buildings":"all",
		"requirement":{"type":"population","amount":30},
	},
	"Lost Cat":{
		"desc":"A cat has gone missing. His picture is on every lamp post, but there is no reward for finding him.",
		"options":[
			{"name":"Organise a search party","effects":[{"name":"lose_money","value":8},{"name":"happiness_boost","value":10,"duration":300}]},
			{"name":"Hope he comes back","effects":[{"name":"happiness_boost","value":-5,"duration":300}]},
		],
		"eligible_buildings":"all_housing",
		"requirement":{"type":"population","amount":15},
	},
	"Burst Water Pipe":{
		"desc":"A pipe burst, and now the street is a river. The kids are thrilled.",
		"options":[
			{"name":"Call a plumber","effects":[{"name":"lose_money","value":25}]},
			{"name":"Let the kids splash","effects":[{"name":"happiness_boost","value":8,"duration":300},{"name":"reduce_income","value":20,"duration":300}]},
		],
		"eligible_buildings":"all_housing",
		"requirement":{"type":"population","amount":25},
	},
	"Local Newspaper":{
		"desc":"A tiny newspaper wants to write about your city. The headline will probably be 'Boring City'.",
		"options":[
			{"name":"Give an interview","effects":[{"name":"happiness_boost","value":8,"duration":600}]},
			{"name":"Pay for the front page","effects":[{"name":"lose_money","value":20},{"name":"boost_income","value":5,"duration":600}]},
		],
		"eligible_buildings":"all",
		"requirement":{"type":"population","amount":50},
	},
	"Lucky Lottery Ticket":{
		"desc":"A citizen won the lottery and is thinking about sharing. Or maybe not. They're still thinking.",
		"options":[
			{"name":"Ask for a donation","effects":[{"name":"gain_money","value":25},{"name":"happiness_debuff","value":-5,"duration":300}]},
			{"name":"Throw them a party","effects":[{"name":"lose_money","value":15},{"name":"happiness_boost","value":20,"duration":600}]},
		],
		"eligible_buildings":"all",
		"requirement":{"type":"population","amount":200},
	},
	"Rooftop Garden":{
		"desc":"The people in the tower want a garden on the roof. They are already theorizing about the veggies they will plant.",
		"options":[
			{"name":"Plant away","effects":[{"name":"lose_money","value":40},{"name":"boost_population","value":10,"duration":600}]},
			{"name":"Keep the roof flat","effects":[{"name":"happiness_debuff","value":-10,"duration":300}]},
		],
		"eligible_buildings":"Large Apartment Complex",
		"requirement":{"type":"building","name":"Large Apartment Complex","amount":1},
	},
	"Residents' Committee":{
	"desc":"The building is so full that the residents started a committee. Their meetings last for hours, and there are snacks.",
		"options":[
			{"name":"Attend the meetings","effects":[{"name":"happiness_boost","value":15,"duration":600},{"name":"reduce_income","value":5,"duration":300}]},
			{"name":"Skip them","effects":[{"name":"happiness_debuff","value":-10,"duration":600}]},
		],
		"eligible_buildings":"Mega Apartment Complex",
		"requirement":{"type":"building","name":"Mega Apartment Complex","amount":1},
	},
	"Overcrowded Lobby":{
		"desc":"So many people live here that the lobby was overfull yesterday. A homeless man even slept on a bench in the lobby last night.",
		"options":[
			{"name":"Build a bigger lobby","effects":[{"name":"lose_money","value":100},{"name":"boost_population","value":15,"duration":900}]},
			{"name":"Hand out waiting numbers","effects":[{"name":"happiness_debuff","value":-10,"duration":300}]},
		],
		"eligible_buildings":"Giant Apartment Complex",
		"requirement":{"type":"building","name":"Giant Apartment Complex","amount":1},
	},
	"Self-Checkout Rollout":{
		"desc":"New machines that scan your groceries for you. They are pretty expensive, but the CEO says it's worth it.",
		"options":[
			{"name":"Install them","effects":[{"name":"lose_money","value":60},{"name":"boost_income","value":20,"duration":600}]},
			{"name":"Keep the cashiers","effects":[{"name":"happiness_boost","value":10,"duration":600}]},
		],
		"eligible_buildings":"Large Supermarket",
		"requirement":{"type":"building","name":"Large Supermarket","amount":1},
	},
	"Mall Santa":{
		"desc":"Santa arrived at the mall way too early this year. The kids are thrilled. Santa is mostly after the free cookies.",
		"options":[
			{"name":"Build a big grotto","effects":[{"name":"lose_money","value":50},{"name":"boost_income","value":25,"duration":600}]},
			{"name":"Keep it small","effects":[{"name":"boost_income","value":8,"duration":300}]},
		],
		"eligible_buildings":"Mall",
		"requirement":{"type":"building","name":"Mall","amount":1},
	},
	"Broken Escalator":{
		"desc":"The mall escalator stopped working. Now it's just stairs, but some people stand still on them anyway.",
		"options":[
			{"name":"Repair it","effects":[{"name":"lose_money","value":45}]},
			{"name":"Call it stairs","effects":[{"name":"reduce_income","value":15,"duration":600}]},
		],
		"eligible_buildings":"Mall",
		"requirement":{"type":"building","name":"Mall","amount":1},
	},
	"Loyalty Cards":{
		"desc":"A shop owner wants to hand out little cards. Collect ten stamps and get a free cookie, or 2% off your next purchase.",
		"options":[
			{"name":"Start the program","effects":[{"name":"lose_money","value":30},{"name":"boost_income","value":15,"duration":900}]},
			{"name":"Skip it","effects":[{"name":"reduce_income","value":5,"duration":300}]},
		],
		"eligible_buildings":"all_shops",
		"requirement":{"type":"building","name":"Small Supermarket","amount":3},
	},
	"Barista Championship":{
		"desc":"Two baristas are fighting over who makes the best coffee. They are currently arguing about the difference between oat and cow milk.",
		"options":[
			{"name":"Host a contest","effects":[{"name":"lose_money","value":25},{"name":"boost_income","value":30,"duration":300},{"name":"happiness_boost","value":8,"duration":300}]},
			{"name":"Declare a tie","effects":[{"name":"happiness_boost","value":5,"duration":300}]},
		],
		"eligible_buildings":"Cafe",
		"requirement":{"type":"building","name":"Cafe","amount":1},
	},
	"Cracked Millstone":{
		"desc":"The big stone in the mill cracked in half. It had the satisfying crack when it broke down.",
		"options":[
			{"name":"Buy a new one","effects":[{"name":"lose_money","value":55}]},
			{"name":"Use the half stone","effects":[{"name":"reduce_income","value":20,"duration":600}]},
		],
		"eligible_buildings":"Mill",
		"requirement":{"type":"building","name":"Mill","amount":1},
	},
	"Sourdough Craze":{
		"desc":"Everyone wants sourdough now. Experts say it is 'healthy'.",
		"options":[
			{"name":"Bake more","effects":[{"name":"lose_money","value":60},{"name":"boost_income","value":25,"duration":600}]},
			{"name":"Keep it normal","effects":[{"name":"boost_income","value":5,"duration":300}]},
		],
		"eligible_buildings":"Bakery",
		"requirement":{"type":"building","name":"Bakery","amount":1},
	},
	"Secret Recipe":{
		"desc":"The butcher has a secret sausage recipe. Everyone is guessing what's in it, with popular guesses being pineapple, plum and shrimp.",
		"options":[
			{"name":"Buy the recipe","effects":[{"name":"lose_money","value":70},{"name":"boost_income","value":30,"duration":900}]},
			{"name":"Let it stay secret","effects":[{"name":"happiness_boost","value":10,"duration":600}]},
		],
		"eligible_buildings":"Butcher",
		"requirement":{"type":"building","name":"Butcher","amount":1},
	},
	"Escaped Pig":{
		"desc":"A pig escaped the farm and is running through town. The kids refuse to let him return.",
		"options":[
			{"name":"Chase him down","effects":[{"name":"lose_money","value":15}]},
			{"name":"Let the kids adopt it","effects":[{"name":"happiness_boost","value":15,"duration":300},{"name":"reduce_income","value":5,"duration":300}]},
		],
		"eligible_buildings":"Animal Farm",
		"requirement":{"type":"building","name":"Animal Farm","amount":2},
	},
	"Health Inspector":{
		"desc":"A health inspector found a suspicious fridge in the back of the restaurant. The owner forgot it's contents.",
		"options":[
			{"name":"Open it and clean up","effects":[{"name":"lose_money","value":35}]},
			{"name":"Lock it forever","effects":[{"name":"reduce_income","value":15,"duration":300}]},
		],
		"eligible_buildings":"Restaurant",
		"requirement":{"type":"building","name":"Restaurant","amount":1},
	},
	"Coal Shortage":{
		"desc":"The coal truck is lost. News sites say it 'Made a sudden stop near the edge of a cliff'.",
		"options":[
			{"name":"Buy emergency coal","effects":[{"name":"lose_money","value":50}]},
			{"name":"Wait for the truck","effects":[{"name":"reduce_income","value":20,"duration":300}]},
		],
		"eligible_buildings":"Thermal Power Plant",
		"requirement":{"type":"building","name":"Thermal Power Plant","amount":1},
	},
	"Cloudy Weeks":{
		"desc":"It has been cloudy for weeks. All the solar panel batteries are basically empty.",
		"options":[
			{"name":"Buy extra power","effects":[{"name":"lose_money","value":40}]},
			{"name":"Wait for the sun","effects":[{"name":"reduce_income","value":15,"duration":600}]},
		],
		"eligible_buildings":"Small Solar Farm",
		"requirement":{"type":"building","name":"Small Solar Farm","amount":3},
	},
	"Panel Thieves":{
		"desc":"Someone stole three solar panels during the night. They left a thank-you note.",
		"options":[
			{"name":"Hire a guard","effects":[{"name":"lose_money","value":60}]},
			{"name":"Leave it","effects":[{"name":"reduce_income","value":15,"duration":600}]},
		],
		"eligible_buildings":"Large Solar Farm",
		"requirement":{"type":"building","name":"Large Solar Farm","amount":1},
	},
	"Cracked Blade":{
		"desc":"One of the turbine blades cracked. It now makes sad attempts at rotating around.",
		"options":[
			{"name":"Replace it","effects":[{"name":"lose_money","value":60}]},
			{"name":"Fix it with some glue","effects":[{"name":"reduce_income","value":10,"duration":600}]},
		],
		"eligible_buildings":"Wind Turbine",
		"requirement":{"type":"building","name":"Wind Turbine","amount":1},
	},
	"Surge Protection":{
		"desc":"A big lightning storm is on the way. The transformator building will be dead if hit.",
		"options":[
			{"name":"Install protection","effects":[{"name":"lose_money","value":70}]},
			{"name":"Hope for the best","effects":[{"name":"reduce_population","value":10,"duration":300}]},
		],
		"eligible_buildings":"Transformator Building",
		"requirement":{"type":"building","name":"Transformator Building","amount":1},
	},
	"Grid Demand Spike":{
		"desc":"Everyone turned on their oven at the same time. Your power grid is failing the pressure.",
		"options":[
			{"name":"Run at full power","effects":[{"name":"boost_income","value":15,"duration":300},{"name":"happiness_debuff","value":-10,"duration":300}]},
			{"name":"Ask people to wait","effects":[{"name":"reduce_income","value":10,"duration":300}]},
		],
		"eligible_buildings":"all_power_generators",
		"requirement":{"type":"building","name":"Transformator Building","amount":1},
	},
	"Duck Pond Dispute":{
		"desc":"Two groups of ducks are fighting over the fountain. They seem to be thirsty.",
		"options":[
			{"name":"Build a second pond","effects":[{"name":"lose_money","value":35},{"name":"happiness_boost","value":10,"duration":600}]},
			{"name":"Let them fight","effects":[{"name":"happiness_debuff","value":-10,"duration":300}]},
		],
		"eligible_buildings":"Fountain Park",
		"requirement":{"type":"building","name":"Fountain Park","amount":1},
	},
	"Memorial Bench Plaques":{
		"desc":"Citizens want to buy little benches with little plaques. 'Here sat Bob. Bob was a real hero.'",
		"options":[
			{"name":"Sell the benches","effects":[{"name":"gain_money","value":30}]},
			{"name":"Give them for free","effects":[{"name":"happiness_boost","value":15,"duration":600}]},
		],
		"eligible_buildings":"all_parks",
		"requirement":{"type":"building","name":"Pocket Park","amount":1},
	},
	"Forest Fire Risk":{
		"desc":"It's very dry in the forest, and it's the perfect weather for barbecues. It's a recipe for disaster.",
		"options":[
			{"name":"Cut a firebreak","effects":[{"name":"lose_money","value":45}]},
			{"name":"Ban barbecues","effects":[{"name":"happiness_debuff","value":-10,"duration":600}]},
		],
		"eligible_buildings":"Lumber Mill",
		"requirement":{"type":"building","name":"Lumber Mill","amount":1},
	},
	"Beehive Boom":{
		"desc":"A beehive appeared in the park. The bees are calm, but the picnic people are not.",
		"options":[
			{"name":"Keep the honey","effects":[{"name":"gain_money","value":25},{"name":"happiness_debuff","value":-5,"duration":300}]},
			{"name":"Move the bees","effects":[{"name":"lose_money","value":20}]},
			{"name":"Destroy the bee nest","effects":[{"name":"happiness_debuff","value":-8,"duration":300}]},
		],
		"eligible_buildings":"Large Park",
		"requirement":{"type":"building","name":"Large Park","amount":1},
	},
	"Conveyor Jam":{
		"desc":"One box got stuck on the conveyor belt, and now there are thousands of boxes falling off the conveyor.",
		"options":[
			{"name":"Fix it","effects":[{"name":"lose_money","value":35}]},
			{"name":"Wait it out","effects":[{"name":"reduce_income","value":20,"duration":300}]},
		],
		"eligible_buildings":"all_factories",
		"requirement":{"type":"building","name":"Small Factory","amount":1},
	},
	"Night Shift":{
		"desc":"The workers could work at night too. Everything for capitalism.",
		"options":[
			{"name":"Approve it","effects":[{"name":"boost_income","value":20,"duration":600},{"name":"happiness_debuff","value":-50,"duration":600}]},
			{"name":"Keep it day only","effects":[{"name":"happiness_boost","value":8,"duration":600}]},
		],
		"eligible_buildings":"Small Factory",
		"requirement":{"type":"building","name":"Small Factory","amount":1},
	},
	"Industrial Espionage":{
		"desc":"A mysterious man was seen taking photos of your machines. He couldn't speak english, and left in a limousine.",
		"options":[
			{"name":"Hire security","effects":[{"name":"lose_money","value":80}]},
			{"name":"Sell him the secrets","effects":[{"name":"gain_money","value":60},{"name":"reduce_income","value":10,"duration":600}]},
		],
		"eligible_buildings":"Large Factory",
		"requirement":{"type":"building","name":"Large Factory","amount":1},
	},
	"Recycling Programme":{
		"desc":"A citizen wants the factories to recycle their scraps. The factory owner is fine with it, but he wants compensation.",
		"options":[
			{"name":"Start recycling","effects":[{"name":"lose_money","value":50},{"name":"boost_population","value":8,"duration":900}]},
			{"name":"Skip it","effects":[{"name":"happiness_debuff","value":-8,"duration":600}]},
		],
		"eligible_buildings":"all_factories",
		"requirement":{"type":"building","name":"Small Factory","amount":2},
	},
	"Cave Paintings":{
		"desc":"The miners found cave paintings. They show a stick figure holding a controller.",
		"options":[
			{"name":"Open a museum","effects":[{"name":"lose_money","value":40},{"name":"boost_income","value":15,"duration":900}]},
			{"name":"Keep digging","effects":[{"name":"boost_income","value":10,"duration":300},{"name":"happiness_debuff","value":-5,"duration":300}]},
		],
		"eligible_buildings":"Mine",
		"requirement":{"type":"building","name":"Mine","amount":1},
	},
	"Gem Price Crash":{
		"desc":"Gem prices suddenly dropped as a massive deposit was found. Your investors are sending complaint emails.",
		"options":[
			{"name":"Hold on to them","effects":[{"name":"reduce_income","value":10,"duration":600}]},
			{"name":"Sell now","effects":[{"name":"gain_money","value":40}]},
		],
		"eligible_buildings":"Ore Extractor",
		"requirement":{"type":"building","name":"Ore Extractor","amount":1},
	},
	"Quicksand":{
		"desc":"A digger fell into the sand and is slowly sinking. It's waving goodbye with its little arm.",
		"options":[
			{"name":"Rescue it","effects":[{"name":"lose_money","value":50}]},
			{"name":"Wave goodbye","effects":[{"name":"reduce_income","value":15,"duration":600}]},
		],
		"eligible_buildings":"Sand Mine",
		"requirement":{"type":"building","name":"Sand Mine","amount":1},
	},
	"Glassblowers' Guild":{
		"desc":"A guild of glassblowers wants to use your furnace. They make very tiny glass animals.",
		"options":[
			{"name":"Let them in","effects":[{"name":"lose_money","value":60},{"name":"boost_income","value":15,"duration":600}]},
			{"name":"Say no","effects":[{"name":"gain_money","value":5}]},
		],
		"eligible_buildings":"Smeltery",
		"requirement":{"type":"building","name":"Smeltery","amount":1},
	},
	"Sea Monster Sighting":{
		"desc":"A fisherman swears he saw a giant sea monster. He says it waved at him.",
		"options":[
			{"name":"Go look for it","effects":[{"name":"lose_money","value":80},{"name":"boost_income","value":20,"duration":600}]},
			{"name":"Tell him to sleep more","effects":[{"name":"happiness_debuff","value":-5,"duration":300}]},
		],
		"eligible_buildings":"Fishing Boat",
		"requirement":{"type":"building","name":"Fishing Boat","amount":1},
	},
	"Seagull Menace":{
		"desc":"Seagulls keep stealing fish right off the dock. One of them has started entering Supermarkets and stealing fish as coolers were opened.",
		"options":[
			{"name":"Build a scarecrow","effects":[{"name":"lose_money","value":25}]},
			{"name":"Feed them","effects":[{"name":"reduce_income","value":10,"duration":600},{"name":"happiness_boost","value":10,"duration":300}]},
		],
		"eligible_buildings":"Fishing Dock",
		"requirement":{"type":"building","name":"Fishing Dock","amount":1},
	},
	"Sushi Craze":{
		"desc":"Everybody wants sushi! There's a line of a hundred people waiting for a famous California Roll.",
		"options":[
			{"name":"Open a sushi bar","effects":[{"name":"lose_money","value":45},{"name":"boost_income","value":30,"duration":600}]},
			{"name":"Stick to fish","effects":[{"name":"boost_income","value":8,"duration":300}]},
		],
		"eligible_buildings":"Seafood Market",
		"requirement":{"type":"building","name":"Seafood Market","amount":1},
	},
	"Beaver Dam":{
		"desc":"Some beavers built a dam next to the lumber mill. They are chopping down trees in front of the workers eyes.",
		"options":[
			{"name":"Hire the beavers","effects":[{"name":"lose_money","value":20},{"name":"boost_income","value":20,"duration":600}]},
			{"name":"Remove the dam","effects":[{"name":"lose_money","value":30}]},
		],
		"eligible_buildings":"Lumber Mill",
		"requirement":{"type":"building","name":"Lumber Mill","amount":1},
	},
	"Cow on the Tracks":{
		"desc":"A cow is standing on the tracks and refuses to move. She's chewing. She's winning.",
		"options":[
			{"name":"Wait for her","effects":[{"name":"reduce_income","value":15,"duration":300}]},
			{"name":"Offer her some fresh grass","effects":[{"name":"lose_money","value":10}]},
		],
		"eligible_buildings":"Train Station",
		"requirement":{"type":"building","name":"Train Station","amount":1},
	},
	"Rail Graffiti":{
		"desc":"Someone painted 200m of train track bright pink. The railway workers are really confused.",
		"options":[
			{"name":"Keep it pink","effects":[{"name":"happiness_boost","value":10,"duration":600},{"name":"reduce_income","value":20,"duration":200}]},
			{"name":"Clean it","effects":[{"name":"lose_money","value":25}]},
		],
		"eligible_buildings":"Rail",
		"requirement":{"type":"building","name":"Rail","amount":1},
	},
	"Train Enthusiasts":{
		"desc":"A group of train spotters arrived with notebooks. They're very excited about a specific train.",
		"options":[
			{"name":"Give them a platform","effects":[{"name":"lose_money","value":15},{"name":"happiness_boost","value":8,"duration":600},{"name":"boost_income","value":8,"duration":300}]},
			{"name":"Ask them to leave","effects":[{"name":"happiness_debuff","value":-5,"duration":300}]},
		],
		"eligible_buildings":"Train Station",
		"requirement":{"type":"building","name":"Train Station","amount":1},
	},
	"Flooded Metro":{
		"desc":"There is water in the metro! The rats are crawling up the stairs like... rats.",
		"options":[
			{"name":"Pump it out","effects":[{"name":"lose_money","value":100}]},
			{"name":"Close the station","effects":[{"name":"reduce_income","value":20,"duration":600}]},
		],
		"eligible_buildings":"Metro Station",
		"requirement":{"type":"building","name":"Metro Station","amount":1},
	},
	"Bird Strike":{
		"desc":"A bird flew into a plane. The plane is fine, but the bird couldn't live to tell the story.",
		"options":[
			{"name":"Fence the runway","effects":[{"name":"lose_money","value":55}]},
			{"name":"Hire a falcon","effects":[{"name":"lose_money","value":25},{"name":"happiness_boost","value":5,"duration":300}]},
		],
		"eligible_buildings":"Airport Runway",
		"requirement":{"type":"building","name":"Airport Runway","amount":1},
	},
	"Bed Bugs":{
		"desc":"Bed bugs were found in one of the rooms. The guest ran away screaming.",
		"options":[
			{"name":"Sterilize all the rooms","effects":[{"name":"lose_money","value":100}]},
			{"name":"Call them 'wildlife'","effects":[{"name":"happiness_debuff","value":-20,"duration":600},{"name":"reduce_income","value":10,"duration":300}]},
		],
		"eligible_buildings":"all_hotels",
		"requirement":{"type":"building","name":"Small Motel","amount":1},
	},
	"Wedding Weekend":{
		"desc":"A big wedding wants the whole hotel. There are three cakes, and they want speakers to be installed.",
		"options":[
			{"name":"Host the wedding","effects":[{"name":"gain_money","value":70},{"name":"happiness_debuff","value":-5,"duration":300}]},
			{"name":"Politely decline","effects":[{"name":"happiness_debuff","value":-15,"duration":300}]},
		],
		"eligible_buildings":"Luxury Hotel",
		"requirement":{"type":"building","name":"Luxury Hotel","amount":1},
	},
	"Film Festival":{
		"desc":"A film festival wants to use your cinema. Some movies are significantly better than others.",
		"options":[
			{"name":"Host it","effects":[{"name":"lose_money","value":30},{"name":"boost_income","value":20,"duration":600},{"name":"happiness_boost","value":8,"duration":600}]},
			{"name":"Show a blockbuster instead","effects":[{"name":"boost_income","value":10,"duration":300}]},
		],
		"eligible_buildings":"Cinema",
		"requirement":{"type":"building","name":"Cinema","amount":1},
	},
	"Haunted House Attraction":{
		"desc":"The haunted house is so scary that it is on the front page of many newspapers. Visitors want more.",
		"options":[
			{"name":"Turn it down","effects":[{"name":"lose_money","value":20},{"name":"happiness_boost","value":5,"duration":300}]},
			{"name":"Make it scarier","effects":[{"name":"boost_income","value":25,"duration":300},{"name":"happiness_debuff","value":-10,"duration":300}]},
		],
		"eligible_buildings":"Theme Park",
		"requirement":{"type":"building","name":"Theme Park","amount":1},
	},
}
