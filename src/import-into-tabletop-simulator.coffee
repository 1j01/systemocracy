
{moveMouse, mouseToggle, mouseClick, getScreenSize} = require "robotjs"

after = (ms, fn)-> setTimeout fn, ms

{width, height} = getScreenSize()

positions = 
	"Host": [width/2, 30]
	"Chest": [width/2, 120]
	"Cards": [width-120, 120]
	"Custom": [width-420, height-80]

window_offset = [-1920, 30]

click = (thing)->
	position = positions[thing]
	moveMouse position[0] + window_offset[0], position[1] + window_offset[1]
	# mouseClick()
	mouseToggle "down"
	after 50, ->
		mouseToggle "up"

click "Host"
after 300, ->
	click "Chest"
	after 300, ->
		click "Cards"
		after 300, ->
			click "Custom"

# Wait, why am I doing this?
# I should look at the save file format first...
# and oh look, it's basically ideal
