
webshot = require "webshot"

webshot "./index.html", "./cards.png",
	siteType: "file"
	windowSize:
		width: 1920 * 2
		height: 1080
	shotSize:
		width: "window"
		height: "all"
	customCSS: ".card { margin: 0 !important; } body { zoom: 2; }"
	renderDelay: 200
	errorIfStatusIsNot200: yes
	errorIfJSException: yes
	takeShotOnCallback: yes
	(err)->
		throw err if err
		console.log "did it"
