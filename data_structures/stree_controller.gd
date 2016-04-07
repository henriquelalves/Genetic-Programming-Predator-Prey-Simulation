# Made by HENRIQUE ALVES
# A simple global node to control the creation of Syntax Trees (LISP-like). 

extends Node

var mutation_probability = 0.1
var _tree_pools = {}
var _function_set = []
var _terminal_set = []

# _________________________________________________________________
# Public functions

func reset():
	_tree_pools.clear()
	_function_set.clear()
	_terminal_set.clear()

func reset_pools():
	for pool in _tree_pools:
		_tree_pools[pool].clear()
	print(_tree_pools)

func add_function(function):
	var name = (function["name"])
	var n_arguments = (function["n_arguments"])
	var type_argument = Array(function["type_argument"])
	var type_function = (function["type_function"])
	_function_set.append({"name":name,"n_arguments":n_arguments,"type_argument":type_argument,"type_function":type_function})

func add_terminal(terminal):
	var value = terminal["value"]
	var type = terminal["type"]
	_terminal_set.append({"value":value,"type":type})

func add_pool(name):
	if not _tree_pools.has(name):
		_tree_pools[name] = []
	else:
		_tree_pools[name].clear()

func initialize_pool(p,population,max_depth): # Initialize trees with specified number of rabbit and fox
	if(not _tree_pools.has(p)):
		print("Error: No pool called ", p)
		return
	# Using full method of initializing the population:
	# random functions are added from the set, until max_depth
	# is reached - from where only terminals can be chosen
	
	print("\nINITIALIZING TREES\n")
	
	# Create the pool
	for n in range(0,population):
		_tree_pools[p].append(SyntaxTree.new())
	
	# For each pool, set the algorithm
	for pool in _tree_pools[p]:
		_create_tree_from_node(pool,0,max_depth)

func get_pool(pool):
	if _tree_pools.has(pool):
		return _tree_pools[pool]
	return null

func crossover(pool, fitness):
	var new_pool = []
	
	for i in range(0, _tree_pools[pool].size()):
		var individuals = _select(fitness)
		
		# Create new child:
		# Inherits from the first individual with a 
		# random crossover with the second individual
		var new_tree = SyntaxTree.new()
		new_tree.set_string(_tree_pools[pool][individuals[0]].get_string())
		
		# Get random node from the both trees
		# More chances to get a leaf from the first,
		# More chances to get a root from the second
		var random_node0 = randi()%(new_tree.get_number_nodes())
		var random_node1 = randi()%(_tree_pools[pool][individuals[1]].get_number_nodes())
		# Get that node branch string
		var random_node1_string = _tree_pools[pool][individuals[1]].get_branch_string(random_node1)
		# Exchange branches
		new_tree.replace_branch(random_node0, random_node1_string)
		
		new_pool.append(new_tree)
	
	_tree_pools[pool] = new_pool
	
	pass

func crossover_pair(pool, fitness):
	var new_pool = []
	
	for i in range(0, ceil(float(_tree_pools[pool].size())/2)):
		var individuals = _select(fitness)
		
		# Create new child:
		# Inherits from the first individual with a 
		# random crossover with the second individual
		var new_tree0 = SyntaxTree.new()
		var new_tree1 = SyntaxTree.new()
		new_tree0.set_string(_tree_pools[pool][individuals[0]].get_string())
		new_tree1.set_string(_tree_pools[pool][individuals[1]].get_string())
		
		# Get random node from the both trees
		# More chances to get a leaf from the first,
		# More chances to get a root from the second
		var random_node0 = randi()%(new_tree0.get_number_nodes())
		var random_node1 = randi()%(new_tree1.get_number_nodes())
		# Get that node branch string
		var random_node0_string = new_tree0.get_branch_string(random_node0)
		var random_node1_string = new_tree1.get_branch_string(random_node1)
		# Exchange branches
		new_tree0.replace_branch(random_node0, random_node1_string)
		new_tree1.replace_branch(random_node1, random_node0_string)
		
		new_pool.append(new_tree0)
		new_pool.append(new_tree1)
	
	_tree_pools[pool] = new_pool
	
	pass

