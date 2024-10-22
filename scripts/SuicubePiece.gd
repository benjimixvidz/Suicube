extends Node2D

# Taille des cellules
const CELL_SIZE = 32
var shape = []
var color = Color.WHITE
var piece_type = ""

# Initialiser la pièce avec une forme et une couleur
func initialize(new_shape, new_color, new_type):
	shape = new_shape
	color = new_color
	piece_type = new_type
	queue_redraw()

# Dessiner la pièce
func _draw():
	for y in range(len(shape)):
		for x in range(len(shape[y])):
			if shape[y][x] == 1:
				var pos = Vector2(x, y) * CELL_SIZE
				var rect = Rect2(pos, Vector2(CELL_SIZE, CELL_SIZE))
				draw_rect(rect, color)
				draw_rect(rect, Color(0, 0, 0, 1), false)

# Obtenir une copie de la forme de la pièce
func get_shape_copy():
	return shape.duplicate()

# Fonction pour faire tourner la pièce
func rotate_piece():
	var original_width = len(shape[0])
	var original_height = len(shape)

	# Effectuer la rotation
	shape = rotate_matrix(shape)

	# Calculer le nouveau décalage pour recentrer la pièce
	var new_width = len(shape[0])
	var new_height = len(shape)
	
	# Calculer le décalage pour maintenir la pièce centrée
	var offset_x = (original_width - new_width) / 2
	var offset_y = (original_height - new_height) / 2

	# Appliquer le décalage de position après rotation
	position += Vector2(offset_x, offset_y) * CELL_SIZE
	queue_redraw()  # Redessiner la pièce après rotation

# Fonction de rotation de la matrice représentant la pièce
# Cette fonction gère les matrices non carrées
func rotate_matrix(matrix):
	var rows = len(matrix)
	var cols = len(matrix[0])

	var new_matrix = []
	for x in range(cols):
		var new_row = []
		for y in range(rows - 1, -1, -1):
			new_row.append(matrix[y][x])
		new_matrix.append(new_row)
	return new_matrix
