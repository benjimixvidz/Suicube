extends Node2D

const GRID_WIDTH = 10
const GRID_HEIGHT = 20
const CELL_SIZE = 32

var grid = []
var current_piece = null
var piece_spawner = preload("res://scripts/SuicubeShapes.gd")  # Précharger le script

# Instance de SuicubeShapes
var shapes_instance

# Temps entre les chutes des pièces
var fall_time = 0.5
var fall_timer = 0.0

# Variable pour la pause du jeu
var is_paused = false

# Variables pour le déplacement horizontal continu
var move_left_timer = 0.0
var move_right_timer = 0.0
var move_delay = 0.2  # Délai initial avant le déplacement continu
var move_rate = 0.05  # Intervalle entre les mouvements continus

# Initialiser le jeu
func _ready():
	randomize()  # Initialise le générateur aléatoire
	initialize_grid()

	# Créer une instance de SuicubeShapes
	shapes_instance = piece_spawner.new()
	
	spawn_new_piece()
	
	# Réinitialiser le score si nécessaire
	Global.score = 0

# Créer la grille
func initialize_grid():
	grid = []
	for y in range(GRID_HEIGHT):
		var row = []
		for x in range(GRID_WIDTH):
			row.append(null)
		grid.append(row)
		
func _draw():
	# Dessiner les cellules de la grille avec ou sans pièce
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var rect = Rect2(Vector2(x, y) * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE))
			if grid[y][x] != null:
				draw_rect(rect, grid[y][x])  # Dessiner la cellule avec la couleur de la pièce
			else:
				draw_rect(rect, Color(0.1, 0.1, 0.1, 1))  # Couleur de fond de la grille
			draw_rect(rect, Color(0.8, 0.8, 0.8, 1), false)  # Bordure de la cellule

# Générer une nouvelle pièce
func spawn_new_piece():
	current_piece = preload("res://scripts/SuicubePiece.gd").new()
	var shape_data = shapes_instance.get_random_piece()
	current_piece.initialize(shape_data[0], shape_data[1], shape_data[2])
	add_child(current_piece)

	# Calculer la largeur de la pièce
	var piece_width = len(current_piece.shape[0])
	
	# Positionner la pièce horizontalement au centre de la grille
	current_piece.position = Vector2(int((GRID_WIDTH - piece_width) / 2) * CELL_SIZE, 0)
	
	# Vérifier si la position initiale est valide
	if not is_valid_position():
		print("Game Over")
		# Vous pouvez afficher un écran de fin de jeu ici
		current_piece.queue_free()
		current_piece = null
		restart_game()

# Fonction principale de gestion des entrées utilisateur
func _process(delta):
	handle_input(delta)  # Toujours appeler handle_input
	if is_paused:
		return
	if current_piece != null:
		handle_fall(delta)
	queue_redraw()  # Forcer le redessin de la grille et des éléments

# Gérer la chute de la pièce avec le temps
func handle_fall(delta):
	fall_timer += delta
	if fall_timer >= fall_time:
		fall_timer = 0
		if not move_piece(Vector2(0, 1)):
			lock_piece()
			check_lines()
			spawn_new_piece()

# Gérer les entrées utilisateur
func handle_input(delta):
	# Pause du jeu (toujours traitée)
	if Input.is_action_just_pressed("pause_game"):
		is_paused = not is_paused
		return  # Ne pas traiter d'autres entrées lors de ce tick

	if is_paused:
		return  # Si le jeu est en pause, ignorer les autres entrées

	# Déplacement vers la gauche
	if Input.is_action_just_pressed("ui_left"):
		move_piece(Vector2(-1, 0))
		move_left_timer = -move_delay  # Commence le délai initial
	elif Input.is_action_pressed("ui_left"):
		move_left_timer += delta
		if move_left_timer >= move_rate:
			move_piece(Vector2(-1, 0))
			move_left_timer = 0.0  # Réinitialise le timer après chaque déplacement
	else:
		move_left_timer = 0.0  # Réinitialise si la touche n'est pas pressée

	# Déplacement vers la droite
	if Input.is_action_just_pressed("ui_right"):
		move_piece(Vector2(1, 0))
		move_right_timer = -move_delay  # Commence le délai initial
	elif Input.is_action_pressed("ui_right"):
		move_right_timer += delta
		if move_right_timer >= move_rate:
			move_piece(Vector2(1, 0))
			move_right_timer = 0.0  # Réinitialise le timer après chaque déplacement
	else:
		move_right_timer = 0.0  # Réinitialise si la touche n'est pas pressée

	# Descente instantanée
	if Input.is_action_pressed("ui_down"):
		if not move_piece(Vector2(0, 1)):
			lock_piece()
			check_lines()
			spawn_new_piece()

	# Rotation de la pièce
	if Input.is_action_just_pressed("ui_up"):
		rotate_current_piece()

	# Descente rapide (touche Espace)
	if Input.is_action_just_pressed("ui_select"):
		while move_piece(Vector2(0, 1)):
			pass
		lock_piece()
		check_lines()
		spawn_new_piece()

	# Redémarrage du jeu
	if Input.is_action_just_pressed("restart_game"):
		restart_game()