func mutation(pool):
	for i in range(0, _tree_pools[pool].size()):
		# Test mutation probability
		var rng = randf()
		if rng > mutation_probability:
			continue
		# Choose random node from the first half ones
		var random_node = randi()%int(ceil(float(_tree_pools[pool][i].get_number_nodes())/2))
		# Create random branch
		var random_tree = SyntaxTree.new()
		_create_tree_from_node(random_tree, 0, 0)
		_tree_pools[pool][i].replace_branch(random_node,random_tree.get_branch_string(0))
	pass

# _________________________________________________________________
# Private functions

func _init():
	randomize()
	pass

# Select an integer within a range, according to a simple exponential law
func _random_exp_int(max_range):
	var prob = [1]
	for i in range(1, max_range):
		prob.append(prob[i-1]/2)
	var r = randf()
	var selected = 0
	for i in range(0, prob.size()-1):
		if r < prob[i+1]:
			selected+=1
		else:
			break
	return selected

func _random_invexp_int(max_range):
	var prob = [1]
	for i in range(1, max_range):
		prob.push_front(prob[0]/2)
	var r = randf()
	var selected = 0
	for i in range(0, prob.size()-1):
		if r > prob[i]:
			selected+=1
		else:
			break
	return selected

# Create a tree from a starting node
func _create_tree_from_node(pool,node_number,max_depth):
	# Add random root
	var random_f = (_function_set[randi()%_function_set.size()])
	pool.add_node(random_f["name"],node_number)
	
	# Full-filling algorithm
	var buffer = []
	buffer.append(random_f)
	var depth = 0
	var buffer_size = 1
	var node = node_number
	
	# Filling functions
	while(depth < max_depth):
		for i in range(0,buffer_size):
			var repeat = 1
			if(buffer[0]["n_arguments"] == 0):
				repeat += randi()%3
			while(repeat > 0):
				for type in buffer[0]["type_argument"]:
					# Create candidates and choose one
					var candidates = []
					for candidate in _function_set:
						if candidate["type_function"].match(type):
							candidates.append(candidate)
					random_f = candidates[randi()%candidates.size()]
					buffer.push_back(random_f)
					pool.add_node(random_f["name"],node)
				repeat -= 1
			node += 1
			buffer.remove(0)
		depth += 1
		buffer_size = buffer.size()
	
	# Filling terminals
	for i in range(0,buffer_size):
		var repeat = 1
		if(buffer[i]["n_arguments"] == 0):
			repeat += randi()%3
		while(repeat > 0):
			for type in buffer[i]["type_argument"]:
				# Create candidates and choose one
				var candidates = []
				for candidate in _terminal_set:
					if candidate["type"].match(type):
						candidates.append(candidate)
				random_f = candidates[randi()%candidates.size()]
				pool.add_node(random_f["value"],node)
			repeat -= 1
		node += 1
	print(pool.get_string())

# Fitness proportional selection
# Returns a vector with the chosen two individuals
func _select(fit):
	
	var fitness = Array(fit)
	
	var total_fitness = 0
	var individuals = []
	# Calculate total fitness and selection probability array
	for f in fitness:
		total_fitness += f
	var selection_array = [fitness[0]/total_fitness]
	for i in range(1, fitness.size()):
		selection_array.append((fitness[i]/total_fitness)+selection_array[i-1])
	# Select two individuals
	
	var r1 = randf()
	var r2 = randf()
	
	# First individual
	var individual = 0
	for i in range(0, fitness.size()-1):
		if selection_array[i] < r1:
			individual += 1
		else:
			break
	individuals.append(individual)
	
	# Second individual; should not be the same
	var same = true
	while(same):
		same = false
		var individual = 0
		for i in range(0, fitness.size()-1):
			if selection_array[i] < r2:
				individual += 1
			else:
				break
		if (individual == individuals[0]):
			same = true
			r2 = randf()
		else:
			individuals.append(individual)
	
	return individuals

