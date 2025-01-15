class_name Taring

var sides: int = 6 #todo replace with side_values: Array[int]
var modifiers = null #todo
var current_side = 0; #side = value?

func roll() -> int:
	current_side = randi_range(1, sides);
	return current_side;

func reset() -> void:
	current_side = 0;
