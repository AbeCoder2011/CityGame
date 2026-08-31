extends TileMapLayer

var height_noise = FastNoiseLite.new()
var rainfall_noise = FastNoiseLite.new()
const NOISE_SCALE = 3


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
	return res

func _ready():
	var noiseseed = randi()
	Generate(noiseseed)

func Generate(nseed) -> void:
	var random = RandomNumberGenerator.new()
	random.seed = nseed
	height_noise.seed = nseed
	height_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	rainfall_noise.seed = nseed + 1
	rainfall_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	for x in range(-60, 60):
		for y in range(-60, 60):
			var height = height_noise.get_noise_2d(x*NOISE_SCALE,y*NOISE_SCALE)
			var rainfall = rainfall_noise.get_noise_2d(x*NOISE_SCALE*2,y*NOISE_SCALE*2)
			if height < -0.15: # Water
				set_cell(Vector2i(x,y),0,Vector2i(1,0))
			else: # Land
				set_cell(Vector2i(x,y),0,Vector2i(0,0)) # Plains
				if rainfall > 0.1:
					match random.randi_range(0,1):
						0:
							set_cell(Vector2i(x,y),0,Vector2i(0,2)) # Sparse Forest
						1:
							set_cell(Vector2i(x,y),0,Vector2i(0,0)) # Plains
					if rainfall >= 0.2:
						match random.randi_range(0,1):
							0:
								set_cell(Vector2i(x,y),0,Vector2i(0,1)) # Dense Forest
							1:
								set_cell(Vector2i(x,y),0,Vector2i(0,2)) # Sparse Forest
				if height > 0.3 && random.randi_range(0,3) == 0:
					set_cell(Vector2i(x,y),0,Vector2i(2 + random.randi_range(0,1),0)) # Mountain
					if rainfall >= 0.2:
						set_cell(Vector2i(x,y),0,Vector2i(2 + random.randi_range(0,1),1))
