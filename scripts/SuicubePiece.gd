extends Node2D

const CELL_SIZE = 32
var shape = []
var color = Color.WHITE
var piece_type = ""

func initialize(new_shape, new_color, new_type):
	shape = new_shape
	color = new_color
	piece_type = new_type
	queue_redraw()

func _draw():
	for y in range(len(shape)):
		for x in range(len(shape[y])):
			if shape[y][x] == 1:
				var pos = Vector2(x, y) * CELL_SIZE
				var rect = Rect2(pos, Vector2(CELL_SIZE, CELL_SIZE))
				draw_rect(rect, color)
				draw_rect(rect, Color(0, 0, 0, 1), false)

func get_shape_copy():
	return shape.duplicate()

func rotate_piece():
	var original_width = len(shape[0])
	var original_height = len(shape)

	shape = rotate_matrix(shape)

	var new_width = len(shape[0])
	var new_height = len(shape)
	
	var offset_x = float(original_width - new_width) / 2
	var offset_y = float(original_height - new_height) / 2


	position += Vector2(offset_x, offset_y) * CELL_SIZE
	queue_redraw()

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
