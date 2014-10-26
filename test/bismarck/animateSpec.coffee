Canvas = require('../../src/bismarck/canvas')
Animate = require('../../src/bismarck/animate')

describe 'Animate', ->
  svg = null
  canvas = null

  beforeEach ->
    $('body').append('<svg id="svg" width="300" height="300"></svg>')
    canvas = new Canvas(document.getElementById('svg'), id: 'canvas')

  afterEach ->
    $('svg').remove()

  describe '.moveFromTo', ->
    it 'should move an object from one point to another', ->
      drawable = canvas.create(id: 'drawable', centerPoint: 'northwest')

      Animate.moveFromTo(drawable, {x: 0, y: 0}, {x: 100, y: 50}, 0)
      expect(drawable.position).toEqual({x: 0, y: 0})
      expect(drawable.snapElement.getBBox().x).toEqual(0)

      Animate.moveFromTo(drawable, {x: 0, y: 0}, {x: 100, y: 50}, 0.5)
      expect(drawable.position).toEqual({x: 50, y: 25})
      expect(drawable.snapElement.getBBox().x).toEqual(50)

      Animate.moveFromTo(drawable, {x: 0, y: 0}, {x: 100, y: 50}, 1.0)
      expect(drawable.position).toEqual({x: 100, y: 50})
      expect(drawable.snapElement.getBBox().x).toEqual(100)

