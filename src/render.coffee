
after = (ms, fn)-> setTimeout(fn, ms)
every = (ms, fn)-> setInterval(fn, ms)

$cards = $("<main class='cards'/>").appendTo("body")

render_$card = ({name, description, flavor_text, category, attack, defense, cost, major_types, minor_types, arrows, source})->
	$card = $("<div class='card'/>")
	
	arrow_order = ["place", "any", "force"]
	minor_types_order = ["income", "revolutionary", "flying", "naval", "electronic", "human", "single"]
	
	minor_types.sort (a, b)->
		minor_types_order.indexOf(a) - minor_types_order.indexOf(b)
	
	major_types_text = major_types.join(" ")
	minor_types_text = minor_types.join(", ")
	
	$card.addClass(category)
	
	money_symbol = (match, money)->
		"<span class='money'><span>#{money}</span></span>"
	
	damage_symbol = (match, damage)->
		"<span class='damage-counter'><span>#{damage}</span></span>"
	
	revolution_symbol = (match, revolutions)->
		"<span class='revolution-counter'><span>#{revolutions}</span></span>"
	
	bold = (match, text)->
		"<b>#{text}</b>"
	
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
			<img class='img' src='images/cards/#{name}.jpg'>
		</div>
		<div class='flavor-text'>#{
			flavor_text
		}</div>
		<div class='description'>#{
			description
				.replace /\b(Condition:|(?:Economy )?Action:|Stability:)/gi, bold
				.replace ///
				\b(
					# Attributes
					Unblockable|Untargetable|Hidden|
					# Misc
					Upkeep|Child(ren)?|(?:Economy\ )?Actions?|
					# These phrases
					At\ the\ (beginning|end)\ of\ your\ (next\ )?turn|
					# Verbs
					Immediate(ly)?|Gain(s|ed)?|Remove(s|d)?|Spend(s|ed)?|Destroy(s|ed)?|Target(s|ed)?|
					# Catagories
					Revolution|Forces?|Places?|Events?|Permanents?|Systems?|
					# Types
					-?Types?|Occult|Military|Corporate|Electronic|Single|Human|Flying|Naval|Income|Revolutionary|Drug|
					# Logic
					If|Else|Or|Not|Unless|Non-
				)\b
				///gi, bold
				# Attack/defense
				.replace /\b(X|\d*)m\b/gi, money_symbol
				.replace /\b(X|\d*)d\b/gi, damage_symbol
				.replace /\b(X|\d*)r\b/gi, revolution_symbol
				.replace /(\ [+-]?\d+(?:\ \/\ [+-]?\d+)?)/g, bold
		}</div>
		<div class='lower'>
			#{if attack? then "<div class='attack-defense'>#{attack}/#{defense}</div>" else ""}
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
