extends Control

const TUTORIAL_BRANCHES = {
	"start":[
		{"text":"Hello there! Is this your first time being a city mayor?"},
		{"buttons":["Yes","No"],"branch":["tutorial_start","end"]},
		{"await":"buttons"},
	],
	"tutorial_start":[
		{"text":"Awesome! Don't worry, I'll get you up to speed. Im the former city mayor! I got voted out during the last elections, and you were luckily elected!"},
		{"await":"next"},
		{"branch":"movement_tutorial"}
	],
	"movement_tutorial":[
		{"text":"This is your city. You can use the arrow keys and WASD to move around, or use the right mouse button to pan around."},
		{"await":"next"},
		{"text":"Also, you can use the scroll wheel and the + and - keys to zoom in to your city. "},
		{"await":"next"},
		{"text":"Go ahead and try it out!"},
		{"buttons":["Okay, I got it.","Wait, one more time..."],"branch":["stats_tutorial","movement_tutorial"]},
		{"await":"buttons"},
	],
	"stats_tutorial":[
		{"pointer":"money"},
		{"text":"Great! This is your money, which you use to build new buildings."},
		{"await":"next"},
		{"hide_pointer":"money"},
		{"pointer":"build"},
		{"text":"You can build new buildings in the building menu. Access it here. Use them to generate income. "},
		{"await":"next"},
		{"hide_pointer":"build"},
		{"pointer":"basic_house"},
		{"text":"The small supermarket is perfect for earning early game income. Try it out!"},
		{"buttons":["How do I use these buildings?"]},
		{"await":"buttons"},
		{"hide_pointer":"basic_house"},
		{"branch":"building_info"},
	],
"building_info":[
		{"text":"Good question! you can hover over the building to know what it does. You can't ponder yet RIP."},
		{"await":"next"},
		{"text":"Combining buildings cleverly is key to earning money as efficiently as possible."},
		{"await":"next"},
		{"branch":"area_unlock"}
	],
"area_unlock":[
		{"text":"During your city expansion, you might need space for new buildings. You can unlock these here, but warn you, these cost increasing amounts of money."},
		{"await":"next"},
		{"branch":"end"}
	],
	"end":[
		{"text":"Enjoy! You can always restart the tutorial in the settings."},
		{"await":"next"},
	]
}

#const TUTORIAL_DATA = [
	#{"pointer":0},
	#{"text":"Hello, and welcome! Have you played this game before?"},
	#{"buttons":["Yep!","No!"]},
	#{"await":"button"},
	#{"text":"Okay!"},
	#{"await":"next"},
#]

signal next_dialogue
signal button_pressed

var pointers = {}

var next_branch = "start"
var next_branch_options = []

func _ready() -> void:
	StartTutorial()

func StartTutorial():
	show()
	await EnterBranch("start")
	hide()

func EnterBranch(branch_name):
	var data = TUTORIAL_BRANCHES[branch_name]
	for n in data:
		await TutorialPart(n)
	if not branch_name == "end":
		await EnterBranch(next_branch)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_dialogue"):
		done()

func done():
	next_dialogue.emit()

func TutorialPart(part:Dictionary) -> void:
	var v = part.values()[0]
	match part.keys()[0]:
		"pointer":
			pointers.get(v).active = true
		"hide_pointer":
			pointers.get(v).active = false
		"text":
			$HBoxContainer/Jerry/Mayor/Sprite.play()
			await $HBoxContainer/Dialogue/Text.type_text(v,part.get("speed",0.03))
			$HBoxContainer/Jerry/Mayor/Sprite.pause()
		"buttons":
			var i = 0
			for b in $HBoxContainer/Dialogue/Buttons.get_children():
				b.hide()
			for b in v:
				$HBoxContainer/Dialogue/Buttons.get_child(i).show()
				$HBoxContainer/Dialogue/Buttons.get_child(i).text = b
				i += 1
			next_branch_options = part.get("branch",[])
		"await":
			match v:
				"next":
					$NextTexture.show()
					await next_dialogue
					$NextTexture.hide()
				"buttons":
					$NextButton.hide()
					await button_pressed
					$NextButton.show()
					# Hide buttons after input is given
					for b in $HBoxContainer/Dialogue/Buttons.get_children():
						b.hide()
					
		"branch":
			next_branch = v
		
func option_button(idx:int):
	if len(next_branch_options) >= idx + 1:
		next_branch = next_branch_options.get(idx)
	button_pressed.emit()

func h(node):
	node.hide()

func register_pointer(nod:Control,nam:String):
	pointers[nam] = nod
