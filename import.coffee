
fs = require('fs')
readline = require('readline')
async = require('async')
google = require('googleapis')
googleAuth = require('google-auth-library')

# If modifying these scopes, delete your previously saved credentials
SCOPES = ['https://www.googleapis.com/auth/drive']
TOKEN_DIR = (process.env.HOME ? process.env.HOMEPATH ? process.env.USERPROFILE) + '/.credentials/'
TOKEN_PATH = TOKEN_DIR + 'nodejs-drive-access.json'

# The list of documents to get card data from
document_ids = [
	"1Bf5XpVfmI5BQ0kZnUOwDKf6tgWCF3QRpdyxCzyQ2pvo" # Systems
	"18HHX9qU6dYGWXSrX1oYZtofsd4bNGHQLdK6qvs9T46w" # Occult
	"1TOAoNigJ40vKIuDyaDRXfzb6lfhQYBqXT56z4y2RyyI" # Corporate
	"19MkaSLF3VUOl1L3PXrjCTQqxn_fNf_EM-xgsT2vQNJw" # Military
	"1fiYz_SJ0JVQgtGQVmR7_iDZKQNDmLrvghh09AKyZVrM" # Neutral/Misc
]

# Load client secrets from a local file.
fs.readFile 'client_id.json', (err, content)->
	if err
		console.log 'Error loading client secret file: ' + err
		return
	# Authorize a client with the loaded credentials, then call the
	# Drive API.
	authorize JSON.parse(content).web, (auth)->
		service = google.drive('v3')
		
		fetch = (fileId, callback)->
			console.log "fetch", fileId
			mimeType = "text/plain"
			service.files.export {auth, fileId, mimeType}, (err, document_text)->
				if err
					callback err
				else
					# callback null, document_text.replace(/\[\w\].*/g, "")
					callback null, document_text.replace(/\n\[\w\](.|\n|\r)+/gm, "").replace(/\[\w\]/g, "")
					# callback null, document_text
		
		async.map document_ids, fetch, (err, results)->
			throw err if err
			card_data = results.join('\n\n\n\n\n\n\n\n\n\n\n\n')
			fs.writeFile "cards.txt", card_data, "utf8", (err)->
				throw err if err
				console.log "wrote cards.txt"

###
 * Create an OAuth2 client with the given credentials, and then execute the
 * given callback function.
 *
 * @param {Object} credentials The authorization client credentials.
 * @param {function} callback The callback to call with the authorized client.
###
authorize = (credentials, callback)->
	clientSecret = credentials.client_secret
	clientId = credentials.client_id
	# redirectUrl = credentials.redirect_uris[0]
	redirectUrl = "http://multiism.ml/"
	auth = new googleAuth()
	oauth2Client = new auth.OAuth2(clientId, clientSecret, redirectUrl)

	# Check if we have previously stored a token.
	fs.readFile TOKEN_PATH, (err, token)->
		if err
			getNewToken(oauth2Client, callback)
		else
			oauth2Client.credentials = JSON.parse(token)
			callback(oauth2Client)

###
 * Get and store new token after prompting for user authorization, and then
 * execute the given callback with the authorized OAuth2 client.
 *
 * @param {google.auth.OAuth2} oauth2Client The OAuth2 client to get token for.
 * @param {getEventsCallback} callback The callback to call with the authorized
 *     client.
###
getNewToken = (oauth2Client, callback)->
	
	authUrl = oauth2Client.generateAuthUrl
		access_type: 'offline',
		scope: SCOPES
	
	console.log 'Authorize this app by visiting this url: ', authUrl
	
	rl = readline.createInterface
		input: process.stdin,
		output: process.stdout
	
	rl.question 'Enter the code from that page here: ', (code)->
		rl.close()
		oauth2Client.getToken code, (err, token)->
			if err
				console.log 'Error while trying to retrieve access token', err
				return
			oauth2Client.credentials = token
			storeToken(token)
			callback(oauth2Client)


###
 * Store token to disk be used in later program executions.
 *
 * @param {Object} token The token to store to disk.
###
storeToken = (token)->
	try
		fs.mkdirSync(TOKEN_DIR)
	catch err
		unless err.code is 'EEXIST'
			throw err
	
	fs.writeFile(TOKEN_PATH, JSON.stringify(token))
	console.log 'Token stored to ' + TOKEN_PATH

# gdrive = require "google-drive"
# # token = "f_2Ppn5KBIlPGfJe_I-QCeVL"

# fetch = (document_id)->
# 	console.log "fetch", document_id
# 	gdrive(token).files(document_id).get (err, response, body)->
# 		if err
# 			console.error err
# 		else
# 			console.log body
		
# 	# "https:#www.googleapis.com/drive/v3/files/#{document_id}/export?mimeType=text%2Fplain&key=#{api_key}"


# fetch "18HHX9qU6dYGWXSrX1oYZtofsd4bNGHQLdK6qvs9T46w"

# # drive.files.export
# # 	fileId: fileId
# # 	mimeType: 'application/pdf'
# # 	.on 'end', ->
# # 		console.log 'Done'
# # 	.on 'error', (err)->
# # 		console.log 'Error during download', err

