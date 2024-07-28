extends Node

var level = 0
var health

const SCREEN_DIVISION_X = 244

const timer_durations_s = {
	"eye_contact" : [14.0, 12.0, 12.0, 10.0, 9.0],
	"hand_fidget" : [7.0, 7.0, 6.0, 6.0, 4.0],
	"dialogue" : [8.0, 8.0, 7.0, 7.0, 6.0]
}

const heat_speeds = [20.0, 22.0, 24.0, 28.0, 32.0]

const event_delay_ranges = [[5, 10], [4, 8], [3, 7], [3, 5], [2, 4]]

const dialogue_options = [
	{"loveinterest": "What's your favorite food?", "correct": "Pizza", "wolfy": "People"}
]
