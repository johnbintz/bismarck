beforeEach ->
  jasmine.addMatchers {
    toContainSVG: ->
      compare: (svg, select) ->
        result = { pass: svg.select(select)? }

        result.message = if !result.pass
          "Expect #{svg.outerSVG()} to contain #{select}"

        result
  }

require('./bismarckSpec')
require('./bismarck/animateSpec')
require('./bismarck/drawableSpec')
require('./bismarck/layoutSpec')

