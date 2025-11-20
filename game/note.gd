extends Node
class_name Note

@export var type: References.NoteType
@export var start_time: float
@export var duration: float
@export var depth: References.Depth
@export var connect_to_next = false

var was_hit = false
var early = false
var late = false
var okay = false
var good = false
var perfect = false
var was_missed = false
var held_time = 0.0
var hold_scores = 0

signal hit_note

# Hit the note
func hit(time):
	if not was_hit:
		var time_difference = time - start_time
		if time == -1:
			time_difference = 100 # for held notes
		if time_difference == 100:
			perfect = false
			good = false
			okay = false
			early = false
			late = false
		elif abs(time_difference) <= 0.06:
			perfect = true
			print("perfect")
		elif abs(time_difference) <= 0.09:
			good = true
			print("good")
		elif abs(time_difference) <= 0.12:
			okay = true
			print("okay")
		else:
			if time_difference < 0:
				early = true
				print("early")
			else:
				late = true
				print("late")
		hit_note.emit(self, perfect, good, okay, early, late)
		hold_scores += 1
		was_hit = true

# Miss the note
func miss():
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
