dotenv = require('dotenv').config()

debug = require('debug')('evernote-markdown:client')

Evernote2Markdown = require './src/evernote'

token = process.env.EVERNOTE_TOKEN

new Promise (resolve, reject) ->
  converter = new Evernote2Markdown token
  converter.convertNotes()
.then(() ->
  console.log 'complete'
  process.exit 0
).catch (err) ->
  console.log 'Error', err
  process.exit 1
