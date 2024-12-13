extends Node2D

var current_level = 0

func place_level():
	if current_level == 0:
		$level_0.enabled = true
		$level_0.visible = true
	if current_level == 1:
		$level_1.enabled = true
		$level_1.visible = true
	if current_level == 2:
		$level_2.enabled = true
		$level_2.visible = true
	if current_level == 3:
		$level_3.enabled = true
		$level_3.visible = true

func clear():
	$level_0.enabled = false
	$level_0.visible = false
	$level_1.enabled = false
	$level_1.visible = false
	$level_2.enabled = false
	$level_2.visible = false
	$level_3.enabled = false
	$level_3.visible = false
	
