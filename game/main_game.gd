extends Node3D

## TEMPORARY
func _ready():
	$UI/MapUi.load_song("res://songs/song.csv")

## TEMPORARY
func _process(delta):
	$UI/MapUi.update_map(delta)
