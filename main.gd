
extends Control

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	get_node("SimulationStage").connect("new_generation",self,"new_generation")
	pass

func new_generation(n):
	get_node("Controller/Info/Generation_Number").set_text(str(n))

func _on_Stop_pressed():
	get_node("SimulationStage").play_speed = 0


func _on_Play_pressed():
	get_node("SimulationStage").play_speed = 1


func _on_Turbo_pressed():
	get_node("SimulationStage").play_speed = 2


func _on_Mutation_Probability_Slider_value_changed( value ):
	get_node("Controller/Genetic_Parameters/Label_Mutation_Probability_Value").set_text(str(value) + "%")
	get_node("/root/stree_controller").mutation_probability = value/100


func _on_Turn_Limit_Slider_value_changed( value ):
	get_node("Controller/Genetic_Parameters/Label_Turn_Limit_Value").set_text(str(value))
	get_node("SimulationStage").max_turns = value


func _on_Evolve_Fox_toggled( pressed ):
	get_node("SimulationStage").evolve_fox = pressed


func _on_Evolve_Rabbit_toggled( pressed ):
	get_node("SimulationStage").evolve_rabbit = pressed


func _on_TreesToTxt_pressed():
	var f = File.new()
	f.open("res://Trees.txt", File.WRITE)
	
	f.store_string("Fox ================================\n\n")
	
	for t in get_node("/root/stree_controller").get_pool("Fox"):
		f.store_string(t.get_string())
		f.store_string("\n\n")
	
	f.store_string("\nRabbit: =============================\n\n")
	
	for t in get_node("/root/stree_controller").get_pool("Rabbit"):
		f.store_string(t.get_string())
		f.store_string("\n\n")
	
	f.close()