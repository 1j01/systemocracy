gui = require "nw.gui"
fs = require "fs"

css = """
	body {
		zoom: 2;
	}
	.card {
		margin: 0;
	}
"""

options =
	url: "index.html"
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

{width, height, url, format, evalDelay, code, delay, encoding} = options

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
				console.log "got some image data"
				win.close true
				fs.writeFile "cardz.png", buffer, (err)->
					throw err if err
					console.log "k"
					gui.Window.get().close true
			, {format, datatype}
		, evalDelay
	, delay
