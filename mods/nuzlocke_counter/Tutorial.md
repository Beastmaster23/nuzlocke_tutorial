# Mod Tutorial

## So you want to make a mod for Cassette Beasts?

Well first of all, I'm just a dude who is sharing what he knows. I'm not a professional programmer, and I'm not a professional game developer. I'm just a guy who likes to make things. So if you're looking for a professional tutorial, you're in the wrong place. But if you're looking for a tutorial that will get you started, then you're in the right place.

## An Example Mod
This tutorial will be using the example mod that I made. You can find it here:

This mod will count the number of times you've died and broken tapes in the game. It will also show you the number of times you've died and broken tapes in the game when you are in the overworld. And to top it all off, it will also edit the save file to keep track of the number of times you've died and broken tapes in the game.

## Getting Started

### Step 1: Write a metadata file
Every mod needs a metadata file. This file contains information about the mod, such as the name, description, and version number. You might have noticed that by editing the game files directly and export it either doesn't work or it breaks the game. There is many reasons why, but in my experience it's because the things your changing doesn't take effect because the game never get's a reference to the resource you changed or class. An example:
You change a global file. Well let's go through what the game does.

1. The game loads all global files.
2. The game loads all mods.
	1. your mod is loaded.
	2. your mod changes a global file. Wait a minute, the game already loaded all global files and rarely makes another instance of the global file. So the game doesn't know about the changes you made. Now you might be thinking, "Well why doesn't the game just reload the global files?" Well, that is difficult because other files are dependent on the global files. So if the game reloads the global files, it will have to reload all the other files that depend on the global files. And that might not be possible. So the game just doesn't reload the global files.
3. The game loads all scenes.

### Step 2: Write a mod.gd file
So now we know why we should create a script to control loading the mod. So let's create a script called mod.gd. This script will be the main script for the mod. It will have a function called init_content() from the parent class. This function will be called when the mod is loaded. So let's create a script called mod.gd and add the following code to it:

```gdscript
extends ContentInfo

func init_content():
	pass
```

Ok since we have a script, let's add our mod specific code to it.

Wait what do we want the mod to do again? Oh yeah, we want it to count the number of times we've died and broken tapes in the game. So we need to find where the game keeps track of the number of times we've died and broken tapes in the game. Uh oh it doesn't... Well we can fix that. So let's figure out how to do that.

We can start by listening to the scen manager's scene_changed signal. This signal is emitted when the scene changes. So we can use this signal to listen for when the game loads a scene. So let's add the following code to the init_content() function:

```gdscript
func init_content():
	SceneManager.connect("scene_changed", self, "_on_scene_changed")

func _on_scene_changed():
	print("Scene changed to: " + SceneManager.current_scene.name)
```

Now let's run the game and see what happens. We can press "`" this opens the console. This can let us load a save file. So let's load a save file with the cammand "load_file your_save". We also want to turn on permadeath "permadeath true". Then we want to go to a fight so we can die.

When we are in a fight, the console will say "Scene changed to: Battle". We also see that every time we take a turn the console says something. So we should look at the godot editor and see what is happening. So let's open the godot editor and look at the nodes loaded in the scene. We see that there is a node called "Battle". So let's look at the script attached to the "Battle" node. We see that there is a node called "Events". This handles the events that happen in the battle. So let's look at the script attached to the "Events" node. We see that there is nothing but code for notifying others. We should listen to the signals that are emitted by this script. So let's add the following code to the _on_scene_changed() function:

```gdscript
func _on_scene_changed():
	print("Scene changed to: " + SceneManager.current_scene.name)
	var scene = SceneManager.current_scene
	if scene.name == "Battle":
		# We will connect to the notified signal of the BattleScene to get notified of events
		var battle = scene
		battle.events.connect("notified", self, "on_battle_event")

func on_battle_event(id, args):
	print("Battle event: " + str(id) + " " + str(args))
```

Now let's run the game and see what happens. We can press "`" this opens the console. This can let us load a save file. So let's load a save file with the cammand "load_file your_save". We also want to turn on permadeath "permadeath true". Then we want to go to a fight so we can see what events get called then we die.

Did you notice that there is a lot of events that get called? Right after dying their is a death event. So let's look at the args for the death event. We see that the args is a dictionary. The dictionary has 1 key "fighter". This is the fighter that died. So let's find a fighter node. Like "Player1" or "Player2". Every fighter has 3 nodes and one of them is a fighter controller. So let's look at the script attached to the "FighterController" node. We see that there is a function called "die()". This is the function that gets called when a fighter dies. But the player nodes has a player fighter controller. We can now use this information to keep track of the number of times we've died.

