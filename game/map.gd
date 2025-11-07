extends PanelContainer
class_name Map

# The notes in the song
var notes: Array[Note]

# Load the song data from a csv file
# Line format: type, start_time, duration, depth, connect
func load_song(file_path):
	notes.clear()
	var file = FileAccess.open(file_path, FileAccess.READ)
	while not file.eof_reached():
		var note = file.get_csv_line()
		if len(note) < 5:
			print("Invalid note reached, skipping")
		else:
			var type = note[0]
			var start_time = note[1]
			var duration = note[2]
			var depth = note[3]
			var connect_to_next = note[4]
			notes.append(Note.new().load_values(type, start_time, duration, depth, connect_to_next))

# Draw notes to screen
func _draw():
	pass  # Your draw commands here.

# Draw notes to screen
func _process(_delta):
	queue_redraw()