# Déplacer la pièce
func move_piece(direction):
	if current_piece != null:
		current_piece.position += direction * CELL_SIZE
		if not is_valid_position():
			current_piece.position -= direction * CELL_SIZE
			return false
		return true
	return false

# Vérifier si la position actuelle de la pièce est valide
func is_valid_position():
	if current_piece == null:
		return false

	for y in range(len(current_piece.shape)):
		for x in range(len(current_piece.shape[y])):
			if current_piece.shape[y][x] == 1:
				var grid_x = int(current_piece.position.x / CELL_SIZE) + x
				var grid_y = int(current_piece.position.y / CELL_SIZE) + y

				# Vérifier les bords de la grille
				if grid_x < 0 or grid_x >= GRID_WIDTH or grid_y >= GRID_HEIGHT:
					return false

				# Vérifier les collisions avec d'autres pièces dans la grille
				if grid_y >= 0 and grid[grid_y][grid_x] != null:
					return false

	return true

# Verrouiller la pièce en place et mettre à jour la grille
func lock_piece():
	for y in range(len(current_piece.shape)):
		for x in range(len(current_piece.shape[y])):
			if current_piece.shape[y][x] == 1:
				var grid_x = int(current_piece.position.x / CELL_SIZE) + x
				var grid_y = int(current_piece.position.y / CELL_SIZE) + y

				if grid_y < 0:
					# Le bloc est au-dessus de la grille visible
					print("Game Over")
					remove_child(current_piece)
					current_piece.queue_free()
					current_piece = null
					restart_game()
					return  # Arrêter l'exécution de la fonction
				elif grid_y < GRID_HEIGHT and grid_x >= 0 and grid_x < GRID_WIDTH:
					grid[grid_y][grid_x] = current_piece.color

	remove_child(current_piece)
	current_piece.queue_free()
	current_piece = null

# Vérifier et supprimer les lignes complètes
func check_lines():
	var lines_cleared = 0

	for y in range(GRID_HEIGHT - 1, -1, -1):
		if null not in grid[y]:
			remove_line(y)
			lines_cleared += 1
			y += 1  # Re-vérifier la même ligne après le décalage

	if lines_cleared > 0:
		update_score(lines_cleared)

# Supprimer une ligne et décaler les lignes au-dessus
func remove_line(line):
	for y in range(line, 0, -1):
		grid[y] = grid[y - 1]
	# Vider la première ligne
	grid[0] = []
	for x in range(GRID_WIDTH):
		grid[0].append(null)

# Mettre à jour le score lorsque des lignes sont supprimées
func update_score(lines_cleared):
	var points = 0
	match lines_cleared:
		1: points = 100
		2: points = 300
		3: points = 500
		4: points = 800
	Global.score += points
	print("Score: ", Global.score)  # Remplacez par une mise à jour de l'interface utilisateur

# Redémarrer le jeu
func restart_game():
	get_tree().change_scene("res://GameOver.tscn")

# Faire tourner la pièce en vérifiant la validité
func rotate_current_piece():
	if current_piece != null:
		var old_shape = current_piece.get_shape_copy()
		var old_position = current_piece.position
		current_piece.rotate_piece()

		# Ajuster la position si nécessaire
		adjust_position_after_rotation()

		if not is_valid_position():
			# Annuler la rotation si la position n'est pas valide
			current_piece.shape = old_shape
			current_piece.position = old_position
			current_piece.queue_redraw()

# Ajuster la position de la pièce après la rotation pour éviter les débordements
func adjust_position_after_rotation():
	var piece_width = len(current_piece.shape[0])
	var piece_height = len(current_piece.shape)

	var grid_x = int(current_piece.position.x / CELL_SIZE)
	var grid_y = int(current_piece.position.y / CELL_SIZE)

	# Ajuster si la pièce dépasse à gauche
	if grid_x < 0:
		current_piece.position.x -= grid_x * CELL_SIZE

	# Ajuster si la pièce dépasse à droite
	if grid_x + piece_width > GRID_WIDTH:
		current_piece.position.x -= (grid_x + piece_width - GRID_WIDTH) * CELL_SIZE

	# Ajuster si la pièce dépasse en bas
	if grid_y + piece_height > GRID_HEIGHT:
		current_piece.position.y -= (grid_y + piece_height - GRID_HEIGHT) * CELL_SIZE
