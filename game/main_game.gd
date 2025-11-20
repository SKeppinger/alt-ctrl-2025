extends Node3D

var score_val = 0
var start_timer = 3

signal trigger
signal trigger_feedback
signal screw_feedback

## TEMPORARY
func _ready():
	$UI/MapUi.load_song("res://songs/song.csv")

## TEMPORARY
func _process(delta):
	#if Input.is_action_just_pressed("trigger"):
		#trigger.emit()
	#if Input.is_action_pressed("trigger"):
		#drill_controller_states.button_state = true
	#else:
		#drill_controller_states.button_state = false
	#if Input.is_action_pressed("partial_press"):
		#drill_controller_states.force_sensor_0_value = 930
	#if Input.is_action_pressed("full_press"):
		#drill_controller_states.force_sensor_0_value = 800
	#if not Input.is_action_pressed("partial_press") and not Input.is_action_pressed("full_press"):
		#drill_controller_states.force_sensor_0_value = 1000
		#drill_controller_states.force_sensor_1_value = 1000
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
								note.hit(-1)
						References.Depth.PartialPush:
							if not drill_controller_states.is_partially_pushed():
								note.miss()
							elif not note.was_hit:
								note.hit(-1)
						References.Depth.FullPush:
							if not drill_controller_states.is_fully_pushed():
								note.miss()
							elif not note.was_hit:
								note.hit(-1)
				References.NoteType.Trigger:
					if not drill_controller_states.is_drill_held():
						note.miss()
					elif not note.was_hit:
						note.hit(-1)

func _on_drill_press():
	trigger.emit()

func _load_note(note):
	note.hit_note.connect(score)

func score(note, perfect, good, okay, early, late):
	if perfect:
		score_val += 5
	elif good:
		score_val += 3
	elif okay:
		score_val += 2
	else:
		score_val += 1
	if note.type == References.NoteType.Trigger:
		trigger_feedback.emit(perfect, good, okay, early, late)
	elif note.type == References.NoteType.Push:
		screw_feedback.emit(perfect, good, okay, early, late)

func _on_start_music(music):
	$music.stream = music
	$music.play()
