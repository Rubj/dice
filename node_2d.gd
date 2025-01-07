extends Node2D

var state: String = "veereta"; #"pood" | "no-input"
var myDice: Array[Taring] = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	#todo load from savefile
	myDice = [Taring.new(), Taring.new(), Taring.new()];


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == "no-input":
		pass
	
	if state == "veereta":
		stateVeeretaTick(Input.is_action_just_released("click"));
	elif state == "pood":
		statePoodTick();
	#elif state ==

func stateVeeretaTick(vise: bool):
	if vise:
		veereta();

func veereta():
	#todo play animation
	veeretaTaringuid(myDice);

func veeretaTaringuid(ds: Array[Taring]):
	for d in ds:
		d.roll();
		print(d.current_side);

func statePoodTick():
	pass
