extends Node

# Définition des formes et couleurs pour chaque type de pièce (tétriminos standard)
const SHAPES = {
	"I": [
		[1, 1, 1, 1]
	],
	"O": [
		[1, 1],
		[1, 1]
	],
	"T": [
		[0, 1, 0],
		[1, 1, 1]
	],
	"S": [
		[0, 1, 1],
		[1, 1, 0]
	],
	"Z": [
		[1, 1, 0],
		[0, 1, 1]
	],
	"J": [
		[1, 0, 0],
		[1, 1, 1]
	],
	"L": [
		[0, 0, 1],
		[1, 1, 1]
	]
}

const COLORS = {
	"I": Color(0, 1, 1, 1),     # Cyan
	"O": Color(1, 1, 0, 1),     # Jaune
	"T": Color(0.5, 0, 0.5, 1), # Violet
	"S": Color(0, 1, 0, 1),     # Vert
	"Z": Color(1, 0, 0, 1),     # Rouge
	"J": Color(0, 0, 1, 1),     # Bleu
	"L": Color(1, 0.5, 0, 1)    # Orange
}

# Fonction pour récupérer une pièce aléatoire
func get_random_piece():
	var keys = SHAPES.keys()
	var random_key = keys[randi() % keys.size()]
	return [SHAPES[random_key], COLORS[random_key], random_key]
