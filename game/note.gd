extends Node
class_name Note

@export var type: References.NoteType
@export var start_time: float
@export var duration: float
@export var depth: References.Depth
@export var connect_to_next = false

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
