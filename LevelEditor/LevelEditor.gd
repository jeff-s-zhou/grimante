extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var editor_piece_prototype = preload("res://LevelEditor/EditorPiece.tscn")

var editor_grid_prototype = preload("res://LevelEditor/EditorGrid.tscn")

var current_editor_grid

var editor_grids = []

var in_menu = false

var selected = null

var target = null

var current_turn = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	
	get_node("EditorTurnSelector").connect("selected", self, "select_editor_grid")
	
	initialize_grids()


func select_editor_grid(turn_number):
	self.current_turn = turn_number
	for editor_grid in self.editor_grids:
		editor_grid.hide()
	self.current_editor_grid = self.editor_grids[turn_number]
	self.editor_grids[turn_number].show()
	

func get_current_editor_grid():
	return self.current_editor_grid
	
func _input(event):
	if get_node("InputHandler").is_select(event):
		if self.in_menu:
			var hovered = get_node("CursorArea").get_modifier_display_hovered()
			if hovered:
				hovered.input_event(event)
		else:
			var hovered = get_node("CursorArea").get_piece_or_location_hovered()
			if hovered:
				hovered.input_event(event)
			elif selected != null:
				selected.invalid_move()
				
	elif event.is_action("test_action") and event.is_pressed():
		save_level("test.save")
		
	elif event.is_action("test_action2") and event.is_pressed():
		load_level("test.save")
	
	elif event.is_action("test_action3") and event.is_pressed():
		reset_grids()

func set_target(target):
	self.target = target
	if self.selected != null:
		if self.selected.is_instanced(): #if already placed on the map, switch up positions
			self.selected.set_coords(target.coords)
			self.selected = null
		else:
			get_node("PieceForm").show()
			self.in_menu = true
			var values = (yield(get_node("PieceForm"), "finished"))
			var hp = values[0]
			var modifiers = values[1]
			var name = self.selected.name
			var instanced = self.selected.duplicate()
			self.current_editor_grid.add_piece(name, self.current_turn, target.coords, instanced, hp, modifiers)
			self.in_menu = false
			self.selected = null
			

func save_level(file_name):
	var save = File.new()
	save.open("user://" + file_name, File.WRITE)
	for editor_grid in self.editor_grids:
		var enemy_pieces = editor_grid.pieces
		for key in enemy_pieces:
			var enemy_piece = enemy_pieces[key]
			var data = enemy_piece.save()
			save.store_line(data.to_json())
		
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
		self.editor_grids.append(editor_grid)
		editor_grid.set_pos(Vector2(73, 280))
		editor_grid.hide()
		
	get_node("EditorTurnSelector").select(0)


func load_level(file_name):
	print("how many times am I resetting?")
	reset_grids()
	
	var save = File.new()
	if !save.file_exists("user://" + file_name):
		return #Error!  We don't have a save to load

	# Load the file line by line and process that dictionary to restore the object it represents
	var current_line = {} # dict.parse_json() requires a declared dict.
	save.open("user://" + file_name, File.READ)
	while (!save.eof_reached()):
		current_line.parse_json(save.get_line())
		# First we need to create the object and add it to the tree and set its position.
		var new_piece = editor_piece_prototype.instance()
		print(current_line)
		var name = current_line["name"]
		var coords = Vector2(current_line["pos_x"],current_line["pos_y"])
		var hp = current_line["hp"]
		var modifiers = current_line["modifiers"]
		var turn = current_line["turn"]
		self.editor_grids[turn].add_piece(name, turn, coords, new_piece, hp, modifiers)
			
	save.close()

