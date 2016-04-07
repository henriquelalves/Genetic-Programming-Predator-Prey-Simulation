extends Node2D

const PLAY = {
"STOP":0,
"SLOW":1,
"FAST":2,
}

# Simulation properties
export (int) var max_turns = 50
export (int) var play_speed = PLAY["FAST"]

onready var evolve_rabbit = true
onready var evolve_fox = true

# Frame Stuff
const FRAME_UPDATE = 0.1
onready var delay = 0.0

# Genetic Programming nodes
const STREE_FUNCTIONS = [
{"name":"sniff_rabbit",      # Sniff function - if following pheromon gradient, first argument; else, second argument
"n_arguments":2,
"type_argument":["null","null"],
"type_function":"null"},
{"name":"sniff_fox",         # Same, but following the other pheromon
"n_arguments":2,
"type_argument":["null","null"],
"type_function":"null"},
{"name":"progn",              # Set an order of instructions, can take any number of arguments
"n_arguments":0,
"type_argument":["null"],
"type_function":"null"},
]

const STREE_TERMINALS = [
{"value":"advance",              # Move forward
"type": "null"},
{"value":"turn_right",        # Turn right
"type": "null"},
{"value":"turn_left",         # Turn left
"type": "null"},
]

# Tree controller reference
onready var stree = get_node("/root/stree_controller")
onready var matrix = {}
onready var turn = 0
onready var generation = 0

onready var global = get_node("/root/global")

func _ready():
	add_user_signal("new_generation")
	get_node("Actors").hide()
	set_process(true)
	
	# Add nodes to tree global controller
	stree.reset()
	for function in STREE_FUNCTIONS:
		stree.add_function(function)
	for terminal in STREE_TERMINALS:
		stree.add_terminal(terminal)
	
	# Create scene from tilemap
	add_actors_from_tilemap()
	
	# Add tree pools and initialize
	stree.add_pool("Rabbit")
	stree.add_pool("Fox")
	
	stree.initialize_pool("Rabbit", get_tree().get_nodes_in_group("Rabbit").size(),0)
	stree.initialize_pool("Fox", get_tree().get_nodes_in_group("Fox").size(),0)

func _process(delta):
	# Controls update speed
	if(play_speed == PLAY.STOP):
		return
	var update = false
	if(play_speed == PLAY.SLOW):
		delay += delta
		if delay > FRAME_UPDATE:
			delay -= FRAME_UPDATE
			update = true
	else:
		update = true
	# Updates
	if(update):
		turn += 1
		
		var actors
		var pool
		# Update Rabbits
		actors = get_tree().get_nodes_in_group("Rabbit")
		pool = stree.get_pool("Rabbit")
		for i in range(0,actors.size()):
			if(actors[i].alive == false):
				continue
			actors[i].produce_pheromon()
			var progn = true
			while(progn == true):
				progn = false
				var command = pool[i].get_iterate()
				if(command == "sniff_rabbit"):
					var following = actors[i].sniff("Pheromon_Rabbit")
					if following:
						pool[i].iterate_children(0)
					else:
						pool[i].iterate_children(1)
				elif(command == "sniff_fox"):
					var following = actors[i].sniff("Pheromon_Fox")
					if following:
						pool[i].iterate_children(0)
					else:
						pool[i].iterate_children(1)
				elif(command == "advance"):
					actors[i].advance()
					pool[i].iterate()
				elif(command == "turn_right"):
					actors[i].turn_right()
					pool[i].iterate()
				elif(command == "turn_left"):
					actors[i].turn_left()
					pool[i].iterate()
				elif(command == "progn"):
					pool[i].iterate_anchor_children(0)
					progn = true
		# Update Foxes
		actors = get_tree().get_nodes_in_group("Fox")
		pool = stree.get_pool("Fox")
		for i in range(0,actors.size()):
			actors[i].produce_pheromon()
			var repeat = true
			while(repeat == true):
				repeat = false
				var command = pool[i].get_iterate()
				if(command == "sniff_rabbit"):
					var following = actors[i].sniff("Pheromon_Rabbit")
					if following:
						pool[i].iterate_children(0)
					else:
						pool[i].iterate_children(1)
