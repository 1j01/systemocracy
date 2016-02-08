
compare = require('buffer-compare')
gui = nwrequire('nw.gui')

options = JSON.parse(gui.App.argv.toString())
{width, height, url, format, evalDelay, eval, delay, encoding} = options

datatype = if encoding is 'base64' then 'raw' else 'buffer'

newline = Buffer('\n')

capture = (e, cb) ->
	win.eval null, e if e
	setTimeout ->
		win.capturePage (buffer) ->
			if buffer.toString('utf', 0, 10) is 'data:image'
				process.stdout.write buffer
				process.stdout.write newline
				cb()
		, {format, datatype}
	, evalDelay

close = ->
	win.close true
	gui.Window.get().close true

# Needed if the procces is running in a framebuffer (like on travis)
show = process.env.NWSHOT_SHOW is '1'
gui.Window.get().show() if show

if process.platform is 'linux'
	height += 38

win = gui.Window.open url, {width, height, show, frame: show}

win.once 'document-end', ->
	setTimeout ->
		if Array.isArray(options.eval)
			((e) ->
				capture e, ->
					unless options.eval.length
						return close()
					recurse options.eval.shift()
			) options.eval.shift()
		capture options.eval, close
	, options.delay
