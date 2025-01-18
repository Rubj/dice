class_name Combo

var name: String;
var method: Callable;
var points: int; #todo reward other than points?

func _init(name: String, points: int, method: Callable):
	self.name = name;
	self.points = points;
	self.method = method;

func calculate(valueCounts: Dictionary) -> String: #todo return name and points, maybe even dice index
	#if (method.is_null()):
	#	print("COMBO" + name + "DOES NOT HAVE A METHOD TO CALCULATE!");
	#	return;
	var r = method.call(valueCounts);
	if typeof(r) == TYPE_BOOL && r:
		return name + ":" + str(points);
	return "";
