
fs = require "fs"
CardGameGenerator = require "card-game-generator"

counters = {}
for fname in fs.readdirSync "images/counters"
	if fname.match /\.png/
		counter_name = fname.replace /[\-.].*/, ""
		if m = fname.match /-(plus|minus)/
			side = {"plus": "obverse", "minus": "reverse"}[m[1]]
			counters[counter_name] ?= {type: "tile"}
			counters[counter_name][side] = fname
		else
			counters[counter_name] = {type: "token", fname}

cardSets = JSON.parse(fs.readFileSync("data/cards.json", "utf8"))

cgg = new CardGameGenerator {cardSets, counters}

console.log "render cards"
cgg.renderCards
	page: "index.html"
	cardWidth: 225
	cardHeight: 325
	scale: 2
	debug: off
	to: "images/export/"
	(err)->
		throw err if err
		console.log "export Tabletop Simulator save"
		cgg.exportTabletopSimulatorSave
			to: "data/export/"
			saveName: "Systemocracy"
			imagesURL: "https://raw.githubusercontent.com/1j01/systemocracy/gh-pages/images"
			renderedImagesURL: "https://raw.githubusercontent.com/1j01/systemocracy/gh-pages/images/export"
			(err)->
				throw err if err
				console.log "export save to Tabletop Simulator's Chest"
				cgg.exportSaveToTabletopSimulatorChest()
				console.log "done"
