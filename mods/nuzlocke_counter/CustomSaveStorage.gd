extends "res://global/save_system/SaveSystemStorage.gd"

var deaths = 0
var broken_tapes = 0

func store(file_path: String, snapshot: Dictionary, thumbnail_buffer: PoolByteArray) -> int:
	# Save deaths and broken tapes into the snapshot
	snapshot["deaths"] = deaths
	snapshot["broken_tapes"] = broken_tapes
	print("Saving deaths: %d, broken tapes: %d" % [deaths, broken_tapes])
	# Call the parent method to save the snapshot
	return .store(file_path, snapshot, thumbnail_buffer)

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
