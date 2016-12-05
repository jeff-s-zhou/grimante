
const Grunt = preload("res://EnemyPieces/GruntPiece.tscn")
const Healer = preload("res://EnemyPieces/HealerPiece.tscn")

const Berserker = preload("res://PlayerPieces/BerserkerPiece.tscn")
const Cavalier = preload("res://PlayerPieces/CavalierPiece.tscn")
const Archer = preload("res://PlayerPieces/ArcherPiece.tscn")
const Knight = preload("res://PlayerPieces/KnightPiece.tscn")

var level1_instructions = [
	make_tip(Vector2(100, 300), "", "Move the Berserker towards the enemy forces.", "Drag the Berserker to this tile."),
	make_tip(Vector2(100, 300), "An enemy has moved within range.",  "Attack the enemy.", "Drag the Beserker to this enemy."),
	make_tip(Vector2(100, 300), "The Berserker deals 3 damage per attack.",  "Finish off the enemy.", ""),
	make_tip(Vector2(100, 300), "When The Berserker kills an enemy, it lands on their tile. ", \
	 "Move the Berserker next to the incoming enemies to trigger your passive.", ""),
	make_tip(Vector2(100, 300), "When the Berserker lands on a tile, his passive deals 2 damage to adjacent enemies.", \
	"Kill the remaining enemies in one move.")
]

var level1_enemies = [
{3: make(Grunt, 4), 4: make(Grunt, 6), 5: make(Grunt, 3)},
{3: make(Grunt, 4), 4: make(Grunt, 3), 5: make(Grunt, 3)},
{3: make(Grunt, 4), 4: make(Grunt, 3), 5: make(Grunt, 3)},
{1: make(Grunt, 4), 3: make(Grunt, 6), 4: make(Grunt, 7), 6: make(Grunt, 5), 7: make(Grunt, 5)},
{3: make(Grunt, 5), 5: make(Grunt, 5)},
{3: make(Grunt, 4), 4: make(Grunt, 3), 5: make(Grunt, 3)},
{1: make(Grunt, 4), 3: make(Grunt, 6), 4: make(Grunt, 7), 6: make(Grunt, 5), 7: make(Grunt, 5)}
]

var level1_allies = {4: Berserker.instance()}

var Level1 = {"allies":level1_allies, "enemies":level1_enemies, "initial_deploy_count":3, "tutorial_instructions":level1_instructions}

func make(prototype, health):
	var piece = prototype.instance()
	piece.initialize(health)
	return piece
	
func make_tip(position, info_text, objective_text, tooltip_text):
	return {"position":position, "info_text":info_text, "objective_text": objective_text, "tooltip_text": tooltip_text}


