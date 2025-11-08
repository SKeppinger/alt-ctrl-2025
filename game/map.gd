extends PanelContainer
class_name Map

# The notes in the song
var notes: Array[Note]
# The map width (how much time of the song is shown on screen, in seconds)
var map_width_time = 2.0
# The current time
var time = 0.0

# Convert note start time to x value on map
func get_note_x(note):
	var dt = note.start_time - time
	return (dt / 2.0) * size.x

# Convert note depth to y value on map
func get_note_y(note):
	match note.depth:
		References.Depth.NoPush:
			return 78
		References.Depth.PartialPush:
			return 78 + 252
		References.Depth.FullPush:
			return 78 + 252 + 252

# Convert note duration to note width
func get_note_width(note):
	var width = (note.duration / 2.0) * size.x
	if get_note_x(note) + width > size.x:
		return size.x - get_note_x(note)
	return width

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

func update_map(time_passed):
	time += time_passed
	queue_redraw()

# Draw notes to screen
func _draw():
	for note in notes:
		if time >= note.start_time - map_width_time and time <= note.start_time + note.duration:
			match note.type:
				References.NoteType.Trigger:
					draw_rect(Rect2(Vector2(get_note_x(note), get_note_y(note)), Vector2(get_note_width(note), 100)), Color.RED)
				References.NoteType.Switch:
					draw_circle(Vector2(get_note_x(note), get_note_y(note) + 50), 50, Color.BLUE)
			if note.connect_to_next:
				pass ## SOMEHOW connect the note to the next note's depth
