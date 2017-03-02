extends "res://Piece.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	self.side = "KING"
	

#the unit that calls this moves too, as part of the act of pushing

#need to override being pushed by other enemies so that the enemy that pushes it just moves in front of it

#need to have its own phase where it moves by an AI
#own AI first has to consider all valid moves, which should be fine because there's only 6 max
#either swap with other enemy, kill a player, or move to an empty space
#should try to move as far away from players as possible

#I think one problem is that if a player piece tries to check if it can damage, it just sees if it's an enemy
#we can either override the damage function so that it doesn't do anything
#or we can set it to a different side, KING

#need to have a check at the end of its own phase to see if it's adjacent to an enemy and can't move anywhere


#so we establish that the win condition check is at the end of the king's own phase, right?