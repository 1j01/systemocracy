
after = (ms, fn)-> setTimeout(fn, ms)
every = (ms, fn)-> setInterval(fn, ms)


class $Card extends $
	constructor: ({name, description, category, attack, defence, cost, major_types, minor_types, arrows, card_index})->
		$card = $("<div class='card'/>").appendTo("body")
		# $.fn.init.call $card.get(0)
		
		major_types_text = (major_types).join " "
		minor_types_text = (minor_types).join ", "
		
		# $card.addClass(type) for type in major_types
		# $card.addClass(type) for type in minor_types
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
			<div class='lower-stat-bar'>
				<div class='minor-types' style='float: left'>#{minor_types_text}</div>
				#{if attack? then "<div class='attack-defence' style='float: right'>#{attack}/#{defence}</div>" else ""}
			</div>
			<div class='description'>#{description}</div>
			<div class='id'>#{card_index + 1}</div>
		"""
		
		for arrow in arrows
			$card.append("<div class='arrow #{arrow.in_or_out} #{arrow.direction}'>")
		
		# $card.find("img").one "error", ->
		# 	google_image name, (src)=>
		# 		@src = src
		
		#$card.css backgroundPosition: "#{Math.random()*5000}px #{Math.random()*5000}px"
		
		# sat = 90
		# lit = 50
		# switch category
		# 	when "force" then hue = 160
		# 	when "static" then hue = 0
		# 	when "place" then hue = 40
		# 	when "permanent" then hue = 0; lit = 10
		# 	else sat = 0; hue = 0
		
		# $card.css backgroundColor: "hsla(#{hue}, #{sat}%, #{lit}%, 1)"
		###$card.css boxShadow: "
			0 0 250px 10px hsla(#{hue-40}, #{sat-10}%, #{lit+30}%, 0.9) inset,
			0 0 250px 10px hsla(#{hue-40}, #{sat-10}%, #{lit+30}%, 0.9) inset,
			0 0 250px 10px rgba(20,0,0,0.9) inset
		"###

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
				else if m = line.match /^["“](.*)["”]$/
					# Flavor Text
					description += "<q>#{m[1]}</q>"
				else
					# Description (with money symbols)
					money_symbol = (match, money)->
						"<span class='money'><span>#{money}</span></span>"
					
					description += "<p>#{
						line.replace /(\d+)m/g, money_symbol
					}</p>"
			
			switch lwt
				when 1
					if (line.indexOf " - ") isnt -1
						# Name - Play Cost - Type Major
						segs = line.split " - "
						name = segs[0]
						cost = parseFloat segs[1]
						cost = undefined if isNaN cost # cost is n/a
						major_types = for type_char in segs[2]
							major_type_names[type_char]
						
					else
						# Name
						name = line
				when 2
					# Category
					category = line
				when 3
					# Arrows
					# arrows = []
					# for arrow_descriptor in line.split ","
					# 	[direction, in_or_out] = arrow_descriptor.split " "
					# 	if (direction in ["left", "right", "up", "down"]) and (in_or_out in ["in", "out"])
					# 		arrows.push {direction, in_or_out}
					# 	else
					# 		console.error "Card `#{name}` missing arrows", {direction, in_or_out}
					for arrow_descriptor in line.split ","
						direction = arrow_descriptor.match(/up|down|left|right/)?[0]
						in_or_out = arrow_descriptor.match(/in|out/)?[0]
						if direction and in_or_out
							arrows.push {direction, in_or_out}
						else
							console.error "Card '#{name}' missing arrows", {direction, in_or_out}
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
		
		new $Card {name, description, category, attack, defence, cost, major_types, minor_types, arrows, card_index}



$.get "cards.txt", parse_card_data




search_queue = []
google_image = (query, callback)->
	search_queue.push {query, callback}




google.load "search", "1", callback: ->

	searcher = new google.search.ImageSearch()
	searcher.setNoHtmlGeneration()
	searcher.setResultSetSize(1)
	searcher.setRestriction(
		google.search.ImageSearch.RESTRICT_IMAGESIZE
		google.search.ImageSearch.IMAGESIZE_MEDIUM
	)
	do next = ->
		after 100, ->
			if search_queue.length
				search = search_queue.shift()
				searcher.setSearchCompleteCallback @, ->
					do next
					if searcher.results?[0]
						search.callback(searcher.results[0].tbUrl)
						# search.callback(searcher.results[0].url)
					else
						console.error "no search results: ", searcher
				
				searcher.execute search.query
	
	google.search.Search.getBranding $("<div/>").appendTo("body").get(0)

