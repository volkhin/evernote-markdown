debug = require('debug')('evernote-markdown:enml')

libxmljs = require 'libxmljs'
entities = require 'entities'
_ = require 'underscore'

smartTrim = (str) ->
  str = str.replace /^\s+/g, ' '
  str = str.replace /\s+$/g, ' '
  # str.trim()

# endLine = (str) ->
  # str = "#{str}\n" if str.length

blockElement = (str) ->
  str = "#{str.trim()}\n" if str.length
  return str

inlineElement = (str) ->
  str = str.trim()
  str = "#{str} " if str.length
  return str

recursiveWalk = (node) ->
  debug node.name(), node.type(), node.toString()
  switch node.type()
    when 'text' then inlineElement node.toString()
    when 'comment' then ''
    when 'entity_ref' then entities.decodeHTML node.toString()
    when 'element'
      childNodes = (recursiveWalk child for child in node.childNodes())
      content = childNodes.join('') #FIXME spaces after inline elements only
      switch node.name()
        when 'li' then "* #{content}\n"
        when 'i', 'em' then "*#{content}*"
        when 'b', 'strong' then "**#{content}**"
        when 'h1' then "# #{content}\n\n"
        when 'h2' then "## #{content}\n\n"
        when 'h3' then "### #{content}\n"
        when 'h4' then "#### #{content}\n"
        when 'h5' then "##### #{content}\n"
        when 'h6' then "###### #{content}\n"
        when 'a'
          text = content.trim()
          href = node.attr('href')?.value()?.trim()
          "[#{text}](#{href})"
        when 'br' then '\n'
        when 'div', 'en-note', 'ol', 'ul', 'p' then blockElement content
        when 'en-todo'
          " - [#{if node.attr 'checked' then 'x' else ' '}] "
        else content
    else
      throw new Error "no rule to parse #{node.type()} #{node.name()} #{node.toString()}"

toMarkdown = (content) ->
  xmlDoc = libxmljs.parseXml content
  debug xmlDoc.root().text()
  content = recursiveWalk xmlDoc.root()

module.exports =
  toMarkdown: toMarkdown
