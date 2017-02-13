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
    fs.writeFile path, data

  handleNote: (note) =>
    console.log "Loaded note '#{note.title}' (#{note.guid})"
    @noteStore.getNotebook note.notebookGuid
    .then (response) =>
      path = "#{@directory}/#{notebook.name}"
      mkdirp path, (err) =>
        throw err if err? and err.code isnt 'EEXIST'
        markdown = ENML.toMarkdown note.content, true
        filename = note.title.replace /\//g, ''
        @saveToFile "#{path}/#{filename}.md", markdown
    .catch (err) ->
      console.log 'handleNote', err

  convertNotes: ->
    @auth()
    @noteStore = @client.getNoteStore()
    noteFilter = {}
    spec =
      includeTitle: true
    @noteStore.findNotesMetadata noteFilter, 0, 1000, spec
    .then (response) =>
      notes = response.notes
      console.log "Found #{notes.length} note(s)"
      noteSpec =
        includeContent: true
      for note, i in notes
        @noteStore.getNoteWithResultSpec note.guid, noteSpec
        .then (response) =>
          @handleNote note
        .catch (err) ->
          console.log 'getNoteWithResultSpec', err
          Promise.reject err
    .catch (err) ->
      console.log 'convertNotes', err

module.exports = Evernote2Markdown
