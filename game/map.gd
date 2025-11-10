extends Panel
class_name Map

# The notes in the song
var notes: Array[Note]
# The map width (how much time of the song is shown on screen, in seconds)
var map_width_time = 2.0
# The map width (how much of the panel represents the above time)
var map_width_size = size.x - 50
# The current time
var time = 0.0
# The margin of error for input in seconds
var margin = 0.1

signal load_note

# Get the notes that should currently be held (push inputs are followed by depth)
func get_held_notes():
	var held_notes = []
	for note in notes:
		if (note.was_hit or note.hold_scores > 0) and (time > note.start_time and time < note.start_time + note.duration - margin) and note.duration > 0.25:
			if not note.was_missed:
				held_notes.append(note)
	return held_notes

# Convert note start time to x value on map
func get_note_x(note):
	if time > note.start_time:
		return 50
	var dt = note.start_time - time
	return ((dt / map_width_time) * map_width_size) + 50

# Convert note depth to y value on map
func get_note_y(note):
	var y = 78
	match note.depth:
		References.Depth.PartialPush:
			y += 252
		References.Depth.FullPush:
			y += 504
	if note.type == References.NoteType.Trigger:
		y += 25
	return y

# Convert note duration to note width
func get_note_width(note):
	var width = (note.duration / map_width_time) * map_width_size
	if time > note.start_time:
		width -= (((time - note.start_time) / map_width_time) * map_width_size)
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
			var note_node = Note.new().load_values(type, start_time, duration, depth, connect_to_next)
			notes.append(note_node)
			load_note.emit(note_node)

func update_map(time_passed, new_score):
	time += time_passed
	for note in notes:
		if not note.was_missed and not note.was_hit and time > note.start_time + margin:
			note.miss()
	for note in get_held_notes():
		note.held_time = time - note.start_time
		if note.held_time >= 0.25 * note.hold_scores:
			note.was_hit = false
	$Score.text = "Score: " + str(new_score)
	queue_redraw()

# Draw notes to screen
func _draw():
	for note in notes:
		if not note.was_missed and not (note.was_hit and note.duration <= 0.25):
			if time >= note.start_time - map_width_time and time <= note.start_time + note.duration:
				match note.type:
					References.NoteType.Push:
						draw_rect(Rect2(Vector2(get_note_x(note), get_note_y(note)), Vector2(get_note_width(note), 100)), Color.RED)
					References.NoteType.Trigger:
						draw_rect(Rect2(Vector2(get_note_x(note), get_note_y(note)), Vector2(get_note_width(note), 50)), Color.BLUE)
					References.NoteType.Switch:
						draw_circle(Vector2(get_note_x(note), get_note_y(note) + 50), 50, Color.GREEN)
				if note.connect_to_next:
					pass ## SOMEHOW connect the note to the next note's depth
	draw_line(Vector2(50, 0), Vector2(50, 760), Color.WHITE)

# Catch a full press input
func _on_full_press():
	for note in notes:
		if time > note.start_time - margin and time < note.start_time + margin:
			if note.type == References.NoteType.Push and note.depth == References.Depth.FullPush and not note.was_hit:
				note.hit()
				return

# Catch a partial press input
func _on_partial_press():
	for note in notes:
		if time > note.start_time - margin and time < note.start_time + margin:
			if note.type == References.NoteType.Push and note.depth == References.Depth.PartialPush and not note.was_hit:
				note.hit()
				return

# Catch a trigger input
func _on_trigger():
	for note in notes:
		if time > note.start_time - margin and time < note.start_time + margin:
			if note.type == References.NoteType.Trigger and not note.was_hit:
				note.hit()
				return

# Catch a switch input
func _on_switch():
	for note in notes:
		if time > note.start_time - margin and time < note.start_time + margin:
			if note.type == References.NoteType.Switch and not note.was_hit:
				note.hit()
				return
