gui = require "nw.gui"
fs = require "fs"
async = require "async"

try fs.mkdirSync "images/export"

zoom = 2

css = """
	body {
		zoom: #{zoom};
		text-align: left;
		overflow: hidden;
	}
	h2 {
		display: none;
	}
	.card {
		margin: 0;
	}
"""

options =
	width: 225 * 10 * zoom
	height: 325 * 7 * zoom + 39 # magic number 39, maybe related to the magic 38 for Linux below?
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
	
	show = no
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

export_set = (header, callback)->
	console.log "Export #{header}"
	setTimeout ->
		capture "index.html##{header}", options, (buffer)->
			console.log "Got some image data for #{header}"
			file_name = "images/export/#{header}.png"
			fs.writeFile file_name, buffer, (err)->
				return callback err if err
				console.log "Wrote #{file_name}"
				callback null
	, 5000

set_headers = ["Systems", "Neutral", "Corporate", "Military", "Occult"]
parallel = process.env.PARALLEL_EXPORT in ["on", "ON"]

(if parallel then async.each else async.eachSeries) set_headers, export_set,
	(err)->
		if err
			document.body.style.background = "red"
			throw err
		console.log "done"
		gui.Window.get().close true