#					repeat = true
				elif(command == "sniff_fox"):
					var following = actors[i].sniff("Pheromon_Fox")
					if following:
						pool[i].iterate_children(0)
					else:
						pool[i].iterate_children(1)
#					repeat = true
				elif(command == "advance"):
					actors[i].advance()
					pool[i].iterate()
				elif(command == "turn_right"):
					actors[i].turn_right()
					pool[i].iterate()
				elif(command == "turn_left"):
					actors[i].turn_left()
					pool[i].iterate()
				elif(command == "progn"):
					pool[i].iterate_anchor_children(0)
					repeat = true
		# Decay pheromones
		for p in get_tree().get_nodes_in_group("Pheromon_Rabbit"):
			p.decay()
		for p in get_tree().get_nodes_in_group("Pheromon_Fox"):
			p.decay() 
		
		# End simulation after last turn
		if (turn >= max_turns):
			var fitness = calculate_fitness()
			if(evolve_rabbit):
				stree.crossover_pair("Rabbit", fitness[0])
				stree.mutation("Rabbit")
			if(evolve_fox):
				stree.crossover_pair("Fox", fitness[1])
				stree.mutation("Fox")
			
			delete_actors()
			add_actors_from_tilemap()
			turn = 0
			generation += 1
			emit_signal("new_generation", generation)

# Calculate fitness of the Actors; return an array with the fitness for each
# type of actor
func calculate_fitness():
	var rabbit_fitness = []
	var fox_fitness = []
	# Rabbit fitness
	var rabbits = get_tree().get_nodes_in_group("Rabbit")
	for i in range (0, rabbits.size()):
		var fitness = 10.0
		fitness += (global.MAX_SIZE_Y - rabbits[i].get_pos().y)
		fitness += rabbits[i].step_count * 2
		if(rabbits[i].alive == false):
			fitness /= 2
		rabbit_fitness.append(fitness)
	# Fox fitness
	var fox = get_tree().get_nodes_in_group("Fox")
	for i in range (0, fox.size()):
		var fitness = 10.0
		fitness += fox[i].kill_count * 300
		fitness += fox[i].step_count * 5
		fox_fitness.append(fitness)
	return [rabbit_fitness,fox_fitness]

func delete_actors():
	# Delete Actors
	var g = ["Rabbit","Fox","Pheromon_Rabbit","Pheromon_Fox","Tree"]
	for group in g:
		var nodes = get_tree().get_nodes_in_group(group)
		for node in nodes:
			node.queue_free()

# Add actors according to the tilemap placement
func add_actors_from_tilemap():
	var tileset = get_node("Actors").get_tileset()
	for cell in get_node("Actors").get_used_cells():
		var tile_name = tileset.tile_get_name(get_node("Actors").get_cell(cell.x,cell.y))
		var new_child = global.Actors[tile_name].instance()
		new_child.set_global_pos(Vector2(cell.x*20+10,cell.y*20+10))
		if(tile_name != "Tree"):
			var xflip = (get_node("Actors").is_cell_x_flipped(cell.x,cell.y))
			var yflip = (get_node("Actors").is_cell_y_flipped(cell.x,cell.y))
			var trans = (get_node("Actors").is_cell_transposed(cell.x,cell.y))
			# Don't quite understand how these properties works, though-
			# what a "transposed" cell means? Therefore, I'm just using
			# them as "bits" to change the rotation.
			if(!xflip and !yflip and !trans):
				new_child.set_direction(0)
			elif(xflip and !yflip and trans):
				new_child.set_direction(1)
			elif(xflip and yflip and !trans):
				new_child.set_direction(2)
			elif(!xflip and yflip and trans):
				new_child.set_direction(3)
			
		add_child(new_child)