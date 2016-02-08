
after = (ms, fn)-> setTimeout(fn, ms)
every = (ms, fn)-> setInterval(fn, ms)

$cards = $("<main class='cards'/>").appendTo("body")

render_card = ({name, description, category, attack, defence, cost, major_types, minor_types, arrows, card_index, source})->
	$card = $("<div class='card'/>").appendTo($cards)
	
	major_types_text = (major_types).join " "
	minor_types_text = (minor_types).join ", "
	
	$card.addClass(category)
	
	$card.html """
		<div class='header'>
			#{if cost? then "<span class='money'><span>#{cost}</span></span>" else ""}
			<span class='name'>#{name}</span>
		</div>
		<div class='upper-stat-bar'>
			<div class='category' style='float: left'>#{category}</div>
			<div class='major-types' style='float: right'>#{major_types_text}</div>
		</div>
		<div class='image'>
			<img class='img' src='images/#{name}.png'>
		</div>
		<div class='description'>#{description}</div>
		<div class='id'>#{card_index + 1}</div>
		<div class='lower'>
			#{if attack? then "<div class='attack-defence'>#{attack}/#{defence}</div>" else ""}
			<div class='minor-types' style='float: left'>#{minor_types_text}</div>
		</div>
		<div class='arrows'></div>
	"""
	
	for [0..arrows]
		$card.find(".arrows").append("<div class='arrow'>")
	
	$card.attr("data-source", source)


parse_card_data = (data)->
	
	major_type_names =
		C: "Corporate"
		O: "Occult"
		M: "Military"
		N: "Neutral"
		F: "Fantastic"
	
	cards = data.split "\f"
	for card_text, card_index in cards when card_text.trim() isnt ""
		
		name = ""
		description = ""
		major_types = []
		minor_types = []
		arrows = 0
		attack = undefined
		defence = undefined
		category = undefined
		cost = undefined
		
		lines = card_text.split "\n"
		lwt = 0
		for line in lines when line.trim() isnt ""
			line = line.trim()
			lwt += 1
			
			from_content_context = ->
				if line.match /^(([a-z]+, )*[a-z]+)$/
					# Minor Types
					minor_types = line.split /,\s?/
				else if m = line.match /^["“](.*)["”]$/
					# Flavor Text
					description += "<q>#{m[1]}</q>"
				else
					# Description (with money symbols)
					money_symbol = (match, money)->
						"<span class='money'><span>#{money}</span></span>"
					
					description += "<p>#{
						line.replace /\b(X|\d*)m\b/g, money_symbol
					}</p>"
			
			switch lwt
				when 1
					if (line.indexOf " - ") isnt -1
						[name, cost_str, type_major_str, arrows_str] = line.split " - "
						unless cost_str.match /n\/a/i
							cost = parseFloat cost_str
							cost = cost_str.replace(/m/, "") if isNaN(cost)
						major_types = for type_major_char in type_major_str
							major_type_names[type_major_char]
						arrows = parseFloat arrows_str
					else
						# Name
						name = line
				when 2
					# Category
					category = line
				# when 3
				# 	# Arrows
				# 	if line is "none"
				# 		arrows = 0
				# 	else
				# 		arrows = parseInt(line)
				when 3
					# Attack / Defence
					if m = line.match /^(-?\d+) \/ (-?\d+)$/
						attack = parseFloat m[1]
						defence = parseFloat m[2]
					else
						from_content_context()
				else
					from_content_context()
		
		console?.assert? category?, "no category"
		
		render_card {name, description, category, attack, defence, cost, major_types, minor_types, arrows, card_index, source: card_text}
	
	$("<div class='card back'/>").appendTo($cards)

$.get "cards.txt", parse_card_data

