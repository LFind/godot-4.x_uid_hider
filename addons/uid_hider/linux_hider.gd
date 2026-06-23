@tool
class_name UIDLinuxHider
extends UIDBaseHider

func hide_uids(dir_path: String, uids: Array[String]) -> void:
	var hidden_file_path = dir_path.path_join(".hidden")
	var new_content := ""
	for uid in uids:
		new_content += uid + "\n"
		
	var current_content := ""
	if FileAccess.file_exists(hidden_file_path):
		var f := FileAccess.open(hidden_file_path, FileAccess.READ)
		if f:
			current_content = f.get_as_text()
			f.close()
			
	if current_content != new_content:
		var f := FileAccess.open(hidden_file_path, FileAccess.WRITE)
		if f:
			f.store_string(new_content)
			f.close()
