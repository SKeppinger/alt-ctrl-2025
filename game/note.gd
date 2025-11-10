extends Node
class_name Note

@export var type: References.NoteType
@export var start_time: float
@export var duration: float
@export var depth: References.Depth
@export var connect_to_next = false

var was_hit = false
var was_missed = false
var held_time = 0.0
var hold_scores = 0

signal hit_note

# Hit the note
func hit():
	print("hit!")
	hit_note.emit()
	hold_scores += 1
	was_hit = true

# Miss the note
func miss():
	print("miss!")
	hold_scores = 0
	was_missed = true

# Parse string values and return self
func load_values(t, st, dur, dep, con):
	# Note type
	match t:
		"Trigger":
			type = References.NoteType.Trigger
		"Switch":
			type = References.NoteType.Switch
	# Start time
	start_time = float(st)
	# Duration
	duration = float(dur)
	# Depth
	match dep:
		"NoPush":
			depth = References.Depth.NoPush
		"PartialPush":
			depth = References.Depth.PartialPush
		"FullPush":
			depth = References.Depth.FullPush
	# Connect to next
	match con:
		"true":
			connect_to_next = true
		"false":
			connect_to_next = false
	return self
