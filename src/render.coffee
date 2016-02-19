
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


$.getJSON "data/cards.json", (cards)->
	
	export_only = location.hash.replace /#/, ""
	
	for set_name, sorted_cards of cards when (not export_only) or export_only is set_name
		$("<h2>").text(set_name).appendTo($cards)
		for card in sorted_cards
			render_$card(card).appendTo($cards)
		if export_only
			$("<div class='card back'/>").appendTo($cards) for [sorted_cards.length...10*7]
	if (not export_only) or export_only is "Back"
		$("<h2>").text("Back").appendTo($cards)
		$("<div class='card back'/>").appendTo($cards)
