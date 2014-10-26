Canvas = require('./bismarck/canvas')

Bismarck = (element, options) ->
  if typeof element == 'string'
    new Canvas(document.getElementById(element), options)
  else
    new Canvas(element, options)

Bismarck.debug = false

module.exports = Bismarck

if window?
  window.Bismarck = Bismarck

