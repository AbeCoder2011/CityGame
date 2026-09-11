extends TileMapLayer

var height_noise = FastNoiseLite.new()
var rainfall_noise = FastNoiseLite.new()
var temperature_noise = FastNoiseLite.new()
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
			res = 5 # Any Type of Mountain
	return res

func _ready():
	if Global.LoadSettings["load"] == false:
		seed = randi()
		Generate()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("reroll_seed") and event.is_pressed():
		seed = randi()
		print(seed)
		Generate()
func Generate() -> void:
	var random = RandomNumberGenerator.new()
	random.seed = seed
	height_noise.seed = seed
	height_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	height_noise.offset = Vector3(50,50,50)
	height_noise.fractal_octaves = 2
	rainfall_noise.seed = seed + 1
	rainfall_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	rainfall_noise.fractal_octaves = 3
	height_noise.offset = Vector3(50,50,50)
	temperature_noise.seed = seed+2
	temperature_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	temperature_noise.fractal_octaves = 2
	height_noise.offset = Vector3(50,50,50)
	for x in range(-60, 60):
		for y in range(-60, 60):
			var height = height_noise.get_noise_2d(x*NOISE_SCALE,y*NOISE_SCALE)
			var rainfall = rainfall_noise.get_noise_2d(x*NOISE_SCALE*2,y*NOISE_SCALE*2)
			var temp = temperature_noise.get_noise_2d(x*NOISE_SCALE * 0.25,y*NOISE_SCALE * 0.25)
			if (height < 0 && rainfall >= 0.2) or (height <= -0.15 && rainfall >= 0): # Water
				set_cell(Vector2i(x,y),0,Vector2i(1,0))
			else: # Land
				set_cell(Vector2i(x,y),0,Vector2i(0,0)) # Plains
				if rainfall <= -0.2 && temp >= 0.2: # Desert
					set_cell(Vector2i(x,y),0,Vector2i(0,3))
					if rainfall >= -0.3 && random.randi_range(0, 15) == 0: 
						set_cell(Vector2i(x,y),0,Vector2i(1,3))
					if height >= 0.4 && random.randi_range(0, 5) == 0:
						set_cell(Vector2i(x,y),0,Vector2i(3, 3)) # Desert Mountain
				else:
					if rainfall >= 0.1 && rainfall <= 0.15 && height <= 0.1:
						set_cell(Vector2i(x,y),0,Vector2(0,4)) # Wheat
					if height >= 0.15 && rainfall > 0.12:
						set_cell(Vector2i(x,y),0,Vector2i(0,2)) # Sparse Forest
						if rainfall >= 0.3:
							set_cell(Vector2i(x,y),0,Vector2i(0,1)) # Dense Forest
					if height > 0.35 && random.randi_range(0,5) == 0:
						set_cell(Vector2i(x,y),0,Vector2i(2 + random.randi_range(0,1),0)) # Mountain
						if rainfall >= 0.25:
							set_cell(Vector2i(x,y),0,Vector2i(2 + random.randi_range(0,1),1))
