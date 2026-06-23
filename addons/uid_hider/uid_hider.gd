@tool
extends EditorPlugin

const UID_RESOURCE_EXTENSIONS = ["gd", "res", "tres", "material", "shader", "png", "svg"]

var file_system: EditorFileSystem
var is_updating: bool = false
var hider: UIDBaseHider

func _enter_tree() -> void:
	_initialize_hider()
	
	file_system = EditorInterface.get_resource_filesystem()
	if file_system:
		file_system.filesystem_changed.connect(_on_filesystem_changed)
		_update_dirty_folders()

func _exit_tree() -> void:
	if file_system and file_system.filesystem_changed.is_connected(_on_filesystem_changed):
		file_system.filesystem_changed.disconnect(_on_filesystem_changed)

func _on_filesystem_changed() -> void:
	if is_updating:
		return
	_update_dirty_folders()

func _initialize_hider() -> void:
	var os_name = OS.get_name()
	match os_name:
		"Windows":
			hider = UIDWindowsHider.new()
		"Linux", "macOS":
			hider = UIDLinuxHider.new()
		_:
			hider = UIDLinuxHider.new()

func _update_dirty_folders() -> void:
	if not hider:
		return
	is_updating = true
	WorkerThreadPool.add_task(_scan_cached_fs.bind(file_system.get_filesystem()))

func _scan_cached_fs(root_dir: EditorFileSystemDirectory) -> void:
	if not root_dir:
		call_deferred("_unlock_update")
		return
		
	var target_dirs: Array[String] = []
	_find_dirs_with_resources_in_cache(root_dir, target_dirs)
	
	for dir_path in target_dirs:
		_process_single_directory(dir_path)
		
	call_deferred("_unlock_update")

func _unlock_update() -> void:
	is_updating = false

func _find_dirs_with_resources_in_cache(dir: EditorFileSystemDirectory, out_dirs: Array[String]) -> void:
	var path = dir.get_path()
	var has_uid_resource = false
	
	for i in dir.get_file_count():
		var file_ext = dir.get_file(i).get_extension().to_lower()
		if file_ext in UID_RESOURCE_EXTENSIONS:
			has_uid_resource = true
			break
			
	if has_uid_resource:
		out_dirs.append(path)
		
	for i in dir.get_subdir_count():
		var subdir = dir.get_subdir(i)
		if subdir and not subdir.get_name().begins_with("."):
			_find_dirs_with_resources_in_cache(subdir, out_dirs)

func _process_single_directory(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if not dir:
		return
		
	dir.include_navigational = false
	dir.include_hidden = false
	
	var uids: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".uid"):
			uids.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	if hider:
		hider.hide_uids(dir_path, uids)
