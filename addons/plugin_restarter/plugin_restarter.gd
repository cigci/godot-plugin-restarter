@tool
extends EditorPlugin

const WindowScene: PackedScene = preload("./window.tscn")
var selected_plugins: Array[String]


func _input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return

	if (
		event.keycode == KEY_A
		and event.shift_pressed
		and event.ctrl_pressed
		and event.pressed
	):
		for plugin in get_all_plugins():
			EditorInterface.set_plugin_enabled(plugin, false)
			EditorInterface.set_plugin_enabled(plugin, true)
		get_viewport().set_input_as_handled()
		print("Restarted All Plugins!")
		
	if (
		event.keycode == KEY_S
		and event.shift_pressed
		and event.ctrl_pressed
		and event.pressed
	):
		for plugin in selected_plugins:
			EditorInterface.set_plugin_enabled(plugin, false)
			EditorInterface.set_plugin_enabled(plugin, true)
		get_viewport().set_input_as_handled()
		print("Restarted All Selected Plugins!")


func create_window() -> void:
	var window_scene: Window = WindowScene.instantiate()
	EditorInterface.get_base_control().add_child(window_scene)
	window_scene.plugin_script = self
	window_scene.init_window()


func _enter_tree() -> void:
	add_tool_menu_item("Plugin Restarter...", create_window)


func _exit_tree() -> void:
	remove_tool_menu_item("Plugin Restarter...")


func has_config_file(plugin_dir: String) -> bool:
	var dir = DirAccess.open(plugin_dir)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		
		# Search for .cfg file extension
		while not file_name.is_empty():
			if file_name.to_lower().ends_with(".cfg"):
				dir.list_dir_end()
				return true # .cfg-file found
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return false 


func get_all_plugins() -> PackedStringArray:
	var plugins: PackedStringArray = [] 
	var dir = DirAccess.open("res://addons")
	
	if not dir:
		return plugins
	
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while not file_name.is_empty():
		if dir.current_is_dir() and file_name != "plugin_restarter":
			var plugin_path = "res://addons/" + file_name
			if has_config_file(plugin_path):
				plugins.append(file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	plugins.sort()
	
	return plugins
