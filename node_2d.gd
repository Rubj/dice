extends Node3D

var state_just_changed: bool = true;
enum St {NoInput,Veereta, SpinDice, YourTurn,EnemyTurn,Pood,Vali, Test};
var state: St = St.Veereta;
var myDice: Array[Taring] = []; #todo replace with var diceInHand: Array[Taring];
var taringud: Array[MeshInstance3D] = [];#taringud laual todo ilusam godot ref
var viskeid: int;
var combos: Array[Combo] = []
var battleScene: Node3D;
@onready var D6: PackedScene = preload("res://scenes/d6.tscn");


#for dice spinning
var maxSpintime: float = 0.7; #sec?
var spinTimer: float = 0.0;

#todo move all these combo methods to somewhere else
func countValues(values: Array) -> Dictionary:
	var valCounters = {};
	for i in range(values.size()):
		var v = values[i];
		if valCounters.has(v):
			valCounters[v] += 1;
		else:
			valCounters[v] = 1;
	return valCounters;
func jarjest(mitu: int, valueCounts: Dictionary): #todo TEST THIS!
	var last_in_order = -1;
	var count = 0;
	var values = valueCounts.keys();
	values.sort();
	#print("a ",values);
	for v in values:
		if last_in_order == -1 || (v - 1) == last_in_order:
			last_in_order = v;
			count += 1;
	return count == mitu;
func stairwayToHeaven(valueCounts: Dictionary) -> int: #returns points instead of bool
	if valueCounts.keys().size() < 3: return -1;
	#var firstIndxTocountFromFirst: Dictionary = {0: 0}; #todo if need to expand from 3 in a row
	var keys = valueCounts.keys(); #sort dice values (keys) by how many of each, decending
	keys.sort_custom(func(a, b): return valueCounts[a] > valueCounts[b]);
	for i in range(keys.size()-2):
		if (valueCounts[keys[i]] > valueCounts[keys[i + 1]] && valueCounts[keys[i + 1]] > valueCounts[keys[i + 2]] && keys[i] > keys[i + 1] && keys[i + 1] > keys[i + 2]): #3 groups of decending counts in a row decending
			print("STAIRWAY: " + str(keys[i])+":"+str(valueCounts[keys[i]]) +","+ str(keys[i + 1])+":"+str(valueCounts[keys[i + 1]]) +","+ str(keys[i + 2])+":"+str(valueCounts[keys[i + 2]]));
			return 200;
	return -1;

#func remove_duplicates(arr: Array) -> Array:
#	var dict := {}
#	for a in arr:
#		dict[a] = 0;
#	return dict.keys();

# Called when the node enters the scene tree for the first time.
func _ready():
	#todo load from savefile
	myDice = [Taring.new(), Taring.new(), Taring.new(), Taring.new(), Taring.new(), Taring.new(), Taring.new(), Taring.new()]; #8d6
	viskeid = 10; #todo move to battle init add_child(battleScene.instantiate());
	combos = [ #todo sort by points, so that always max points are given first, OR let player choose if multible combinations of combos possible
		Combo.new("Bottom of the Barrel", 350, func(valueCounts: Dictionary): return valueCounts.size() == 1 && valueCounts.has(1)),
		Combo.new("Top of the World", 350, func(valueCounts: Dictionary): return valueCounts.size() == 1 && valueCounts.has(6)),
		Combo.new("Pair", 20, func(valueCounts: Dictionary): return valueCounts.values().any(func(c): return c == 2)), #todo what if multiple pairs?
		Combo.new("Three of a Kind", 50, func(valueCounts: Dictionary): return valueCounts.values().any(func(c): return c == 3)),
		Combo.new("Four of a Kind", 100, func(valueCounts: Dictionary): return valueCounts.values().any(func(c): return c == 4)),
		Combo.new("Five of a Kind", 150, func(valueCounts: Dictionary): return valueCounts.values().any(func(c): return c == 5)),
		Combo.new("Six of a Kind", 200, func(valueCounts: Dictionary): return valueCounts.values().any(func(c): return c == 6)),
		Combo.new("Small Straight", 100, func(v): return jarjest(4, v)),
		Combo.new("Straight", 120, func(v): return jarjest(5, v)),
		Combo.new("Extended Straight", 200, func(v): return jarjest(6, v)),
		Combo.new("Full House", 180, func(valueCounts: Dictionary): return valueCounts.values().any(func(c): return c == 2) && valueCounts.values().any(func(c): return c == 3)),
		Combo.new("Three Pairs", 200, func(valueCounts: Dictionary): return valueCounts.values().find(func(c): return c == 2, 2)),
		Combo.new("Two Triplets", 250, func(valueCounts: Dictionary): return valueCounts.values().find(func(c): return c == 3, 1)),
		Combo.new("Stairway to Heaven", 200, stairwayToHeaven) #+50 lisapunkte veel kui samade väärtuste grupid kasvavad 1 võrra või eraldi combo selle jaoks?
	];
	battleScene = get_node("Battle");

	#todo remove if starting with empty board and test dice removed
	var taringD6: MeshInstance3D = battleScene.get_node("D6");
	battleScene.remove_child(taringD6);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state in [St.NoInput]:
		pass

	if state == St.Veereta:
		if (state_just_changed):
			#add_child(battleScene);
			battleScene.set_visible(true);
			state_just_changed = false;
		stateVeeretaTick(Input.is_action_just_released("click"), viskeid);
	elif state == St.Vali:
		if (state_just_changed):
			state_just_changed = false; #todo state change handler
			veeretaTaringuid();
		if (Input.is_action_just_released("enter")):
			endTurn();
		elif (Input.is_action_just_pressed("click") && battleScene.mouseOnDiceIndex > -1): #&& mouse coordinates
			var a = battleScene.get_node("D6"+str(battleScene.mouseOnDiceIndex));
			a.toggleSelected(); #pooleli todo
	elif state == St.SpinDice:
		spinStateTick(state_just_changed, delta);
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
	#todo move to initialize dice in hand and refactor positioning
	var left_side: float = -0.9;
	for i in range(myDice.size()):
		if (taringud.size() < myDice.size()):
			var t: MeshInstance3D = D6.instantiate();
			t.name = "D6"+str(i);
			t.my_index = i;
			battleScene.add_child(t);
			t.set_owner(battleScene); #todo add group for better referencing
			if i > 3:
				t.position = Vector3(left_side + ((i-4)*0.6), 0, 0.3);
			else:
				t.position = Vector3(left_side + (i*0.6), 0, -0.3);
			taringud.push_back(t);
	#todo play animation instead of spin?
	state = St.SpinDice;
	state_just_changed = true;

