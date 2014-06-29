{Evernote} = require 'evernote'
ENML = require './ENML'
fs = require 'fs'
mkdirp = require 'mkdirp'

class Evernote2Markdown
  directory: 'notes'

  constructor: (@token) ->

  auth: ->
    throw Error 'Please specify auth token!' if not @token
    @client = new Evernote.Client
      token: @token
      sandbox: false
    return @client

  saveToFile: (path, data) ->
    fs.writeFile path, data

  handleNote: (note) =>
    console.log "Loaded node '#{note.title}' (#{note.guid})"
    @noteStore.getNotebook note.notebookGuid, (err, notebook) =>
      throw Error err if err?
      path = "#{@directory}/#{notebook.name}"
      mkdirp path, (err) =>
        throw Error err if err? and err.code isnt 'EEXIST'
        # @saveToFile "#{path}/#{note.title}.enml", note.content
        markdown = ENML.toMarkdown note, true
        # console.log markdown
        filename = note.title.replace /\//g, ''
        @saveToFile "#{path}/#{filename}.md", markdown

  convertNotes: ->
    @auth()
    @noteStore = @client.getNoteStore()
    noteFilter = new Evernote.NoteFilter()
    spec = new Evernote.NotesMetadataResultSpec()
    notes = @noteStore.findNotesMetadata noteFilter, 0, 1000, spec, (error, response) =>
      throw Error err if err?
      notes = response.notes
      console.log "Found #{notes.length} note(s)"
      for note, i in notes
        @noteStore.getNote note.guid, true, false, false, false, (error, note) =>
          throw Error err if err?
          @handleNote note

module.exports = Evernote2Markdown
