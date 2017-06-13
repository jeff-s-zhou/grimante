extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const DustWaveParticlesPrototype = preload("res://Effects/DustWaveParticles.tscn")
const WindParticlesPrototype = preload("res://Effects/WindParticles.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func emit_dust(position):
	#var dust_wave = DustWaveParticlesPrototype.instance()
	var dust_wave = get_node("DustWaveParticles")
	dust_wave.set_pos(position)
	print(position)
	dust_wave.set_emit_timeout(0.2)
	dust_wave.set_emitting(true)

#we have the drummer call it every x seconds on a repeating Tween, with its current coords
#so there's no state to keep track of in here
func emit_wind(coords):
	var wind = WindParticlesPrototype.instance()
	add_child(wind)
	
	var tween = Tween.new()
	add_child(tween)
	
	var current_pos = get_parent().locations[coords].get_pos()
	
	var column_range = get_parent().get_location_range(coords, [1, 9], [0, 1])
	var start_pos
	if column_range == []:
		start_pos = current_pos + Vector2(0, -80)
	else:
		var top_of_column = column_range[column_range.size() - 1]
		start_pos = get_parent().locations[top_of_column].get_pos() + Vector2(0, -80)
	
	column_range = get_parent().get_location_range(coords, [1, 9], [3, 4])
	var end_pos
	if column_range == []:
		end_pos = current_pos + Vector2(0, 80)
	else:
		var bottom_of_column = column_range[column_range.size() - 1]
		end_pos = get_parent().locations[bottom_of_column].get_pos() + Vector2(0, 80)
	
	tween.interpolate_property(wind, "transform/pos", start_pos, end_pos, 5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	wind.get_node("Particles2D").set_emitting(true)
	tween.start()
	yield(tween, "tween_complete")
	wind.get_node("Particles2D").set_emitting(false)
	tween.interpolate_property(wind, "visibility/opacity", 1, 0, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	yield(tween, "tween_complete")
	tween.queue_free()
	wind.queue_free()
	
	
	#queue free the tween and wind particles