# =================================================================
# ======================= Tree subclass ===========================
# =================================================================
# e.g. (RootFunction(terminal1)(Function(terminal2)))
class SyntaxTree:
	var _tree_string = ""
	var _iterator = [1]
	
	func get_iterate():
		return get_node_string_pos(_iterator[0])
	
	func get_iterate_children():
		return _get_node_children(_iterator[0])
	
	func iterate():
		_iterator.remove(0)
		if _iterator.empty(): # Reset to root
			_iterator.push_back(1)
	
	func iterate_children(n):
		var children = _get_node_children(_iterator[0])
		_iterator.remove(0)
		_iterator.insert(0,children[n])
	
	func iterate_anchor_children(n):
		var children = _get_node_children(_iterator[0])
		_iterator.remove(0)
		for n in range(0,children.size()):
			_iterator.insert(n,children[n])
	
	func set_string(s):
		_tree_string = String(s)
	
	func get_string():
		return _tree_string
	
	func get_number_nodes():
		var pos = 0
		var n = 0
		pos = _tree_string.findn("(",pos)
		while(pos != -1):
			n+=1
			pos = _tree_string.findn("(",pos+1)
		return n
	
	func add_node(node, parent):
		if _tree_string.empty():
			_tree_string = "(" + node + ")"
			return
		
		var pos_parent = _get_node_pos(parent)
		
		var child_pos = 0
		if (_is_terminal(pos_parent) == 1):
			child_pos = _tree_string.findn(")", pos_parent)
			_tree_string = _tree_string.left(child_pos) + "(" + node + ")" + _tree_string.right(child_pos)
		else:
			child_pos = _tree_string.findn("(", pos_parent)
			while(_tree_string[child_pos] != ")"):
				child_pos += 1
				child_pos = _jump_branch(child_pos)
			_tree_string = _tree_string.left(child_pos) + "(" + node + ")" + _tree_string.right(child_pos)
		return 
	
	func get_node_string(n):
		var pos = _get_node_pos(n)
		var l_pos = pos
		while(_tree_string[l_pos] != "(" and _tree_string[l_pos] != ")"):
			l_pos+=1
		return _tree_string.substr(pos,l_pos-pos)
	
	func get_node_string_pos(pos):
		var l_pos = pos
		while(_tree_string[l_pos] != "(" and _tree_string[l_pos] != ")"):
			l_pos+=1
		return _tree_string.substr(pos,l_pos-pos)
	
	func get_branch_string(n):
		var pos = _get_node_pos(n)
		var end_pos = _jump_branch(pos) - 1
		return _tree_string.substr(pos,end_pos-pos)
	
	func replace_branch(n, new_branch):
		var pos = _get_node_pos(n)
		var end_pos = _jump_branch(pos) - 1
		_tree_string = _tree_string.left(pos) + _tree_string.right(end_pos)
		_tree_string = _tree_string.insert(pos,new_branch)
	
	# Breadth first search position
	func _get_node_pos(n):
		if(_tree_string.empty()):
			print("Error: Tree is empty.")
			return -1
		
		if(n == 0):
			return 1
		
		var buffer = [1]
		var depth = 0
		var layer_size = 1
		
		var total = 0
		
		while(n > total + buffer.size()-1):
			
			for i in range(0,layer_size):
				for c in _get_node_children(buffer[0]):
					buffer.append(c)
				buffer.remove(0)
			total += layer_size
			layer_size = buffer.size()
		return buffer[n - total]

	func _is_terminal(pos):
#		print(_tree_string[pos])
		while(_tree_string[pos] != ")" and _tree_string[pos] != "("):
			pos+=1
		if(_tree_string[pos] == ")"):
			return 1 # Terminal
		else:
			return 0 # Function
	
	func _get_node_children(pos):
		var children = []
		if(_is_terminal(pos) == 1):
			return children
		pos = _tree_string.findn("(",pos)
		while(_tree_string[pos] != ")"):
			pos += 1
			children.append(pos)
			pos = _jump_branch(pos)
		return children
	
	func _jump_branch(pos):
		if(_is_terminal(pos) == 1):
			return _tree_string.findn(")", pos) + 1
		pos = _tree_string.findn("(", pos)
		var numb = 1
		while(numb >= 0):
			pos += 1
			if(_tree_string[pos] == "("):
				numb += 1
			elif(_tree_string[pos] == ")"):
				numb -= 1
		return pos+1