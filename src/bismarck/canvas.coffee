Drawable = require('./drawable')
Resources = require('./resources')
Layout = require('./layout')

class Canvas
  constructor: (@element, options = {}) ->
    @snapElement = Snap(@element)
    if not @snapElement.attr('bismarck')
      if options.id
        @snapElement.attr(id: options.id, bismarck: 'canvas')

  fromLayout: (xml, callback) ->
    Layout(xml, this, callback)

  create: (options) ->
    drawable = new Drawable(this, options)
    drawable.attachTo(@snapElement)
    drawable

  find: (id) ->
    drawable = new Drawable(this)
    drawable.useExisting(@snapElement.select("##{id}"))
    drawable

  resources: ->
    return @_resources if @_resources

    @_resources = new Resources(this)
    @_resources.attachTo(@snapElement)
    @_resources

module.exports = Canvas
