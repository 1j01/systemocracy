
image_export_url_base = "https://raw.githubusercontent.com/1j01/cards/gh-pages/images/export"

make_deck = (deck_name, cards_in_set, position_x)->
	
	CustomDeck =
		"1":
			FaceURL: "#{image_export_url_base}/#{deck_name}.png"
			BackURL: "#{image_export_url_base}/Back.png"
			NumWidth: 10,
			NumHeight: 7,
			BackIsHidden: no
	
	id_counter = 100
	
	make_card = ->
		Name: "Card"
		Transform:
			posX: -0.7677575
			posY: 1.56185019
			posZ: -0.600654542
			rotX: 0.006403894
			rotY: 179.974472
			rotZ: 179.99202
			scaleX: 1.0
			scaleY: 1.0
			scaleZ: 1.0
		Nickname: ""
		Description: ""
		ColorDiffuse:
			r: 0.713243067
			g: 0.713243067
			b: 0.713243067
		Locked: no
		Grid: yes
		Snap: yes
		Autoraise: yes
		Sticky: yes
		CardID: id_counter++
		SidewaysCard: no
		CustomDeck: CustomDeck
		LuaScript: ""
		GUID: "ea94f7"
	
	cards = (make_card(card) for card in cards_in_set)
	
	Name: "DeckCustom"
	Transform:
		posX: position_x
		posY: 1.25730264
		posZ: -0.000734800939
		rotX: -4.125913e-07
		rotY: 179.960922
		rotZ: 180.0
		scaleX: 1.0
		scaleY: 1.0
		scaleZ: 1.0
	Nickname: ""
	Description: ""
	ColorDiffuse:
		r: 0.713243067
		g: 0.713243067
		b: 0.713243067
	Locked: no
	Grid: yes
	Snap: yes
	Autoraise: yes
	Sticky: yes
	SidewaysCard: no
	DeckIDs: (card.CardID for card in cards)
	CustomDeck: CustomDeck
	LuaScript: ""
	ContainedObjects: cards
	GUID: "48d1a6"

make_infinite_bag = (object, position_x)->
	Name: "Infinite_Bag"
	Transform:
		posX: position_x - 11
		posY: 5
		posZ: 5
		rotX: -5.922744e-05
		rotY: 359.563446
		rotZ: -0.003366101
		scaleX: 0.75
		scaleY: 0.75
		scaleZ: 0.75
	Nickname: ""
	Description: ""
	ColorDiffuse:
		r: 0.3058885
		g: 0.372555166
		b: 1.0
	Locked: false
	Grid: true
	Snap: true
	Autoraise: true
	Sticky: true
	MaterialIndex: -1
	MeshIndex: -1
	LuaScript: ""
	ContainedObjects: [object]
	GUID: "431ce5"

make_counter_tile = (counter)->
	Name: "Custom_Tile"
	Transform:
		posX: -11.6647787
		posY: 2.44301963
		posZ: 1.71856892
		rotX: 11.5853672
		rotY: 330.263062
		rotZ: 351.876923
		scaleX: 0.274931431
		scaleY: 1.0
		scaleZ: 0.274931431
	Nickname: ""
	Description: ""
	ColorDiffuse:
		r: 0.0
		g: 0.0
		b: 0.122524768
	Locked: false
	Grid: true
	Snap: true
	Autoraise: true
	Sticky: true
	CustomImage:
		ImageURL: "https://raw.githubusercontent.com/1j01/cards/gh-pages/images/counters/#{counter.plus}"
		ImageSecondaryURL: "https://raw.githubusercontent.com/1j01/cards/gh-pages/images/counters/#{counter.minus}"
		WidthScale: 0.0
		CustomTile:
			Type: 2
			Thickness: 0.1
			Stackable: true
	LuaScript: ""
	GUID: "3c4df3"

make_counter_token = (counter)->
	Name: "Custom_Token"
	Transform:
		posX: -1.57679212
		posY: 1.1973033
		posZ: 6.25402451
		rotX: 0.203478456
		rotY: 165.02063
		rotZ: 0.12986508
		scaleX: 0.165484071
		scaleY: 1.0
		scaleZ: 0.165484071
	Nickname: ""
	Description: ""
	ColorDiffuse:
		r: 1.0
		g: 1.0
		b: 1.0
	Locked: false
	Grid: true
	Snap: true
	Autoraise: true
	Sticky: true
	CustomImage:
		ImageURL: "https://raw.githubusercontent.com/1j01/cards/gh-pages/images/counters/#{counter.fname}"
		ImageSecondaryURL: ""
		WidthScale: 0.0
		CustomToken:
			Thickness: 0.1
			MergeDistancePixels: 5.0
			Stackable: true
	LuaScript: ""
	GUID: "a6f7c1"

make_counter = (counter_name, counter)->
	switch counter.type
		when "token"
			make_counter_token(counter)
		when "tile"
			make_counter_tile(counter)

fs = require "fs"

make_save = ->
	card_set_names = ["Systems", "Neutral", "Corporate", "Military", "Occult"]

	card_sets = JSON.parse fs.readFileSync "data/cards.json", "utf8"
	
	counters = {}
	for fname in fs.readdirSync "images/counters"
		if fname.match /\.png/
			counter_name = fname.replace /[\-.].*/, ""
			if m = fname.match /-(plus|minus)/
				plus_minus = m[1]
				counters[counter_name] ?= {type: "tile"}
				counters[counter_name][plus_minus] = fname
			else
				counters[counter_name] = {type: "token", fname}
	
	save =
		SaveName: ""
		GameMode: ""
		Date: ""
		Table: ""
		Sky: ""
		Note: ""
		Rules: ""
		PlayerTurn: ""
		LuaScript: ""
		ObjectStates: []
		TabStates: {}
	
	position_counter = 0
	for set_name, cards_in_set of card_sets
		save.ObjectStates.push make_deck set_name, cards_in_set, position_counter += 2.3
	
	position_counter = 10
	for counter_name, counter of counters
		save.ObjectStates.push make_infinite_bag(make_counter(counter_name, counter), position_counter += 2.3)
	
	save

save = make_save()
save_json = JSON.stringify(save, null, 2)
save_name = "Card Game"

try fs.mkdirSync "data"
try fs.mkdirSync "data/export"
fs.writeFileSync "data/export/#{save_name}.json", save_json, "utf8"
ts_folder = "#{process.env.USERPROFILE}/Documents/My Games/Tabletop Simulator"
chest_folder = "#{ts_folder}/Saves/Chest"
cache_folder = "#{ts_folder}/Mods/Images"
try fs.writeFileSync "#{chest_folder}/#{save_name}.json", save_json, "utf8"
for fname in fs.readdirSync cache_folder
	try fs.unlinkSync "#{cache_folder}/#{fname}"
