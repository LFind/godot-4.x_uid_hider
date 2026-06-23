# Godot UID Hider Plugin

A lightweight Godot 4.x editor plugin that automatically hides generated `.uid` files in your project directory. It helps keep your file manager clean and clutter-free without interfering with Godot's internal resource management.

## Features

* 
**Multi-Platform Support**: Works seamlessly on both **Linux** and **Windows**.


* **OS-Specific Hiding Mechanisms**:
* 
**Linux**: Automatically generates and updates a `.hidden` file inside folders containing target resources, which native file managers read to hide specific files.


* 
**Windows**: Uses the native `attrib +h` command via OS execution to hide `.uid` files directly.




* 
**Background Processing**: Uses Godot's `WorkerThreadPool` to scan the project filesystem asynchronously without freezing the editor UI.



## Compatibility & Testing

> [!IMPORTANT]
> This plugin has been actively tested and verified **only on Linux (using the Dolphin file manager) with Godot 4.7**.

While it includes implementation for Windows using native system attributes, it should be considered experimental on platforms other than the tested environment.

---

## Configuration & Customization

The plugin scans directories that contain specific resource extensions. If you find that `.uid` files in a particular folder are not being hidden, it is likely because that folder contains resources with extensions not currently tracked by the plugin.

To fix this, you can manually add the missing file extension to the `UID_RESOURCE_EXTENSIONS` constant inside `uid_hider.gd`:

```gdscript
# uid_hider.gd
const UID_RESOURCE_EXTENSIONS = ["gd", "res", "tres", "material", "shader", "png", "svg", "your_extension_here"]

```

---

## How It Works

1. 
**Initialization**: When the plugin enables, it detects your current operating system and instantiates the correct hider implementation (`UIDWindowsHider` or `UIDLinuxHider`).


2. 
**Filesystem Scan**: The plugin hooks into the `EditorFileSystem.filesystem_changed` signal. Whenever changes occur, it safely scans your project cache on a separate thread.


3. 
**Execution**: It aggregates `.uid` files in folders containing tracked resources and delegates the hiding process to the OS-specific class.