Oh no we need a place to store the number of times we've died. Well we can use the save file. If you look at the global files you see that their is a folder called save_system. This holds a class that handles the save files and when to save. You might think that you can just create a script and instance it and override it. But that won't work because the game already instanced an old version of the class and many times there's other files that depend on the class and have references already. So we can't just override it. But if we look further we see a class that only handles the save file. So we can extend this class and override the store() function. So let's create a script called "CustomSaveStorage.gd" and add the following code to it:

```gdscript
extends "res://global/save_system/SaveSystemStorage.gd"

var deaths = 0
var broken_tapes = 0

func store(file_path: String, snapshot: Dictionary, thumbnail_buffer: PoolByteArray) -> int:
	pass

func read(file_path: String) -> ReadResult:
	pass
```

Now we need to override the store() function. So let's add the following code to the store() function:

```gdscript

func store(file_path: String, snapshot: Dictionary, thumbnail_buffer: PoolByteArray) -> int:
	# Save deaths and broken tapes into the snapshot
	snapshot["deaths"] = deaths
	snapshot["broken_tapes"] = broken_tapes
	print("Saving deaths: %d, broken tapes: %d" % [deaths, broken_tapes])
	# Call the parent method to save the snapshot
	return .store(file_path, snapshot, thumbnail_buffer)
```

The snapshot is a dictionary that holds the data that will be saved. So we can add the number of deaths and broken tapes to the snapshot. Then we can call the parent method to save the snapshot. We do this so that other mods can save their data too. Now we need to override the read() function. So let's add the following code to the read() function:

```gdscript
func read(file_path: String) -> ReadResult:
	var result = .read(file_path)
	# If the parent method failed, return the error
	if result.error != OK:
		return result
	
	# If the snapshot doesn't have the deaths or broken_tapes keys, add them
	var snapshot = result.result
	if not snapshot.has("deaths"):
		snapshot["deaths"] = 0
	if not snapshot.has("broken_tapes"):
		snapshot["broken_tapes"] = 0
	
	# Load deaths and broken tapes from the snapshot
	deaths = snapshot["deaths"]
	broken_tapes = snapshot["broken_tapes"]

	print("Loading deaths: %d, broken tapes: %d" % [deaths, broken_tapes])
	# Return the result
	return result
```

This just loads the deaths and broken tapes from the snapshot. Now we need to use this class. So let's add the following code to our mod.gd file:

```gdscript
var CustomSaveStorage :Resource= preload("res://mods/nuzlocke_counter/CustomSaveStorage.gd")
var custom_save_storage

func init_content():
	# This is where we will setup and load our mod
	# We will connect to the scene_changed signal of the SceneManager
	SceneManager.connect("scene_changed", self, "on_scene_changed")

	# Change SaveSystemStorage to our custom one
	CustomSaveStorage.take_over_path("res://global/save_system/SaveSystemStorage.gd")
	yield(SaveSystem, "ready")
	custom_save_storage = CustomSaveStorage.new()
	SaveSystem.storage = custom_save_storage
```

Some modders discovered that using the take_over_path() function can help you avoid issues. This tells the rest of the game to use our class instead of the old one. Then we need to wait for the SaveSystem to be ready so we can change the storage. Then we need to create an instance of our class and set the storage to our class.

Yay the backend is officially done. You can run this and check the logs to see if it's working.

If it's not working make sure your metadata.tres is using your mod.gd script. I forget to do this all the time.

Now we need to add the UI. So let's add the following code to our mod.gd file:

```gdscript
func get_labels():
	var ui_node = GlobalUI.get_parent().get_node_or_null("MenuHelper/WorldUIOverlay/MarginContainer/Widget/WidgetContents")
	if not ui_node:
		return []
	var vbox = ui_node.get_node_or_null("VBoxContainer")
	if not vbox:
		vbox= VBoxContainer.new()
		vbox.margin_left=32
		vbox.margin_top=150
		vbox.name = "VBoxContainer"
		ui_node.add_child(vbox)
	var labels = []
	for child in vbox.get_children():
		if child.name == "DeathCounter" or child.name == "TapeCounter":
			labels.append(child)
	if labels.size() < 2:
		for child in labels:
			vbox.remove_child(child)
			child.queue_free()
		var deaths_label = Label.new()
		deaths_label.name = "DeathCounter"
		deaths_label.text = "Deaths: %d" % custom_save_storage.deaths
		vbox.add_child(deaths_label)
		var broken_tapes_label = Label.new()
		broken_tapes_label.name = "TapeCounter"
		broken_tapes_label.text = "Tapes: %d" % custom_save_storage.broken_tapes
		vbox.add_child(broken_tapes_label)
		labels = [deaths_label, broken_tapes_label]
	return labels
```

This function will return a list of labels that we can use to update the text. It will also create the labels if they don't exist. Now we need to add the following code to our mod.gd file:

We are done with the mod!

I hope you can use some of this information to make your own mods.

## Websites
The modding wiki: https://wiki.cassettebeasts.com/wiki/Modding:Mod_Developer_Guide

## Credits

## Thanks