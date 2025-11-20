extends Control

var press_timer = 0

func _ready():
	$Drill/Held.visible = false
	$Drill/Pressed.visible = false
	$Screw/PartialPush.visible = false
	$Screw/FullPush.visible = false

func _process(delta):
	if drill_controller_states.button_state:
		$Drill/Held.visible = true
	else:
		$Drill/Held.visible = false
	if $Drill/Pressed.visible and press_timer < 1:
		press_timer += delta
	if press_timer >= 1:
		$Drill/Pressed.visible = false
		press_timer = 0
	for child in $Screw.get_children():
		child.visible = false
	if drill_controller_states.force_sensor_0_value < 820:
		$Screw/FullPush.visible = true
	elif drill_controller_states.force_sensor_0_value < 940:
		$Screw/PartialPush.visible = true
	else:
		$Screw/NoPush.visible = true

func _on_read_serial_input_drill_press():
	$Drill/Pressed.visible = true
