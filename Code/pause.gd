extends Control

var main_menu = true
# main, pause, settings, general_settings, video_settings, sound_settings, accesibility_settings, 
var menu = "main"

const WINDOW_SIZES = [
	Vector2i(1600,900),
	Vector2i(1920,1080),
	Vector2i(1920,1200),
	Vector2i(3840,2160),
]

const WINDOW_MODES = [
	Window.MODE_WINDOWED,
	Window.MODE_FULLSCREEN,
	Window.MODE_EXCLUSIVE_FULLSCREEN,
]
func _ready() -> void:
	main_menu = (get_parent().name == "Title")
	if main_menu:
		$Base/Paused.text = "Settings"
		$Settings/SettingsText.hide()
		$Base/ColorRect.hide()
		offset_top = 155



func _on_settings_pressed() -> void:
	$Main.hide()
	$Settings.show()
	show()
	menu = "settings"

func _on_back_settings_pressed() -> void:
	$Settings.hide()
	$General.hide()
	$Audio.hide()
	$Video.hide()
	$Accesibility.hide()
	if main_menu:
		hide()
		menu = "closed"
		$".."._on_back_pressed()
	else:
		$Main.show()
		menu = "paused"

func _on_back_sub_setting_pressed() -> void:
	$General.hide()
	$Audio.hide()
	$Video.hide()
	$Accesibility.hide()
	$Settings.show()
	menu = "settings"

func SubSetting(nam:String):
	$General.hide()
	$Audio.hide()
	$Video.hide()
	$Accesibility.hide()
	
	match nam:
		"general":
			$General.show()
			menu = "general_settings"
		"audio":
			menu = "audio_settings"
			$Audio.show()
		"video":
			menu = "video_settings"
			$Video.show()
		"accesibility":
			menu = "accesibility_settings"
			$Accesibility.show()
	SaveSettings()

func SetSettingValue(new_value:float,nam:String):
	Global.Settings[nam] = new_value
	match nam:
		"camera_speed":
			$"General/HBoxContainer/1/CamSpeed".text = "Camera Speed (" + str(int(new_value)) + "px)"
		"autosave_interval":
			$"General/HBoxContainer/1/AutosaveInterval2".text = "Autosave Interval (" + str(int(new_value)) + "s)"
			if not main_menu:
				$"../../../Autosaver".wait_time = new_value
		"master_volume":
			AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"),new_value)
			$"Audio/HBoxContainer/1/Master".text = "Master Volume (%d%s)" % [(new_value * 100),"%"]
		"sfx_volume":
			AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"),new_value)
			$"Audio/HBoxContainer/1/SFX".text = "Sound Effects Volume (%d%s)" % [(new_value * 100),"%"]
		"music_volume":
			AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"),new_value)
			$"Audio/HBoxContainer/1/Music".text = "Music Volume (%d%s)" % [(new_value * 100),"%"]
		"max_fps":
			if new_value >= 300:
				Engine.max_fps = 0
				$"Video/HBoxContainer/1/FPS".text = "Maximum FPS (Unlimited)"
			else:
				Engine.max_fps = int(new_value)
				$"Video/HBoxContainer/1/FPS".text = "Maximum FPS (%d fps)" % new_value
	SaveSettings()

func SetSettingBool(new_state:bool,nam:String):
	Global.Settings[nam] = new_state
	match nam:
		"autosave":
			$"General/HBoxContainer/1/AutosaveInterval2".visible = new_state
			$"General/HBoxContainer/1/AutosaveIntervalSlider".visible = new_state
		"show_building_grid":
			if !main_menu:
				$"../../../Background/Grid".visible = new_state
	SaveSettings()

func SetOptionID(new_id:int,nam:String):
	Global.Settings[nam] = new_id
	match nam:
		"window_size":
			get_window().size = WINDOW_SIZES[new_id]
		"window_mode":
			get_window().mode = WINDOW_MODES[new_id]
	SaveSettings()

func SaveSettings() -> void:
	var settings = ConfigFile.new()
	settings.set_value("Settings","dict",Global.Settings)
	settings.save("user://settings.cfg")

func LoadSettings() -> void:
	var settings = ConfigFile.new()
	settings.load("user://settings.cfg")
	Global.Settings = settings.get_value("Settings","dict",{})
	for nam in Global.Settings.keys():
		var v = Global.Settings[nam]
		match nam:
			"disable_income_popup":
				$"General/HBoxContainer/1/DisableIncomeNumber".button_pressed = v
			"disable_unlock_notification":
				$"General/HBoxContainer/1/DisableUnlockNotifcation".button_pressed = v
			"autosave":
				$"General/HBoxContainer/1/Autosave".button_pressed = v
				$"General/HBoxContainer/1/AutosaveInterval2".visible = v
				$"General/HBoxContainer/1/AutosaveIntervalSlider".visible = v
			"autosave_interval":
				$"General/HBoxContainer/1/AutosaveIntervalSlider".value = v
			"camera_speed":
				$"General/HBoxContainer/1/CamSpeedSlider".value = v
			"number_notation":
				$"General/HBoxContainer/2/NumberFormatButton".select(v)
			"show_building_grid":
				$"General/HBoxContainer/1/ShowBuildingGrid".button_pressed = v
				if !main_menu:
					$"../../../Background/Grid".visible = v
			"number_format":
				$"General/HBoxContainer/2/NumberFormatButton".select(v)
			"master_volume":
				AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"),v)
				$"Audio/HBoxContainer/1/Master".text = "Master Volume (%d%s)" % [(v * 100),"%"]
				$"Audio/HBoxContainer/1/MasterSlider".value = v
			"sfx_volume":
				AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"),v)
				$"Audio/HBoxContainer/1/SFX".text = "Sound Effects Volume (%d%s)" % [(v * 100),"%"]
				$"Audio/HBoxContainer/1/SFXslider".value = v
			"music_volume":
				AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"),v)
				$"Audio/HBoxContainer/1/Music".text = "Music Volume (%d%s)" % [(v * 100),"%"]
				$"Audio/HBoxContainer/1/MusicSlider".value = v
			"max_fps":
				if v >= 300:
					Engine.max_fps = 0
					$"Video/HBoxContainer/1/FPS".text = "Maximum FPS (Unlimited)"
				else:
					Engine.max_fps = v
					$"Video/HBoxContainer/1/FPS".text = "Maximum FPS (%d fps)" % v
			"autosave_interval":
				if !main_menu:
					$"../Autosaver".wait_time = Global.Settings.get("autosave_interval",60)
			"window_size":
				get_window().size = WINDOW_SIZES[v]
			"window_mode":
				get_window().mode = WINDOW_MODES[v]
			_:
				print("idk! ",nam,"   ",v)
				
	print("Settings Loaded! ")


func _on_save_and_return_pressed() -> void:
	$"../.."._on_save_and_return_pressed()


func _on_save_and_quit_pressed() -> void:
	$"../.."._on_save_and_quit_pressed()


func _on_continue_pressed() -> void:
	$"../.."._on_continue_pressed()
