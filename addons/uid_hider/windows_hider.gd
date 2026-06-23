@tool
class_name UIDWindowsHider
extends UIDBaseHider

func hide_uids(dir_path: String, uids: Array[String]) -> void:
	for uid in uids:
		var full_path = ProjectSettings.globalize_path(dir_path.path_join(uid))
		
		
		var args: PackedStringArray = ["+h", full_path]
		OS.execute("attrib", args)