func veeretaTaringuid():
	for i in range(myDice.size()):
		var d = myDice[i];
		d.roll();
		#var t2 = taringud[i];
		#if randi_range(0, 4) < 1:
		#	if i == 1:
		#		d.current_side = 1;
		#	if i == 2 || i == 3:
		#		d.current_side = 2;
		#	if i > 3:
		#		d.current_side = 6;
		var t2: MeshInstance3D = battleScene.get_node("D6"+str(i));
		t2.set_rotation_degrees(Vector3(0,0,0));
		t2.setSelected(true);
		turnD6(d.current_side, t2);
	print("veeretasid: " + str(myDice.map(func(d): return d.current_side)) + " || kui täringud valitud siis vajuta enter. viskeid jäänud: " + str(viskeid));

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
	var selectedDice: Array = taringud.filter(func(t): return t.is_selected).map(func(t): return myDice[t.my_index].current_side);
	calculateCombos(selectedDice);
	for t in taringud: t.setSelected(false);
	if viskeid > 0:
		state_just_changed = true;
		state = St.Veereta;
		return;
	battleEnd();

func calculateCombos(diceValues: Array):
	print("valisid:    " + str(diceValues) + " || click et uuesti veeretada");

	var counts: Dictionary = countValues(diceValues);
	var gotCombos: Array = [];
	for c in combos:
		var res = c.calculate(counts);
		if res != "": gotCombos.push_back(res);
	print("valikus sisalduvad combod: " + str(gotCombos));
	pass #todo

#func battleInit
func battleEnd(): #battleInstance: PackedScene to remove
	state = St.NoInput;
	state_just_changed = true;
	battleScene.set_visible(false);
	viskeid = 10; #todo oooo
	state = St.Pood #todo handle next state (map to choose?) stateHandler class


func statePoodTick(enter: bool):
	if enter:
		state_just_changed = false;
		var text = Label.new();
		text.text = "POOD"
		add_child(text); #todo load
		print("astusid poodi!");
	pass

func spinStateTick(enter: bool, delta):
	if enter:
		state_just_changed = false;
		spinTimer = 0.0
	if spinTimer > maxSpintime:
		state = St.Vali;
		state_just_changed = true;
	var suund = 0;
	spinTimer += delta;
	for i in range(taringud.size()):
		var target = taringud[i];
		if suund == 1: #left
			target.rotate_z(+PI/4-randi_range(0, 10)); #todo make these values more sane, value should be close to 0
		if suund == 0: #right
			target.rotate_z(-PI/4-randi_range(0, 10));
		if suund == 2: #top
			target.rotate_x(-PI/4-randi_range(0, 10));
		if suund == 3: #bottom
			target.rotate_x(+PI/4-randi_range(0, 10));
		if suund == 0: #forward
			target.rotate_y(-PI/4-randi_range(0, 10));
		if suund == 5: #back
			target.rotate_y(+PI/4-randi_range(0, 10));
