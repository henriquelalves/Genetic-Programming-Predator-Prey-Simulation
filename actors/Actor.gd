extends Sprite

export (String, "Rabbit", "Fox") var actor_type = "Fox"
export (float) var pheromon_decay

# ======= Constants =========

const DIRECTION = {
"UP":0,
"RIGHT":1,
"DOWN":2,
"LEFT":3,
}

const SNIFF = {
"FOX":0,
"RABBIT":1,
}

# =========== Variables ==============
onready var alive = true
onready var kill_count = 0
onready var step_count = 0

onready var _current_direction
onready var _matrix
onready var _alive = true
onready var _alive_tick = 0
onready var _global = get_node("/root/global")

# =========== Actions ==================
# Move actor in a direction
func advance():
	var vec
	if(_current_direction == DIRECTION["UP"]):
		vec = (get_pos()-Vector2(0,_global.TILE_SIZE))
	elif(_current_direction == DIRECTION["RIGHT"]):
		vec = (get_pos()+Vector2(_global.TILE_SIZE,0))
	elif(_current_direction == DIRECTION["DOWN"]):
		vec = (get_pos()+Vector2(0,_global.TILE_SIZE))
	elif(_current_direction == DIRECTION["LEFT"]):
		vec = (get_pos()-Vector2(_global.TILE_SIZE,0))
	
	if(!_check_actor_pos(vec, actor_type) and !_check_actor_pos(vec, "Tree") and _inbounds(vec)):
		set_pos(vec)
		step_count += 1
	
	if(actor_type == "Rabbit"):
		var ref = []
		if(_check_actor_pos(get_pos(), "Fox", ref)):
			kill()
			ref[0].kill_count += 1
	elif(actor_type == "Fox"):
		var ref = []
		if(_check_actor_pos(get_pos(), "Rabbit", ref)):
			ref[0].kill()
			kill_count += 1

# Produce a pheromon node, belonging to this actor type
func produce_pheromon():
	var pheromon
	if(actor_type == "Fox"):
		pheromon = _global.Actors["Pheromon_Fox"].instance()
	else:
		pheromon = _global.Actors["Pheromon_Rabbit"].instance()
	get_parent().add_child(pheromon)
	pheromon.set_pos(get_pos())
	pheromon.set_decay_time(pheromon_decay)

# Check if it is following pheromon trail
func sniff(pheromon):
	var vec
	if(_current_direction == DIRECTION["UP"]):
		vec = (get_pos()-Vector2(0,_global.TILE_SIZE))
	elif(_current_direction == DIRECTION["RIGHT"]):
		vec = (get_pos()+Vector2(_global.TILE_SIZE,0))
	elif(_current_direction == DIRECTION["DOWN"]):
		vec = (get_pos()+Vector2(0,_global.TILE_SIZE))
	elif(_current_direction == DIRECTION["LEFT"]):
		vec = (get_pos()-Vector2(_global.TILE_SIZE,0))
	
	var pheromon_front = _get_pheromon_pos(vec, pheromon)
	var pheromon_current = _get_pheromon_pos(get_pos(),pheromon)
	if pheromon_front > pheromon_current:
		return true
	return false

# Set an specific direction
func set_direction(direction):
	_current_direction = direction
	if _current_direction == DIRECTION["UP"]:
		set_rot(0)
	elif _current_direction == DIRECTION["RIGHT"]:
		set_rot(3*PI/2)
	elif _current_direction == DIRECTION["DOWN"]:
		set_rot(PI)
	elif _current_direction == DIRECTION["LEFT"]:
		set_rot(PI/2)

# Rotate the Actor
func turn_left():
	set_direction((_current_direction+3)%4)

func turn_right():
	set_direction((_current_direction+1)%4)

# Prey got killed
func kill():
	hide()
	alive = false

# ============= Private functions ================
func _ready():
	add_to_group(actor_type)
	if(_current_direction == null):
		set_direction(DIRECTION["UP"])
	pass

func _inbounds(pos):
	if pos.x >= 0 and pos.x <= _global.MAX_SIZE_X and pos.y >= 0 and pos.y <= _global.MAX_SIZE_Y:
		return true
	return false

func _check_actor_pos(pos, type, ref = null):
	var group = get_tree().get_nodes_in_group(type)
	for actor in group:
		if actor.alive == true and actor.get_pos() == pos:
			if (ref != null):
				ref.push_back(actor)
			return true
	return false

func _get_pheromon_pos(pos,pheromon):
	var ret = 0
	for p in get_tree().get_nodes_in_group(pheromon):
		if p.get_pos() == pos:
			ret = p._decay_time
			break
	return ret