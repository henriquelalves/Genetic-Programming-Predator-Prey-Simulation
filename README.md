# Genetic Programming Predator Prey Simulation
A small and chaotic Genetic Programming simulation of a Predator Prey system, using Godot Engine.

The idea of the initial simulation was to explore a simple Predator and Prey environment using pheromones as a "hunting" mechanic - blue icons are the Rabbits, Red icons are the foxes.

## How to play the simulation
To play the simulation, you'll need the Godot engine (http://godotengine.org/).

1. Clone this repository.
2. Open the project with the Godot engine.
3. Play the project (F5).

The simulation window should open then. To start the simulation, press the "Play" button under the "Simulation Speed" label, on the side menu. The simulation will happen on the screen to the right.

The simulation characteristics (including Genetic settings, such as Mutation probability, and if either Foxes or Rabbits are going to evolve on the next generation) can be changed on-the-fly. To check the Genetic-Programming generated on each generation, press the "Save trees in txt" button, and check the generated "Trees.txt" file generated on the Project folder.

## About the "Rabbit Race" simulation

In this initial simulation, the "objective" of the Rabbits is to reach the top of the screen (preferably without getting caught by the foxes), while the objective of the foxes is to hunt the biggest number of rabbits possible in the time limit (50 turns is the default).

Usually, what it can be observed is that the rabbits stay as simpletons for a long time (because its very possible that at least one rabbit reach the top of the screen by simply moving forward, and therefore it is probably going to be the parent during the Fitness selection phase), while the foxes stay as simpletons during the first generations (usually under 50), until the mutation chance triggers a behavior that is responsible in "eating" a rabbit - then the foxes starts to get increasily complex, but under a very big variation (since this is a small and chaotic simulation).

## How the Genetic-Programming works

This simulation uses a full-tree generation to produce the initial random children, and for each generation, a simple Fitness-proportional selection is used to choose the parents that are going to participate in the Crossover reproduction.

The entire Genetic trees are just a String, in which the operations are performed using Godots GDScript.

One should be able to easily change the simulation and Fitness method for other tree-based Genetic-Programming simulations on the "Simulation_RabbitRace.gd". All the Genetic Programming algorithm and Syntax tree is built on the "stree_controller.gd" script (Syntax Tree Controller, the singleton responsible in controlling all Syntax tree pools and Genetic operators).