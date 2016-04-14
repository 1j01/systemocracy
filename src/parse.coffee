
module.exports = (all_card_data)->
	
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
	
	parse_card = (card_data)->
		name = ""
		description = ""
		flavor_text = ""
		major_types = []
		minor_types = []
		arrows = []
		attack = undefined
		defense = undefined
		category = undefined
		cost = undefined
		
		lines = card_data.trim().split("\n")
		lwt = 0
		for line in lines
			line = line.trim()
			lwt += 1
			
			from_content_context = ->
				return if line is ""
				if m = line.match /^(\d+) \/ (\d+)$/
					# Attack / Defense
					attack = parseFloat m[1]
					defense = parseFloat m[2]
				else if line.match /^(([a-z]+, )*[a-z]+)$/
					# Minor Types
					minor_types = line.split /,\s?/
					minor_types = minor_types.filter (mt)->
						for type_major_char, major_type_name of major_type_names
							if mt.toLowerCase() is major_type_name.toLowerCase()
								return no
						yes
				else if m = line.match /^["“](.*)["”]$/
					# Flavor Text
					flavor_text = "<p><q>#{m[1]}</q></p>"
				else
					# Description
					description += "<p>#{line}</p>"
			
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
					category = line.toLowerCase()
				when 3
					# Arrows
					if line is ""
						lwt += 1
					else
						unless line.match /none|n\/a/i
							for arrow_def in line.split(",")
								match = arrow_def.match /(\d+)(f|p|a)/i
								if match
									[_, n_arrows, arrow_category] = match
									arrows.push category_class_names[arrow_category] for [0...parseInt(n_arrows)]
								else
									console.error "Arrow definitions for #{name} don't jive: #{line}"
				else
					from_content_context()
		
		console?.assert? category?, "no category"
		
		{name, description, flavor_text, category, attack, defense, cost, major_types, minor_types, arrows, source: card_data}
	
	
	card_datas = all_card_data.split /\f|________________/
	for card_data in card_datas when card_data.trim().match /\n/im
		parse_card card_data
