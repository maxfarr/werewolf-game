extends Node

var level = 4
var health

var first_dialogue = true
var instructions_read = false

const timer_durations_s = {
	"eye_contact" : [12.0, 10.0, 10.0, 8.0, 7.0],
	"hand_fidget" : [7.0, 7.0, 6.0, 6.0, 4.0],
	"dialogue" : [9.0, 9.0, 8.0, 8.0, 7.0],
	"intrusive_thoughts" : [6.0, 6.0, 6.0, 5.5, 5.0]
}

const intrusive_thoughts_number = [3, 3, 5, 5, 5]

const heat_speeds = [20.0, 22.0, 24.0, 28.0, 32.0]

const event_delay_ranges = [[5, 10], [4, 8], [3, 7], [3, 5], [2, 4]]

const intrusive_thought_options = [
	"You're being boring!",
	"You suck!",
	"You should go home!",
	"ANXIETY",
	"Hey! Hey! Hey!",
	"Your nose is itching",
	"[painful memory]",
	"That was CRINGE",
	"Why did you say that?!", 
	"Stop being a weirdo!"
]

const dialogue_options = [
	{"loveinterest": "What's your favorite food?", "correct": "Pizza", "wolfy": "People"},
	{"loveinterest": "What's your favorite game?", "correct": "Kingdom Hearts", "wolfy": "Fetch"},
	{"loveinterest": "What's your worst habit?", "correct": "Oversleeping", "wolfy": "Biting people"},
	{"loveinterest": "What's your hidden talent?", "correct": "Juggling", "wolfy": "Barking"},
	{"loveinterest": "What's on your bucket list?", "correct": "Skydiving", "wolfy": "Killing a deer"},
	{"loveinterest": "What's your pet peeve?", "correct": "Rudeness", "wolfy": "Animal control"},
	{"loveinterest": "What's your favorite vacation spot?", "correct": "The beach", "wolfy": "Creepy dungeon"},
	{"loveinterest": "What do you think of Kant's Categorical Imperative?", "correct": "Desire is controllable", "wolfy": "AKJSGHFKGJHASDSDFKGSDKJHGFKJFGKJSAFHFDJHKSFJKSKJHDFJGSKDGHHJDFGSHJKJSDJHKG"},
	{"loveinterest": "What kind of music do you listen to?", "correct": "Fusion Jazz", "wolfy": "Howling"},
	{"loveinterest": "Do you have any hobbies?", "correct": "Pottery", "wolfy": "Chewing on bones"},
	{"loveinterest": "Isn't the full moon beautiful tonight?", "correct": "Yeah", "wolfy": "AWOOOOO"},
]
