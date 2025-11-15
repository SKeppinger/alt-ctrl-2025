extends Node2D

var serial: GdSerial
var port = "COM4" # changes based on system and whether we are using arduino serial or rs232

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	serial = GdSerial.new()
	
	serial.set_port(port)
	serial.set_baud_rate(115200)
	
	if serial.open():
		print("Controller Opened Successfully")
	else:
		print("Error: Cannot open serial port: ", port)
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input_state_str = serial.readline()
	
	if input_state_str.contains('{') and input_state_str.contains('}'):
		# packet is well formed
		input_state_str = input_state_str.substr(1, input_state_str.length()-2)
		var input_state_arr = input_state_str.split(',')
		if (input_state_arr.size() == 6):
			var button_state = bool(int(input_state_arr[0])) # True if button is pressed, false otherwise
			var switch_state = bool(int(input_state_arr[1])) # True if switch is closed, false otherwise
			var force_sensor_0_value = int(input_state_arr[2])
			var force_sensor_1_value = int(input_state_arr[3])
			var force_sensor_2_value = int(input_state_arr[4])
			var force_sensor_3_value = int(input_state_arr[5])
			
			drill_controller_states.button_state = button_state
			drill_controller_states.switch_state = switch_state
			drill_controller_states.force_sensor_0_value = force_sensor_0_value
			drill_controller_states.force_sensor_1_value = force_sensor_1_value
			drill_controller_states.force_sensor_2_value = force_sensor_2_value
			drill_controller_states.force_sensor_3_value = force_sensor_3_value
			
	print(drill_controller_states.button_state, ',', 
		  drill_controller_states.switch_state, ',', 
		  drill_controller_states.force_sensor_0_value, ',', 
		  drill_controller_states.force_sensor_1_value, ',', 
		  drill_controller_states.force_sensor_2_value, ',', 
		  drill_controller_states.force_sensor_3_value)
