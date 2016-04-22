
fs = require "fs"
CardGameGenerator = require "card-game-generator"

counters = {}
for fname in fs.readdirSync "images/counters"
	if fname.match /\.png/
		counter_name = fname.replace /[\-.].*/, ""
		if m = fname.match /-(front|back)/
			front_back = m[1]
			counters[counter_name] ?= {type: "tile"}
			counters[counter_name][front_back] = fname
		else
			counters[counter_name] = {type: "token", fname}

cgg = new CardGameGenerator
	cardSets: JSON.parse(fs.readFileSync("data/cards.json", "utf8"))
	counters: counters
	imagesURL: "https://raw.githubusercontent.com/1j01/cards/gh-pages/images"
	exportedImagesURL: "https://raw.githubusercontent.com/1j01/cards/gh-pages/images/export"

cgg.export
	page: "index.html"
	cardWidth: 225
	cardHeight: 325
	scale: 2
	debug: off
	exportFolder: "images/export/"
	(err)->
		throw err if err
		cgg.exportToTabletopSimulator
			exportFolder: "export/"
			saveName: "Card Game"
