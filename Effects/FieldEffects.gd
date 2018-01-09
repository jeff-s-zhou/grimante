extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const DustWaveParticlesPrototype = preload("res://Effects/DustWaveParticles.tscn")
const WindParticlesPrototype = preload("res://Effects/WindParticles.tscn")
const SpeedUpParticlesPrototype = preload("res://Effects/SpeedUpIndicator.tscn")

var speed_ups = {}

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func emit_dust(position):
	#var dust_wave = DustWaveParticlesPrototype.instance()
	var dust_wave = get_node("DustWaveParticles")
	dust_wave.set_pos(position)
#	get_node("Timer").set_wait_time(0.2)
#	get_node("Timer").start()
#	yield(get_node("Timer"), "timeout")
	dust_wave.set_emit_timeout(0.2)
	dust_wave.set_emitting(true)

func clear_speed_up(coords):
	if self.speed_ups.has(coords):
		var pair = self.speed_ups[coords] #free both the Tween and the Particles
		pair[0].queue_free()
		pair[1].queue_free()


func emit_speed_up(coords):
	var speed_up = SpeedUpParticlesPrototype.instance()
	
	add_child(speed_up)
	
	var tween = Tween.new()
	add_child(tween)
	
	self.speed_ups[coords] = [speed_up, tween]
	
	var start_pos = get_parent().locations[coords].get_pos()
	
	var column_range = get_parent().get_location_range(coords, [1, 9], [3, 4])
	var end_pos
	if column_range == []:
		end_pos = start_pos + Vector2(0, 20)
	else:
		var bottom_of_column = column_range[column_range.size() - 1]
		end_pos = get_parent().locations[bottom_of_column].get_pos()
	
	var distance = (end_pos - start_pos).length()
	var time = distance/150
		
	speed_up.set_emitting(true)
	tween.interpolate_property(speed_up, "transform/pos", start_pos, end_pos, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.set_repeat(true)
	tween.start()


func emit_frost(coords):
	var half_x = get_viewport().get_rect().size.x/2
	get_node("FrostGroundParticles").set_global_pos(Vector2(half_x, 300))
	var current_pos = get_parent().locations[coords].get_pos()
	get_node("FrostGroundParticles").animate(current_pos)
#
#func hide_frost():
#	get_node("Frost").clear()



#we have the drummer call it every x seconds on a repeating Tween, with its current coords
#so there's no state to keep track of in here
#func emit_wind(coords):
#	var wind = WindParticlesPrototype.instance()
#	add_child(wind)
#	
#	var tween = Tween.new()
#	add_child(tween)
#	
#	var current_pos = get_parent().locations[coords].get_pos()
#	
#	var column_range = get_parent().get_location_range(coords, [1, 9], [3, 4])
#	var end_pos
#	if column_range == []:
#		end_pos = current_pos + Vector2(0, 80)
#	else:
#		var bottom_of_column = column_range[column_range.size() - 1]
#		end_pos = get_parent().locations[bottom_of_column].get_pos() + Vector2(0, 40)
#	
#	tween.interpolate_property(wind, "transform/pos", current_pos, end_pos, 5, Tween.TRANS_LINEAR, Tween.EASE_IN)
#	wind.get_node("Particles2D").set_emitting(true)
#	tween.start()
#	yield(tween, "tween_complete")
#	wind.get_node("Particles2D").set_emitting(false)
#	tween.interpolate_property(wind, "visibility/opacity", 1, 0, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN)
#	yield(tween, "tween_complete")
#	tween.queue_free()
#	wind.queue_free()
#