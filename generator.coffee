
after = (ms, fn)-> setTimeout(fn, ms)
every = (ms, fn)-> setInterval(fn, ms)

$cards = $("<main class='cards'/>").appendTo("body")

render_$card = ({name, description, category, attack, defence, cost, major_types, minor_types, arrows, source})->
	$card = $("<div class='card'/>")
	
	arrow_order = ["place", "any", "force"]
	minor_types_order = ["income", "revolutionary", "flying", "naval", "electronic", "human", "single"]
	
	minor_types.sort (a, b)->
		minor_types_order.indexOf(a) - minor_types_order.indexOf(b)
	
	major_types_text = (major_types).join " "
	minor_types_text = (minor_types).join ", "
	
	$card.addClass(category)
	
	$card.html """
		<div class='header'>
			#{if cost? then "<span class='money'><span>#{cost}</span></span>" else ""}
			<span class='name'>#{name}</span>
		</div>
		<div class='categorical-bar'>
			<div class='category'>#{category}</div>
			<div class='major-types'>#{major_types_text}</div>
		</div>
		<div class='image'>
			<img class='img' src='images/#{name}.png'>
		</div>
		<div class='description'>#{description}</div>
		<div class='lower'>
			#{if attack? then "<div class='attack-defence'>#{attack}/#{defence}</div>" else ""}
			<div class='minor-types'>#{minor_types_text}</div>
		</div>
		<div class='arrows'></div>
	"""
	
	for arrow_category in arrows.sort((a, b)-> arrow_order.indexOf(a) - arrow_order.indexOf(b))
		$card.find(".arrows").append("<div class='arrow #{arrow_category}'>")
	
	$card.attr("data-source", source)
	$card


parse_card_data = (data)->
	
	major_type_names =
		C: "Corporate"
		O: "Occult"
		M: "Military"
		N: "Neutral"
		F: "Fantastic"
	
	category_class_names =
		a: "any"
		p: "place"
		f: "force"
		e: "event"
	
	parse_card = (card_text)->
		name = ""
		description = ""
		major_types = []
		minor_types = []
		arrows = []
		attack = undefined
		defence = undefined
		category = undefined
		cost = undefined
		
		lines = card_text.trim().split("\n")
		lwt = 0
		for line in lines
			line = line.trim()
			lwt += 1
			
			from_content_context = ->
				return if line is ""
				if line.match /^(([a-z]+, )*[a-z]+)$/
					# Minor Types
					minor_types = line.split /,\s?/
					minor_types = minor_types.filter (mt)->
						for type_major_char, major_type_name of major_type_names
							if mt.toLowerCase() is major_type_name.toLowerCase()
								return no
						yes
				else if m = line.match /^["“](.*)["”]$/
					# Flavor Text
					description += "<p><q>#{m[1]}</q></p>"
				else
					# Description (with symbols)
					money_symbol = (match, money)->
						"<span class='money'><span>#{money}</span></span>"
					
					damage_symbol = (match, damage)->
						"<span class='damage-counter'><span>#{damage}</span></span>"
					
					revolution_symbol = (match, revolutions)->
						"<span class='revolution-counter'><span>#{revolutions}</span></span>"
					
					bold = (match, text)->
						"<b>#{text}</b>"
					
					description += "<p>#{
						line
							.replace /\b(X|\d*)m\b/g, money_symbol
							.replace /\b(X|\d*)d\b/g, damage_symbol
							.replace /\b(X|\d*)r\b/g, revolution_symbol
							.replace /\b(Condition:|Action:)/g, bold
					}</p>"
			
			switch lwt
				when 1
					if (line.indexOf " - ") isnt -1
						[name, cost_str, type_major_str] = line.split " - "
						unless cost_str.match /n\/a/i
							cost = parseFloat cost_str
							cost = cost_str.replace(/m/, "") if isNaN(cost)
						major_types = for type_major_char in type_major_str
							major_type_names[type_major_char]
					else
						# Name
						name = line
				when 2
					# Category
					category = line
				when 3
					# Arrows
					if line is ""
						lwt += 1
					else
						unless line.match /none|n\/a/
							for arrow_def in line.split(",")
								match = arrow_def.match /(\d+)(f|p|a)/
								if match
									[_, n_arrows, arrow_category] = match
									arrows.push category_class_names[arrow_category] for [0...parseInt(n_arrows)]
								else
									console.error "Arrow definitions for #{name} don't jive: #{line}"
				when 5
					# Attack / Defence
					if m = line.match /^(-?\d+) \/ (-?\d+)$/
						attack = parseFloat m[1]
						defence = parseFloat m[2]
					else
						from_content_context()
				else
					from_content_context()
		
		console?.assert? category?, "no category"
		
		{name, description, category, attack, defence, cost, major_types, minor_types, arrows, source: card_text}
	
	
	card_texts = data.split "\f"
	cards = 
		for card_text in card_texts when card_text.trim() isnt ""
			parse_card card_text
	
	cards_by_export = {}
	for card in cards
		if card.category is "system"
			header = "Systems"
		else
			[header] = card.major_types
		cards_by_export[header] ?= []
		cards_by_export[header].push card
	
	export_only = location.hash.replace /#/, ""
	
	for header, sorted_cards of cards_by_export when (not export_only) or (export_only.toLowerCase() is header.toLowerCase())
		$("<h2>").text(header).appendTo($cards)
		for card in sorted_cards
			render_$card(card).appendTo($cards)
		if export_only
			$("<div class='card back'/>").appendTo($cards) for [sorted_cards.length...10*7]
		else
			$("<div class='card back'/>").appendTo($cards)

$.get "cards.txt", parse_card_data

