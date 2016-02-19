
position_counter = -0.7677575

make_deck = (deck_name, cards_in_set)->
	
	CustomDeck =
		"1":
			FaceURL: "https://raw.githubusercontent.com/1j01/cards/gh-pages/images/export/#{deck_name}.png"
			BackURL: "https://raw.githubusercontent.com/1j01/cards/gh-pages/images/export/Back.png"
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
	
	# cards = (make_card() for [0..52])
	cards = (make_card(card) for card in cards_in_set)
	
	Name: "DeckCustom"
	Transform:
		posX: position_counter += 500
		posY: 1.25730264
		posZ: -0.000734800939
		rotX: position_counter #-4.125913e-07
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

fs = require "fs"

make_save_game = ->
	card_set_names = ["Systems", "Neutral", "Corporate", "Military", "Occult"]

	cards = JSON.parse fs.readFileSync "data/cards.json", "utf8"
	
	SaveName: ""
	GameMode: ""
	Date: ""
	Table: ""
	Sky: ""
	Note: ""
	Rules: ""
	PlayerTurn: ""
	LuaScript: ""
	# ObjectStates: (make_deck name for name in card_set_names)
	ObjectStates: (make_deck set_name, cards_in_set for set_name, cards_in_set of cards)
	TabStates: {}

save_game = make_save_game()

try fs.mkdirSync "data"
try fs.mkdirSync "data/export"
fs.writeFileSync "data/export/Card Game.json", JSON.stringify(save_game, null, 2), "utf8"
