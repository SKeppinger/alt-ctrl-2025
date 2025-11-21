extends Node

var button_state : bool
var switch_state : bool

var force_sensor_0_value : int
var force_sensor_1_value : int

func is_drill_held():
	return button_state

func is_not_pushed():
	return force_sensor_0_value >= 940 and force_sensor_1_value >= 940

func is_partially_pushed():
	return (force_sensor_0_value < 940 and force_sensor_0_value >= 885) or (force_sensor_1_value < 940 and force_sensor_1_value >= 885)

func is_fully_pushed():
	return force_sensor_0_value < 885 or force_sensor_1_value < 885
