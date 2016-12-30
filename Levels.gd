
const Grunt = preload("res://EnemyPieces/GruntPiece.tscn")
const Fortifier = preload("res://EnemyPieces/FortifierPiece.tscn")
const Grower = preload("res://EnemyPieces/GrowerPiece.tscn")

const Berserker = preload("res://PlayerPieces/BerserkerPiece.tscn")
const Cavalier = preload("res://PlayerPieces/CavalierPiece.tscn")
const Archer = preload("res://PlayerPieces/ArcherPiece.tscn")
const Knight = preload("res://PlayerPieces/KnightPiece.tscn")
const Assassin = preload("res://PlayerPieces/AssassinPiece.tscn")

func make(prototype, health):
	return {"prototype": prototype, "health": health}
	
	
func make_tip(tip_text, objective_text, arrow_coords, tooltip):
	return {"tip_text":tip_text, "objective_text": objective_text, "arrow_coords": arrow_coords, "tooltip": tooltip}
	
var sandbox_allies = {2: Knight, 3:Assassin, 4: Berserker}

var sandbox_enemies = [
{Vector2(4, 6):make(Grunt, 6), Vector2(5, 6):make(Fortifier, 3)}
]

var Sandbox_Level = {"allies": sandbox_allies, "enemies":sandbox_enemies, "initial_deploy_count":3,
"instructions":[], "reinforcements": {}, "next_level":null}

#LEVEL 5

var level5_allies = {3: Cavalier, 5: Knight, 4:Berserker, 6:Archer}

var level5_enemies = [
	{2: make(Grunt, 5), 4: make(Grunt, 5), 6:make(Grunt, 3), 7:make(Grunt, 4)},
	{1: make(Grunt, 3), 3: make(Grunt, 6), 5:make(Grunt, 4), 6:make(Grunt, 4)},
	{1: make(Grunt, 3), 2: make(Grunt, 3), 4:make(Grunt, 2), 5:make(Grunt, 3)},
	{3: make(Grower, 1), 4: make(Fortifier, 2), 6:make(Grower, 1)},
	{0: make(Grower, 1), 3: make(Grunt, 4), 4:make(Fortifier, 3), 5:make(Grunt, 5)},
	{2: make(Grunt, 4), 3: make(Fortifier, 3), 4:make(Grower, 1), 5:make(Grunt, 5)},
	{2: make(Fortifier, 1), 3: make(Grower, 3), 4:make(Fortifier, 5), 5:make(Grunt, 5)}
]

var level5_instructions = [
make_tip("Have no fear, the Knight is here! The Knight is a utility unit that can push both enemies and allies.", "Uhh, use the Knight.", null, ""),
make_tip("New enemies!", "Hold spacebar over them to read what they do.", null, ""),
make_tip("Yeah my b, kinda ran out of time...", "Beat this last level and give Jeff feedback.", null, ""),
]

var Level5 = {"allies": level5_allies, "enemies":level5_enemies, "initial_deploy_count":3,
"instructions":level5_instructions, "reinforcements": {}, "next_level":null}
	
#LEVEL 4
var level4_allies = {3: Berserker, 4: Cavalier}
var level4_enemies = [
{Vector2(7, 7): make(Grunt, 4)},
{Vector2(3, 4): make(Grunt, 3), Vector2(4, 4): make(Grunt, 4), Vector2(5, 5):make(Grunt, 2)},
{Vector2(1, 3): make(Grunt, 3), Vector2(2, 4): make(Grunt, 2)},
{2: make(Grunt, 5), 3: make(Grunt, 3), 4: make(Grunt, 6), 5:make(Grunt, 2)},
{2: make(Grunt, 4), 4: make(Grunt, 2), 5:make(Grunt, 3)},
{2: make(Grunt, 2), 3: make(Grunt, 4), 7:make(Grunt, 3)}
]
var level4_instructions = [
make_tip("Each Friendly Unit can move once per turn. To quickly end your turn, you can press END TURN on the sidebar." \
,"", null, ""),
make_tip("Remaining Enemy Waves are deployed from the top of the screen.", "", null, ""),
make_tip("The Archer has arrived! The Archer can either move 1 space OR fire a ranged attack for 4 damage.", "", null, ""),
make_tip("The Archer's ranged attack hits the first target in a line, and can target hex diagonals.", "", null, ""),
make_tip("The Archer has 0 Armor, so if it gets pushed it's KOed.", "Win?", null, ""),
]

