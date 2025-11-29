extends Node2D

@onready var rich_text_label: RichTextLabel = $ColorRect/RichTextLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var sayings = [
	"Thanks ye yella cowboy!",
	"Fancy a pint?",
	"I got dem bullets",
	"Buy some more!",
	"It's hot out here",
	"Need a cold one?",
	"Get ya bullet here!",
	"Sing us a tune outlaw",
	"What's yer name again?",
	"Met a lady last night...",
	"Load up the chamber!",
	"You hear of a devil cactus?",
	"These working conditions!",
	"My horse was stolen today...",
	"No sheriff round these parts"
]

var said_sayings = []

func play_saying():
	var rng = RandomNumberGenerator.new()
	var random_saying_index = 0
	var random_saying = ""
	
	# pop
	if len(sayings) <= 0:
		sayings = said_sayings.duplicate(true)
		said_sayings.clear()
	
	random_saying_index = rng.randi_range(0,len(sayings) - 1)
	random_saying = sayings.pop_at(random_saying_index)
	said_sayings.push_back(random_saying)
	
	# set to text
	rich_text_label.text = "[center]" + random_saying + "[/center]"
	
	# play animation
	animation_player.play("say")
