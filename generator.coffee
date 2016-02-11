
after = (ms, fn)-> setTimeout(fn, ms)
every = (ms, fn)-> setInterval(fn, ms)

$cards = $("<main class='cards'/>").appendTo("body")

render_card = ({name, description, category, attack, defence, cost, major_types, minor_types, arrows, source})->
	$card = $("<div class='card'/>").appendTo($cards)
	
	major_types_text = (major_types).join " "
	minor_types_text = (minor_types).join ", "
	
	$card.addClass(category)
	
	$card.html """
		<div class='header'>
			#{if cost? then "<span class='money'><span>#{cost}</span></span>" else ""}
			<span class='name'>#{name}</span>
		</div>
		<div class='categorical-bar'>
			<div class='category' style='float: left'>#{category}</div>
			<div class='major-types' style='float: right'>#{major_types_text}</div>
		</div>
		<div class='image'>
			<img class='img' src='images/#{name}.png'>
		</div>
		<div class='description'>#{description}</div>
		<div class='lower'>
			#{if attack? then "<div class='attack-defence'>#{attack}/#{defence}</div>" else ""}
			<div class='minor-types' style='float: left'>#{minor_types_text}</div>
		</div>
		<div class='arrows'></div>
	"""
	
	arrow_order = ["place", "any", "force"]
	
	for arrow_category in arrows.sort((a, b)-> arrow_order.indexOf(a) - arrow_order.indexOf(b))
		$card.find(".arrows").append("<div class='arrow #{arrow_category}'>")
	
	$card.attr("data-source", source)


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
	
	cards = data.split "\f"
	for card_text in cards when card_text.trim() isnt ""
		
		name = ""
		description = ""
		major_types = []
		minor_types = []
		arrows = []
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
					minor_types = minor_types.filter (mt)->
						for type_major_char, major_type_name of major_type_names
							if mt.toLowerCase() is major_type_name.toLowerCase()
								return no
						yes
				else if m = line.match /^["“](.*)["”]$/
					# Flavor Text
					description += "<q>#{m[1]}</q>"
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
					unless line.match /none|n\/a/
						for arrow_def in line.split(",")
							match = arrow_def.match /(\d+)(f|p|a)/
							if match
								[_, n_arrows, arrow_category] = match
								arrows.push category_class_names[arrow_category] for [0...parseInt(n_arrows)]
							else
								console.error "Arrow definitions for #{name} don't jive: #{line}"
				when 4
					# Attack / Defence
					if m = line.match /^(-?\d+) \/ (-?\d+)$/
						attack = parseFloat m[1]
						defence = parseFloat m[2]
					else
						from_content_context()
				else
					from_content_context()
		
		console?.assert? category?, "no category"
		
		render_card {name, description, category, attack, defence, cost, major_types, minor_types, arrows, source: card_text}
	
	$("<div class='card back'/>").appendTo($cards)

$.get "cards.txt", parse_card_data

