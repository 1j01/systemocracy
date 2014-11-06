
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
					# Type Tags
					minor_types = line
				else if line.match /^["“](.*)["”]$/
					# Flavor Text (?)
					description += "<q>#{
						line.match(/^["“](.*)["”]$/)[1]
					}</q>"
				else
					# Money
					description += "<p>#{
						line.replace /(\d+)m/g, (m, m1)->
							"<span class='money'>
								#{m1}<span class='m'></span>
							</span>"
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
				<span class='name'>#{name}</span>
				#{if cost? then "<span class='cost'>#{cost}<span class='m'></span></span>" else ""}
			</div>
			<div class='subheader'>
				<span class='category subthing' style='float: left'>#{category}</span>
				<span class='major-types subthing' style='float: right'>#{major_types_text}</span>
			</div>
			<div class='image'>
				<img class='img' src='images/#{name}.png'>
			</div>
			<div class='lower'>
				#{if attack? then "<br><span class='yghfhsdf'>#{attack}/#{defence}</span>" else ""}
				<div class='description'>#{description}</div>
				<span class='id'>#{card_index + 1}</span>
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




search = null # ?

google.load "search", "1", callback: ->

	search = new google.search.ImageSearch()
	search.setNoHtmlGeneration()
	search.setResultSetSize(1)
	
	do next = ->
		iid = setInterval ->
			if searches_to_execute.length
				clearInterval iid
				search.setSearchCompleteCallback @, ->
					do next
					if search.results?[0]
						searches_to_execute[0].callback(search.results[0].tbUrl)
					else
						console.error "no results: ", search.results, search
					
					searches_to_execute.splice 0, 1
				, null
				search.execute searches_to_execute[0].query
		, 100
	
	#causes an error
	#google.search.Search.getBranding('branding')

