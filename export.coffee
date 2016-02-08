gui = require "nw.gui"
fs = require "fs"

# options = JSON.parse(gui.App.argv.toString())

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
	width: 4800 # 1920 * 2 + 480 * 2
	height: 1080
	format: "png"
	evalDelay: 4000
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

newline = new Buffer("\n")

# capture = (code, callback) ->
# 	win.eval null, code if code
# 	setTimeout ->
# 		win.capturePage callback
# 		# win.capturePage (buffer) ->
# 		# 	if buffer.toString("utf8", 0, 10) is "data:image"
# 		# 		win.close true
# 		# 		callback null, buffer
# 		# 	else
# 		# 		console.log buffer.toString("utf8", 0, 10)
# 		# 		callback new Error "Buffer returned by capturePage does not contain image data, it returned magic instead. Your magic balance has been increased by 350mp."
# 		, {format, datatype}
# 	, evalDelay

show = yes
gui.Window.get().show() if show

win = gui.Window.open url, {width, height, show, frame: show}

win.once "document-end", ->
	win.setMaximumSize width * 2, height * 2
	win.width = width
	win.height = height
	setTimeout ->
		win.height = height
		# capture code, (err)->
		# 	if err
		# 		console.error err
		# 	else
		# 		console.log "k, got some image data"
				
			# gui.Window.get().close true
		# capture code, (buffer)->
		# 	console.log "got some image data"
		# 	fs.writeFile "cardz.png", buffer, (err)->
		# 		throw err if err
		# 		console.log "k"
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
