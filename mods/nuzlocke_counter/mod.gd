extends ContentInfo

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

func on_scene_changed():
	print("Scene changed to: %s" % SceneManager.current_scene.name)
	var scene = SceneManager.current_scene
	if scene.name == "Battle":
		# We will connect to the notified signal of the BattleScene to get notified of events
		var battle = scene
		battle.events.connect("notified", self, "on_battle_event")

	elif scene.name == "GameOver":
		# We can increase the number of deaths in the custom save storage
		custom_save_storage.deaths+=1
	elif WorldSystem.get_level_map():
		var labels = get_labels()
		if labels.size() > 0:
			labels[0].text = "Deaths: %d" % custom_save_storage.deaths
			labels[1].text = "Tapes: %d" % custom_save_storage.broken_tapes
func on_battle_event(id, args):
	if id =="death_ending":
		var fighter:FighterNode = args["fighter"] as FighterNode
		print("Death of %s" % fighter.team)
		# Look for PlayerFighterController to know if it was the player
		var player_controller = fighter.get_controller()
		if player_controller:
			if player_controller is PlayerFighterController:
				custom_save_storage.broken_tapes+=1
				
