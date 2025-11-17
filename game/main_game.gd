extends Node3D

var score_val = 0

signal partial_press
signal full_press
signal switch
signal trigger

## TEMPORARY
func _ready():
	$UI/MapUi.load_song("res://songs/song.csv")

## TEMPORARY
func _process(delta):
	$UI/MapUi.update_map(delta, score_val)
	# Initial note hits
	if Input.is_action_just_pressed("partial_press"):
		partial_press.emit()
	if Input.is_action_just_pressed("full_press"):
		full_press.emit()
	if Input.is_action_just_pressed("switch"):
		switch.emit()
	if Input.is_action_just_pressed("trigger"):
		trigger.emit()
	# Note holds
	for note in $UI/MapUi.get_held_notes():
		if not note.was_missed:
			match note.type:
				References.NoteType.Push:
					match note.depth:
						References.Depth.NoPush:
							if Input.is_action_pressed("full_press") or Input.is_action_pressed("partial_press"):
								note.miss()
							elif not note.was_hit:
								note.hit()
						References.Depth.PartialPush:
							if not Input.is_action_pressed("partial_press"):
								note.miss()
							elif not note.was_hit:
								note.hit()
						References.Depth.FullPush:
							if not Input.is_action_pressed("full_press"):
								note.miss()
							elif not note.was_hit:
								note.hit()
				References.NoteType.Trigger:
					if not Input.is_action_pressed("trigger"):
						note.miss()
					elif not note.was_hit:
						note.hit()

func _on_drill_press():
	trigger.emit()

func _load_note(note):
	note.hit_note.connect(score)

func score():
	score_val += 1 ## TEMPORARY
