extends Resource
class_name Logger

enum levels {
	DEBUG,
	INFO,
	NETWORKING,
	WARNING,
	ANALYTICS,
	ERROR,
}

var owning_class = ""

func _init(_owning_class : String):
	owning_class = _owning_class

func log(message: String, flag: int = 0, owning_suffix: String = ""):
	var t = Thread.new()
	t.start(self, "_create_log", [flag, message, owning_suffix ], t.PRIORITY_NORMAL)
	t.wait_to_finish()

func _create_log(data: Array):
	var message_log = ""
	if OS.is_debug_build():
		if data[2] != "":
			message_log = "%s [%s] | %s" %[levels.keys()[data[0]], owning_class+"/"+data[2], data[1]]
		else:
			message_log = "%s [%s] | %s" %[levels.keys()[data[0]], owning_class, data[1], ]
		print (message_log)
