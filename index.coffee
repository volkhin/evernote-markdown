Evernote2Markdown = require './src/evernote'
# get token at https://www.evernote.com/api/DeveloperToken.action
token = 'PUT YOUR TOKEN HERE'
converter = new Evernote2Markdown token
converter.convertNotes()
