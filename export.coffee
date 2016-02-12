gui = require "nw.gui"
fs = require "fs"

try fs.mkdirSync "export"

css = """
	body {
		zoom: 2;
		text-align: left;
	}
	h2 {
		display: none;
	}
	.card {
		margin: 0;
	}
"""

options =
	width: 4800
	height: 6000
	format: "png"
	evalDelay: 14000
	code: """
		var css = #{JSON.stringify(css)};
		var style = document.createElement('style');
		style.type = 'text/css';
		style.appendChild(document.createTextNode(css));
		document.head.appendChild(style);
	"""
	delay: 500
	encoding: "binary"

capture = (url, {width, height, format, evalDelay, code, delay, encoding}, callback)->

	height += 38 if process.platform is "linux"

	datatype = if encoding is "base64" then "raw" else "buffer"

	show = yes
	gui.Window.get().show() if show

	win = gui.Window.open url, {width, height, show, frame: show}

	win.once "document-end", ->
		win.setMaximumSize width * 2, height * 2
		win.width = width
		win.height = height
		setTimeout ->
			win.eval null, code if code
			setTimeout ->
				win.capturePage (buffer)->
					win.close true
					callback buffer
				, {format, datatype}
			, evalDelay
		, delay

for header in ["Systems", "Neutral", "Corporate", "Military", "Occult"]
	do (header)->
		capture "index.html##{header}", options, (buffer)->
			console.log "Got some image data for #{header}"
			
			file_name = "export/#{header}.png"
			fs.writeFile file_name, buffer, (err)->
				throw err if err
				console.log "Wrote #{file_name}"
				gui.Window.get().close true