var level4_reinforcements = {3:{7: Archer}}

var Level4 = {"allies": level4_allies, "enemies":level4_enemies, "initial_deploy_count":4,
"instructions":level4_instructions, "reinforcements": level4_reinforcements, "next_level":Level5}


#LEVEL 3
var level3_allies = {3: Berserker}
var level3_enemies = [
{Vector2(4, 4) : make(Grunt, 2)},
{Vector2(3, 5) : make(Grunt, 1), Vector2(4, 5) :make(Grunt, 8)},
{ Vector2(4, 7): make(Grunt, 4) },
{Vector2(3, 7): make(Grunt, 2), Vector2(4, 8): make(Grunt, 3), Vector2(5, 8): make(Grunt, 2)},
{Vector2(3, 8): make(Grunt, 2), Vector2(4, 9): make(Grunt, 2), Vector2(5, 9): make(Grunt, 2)}
]
var level3_instructions = [
make_tip("If you need a refresher on a Unit, hold spacebar over a Unit for a summary.", "Smash!", Vector2(4, 8), ""),
make_tip("Enemies will push Friendly Units forward. If a Friendly Unit is pushed off the map, it is KOed.", \
"Don't let the Berserker get KOed.", null, ""),
make_tip("You LOSE if an enemy exits from the bottom of the map or all Friendly Units are KOed.", "Don't lose.", null, "")
]

var Level3 = {"allies": level3_allies, "enemies":level3_enemies, "initial_deploy_count":5,
"instructions":level3_instructions, "reinforcements": {}, "next_level":Level4}

#LEVEL 2
var level2_allies = {4: Cavalier}
var level2_enemies = [
{Vector2(4, 6): make(Grunt, 6), Vector2(4, 5): make(Grunt, 2), Vector2(4,4): make(Grunt, 2), Vector2(4, 3): make(Grunt, 2)},
{2: make(Grunt, 2), 3:make(Grunt, 2)},
{4: make(Grunt, 3)}
]

var level2_instructions = [
	make_tip("You win when all enemies waves are deployed and all enemies are eliminated.", \
	"The Cavalier can run through enemies and Trample them. Move the Cavalier behind enemy lines.", Vector2(4, 2), ""),
	make_tip("The Cavalier does 2 damage to each enemy he Tramples through.", \
	"The Cavalier can unleash a strong attack when he has an open path to an enemy. Charge at the enemy!", Vector2(4, 7), ""),
	make_tip("Charge deals 1 damage for each tile travelled.", "Eliminate all remaining enemies.", null, ""),
]
var Level2 = {"allies": level2_allies, "enemies":level2_enemies, "initial_deploy_count":1,
"instructions":level2_instructions, "reinforcements": {}, "next_level":Level3}


#LEVEL 1
var level1_allies = {4: Berserker}

var level1_enemies = [
{ Vector2(4, 4): make(Grunt, 6), 1: make(Grunt, 2), Vector2(1, 1): make(Grunt, 2)},
{2: make(Grunt, 2)},
{3: make(Grunt, 2), 4: make(Grunt, 3), 5: make(Grunt, 2)},
{4: make(Grunt, 2)},
]

var level1_instructions = [
	make_tip("", "Move the Berserker towards the enemy forces.", Vector2(4, 7), "Drag the Berserker to this tile." ),
	make_tip("Enemies move down one tile each turn.",  "Attack the nearby enemy.", Vector2(4, 5), "Drag the Berserker to this enemy."),
	make_tip("The Berserker deals 3 damage per direct attack.",  "Finish off the enemy.", Vector2(4, 6), ""),
	make_tip("When The Berserker kills an enemy, it lands on their tile. ", \
	 "The next group of enemies is outside of attack range. Move the Berserker next to them to trigger its passive ability.", \
	 Vector2(2, 4), ""),
	make_tip("When the Berserker lands on a tile, his passive deals 2 damage to adjacent enemies.", \
	"Kill the remaining enemies in one move.", null, "")
]

var Level1 = {"allies":level1_allies, "enemies":level1_enemies, "initial_deploy_count":1, 
"instructions":level1_instructions, "reinforcements": {}, "next_level": Level2}





