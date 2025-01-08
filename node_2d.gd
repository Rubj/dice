extends Node2D

var state_just_changed: bool = true;
var state: String = "lahing"; #"pood" | "no-input" | ...
var myDice: Array[Taring] = [];
var viskeid: int;

# Called when the node enters the scene tree for the first time.
func _ready():
	#todo load from savefile
	myDice = [Taring.new(), Taring.new(), Taring.new()];
	viskeid = 5; #todo move to battle init

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if state == "no-input":
		pass
	
	if state == "lahing":
		stateVeeretaTick(Input.is_action_just_released("click"), viskeid);
	elif state == "pood":
		statePoodTick(state_just_changed);
	#elif state ==
	
	#if state_just_changed:
	#	state_just_changed = false;


func stateVeeretaTick(vise: bool, viskeidJaanud):
	if viskeidJaanud < 1:
		state = "no-input";
		battleEnd()
		return;
	if vise:
		veereta();

func veereta():
	viskeid -= 1;
	#todo play animation
	veeretaTaringuid(myDice);

func veeretaTaringuid(ds: Array[Taring]):
	for d in ds:
		d.roll();
	print(str(ds.map(func(d): return d.current_side)) + " || viskeid jäänud: " + str(viskeid));

#func battleInit
func battleEnd():
	state_just_changed = true;
	state = "pood" #todo handle next state (map to choose?) stateHandler class


func statePoodTick(enter: bool):
	if enter:
		state_just_changed = false;
		print("astusid poodi!");
	pass
