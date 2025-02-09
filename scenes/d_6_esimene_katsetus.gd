class_name D6
extends MeshInstance3D

# Nodes
#const self_scene = preload("res://scenes/d6.tscn")

# Members
#@export var dice_id: int

#static func constructor(id: int = 0)-> MeshInstance3D:
#	var obj = self_scene.instantiate()
#	obj.dice_id = id
#	return obj

var my_index: int;
var mouse_is_on: bool = false;
var is_selected: bool = true;
var outline: MeshInstance3D;

# Called when the node enters the scene tree for the first time.
func _ready():
	outline = get_node("outline");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_static_body_3d_input_event(camera, event, event_position, normal, shape_idx):
	#print(event)
	pass

func _on_static_body_3d_mouse_entered():
	mouseOn(true);

func _on_static_body_3d_mouse_exited():
	mouseOn(false);

func mouseOn(v: bool):
	mouse_is_on = v;
	var d = -1;
	if v: d = my_index;
	get_parent().mouseOnDiceIndex = d;
	#if v: print(d);
	if is_selected: return;

	outline.set_visible(v);

func setSelected(v: bool):
	outline.set_visible(v);
	#todo glow for selected
	is_selected = v;

func toggleSelected():
	is_selected = !is_selected;
	outline.set_visible(is_selected);
