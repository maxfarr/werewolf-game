extends Node

var level = 0
var health

const SCREEN_DIVISION_X = 244

const timer_durations_s = {
	"eye_contact" : [14.0, 12.0, 12.0, 10.0, 9.0],
	"hand_fidget" : [7.0, 7.0, 6.0, 6.0, 4.0],
	"dialogue" : [9.0, 9.0, 8.0, 8.0, 7.0],
	"intrusive_thoughts" : [6.0, 6.0, 6.0, 6.0, 6.0]
}

const intrusive_thoughts_number = [3, 3, 3, 4, 5]

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
	{"loveinterest": "What's your favorite food?", "correct": "Pizza", "wolfy": "People"}
]
