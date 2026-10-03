extends TileMapLayer

var height_noise = FastNoiseLite.new()
var rainfall_noise = FastNoiseLite.new()
var temperature_noise = FastNoiseLite.new()
var random = RandomNumberGenerator.new()
var hiddenlayerrandom = RandomNumberGenerator.new()
var hiddenlayer = []
const NOISE_SCALE = 3
@export var seed = 0

func get_tile(coords:Vector2i) -> int:
	var res = -1
	match get_cell_atlas_coords(coords):
		Vector2i(0,0):
			res = 0 # Plains
		Vector2i(1,0):
			res = 1 # Water
		Vector2i(0,2):
			res = 2 # Sparse Forest (Will cost less to remove but produce less lumber)
		Vector2i(0,1):
			res = 3 # Dense Forest
		Vector2i(2,0), Vector2i(3, 0), Vector2i(2, 1), Vector2i(3, 1):
			res = 4 # Any Type of Mountain
		Vector2i(0,4):
			res = 5 # Wheat field
		Vector2i(0,3),Vector2i(1,3),Vector2i(2,3),Vector2i(3,3):
			res = 6 # Any desert tile
		Vector2i(1,1):
			res = 7 # Deep Water
	return res
func get_hiddenlayer_value(coords: Vector2i) -> float:
	return hiddenlayer[coords.y + Global.LoadSettings.get("map_size",20) * 6][coords.x + Global.MAP_SIZE.x * 6]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("reroll_seed") and event.is_pressed():
		var valid = false
		var s = 0
		while not valid:
			s = randi()
			valid = ValidateSeed(s)
			print(s," is valid ",valid)
		seed = s
		Generate()

func SetUpNoiseMaps(s:int):
	height_noise.seed = s
	height_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	height_noise.offset = Vector3(50,50,50)
	height_noise.fractal_octaves = 2
	rainfall_noise.seed = s + 1
	rainfall_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	rainfall_noise.fractal_octaves = 3
	height_noise.offset = Vector3(50,50,50)
	temperature_noise.seed = s+2
	temperature_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	temperature_noise.fractal_octaves = 2
	height_noise.offset = Vector3(50,50,50)
	random.seed = s
	hiddenlayerrandom.seed = s + 5

func Generate() -> void:
	$"../UI".SetLoadProgress("Generating Terrain...",0)
	await get_tree().process_frame
	SetUpNoiseMaps(seed)
	var i = 0.0
	var total = (Global.GameSettings.get("map_size",20) * 12 + 6) ** 2
	for y in range(- Global.GameSettings.get("map_size",20) * 6 - 3, Global.GameSettings.get("map_size",20) * 6 + 3):
		hiddenlayer.append([])
		for x in range(- Global.GameSettings.get("map_size",20) * 6 - 3, Global.GameSettings.get("map_size",20) * 6 + 3):
			if random.randi_range(0, 3) == 0:
				hiddenlayer[y + Global.GameSettings.get("map_size",20) * 6 + 3].append(random.randf_range(0, 1))
			else:
				hiddenlayer[y + Global.GameSettings.get("map_size",20) * 6 + 3].append(0.0)# Water
			set_cell(Vector2i(x,y),0,FindTerrainTile(x,y))
			i += 1.0
			if floor(int(i)) % 1000 == 0:
				print(i,"   ",total)
				print((i/total*100))
				$"../UI".SetLoadProgress("Generating Terrain...",int(floor(i/total*100)))
				await Global.CheckFrame()
	print("klar")
	$"..".finished.emit()

func FindTerrainTile(x:int,y:int,s=0) -> Vector2i:
	var height = height_noise.get_noise_2d(x*NOISE_SCALE,y*NOISE_SCALE)
	var rainfall = rainfall_noise.get_noise_2d(x*NOISE_SCALE*2,y*NOISE_SCALE*2)
	var temp = temperature_noise.get_noise_2d(x*NOISE_SCALE * 0.25,y*NOISE_SCALE * 0.25)
	if s != 0:
		height = height_noise.get_noise_2d(x*NOISE_SCALE,y*NOISE_SCALE)
		rainfall = rainfall_noise.get_noise_2d(x*NOISE_SCALE*2,y*NOISE_SCALE*2)
		temp = temperature_noise.get_noise_2d(x*NOISE_SCALE * 0.25,y*NOISE_SCALE * 0.25)
	
	if (height < 0 && rainfall >= 0.2) or height <= -0.15:
		if height <= -0.3:
			return Vector2i(1, 1) # Deep Water
		return Vector2i(1, 0) # Water
	# Desert Mountain
	if height >= 0.4 && rainfall <= -0.05 && temp >= 0.2:
		if random.randi_range(0, 5) == 0:
			return Vector2i(3, 3)

	
	if height > 0.35:
		if rainfall >= 0.25:
			return Vector2i(2 + random.randi_range(0, 1), 1) # Forest Mountain
		return Vector2i(2 + random.randi_range(0, 1), 0) # Mountain

	# Desert
	if rainfall <= -0.05 && temp >= 0.2:
		if rainfall >= -0.3 && random.randi_range(0, 15) == 0:
			return Vector2i(1 + random.randi_range(0, 1), 3) # Cactus
		return Vector2i(0, 3) # Normal

	# Wheat
	if rainfall >= 0.1 && rainfall <= 0.15 && height <= 0.1:
		return Vector2i(0, 4)

	# Forest
	if height >= 0.15 && rainfall > 0.12:
		if rainfall >= 0.3:
			return Vector2i(0, 1) # dense
		return Vector2i(0, 2) # sparse

	# Plains
	return Vector2i(0, 0)
	

func ValidateSeed(s:int) -> bool:
	SetUpNoiseMaps(s)
	for x in range(-3,3):
		for y in range(-3,3):
			if FindTerrainTile(x,y,s) not in [Vector2i(1, 1),Vector2i(1, 0)]:
				return true
	return false
