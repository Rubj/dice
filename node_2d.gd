extends Node3D

var state_just_changed: bool = true;
enum St {NoInput,Lahing,YourTurn,EnemyTurn,Pood,Vali, Test};
var state: St = St.Lahing;
var myDice: Array[Taring] = [];
var viskeid: int;
var battleScene: Node3D;
@onready var D6: PackedScene = preload("res://scenes/d6.tscn");

# Called when the node enters the scene tree for the first time.
func _ready():
	#todo load from savefile
	myDice = [Taring.new(), Taring.new(), Taring.new(), Taring.new(), Taring.new()]; #5d6
	viskeid = 5; #todo move to battle init add_child(battleScene.instantiate());
	battleScene = get_node("Battle");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if state in [St.NoInput]:
		pass

	if state == St.Lahing:
		if (state_just_changed):
			#add_child(battleScene);
			battleScene.set_visible(true);
			state_just_changed = false;
		stateVeeretaTick(Input.is_action_just_released("click"), viskeid);
	elif state == St.Vali:
		if (Input.is_action_just_released("click")): #&& mouse coordinates
			var a = battleScene.get_node("D6"+str(randi_range(1,myDice.size()-1)));
			a.setSelected(false); #pooleli todo
	elif state == St.Pood:
		statePoodTick(state_just_changed);



func stateVeeretaTick(vise: bool, viskeidJaanud):
	if viskeidJaanud < 1:
		state = St.NoInput;
		battleEnd()
		return;
	if vise: #todo vise ainult valitud täringutega kui pole kõik valitud
		veereta();

func veereta():
	viskeid -= 1;
	#todo play animation
	veeretaTaringuid(myDice);

func veeretaTaringuid(ds: Array[Taring]):
	var battleScene: Node3D = get_node("Battle");
	var taringD6: MeshInstance3D = battleScene.get_node("D6");
	var left_side: float = -1;
	taringD6.position = Vector3(left_side, 0, 0);
	var taringud: Array[MeshInstance3D] = [taringD6];
	for i in range(ds.size()):
		var d = ds[i];
		d.roll();
		if (taringud.size() < (i + 1)):
			var t: MeshInstance3D = D6.instantiate();
			t.name = "D6"+str(i);
			battleScene.add_child(t);
			t.set_owner(battleScene);
			t.position = Vector3(left_side + (i*0.5), 0, 0);
			taringud.push_back(t);
		var t2 = taringud[i];
		if (i > 0): #todo remove if starting with empty board and test dice removed
			t2 = battleScene.get_node("D6"+str(i));
		turnD6(d.current_side, t2);
	state = St.Vali
	print(str(ds.map(func(d): return d.current_side)) + " || viskeid jäänud: " + str(viskeid));

func turnD6(v: int, t: MeshInstance3D): #todo move to render logic
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


#func battleInit
func battleEnd(): #battleInstance: PackedScene to remove
	state_just_changed = true;
	remove_child(get_child(0));
	state = St.Pood #todo handle next state (map to choose?) stateHandler class


func statePoodTick(enter: bool):
	if enter:
		state_just_changed = false;
		var text = Label.new();
		text.text = "POOD"
		add_child(text); #todo load
		print("astusid poodi!");
	pass
