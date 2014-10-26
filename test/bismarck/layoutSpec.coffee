Canvas = require('../../src/bismarck/canvas')

describe 'layoutSpec', ->
  svg = null
  canvas = null
  drawable = null

  beforeEach ->
    $('body').append('<svg id="svg" width="300" height="300"></svg>')
    canvas = new Canvas(document.getElementById('svg'), id: 'canvas')
    drawable = canvas.create(id: 'drawable', centerPoint: 'northwest')
    svg = canvas.snapElement

  afterEach ->
    $('svg').remove()

  describe 'from canvas', ->
    it 'should create a group of objects with SVG bits', ->
      layout = canvas.fromLayout("""
        <drawable id="cat">
          <rect id="dog" x="10" y="10" width="30" height="20" style="fill: red" />
        </drawable>
      """)

      console.log svg.outerSVG()

      expect(svg).toContainSVG('#cat')
      expect(svg).toContainSVG('rect#dog[style="fill: red"]')
