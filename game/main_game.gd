extends Node3D

var score_val = 0
var start_timer = 3

signal trigger

## TEMPORARY
func _ready():
	$UI/MapUi.load_song("res://songs/song.csv")

## TEMPORARY
func _process(delta):
	if start_timer > -1:
		start_timer -= delta
		if start_timer <= 3 and start_timer > 2:
			$UI/MapUi/Timer.text = "3"
		elif start_timer <= 2 and start_timer > 1:
			$UI/MapUi/Timer.text = "2"
		elif start_timer <= 1 and start_timer > 0:
			$UI/MapUi/Timer.text = "1"
		elif start_timer > -1:
			$UI/MapUi/Timer.text = "GO!"
	else:
		$UI/MapUi/Timer.text = ""
		$UI/MapUi.update_map(delta, score_val)
	# Note holds
	for note in $UI/MapUi.get_held_notes():
		if not note.was_missed:
			match note.type:
				References.NoteType.Push:
					match note.depth:
						References.Depth.NoPush:
							if not drill_controller_states.is_not_pushed():
								note.miss()
							elif not note.was_hit:
								note.hit()
						References.Depth.PartialPush:
							if not drill_controller_states.is_partially_pushed():
								note.miss()
							elif not note.was_hit:
								note.hit()
						References.Depth.FullPush:
							if not drill_controller_states.is_fully_pushed():
								note.miss()
							elif not note.was_hit:
								note.hit()
				References.NoteType.Trigger:
					if not drill_controller_states.is_drill_held():
						note.miss()
					elif not note.was_hit:
						note.hit()

func _on_drill_press():
	trigger.emit()

func _load_note(note):
	note.hit_note.connect(score)

func score():
	score_val += 1 ## TEMPORARY
