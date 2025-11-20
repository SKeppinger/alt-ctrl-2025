extends Panel
class_name Map

# The notes in the song
var notes: Array[Note]
# The map width (how much time of the song is shown on screen, in seconds)
var map_width_time = 2.0
# The map width (how much of the panel represents the above time)
var map_width_size = size.y - 150
# The current time
var time = 0.0
# The margin of error for input in seconds
var margin = 0.1
# The width of a note for no screw push
var no_push_width = 180
# The width of a note for partial screw push
var partial_push_width = 240
# The width of a note for full screw push
var full_push_width = 560

# The rails texture
var rails_text = preload("res://assets/rails.png")
# Trigger note texture
var trigger_note = preload("res://assets/note_circle.png")
# Trigger held note texture
var trigger_hold_note = preload("res://assets/note_rectangle_short_flat.png")
# Screw note texture
var screw_note = preload("res://assets/note_red.png")
# Screw held note texture
var screw_note_hold = preload("res://assets/note_rectangle_long_flat_red.png")

signal load_note

# Get the notes that should currently be held (push inputs are followed by depth)
func get_held_notes():
	var held_notes = []
	for note in notes:
		if (note.was_hit or note.hold_scores > 0) and (time > note.start_time and time < note.start_time + note.duration - margin) and note.duration > 0.25:
			if not note.was_missed:
				held_notes.append(note)
	return held_notes

# Convert note start time to y value on map
func get_note_y(note):
	#if time > note.start_time:
		#return map_width_size
	var dt = note.start_time - time
	return map_width_size - ((dt / map_width_time) * map_width_size)

# Convert note duration to note width
func get_note_width(note):
	var width = (note.duration / map_width_time) * map_width_size
	#if time > note.start_time:
		#width -= (((time - note.start_time) / map_width_time) * map_width_size)
	#if get_note_y(note) - width < 0:
		#return get_note_y(note)
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
	# Draw rails
	draw_texture_rect(rails_text, Rect2(0, 0, size.x, size.y), false)
	# Draw notes
	for note in notes:
		if not note.was_missed:
			if time >= note.start_time - map_width_time and time <= note.start_time + note.duration + 1:
				match note.type:
					References.NoteType.Push:
						var text = screw_note
						if note.duration > 0.25:
							text = screw_note_hold
						match note.depth:
							References.Depth.NoPush:
								draw_texture_rect(text, Rect2(Vector2((size.x / 2) - (no_push_width / 2), get_note_y(note) - (get_note_width(note))), Vector2(no_push_width, -1 * get_note_width(note))), false)
							References.Depth.PartialPush:
								draw_texture_rect(text, Rect2(Vector2((size.x / 2) - (partial_push_width / 2), get_note_y(note) - (get_note_width(note))), Vector2(partial_push_width, -1 * get_note_width(note))), false)
							References.Depth.FullPush:
								draw_texture_rect(text, Rect2(Vector2((size.x / 2) - (full_push_width / 2), get_note_y(note) - (get_note_width(note))), Vector2(full_push_width, -1 * get_note_width(note))), false)
					References.NoteType.Trigger:
						if note.duration <= 0.25:
							draw_texture_rect(trigger_note, Rect2(Vector2((size.x / 2) - 58, get_note_y(note) - (get_note_width(note))), Vector2(116, 116)), false)
						else:
							draw_texture_rect(trigger_hold_note, Rect2(Vector2((size.x / 2) - 40, get_note_y(note) - (get_note_width(note))), Vector2(80, -1 * get_note_width(note))), false)
					References.NoteType.Switch:
						draw_circle(Vector2(350, get_note_y(note) - 100), 50, Color.GREEN)
				if note.connect_to_next:
					pass ## SOMEHOW connect the note to the next note's depth

# Check screw depth
func _process(_delta):
	for note in notes:
		if time > note.start_time - margin and time < note.start_time + margin:
			if note.type == References.NoteType.Push and note.depth == References.Depth.FullPush and not note.was_hit:
				if drill_controller_states.is_fully_pushed():
					note.hit()
					return
			elif note.type == References.NoteType.Push and note.depth == References.Depth.PartialPush and not note.was_hit:
				if drill_controller_states.is_partially_pushed():
					note.hit()
					return
			elif note.type == References.NoteType.Push and note.depth == References.Depth.NoPush and not note.was_hit:
				if drill_controller_states.is_not_pushed():
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
