extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var editor_piece_prototype = preload("res://LevelEditor/EditorPiece.tscn")

var editor_hero_piece_prototype = preload("res://LevelEditor/EditorHeroPiece.tscn")

var editor_grid_prototype = preload("res://LevelEditor/EditorGrid.tscn")

var current_editor_grid

var editor_grids = []

var in_menu = false

var placing_traps = false

var selected = null

var target = null

var current_turn = 0

var original_mouse_pos = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	
	get_node("EditorTurnSelector").connect("selected", self, "select_editor_grid")
	
	initialize_grids()
#	Globals.set("display/height", 1000)
#	Globals.set("display/width", 670)
#	get_tree().get_root().set_size_override(true, Vector2(670, 1000))
#	get_tree().get_root().set_size_override_stretch(true)
#	
	
func select_editor_grid(turn_number):
	self.current_turn = turn_number
	for editor_grid in self.editor_grids:
		editor_grid.set_pos(Vector2(-1500, -1500))
		editor_grid.hide()
	self.current_editor_grid = self.editor_grids[turn_number]
	self.editor_grids[turn_number].show()
	self.editor_grids[turn_number].set_pos(Vector2(73, 160))
	

func get_current_editor_grid():
	return self.current_editor_grid

#passed from the UnitBarArea, to detect scrolling the enemy unit bar
func input_event(event):
	if get_node("InputHandler").is_select(event):
		self.original_mouse_pos = event.pos
	elif get_node("InputHandler").is_unpress(event):
		self.original_mouse_pos = null
	if self.original_mouse_pos != null:
		if get_node("EditorUnitBar").is_visible():
			get_node("EditorUnitBar").translate(Vector2(0, event.pos.y - self.original_mouse_pos.y))
		else:
			get_node("EditorHeroBar").translate(Vector2(0, event.pos.y - self.original_mouse_pos.y))
		self.original_mouse_pos = event.pos
			
	
func _input(event):
	if get_node("InputHandler").is_select(event):
		if self.in_menu: #we do this so it doesn't pick up the other things beneath the menu
			var hovered = get_node("CursorArea").get_modifier_mock_hovered()
			if hovered:
				hovered.input_event(event)
				
		elif self.placing_traps:
			var hovered = get_node("CursorArea").get_piece_or_location_hovered()
			if hovered:
				hovered.toggle_trap()
		else:
			var hovered = get_node("CursorArea").get_piece_or_location_hovered()
			if hovered:
				hovered.input_event(event)

				
	elif event.is_action("test_action") and event.is_pressed():
		save_level()
		
	elif event.is_action("test_action2") and event.is_pressed():
		load_level()
	
	elif event.is_action("test_action3") and event.is_pressed():
		reset_grids()

		
	elif event.is_action("toggle") and event.is_pressed():
		if get_node("EditorUnitBar").is_visible():
			get_node("EditorUnitBar").hide()
			get_node("EditorHeroBar").show()
		else:
			get_node("EditorUnitBar").show()
			get_node("EditorHeroBar").hide()
			
	elif event.is_action("placing_traps") and event.is_pressed():
		if get_node("EditorUnitBar").is_visible() or get_node("EditorHeroBar").is_visible():
			self.placing_traps = true
			get_node("EditorUnitBar").hide()
			get_node("EditorHeroBar").hide()
		else:
			self.placing_traps = false
			get_node("EditorUnitBar").show()
			#get_node("EditorHeroBar").show()

func set_target(target):
	self.target = target
	if self.selected != null:
		if self.selected.is_instanced(): #if already placed on the map, switch up positions
			self.selected.move(target.coords)
			self.selected = null
		else:
			if self.selected.is_hero:
				var name = self.selected.name
				var instanced = self.selected.duplicate()
				self.current_editor_grid.add_hero_piece(name, self.current_turn, target.coords, instanced)
			else:
				get_node("PieceForm").show()
				self.in_menu = true
				var values = (yield(get_node("PieceForm"), "finished"))
				if values != null: #if not cancelled
					var hp = values[0]
					var modifiers = values[1]
					var name = self.selected.name
					var instanced = self.selected.duplicate()
					self.current_editor_grid.add_piece(name, self.current_turn, target.coords, instanced, hp, modifiers)
			
			self.in_menu = false
			self.selected = null
			
			
func modify_unit():
	get_node("PieceForm").show(true)
	self.in_menu = true
	var values = (yield(get_node("PieceForm"), "finished"))
	
	if values != null: #if not cancelled
		if typeof(values) == TYPE_ARRAY:
			var hp = values[0]
			var modifiers = values[1]
			self.selected.edit(hp, modifiers)
			self.selected = null
		else:
			var deleted_unit = self.selected
			self.selected = null
			deleted_unit.delete()
	
	self.in_menu = false


func save_level():
	var first_line = true
	
	var file_name = get_node("FileName").get_text()
	var save = File.new()
	save.open("res://Levels/" + file_name, File.WRITE)
	for editor_grid in self.editor_grids:
		var enemy_pieces = editor_grid.pieces
		for key in enemy_pieces:
			var enemy_piece = enemy_pieces[key]
			var data = enemy_piece.save()
			
			#have to do this instead of store_line because loading bugs out on the last linebreak
			if first_line:
				first_line = false
			else:
				save.store_string("\n")
			save.store_string(data.to_json()) 
			
		for location in editor_grid.locations.values():
			if location.trapped:
				var data = location.save()
				save.store_string("\n")
				save.store_string(data.to_json()) 
			
	save.close()
	
	
func reset_grids():
	for editor_grid in self.editor_grids:
		editor_grid.queue_free()
	self.editor_grids = []
	self.current_turn = 0
	self.current_editor_grid = null
	self.selected = null
	self.target = null
	initialize_grids()
	
func initialize_grids():
	for i in range(0, 9):
		var editor_grid = editor_grid_prototype.instance()
		add_child(editor_grid)
		editor_grid.initialize(i)
		self.editor_grids.append(editor_grid)
		editor_grid.set_pos(Vector2(73, 280))
		editor_grid.hide()
		
	get_node("EditorTurnSelector").select(0)


func load_level():
	var file_name = get_node("FileName").get_text()
	reset_grids()
	
	var save = File.new()
	if !save.file_exists("res://Levels/" + file_name):
		return #Error!  We don't have a save to load

	# Load the file line by line and process that dictionary to restore the object it represents
	
	save.open("res://Levels/" + file_name, File.READ)
	while (!save.eof_reached()):
		var current_line = {} # dict.parse_json() requires a declared dict.
		current_line.parse_json(save.get_line())
		if current_line.has("hp"): #EnemyPiece
			var new_piece = editor_piece_prototype.instance()
			var name = current_line["name"]
			var coords = Vector2(current_line["pos_x"],current_line["pos_y"])
			var hp = current_line["hp"]
			var modifiers = current_line["modifiers"]
			var turn = current_line["turn"]
			self.editor_grids[turn].add_piece(name, turn, coords, new_piece, hp, modifiers)
		elif current_line.has("name"): #HeroPiece
			var new_piece = editor_hero_piece_prototype.instance()
			var name = current_line["name"]
			var coords = Vector2(current_line["pos_x"],current_line["pos_y"])
			var turn = current_line["turn"]
			self.editor_grids[turn].add_hero_piece(name, turn, coords, new_piece)
		else:
			var coords = Vector2(current_line["pos_x"],current_line["pos_y"])
			var turn = current_line["turn"]
			self.editor_grids[turn].locations[coords].toggle_trap()


	save.close()

