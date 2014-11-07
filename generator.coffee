
E = (e)->
	parts = e.split '.'
	tagName = parts[0]
	$e = document.createElement tagName
	$e.className = parts[1] if parts[1]
	$e

$id = (id)-> document.getElementById id

after = (ms, fn)-> setTimeout(fn, ms)
every = (ms, fn)-> setInterval(fn, ms)



render_cards = (data)->
	
	$e = document.body
	
	major_type_names =
		C: "Corporate"
		O: "Occult"
		M: "Military"
		N: "Neutral"
		F: "Fantastic"
	
	cards = data.split "\f"
	for card_text, card_index in cards
		
		if card_text.match /^[\s\r\n]*$/
			continue
		
		$container = E "div.container"
		$card = E "div.card"
		name = ""
		description = ""
		major_types = ""
		minor_types = ""
		attack = undefined
		defence = undefined
		category = undefined
		cost = undefined
		
		lines = card_text.split "\n"
		lwt = 0
		for line in lines
			line = line.trim()
			if line.match /^[\s\n\r]*$/m
				continue
			
			lwt += 1
			from_context = ->
				if line.match /^(([a-z]+, )*[a-z]+)$/
					# Minor Types
					minor_types = line
				else if m = line.match /^["“](.*)["”]$/
					# Flavor Text
					description += "<q>#{m[1]}</q>"
				else
					# Description (with money symbols)
					description += "<p>#{
						line.replace /(\d+)m/g, (m, m1)->
							"<div class='money'><div>#{m1}</div></div>"
					}</p>"
			
			switch lwt
				when 1
					if (line.indexOf " - ") isnt -1
						# Name - Play Cost - Type Major
						segs = line.split " - "
						name = segs[0]
						cost = parseFloat segs[1]
						cost = undefined if isNaN cost
						major_types = segs[2]
					else
						# Name
						name = line
				when 2
					# Category
					category = line
				when 3
					# Attack / Defence
					if m = line.match /^(-?\d+) \/ (-?\d+)$/
						attack = parseFloat m[1]
						defence = parseFloat m[2]
					else
						from_context()
				else
					from_context()
		
		console?.assert? category?, "no category"
		
		major_types_text = (
			for type_char in major_types
				major_type_names[type_char]
		).join " "
		
		#	<div class='back'>
		#		this is the back lol
		#	</div>
		#	<div class='front'>
		$card.innerHTML = """
			<div class='header'>
				<div class='name'>#{name}</div>
				#{if cost? then "<div class='money'><div>#{cost}</div></div>" else ""}
			</div>
			<div class='subheader'>
				<div class='category subthing' style='float: left'>#{category}</div>
				<div class='major-types subthing' style='float: right'>#{major_types_text}</div>
			</div>
			<div class='image'>
				<img class='img' src='images/#{name}.png'>
			</div>
			<div class='lower'>
				#{if attack? then "<br><div class='attack-defence'>#{attack}/#{defence}</div>" else ""}
				<div class='description'>#{description}</div>
				<div class='id'>#{card_index + 1}</div>
				<div class='minor-types'>#{minor_types}</div>
			</div>
		"""
		#	</div>
						# (for type in minor_types.split(", ")
						# 	"<a href='https://twitter.com/hashtag/#{type}'>#{type}</a>"
						# ).join " "
		
		$card.querySelector("img").onerror = do (name)-> ->
			@onerror = null
			google_image name, (src)=>
				@src = src
		
		$card.style.backgroundPosition = "#{Math.random()*5000}px #{Math.random()*5000}px"
		
		###sat = 90
		lit = 50
		switch category
			when "force" then hue = 160
			when "static" then hue = 0
			when "place" then hue = 40
			when "permanent" then hue = 230
			else sat = 0; hue = 0
		
		$card.style.backgroundColor = "hsla(#{hue}, #{sat}%, #{lit}%, 1)"
		$card.style.boxShadow = "
			0 0 250px 10px hsla(#{hue-40}, #{sat-10}%, #{lit+30}%, 0.9) inset,
			0 0 250px 10px hsla(#{hue-40}, #{sat-10}%, #{lit+30}%, 0.9) inset,
			0 0 250px 10px rgba(20,0,0,0.9) inset
		";###
		
		$container.appendChild($card)
		$e.appendChild($container)



xhr = new XMLHttpRequest

xhr.onerror = ->
	alert "error"

xhr.onreadystatechange = ->
	if xhr.readyState is 4
		render_cards xhr.responseText

xhr.open "GET", "cards.txt"
xhr.send()




searches_to_execute = []
google_image = (query, callback)->
	searches_to_execute.push {query, callback}




google.load "search", "1", callback: ->

	searcher = new google.search.ImageSearch()
	searcher.setNoHtmlGeneration()
	searcher.setResultSetSize(1)
	searcher.setRestriction(
		google.search.ImageSearch.RESTRICT_IMAGESIZE
		google.search.ImageSearch.IMAGESIZE_MEDIUM
	)
	do next = ->
		iid = setInterval ->
			if searches_to_execute.length
				clearInterval iid
				searcher.setSearchCompleteCallback @, ->
					do next
					if searcher.results?[0]
						searches_to_execute[0].callback(searcher.results[0].tbUrl)
						#searches_to_execute[0].callback(searcher.results[0].url)
					else
						console.error "no search results: ", searcher
					
					searches_to_execute.splice 0, 1
				, null
				searcher.execute searches_to_execute[0].query
		, 100
	
	#causes an error
	#google.search.Search.getBranding('branding')

