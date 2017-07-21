debug = require('debug')('evernote-markdown:evernote-api')

Evernote = require 'evernote'
ENML = require './ENML'
fs = require 'fs'
mkdirp = require 'mkdirp'

class Evernote2Markdown
  directory: 'notes'

  constructor: (@token) ->

  auth: ->
    throw new Error 'Please specify auth token!' if not @token
    @client = new Evernote.Client
      token: @token
      sandbox: false
      china: false
    return @client

  saveToFile: (path, data) ->
    new Promise (resolve, reject) ->
      fs.writeFile path, data, 'utf8', (err) ->
        return reject err if err
        resolve()
    .catch (err) ->
      console.error 'failed to write file', path, err

  handleNote: (note) =>
    debug "Loaded note '#{note.title}' (#{note.guid})"
    @noteStore.getNotebook note.notebookGuid
    .then (notebook) =>
      path = "#{@directory}/#{notebook.name}"
      debug 'making dir', path
      mkdirp path, (err) =>
        throw err if err? and err.code isnt 'EEXIST'
        markdown = ENML.toMarkdown note.content, true
        filename = note.title.replace /\//g, ''
        @saveToFile "#{path}/#{filename}.md", markdown
    .catch (err) ->
      console.error 'handleNote', err

  convertNotes: ->
    @auth()
    @noteStore = @client.getNoteStore()
    noteFilter = {}
    spec =
      includeTitle: true
    @noteStore.findNotesMetadata noteFilter, 0, 1000, spec
    .then (response) =>
      notes = response.notes
      debug "Found #{notes.length} note(s)"
      noteSpec =
        includeContent: true
      for note, i in notes
        @noteStore.getNoteWithResultSpec note.guid, noteSpec
        .then (note) =>
          @handleNote note
        .catch (err) ->
          console.error 'getNoteWithResultSpec', err
          Promise.reject err
    .catch (err) ->
      console.error 'convertNotes', err

module.exports = Evernote2Markdown
