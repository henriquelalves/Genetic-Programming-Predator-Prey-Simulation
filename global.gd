extends Node

const TILE_SIZE = 20
const MAX_SIZE_X = 20*TILE_SIZE
const MAX_SIZE_Y = 20*TILE_SIZE

onready var Actors = {
"Fox":load("actors/Fox.scn"),
"Rabbit":load("actors/Rabbit.scn"),
"Pheromon_Fox":load("actors/Pheromon_Fox.scn"),
"Pheromon_Rabbit":load("actors/Pheromon_Rabbit.scn"),
"Tree":load("actors/Tree.scn"),
}

func _ready():
	# Create trees
	
	pass
