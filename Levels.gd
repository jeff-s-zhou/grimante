
const Grunt = preload("res://EnemyPieces/GruntPiece.tscn")
const Healer = preload("res://EnemyPieces/HealerPiece.tscn")

var Level1 = [3, 
{3: make(Grunt, 4), 4: make(Grunt, 3), 5: make(Grunt, 3)},
{3: make(Grunt, 4), 4: make(Grunt, 3), 5: make(Grunt, 3)},
{3: make(Grunt, 4), 4: make(Grunt, 3), 5: make(Grunt, 3)},
{1: make(Grunt, 4), 3: make(Grunt, 6), 4: make(Grunt, 7), 6: make(Grunt, 5), 7: make(Grunt, 5)},
{3: make(Grunt, 5), 5: make(Grunt, 5)},
{3: make(Grunt, 4), 4: make(Grunt, 3), 5: make(Grunt, 3)},
{1: make(Grunt, 4), 3: make(Grunt, 6), 4: make(Grunt, 7), 6: make(Grunt, 5), 7: make(Grunt, 5)}
]

func make(prototype, health):
	var piece = prototype.instance()
	piece.initialize(health)
	return piece


