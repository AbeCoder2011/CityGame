extends TileMapLayer

var height_noise = FastNoiseLite.new()
var rainfall_noise = FastNoiseLite.new()
var temperature_noise = FastNoiseLite.new()
var random = RandomNumberGenerator.new()
var hiddenlayerrandom = RandomNumberGenerator.new()
var hiddenlayer = []
const NOISE_SCALE = 3

var rivers_starting_points : Array[Vector2i]= []

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
	rainfall_noise.offset = Vector3(50,50,50)
	temperature_noise.seed = s+2
	temperature_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	temperature_noise.fractal_octaves = 2
	temperature_noise.offset = Vector3(50,50,50)
	random.seed = s
	hiddenlayerrandom.seed = s + 5

func Generate() -> void:
	$"../UI".SetLoadProgress("Generating Terrain...",0)
	await get_tree().process_frame
	SetUpNoiseMaps(seed)
	var i = 0.0
	var total = (Global.GameSettings.get("map_size",20) * 12 + 6) ** 2
	
	rivers_starting_points = []
	
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
				$"../UI".SetLoadProgress("Generating Terrain...",int(floor(i/total*100)))
				await Global.CheckFrame()
	i = 0.0
	total = len(rivers_starting_points)
	$"../UI".SetLoadProgress("Placing rivers...",0)
	for n in rivers_starting_points:
		for c in GetRiverPath(n,n):
			set_cell(c,0,Vector2i(1,0))
		i += 1.0
		$"../UI".SetLoadProgress("Placing rivers...",int(floor(i/total*100)))
		await Global.CheckFrame()
	#
	
	$"..".finished.emit()

func GetTileHeight(x,y) -> float:
	return height_noise.get_noise_2d(x*NOISE_SCALE,y*NOISE_SCALE)
func GetTileRainfall(x,y) -> float:
	return rainfall_noise.get_noise_2d(x*NOISE_SCALE,y*NOISE_SCALE)

func FindTerrainTile(x:int,y:int) -> Vector2i:
	var height = height_noise.get_noise_2d(x*NOISE_SCALE,y*NOISE_SCALE)
	var rainfall = rainfall_noise.get_noise_2d(x*NOISE_SCALE*2,y*NOISE_SCALE*2)
	var temp = temperature_noise.get_noise_2d(x*NOISE_SCALE * 0.25,y*NOISE_SCALE * 0.25)
	
	# Wheat fields - Inversed
	var wf_i = 1 / Global.GameSettings.get("wheat_field_amount",1)
	# Wheat fields
	var wf = Global.GameSettings.get("wheat_field_amount",1)
	# Forest - Inversed
	var f_i = 1 / Global.GameSettings.get("forest_amount",1)
	# Mountain - Inversed
	var m_i = 1 / Global.GameSettings.get("mountain_amount",1)
	# Water
	var w = Global.GameSettings.get("water_amount",1)
	# Desert
	var d = Global.GameSettings.get("desert_amount",1)
	
	if (height < -0.6 + (0.6 * w) && rainfall >= -0.2 + (0.4 * w)) or height <= -0.55 + (0.4 * w):
		if height <= -0.7 + (0.4 * w):
			return Vector2i(1, 1) # Deep Water
		if random.randi_range(0,4) == 0:
			var dir = [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN][random.randi_range(0,3)]
			var newpos = Vector2i(x,y) + dir
			if GetTileHeight(newpos.x,newpos.y) > -0.15:
				rivers_starting_points.append(Vector2i(x,y) + dir)
		return Vector2i(1, 0) # Water
	
	
	# Desert Mountain
	if height >= 0 + (0.4 * m_i) && rainfall <= -0.45 + (0.4 * d) && temp >= 0.4 - (0.2 * d):
		if random.randi_range(0, 5) == 0:
			return Vector2i(3, 3)
		return Vector2i(0, 3)
	if rainfall <= -0.45 + (0.4 * d) && temp >= 0.4 - (0.2 * d):
		if rainfall >= -0.3 && random.randi_range(0, 15) == 0:
			return Vector2i(1 + random.randi_range(0, 1), 3) # Cactus
		return Vector2i(0, 3) # Normal desert
	
	if height > 0.35 * m_i and random.randi_range(0, 5) == 0:
		if rainfall >= 0.15 * f_i:
			#if random.randi_range(0,2) == 0:
				#var dir = [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN][random.randi_range(0,3)]
				#rivers_starting_points.append(Vector2i(x,y) + dir)
			return Vector2i(2 + random.randi_range(0, 1), 1) # Forest Mountain
		return Vector2i(2 + random.randi_range(0, 1), 0) # Mountain
	# Wheat
	if rainfall >= 0.1 * wf_i && rainfall <= 0.15 * wf && height <= 0.1 * wf:
		return Vector2i(0, 4)

	# Forest
	if height >= -0.3 + (0.45 * f_i) && rainfall > -0.12 * (0.24 * f_i):
		if rainfall >= 0.3 * f_i:
			return Vector2i(0, 1) # dense
		return Vector2i(0, 2) # sparse

	# Plains
	return Vector2i(0, 0)

func GetRiverPath(pos:Vector2i,startpos:Vector2i,i=0) -> Dictionary:
	if i > 100:
		return {}
	
	var w = Global.GameSettings.get("water_amount",1)
	
	var h = GetTileHeight(pos.x,pos.y)
	if (h < -0.6 + (0.6 * w) && GetTileRainfall(pos.x,pos.y) >= -0.2 + (0.4 * w)) or h <= -0.55 + (0.4 * w):
		return {}
	var dirs = [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]
	
	var best_height := 1.0
	var best_dirs := []
	
	for x in range(4):
		var dir = dirs[random.randi_range(0,len(dirs) - 1)]
		dirs.erase(dir)
		var new_pos = pos + dir
		if startpos.distance_to(new_pos) < startpos.distance_to(pos):
			continue
		var height = GetTileHeight(new_pos.x,new_pos.y)
		# GetTileHeight(new_pos.x + dir.y, new_pos.y + dir.x) > height-0.1 && GetTileHeight(new_pos.x-dir.y, new_pos.y-dir.x) > height-0.1
		if (height - 0.1) <= h && GetTileRainfall(new_pos.x, new_pos.y) >= 0.15:
			best_dirs.append(dir)
			best_height = height
			break
	dirs = [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]
	if best_dirs.is_empty():
		for x in range(4):
			var dir = dirs[random.randi_range(0,len(dirs) - 1)]
			dirs.erase(dir)
			var new_pos = pos + dir
			if startpos.distance_to(new_pos) < startpos.distance_to(pos):
				continue
			var height = GetTileHeight(new_pos.x,new_pos.y)
			# GetTileHeight(new_pos.x + dir.y, new_pos.y + dir.x) > height-0.1 && GetTileHeight(new_pos.x-dir.y, new_pos.y-dir.x) > height-0.1
			if (height - 0.17) <= h && GetTileRainfall(new_pos.x, new_pos.y) >= 0.15:
				best_dirs.append(dir)
				best_height = height
				break
	
	if not best_dirs.is_empty():
		var next : Dictionary = {}
		for n in best_dirs:
			for t in GetRiverPath(pos + n,startpos,i+1):
				next[t] = true
			next[pos] = true
		return next
	return {}


func ValidateSeed(s:int) -> bool:
	var terrain_tiles = 0
	SetUpNoiseMaps(s)
	for x in range(-3,3):
		for y in range(-3,3):
			if FindTerrainTile(x,y) not in [Vector2i(1, 1),Vector2i(1, 0)]:
				terrain_tiles += 1
				if terrain_tiles > 5:
					return true
	return false
