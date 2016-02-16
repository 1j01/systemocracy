
after = (ms, fn)-> setTimeout(fn, ms)
every = (ms, fn)-> setInterval(fn, ms)

$cards = $("<main class='cards'/>").appendTo("body")

render_$card = ({name, description, category, attack, defence, cost, major_types, minor_types, arrows, source})->
	$card = $("<div class='card'/>")
	
	arrow_order = ["place", "any", "force"]
	minor_types_order = ["income", "revolutionary", "flying", "naval", "electronic", "human", "single"]
	
	minor_types.sort (a, b)->
		minor_types_order.indexOf(a) - minor_types_order.indexOf(b)
	
	major_types_text = major_types.join(" ")
	minor_types_text = minor_types.join(", ")
	
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
			<img class='img' src='images/cards/#{name}.png'>
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


$.get "cards.json", (cards)->
	
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


