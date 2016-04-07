extends Sprite

export (String, "Rabbit", "Fox") var pheromon_type

var _decay_time = 0

func _ready():
	add_to_group("Pheromon_" + pheromon_type)
	pass

func set_decay_time(n):
	_decay_time = n

func decay():
	_decay_time -= 1
	if(_decay_time <= 0):
		queue_free()
