extends Node3D

var state_just_changed: bool = true;
enum St {NoInput,Veereta,YourTurn,EnemyTurn,Pood,Vali, Test};
var state: St = St.Veereta;
var myDice: Array[Taring] = []; #todo replace with var diceInHand: Array[Taring];
var taringud: Array[MeshInstance3D] = [];#taringud laual todo ilusam godot ref
var viskeid: int;
var battleScene: Node3D;
@onready var D6: PackedScene = preload("res://scenes/d6.tscn");

# Called when the node enters the scene tree for the first time.
func _ready():
	#todo load from savefile
	myDice = [Taring.new(), Taring.new(), Taring.new(), Taring.new(), Taring.new()]; #5d6
	viskeid = 5; #todo move to battle init add_child(battleScene.instantiate());
	battleScene = get_node("Battle");
	
	#todo remove if starting with empty board and test dice removed
	var taringD6: MeshInstance3D = battleScene.get_node("D6");
	battleScene.remove_child(taringD6);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if state in [St.NoInput]:
		pass

	if state == St.Veereta:
		if (state_just_changed):
			#add_child(battleScene);
			battleScene.set_visible(true);
			state_just_changed = false;
		stateVeeretaTick(Input.is_action_just_released("click"), viskeid);
	elif state == St.Vali:
		if (state_just_changed): state_just_changed = false; #todo state change handler
		if (Input.is_action_just_released("enter")):
			endTurn();
		elif (Input.is_action_just_pressed("click") && battleScene.mouseOnDiceIndex > -1): #&& mouse coordinates
			var a = battleScene.get_node("D6"+str(battleScene.mouseOnDiceIndex));
			a.toggleSelected(); #pooleli todo
	elif state == St.Pood:
		statePoodTick(state_just_changed);


func stateVeeretaTick(vise: bool, viskeidJaanud):
	if viskeidJaanud < 1:
		state = St.NoInput;
		battleEnd()
		return;
	if vise: #MAYBE vise ainult valitud täringutega kui pole kõik valitud?
		veereta();

func veereta():
	viskeid -= 1;
	#todo play animation
	veeretaTaringuid(myDice);

func veeretaTaringuid(ds: Array[Taring]):
	var left_side: float = -1;
	for i in range(ds.size()):
		var d = ds[i];
		d.roll();
		if (taringud.size() < (i + 1)): #todo move to initialize dice in hand
			var t: MeshInstance3D = D6.instantiate();
			t.name = "D6"+str(i);
			t.my_index = i;
			battleScene.add_child(t);
			t.set_owner(battleScene); #todo add group for better referencing
			t.position = Vector3(left_side + (i*0.5), 0, 0);
			taringud.push_back(t);
		var t2 = taringud[i];
		t2 = battleScene.get_node("D6"+str(i));
		turnD6(d.current_side, t2);
	state = St.Vali
	print("veeretasid: " + str(ds.map(func(d): return d.current_side)) + " || vali täringud ja vajuta enter. viskeid jäänud: " + str(viskeid));

func turnD6(v: int, t: MeshInstance3D): #todo move to D6 render logic
	if v == 6:
		t.rotation_degrees = Vector3(0, 0, 0);
	elif v == 5:
		t.rotation_degrees = Vector3(90, 0, 0);
	elif v == 1:
		t.rotation_degrees = Vector3(180, 0, 0);
	elif v == 2:
		t.rotation_degrees = Vector3(-90, 0, 0);
	elif v == 3:
		t.rotation_degrees = Vector3(0, 0, 90);
	elif v == 4:
		t.rotation_degrees = Vector3(0, 0, -90);

func endTurn():
	var selectedDiceIndexes: Array = taringud.filter(func(t): return t.is_selected).map(func(t): return myDice[t.my_index].current_side);
	calculateCombos(selectedDiceIndexes);
	for t in taringud: t.setSelected(false);
	if viskeid > 0:
		state_just_changed = true;
		state = St.Veereta;
		return;
	battleEnd();

func calculateCombos(diceIndexes: Array):
	print("valisid: " + str(diceIndexes) + " || click et uuesti veeretada");
	
	print("combod: ")
	pass #todo

#func battleInit
func battleEnd(): #battleInstance: PackedScene to remove
	state_just_changed = true;
	battleScene.set_visible(false);
	viskeid = 5; #todo oooo
	state = St.Pood #todo handle next state (map to choose?) stateHandler class


func statePoodTick(enter: bool):
	if enter:
		state_just_changed = false;
		var text = Label.new();
		text.text = "POOD"
		add_child(text); #todo load
		print("astusid poodi!");
	pass
