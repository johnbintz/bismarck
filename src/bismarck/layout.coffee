xml2js = require('xml2js')
parseString = require('xml2js').parseString
_ = require('underscore')

svgObjs =
  rect: (options, canvas) ->
    rect = canvas.rect(options.x, options.y, options.width, options.height)
    rect.attr(_.omit(options, 'x', 'y', 'width', 'height'))

    rect

oneOrMore = (value, code) ->
  if value.push?
    for node in value
      code(node)
  else
    code(value)

dive = (node, drawable, topLevel = null) ->
  for own key, value of node
    switch key
      when 'drawable'
        oneOrMore value, (v) ->
          childDrawable = drawable.create(v.$)
          topLevel ||= childDrawable
          dive(v, childDrawable, topLevel)
      when '$'
        # nothing
      else
        oneOrMore value, (v) ->
          drawable.draw (svg) ->
            svgObjs[key](v.$, svg)
          dive(v, drawable, topLevel)

  topLevel

module.exports = (xml, canvas, callback = null) ->
  parseString xml, (err, result) ->
    if err?
      throw err
    else
      diveResult = dive(result, canvas)

      if callback
        callback(diveResult)

