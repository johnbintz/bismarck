Canvas = require('../../src/bismarck/canvas')

describe 'Drawable', ->
  svg = null
  canvas = null
  drawable = null

  beforeEach ->
    $('body').append('<svg id="svg" width="300" height="300"></svg>')
    canvas = new Canvas(document.getElementById('svg'), id: 'canvas')
    drawable = canvas.create(id: 'drawable', centerPoint: 'northwest')

  afterEach ->
    $('svg').remove()

  describe 'offset', ->
    describe 'with children', ->
      it 'should calculate the offset correctly', ->
        childOne = drawable.create(id: 'one', centerPoint: 'northwest')

        childOne.draw (surface) ->
          surface.rect(0, 0, 10, 1).attr(fill: '#000000')

        childTwo = drawable.create(id: 'two', centerPoint: 'northwest')

        childTwo.draw (surface) ->
          surface.rect(0, 0, 1, 10).attr(fill: '#000000')

        expect(drawable.getOffset().x).toEqual(0)
        expect(drawable.getOffset().y).toEqual(0)

        drawable.setCenterPoint('50%', '50%')

        expect(drawable.getOffset().x).toEqual(5)
        expect(drawable.getOffset().y).toEqual(5)

        childTwo.moveTo(20, 0)

        expect(drawable.getOffset().x).toEqual(10.5)
        expect(drawable.getOffset().y).toEqual(5)

      it 'should calculate the offset correctly', ->
        drawable.setCenterPoint('center')
        childOne = drawable.create(id: 'one', centerPoint: 'center')

        childOne.draw (surface) ->
          surface.rect(0, 0, 20, 30).attr(fill: '#000000')

        childOne.moveTo(0, 0)

        childTwo = drawable.create(id: 'two', centerPoint: 'center')

        childTwo.draw (surface) ->
          surface.rect(0, 0, 20, 30).attr(fill: '#000000')

        childTwo.moveTo(0, 30)

        expect(drawable.getOffset().x).toEqual(10)
        expect(drawable.getOffset().y).toEqual(30)

    it 'should calculate the offset correctly', ->
      spyOn(drawable, 'snapBBox').and.callThrough()

      orect = null

      drawable.setCenterPoint(0, 0)

      drawable.draw (surface) ->
        orect = surface.rect(0, 0, 20, 10).attr(fill: '#000000')

      expect(drawable.getOffset().x).toEqual(0)
      expect(drawable.getOffset().y).toEqual(0)

      drawable.setCenterPoint('50%', '50%')

      expect(drawable.getOffset().x).toEqual(10)
      expect(drawable.getOffset().y).toEqual(5)

      drawable.setCenterPoint('-100%', '0%')

      expect(drawable.getOffset().x).toEqual(-20)
      expect(drawable.getOffset().y).toEqual(0)

      drawable.draw (surface) ->
        orect = surface.rect(0, 0, 20, 10).attr(fill: 'red')

      expect(drawable.getOffset().x).toEqual(-20)
      expect(drawable.getOffset().y).toEqual(0)

      drawable.rotateTo(90)

      expect(drawable.getOffset().x).toEqual(-20)
      expect(drawable.getOffset().y).toEqual(0)

      drawable.setCenterPoint('center')

      expect(drawable.getOffset().x).toEqual(10)
      expect(drawable.getOffset().y).toEqual(5)

  describe 'dimensions', ->
    describe 'after drawing', ->
      it 'should position the bbox correctly', ->
        spyOn(drawable, 'snapBBox').and.callThrough()

        orect = null

        drawable.draw (surface) ->
          orect = surface.rect(0, 0, 20, 10).attr(fill: '#000000')

        expect(drawable.getDimensions().w).toEqual(20)
        expect(drawable.getDimensions().h).toEqual(10)

        drawable.draw (surface) ->
          orect.remove()
          surface.rect(10, 10, 20, 10).attr(fill: '#000000')

        expect(drawable.getDimensions().w).toEqual(20)
        expect(drawable.getDimensions().h).toEqual(10)

        expect(drawable.snapBBox.calls.count()).toEqual(2)

        drawable.scaleTo(2)

        expect(drawable.getDimensions().w).toEqual(20)
        expect(drawable.getDimensions().h).toEqual(10)

        drawable.rotateTo(90)

        expect(drawable.getDimensions().w).toBeCloseTo(20, 2)
        expect(drawable.getDimensions().h).toBeCloseTo(10, 2)

    describe 'with children', ->
      describe 'northwest', ->
        it 'should composite together all the drawables', ->
          childOne = drawable.create(id: 'one', centerPoint: 'northwest')

          childOne.draw (surface) ->
            surface.rect(0, 0, 10, 1).attr(fill: '#000000')

          childTwo = drawable.create(id: 'two', centerPoint: 'northwest')

          childTwo.draw (surface) ->
            surface.rect(0, 0, 1, 10).attr(fill: '#000000')

          expect(drawable.getDimensions().w).toEqual(10)
          expect(drawable.getDimensions().h).toEqual(10)

          expect(drawable.upperLeft().x).toBeCloseTo(0, 1)
          expect(drawable.upperLeft().y).toBeCloseTo(0, 1)

          expect(childTwo.upperLeft().x).toBeCloseTo(0, 1)
          expect(childTwo.upperLeft().y).toBeCloseTo(0, 1)

          childTwo.moveTo(-10, 0)

          expect(drawable.getDimensions().w).toEqual(20)
          expect(drawable.getDimensions().h).toEqual(10)
          expect(drawable.upperLeft().x).toBeCloseTo(-10, 1)
          expect(drawable.upperLeft().y).toBeCloseTo(0, 1)
          expect(childTwo.upperLeft().x).toBeCloseTo(0, 1)
          expect(childTwo.upperLeft().y).toBeCloseTo(0, 1)

      describe 'center', ->
        it 'should composite together all the drawables', ->
          drawable.setCenterPoint('center')
          childOne = drawable.create(id: 'one', centerPoint: 'center')

          childOne.draw (surface) ->
            surface.rect(0, 0, 10, 20).attr(fill: '#000000')

          childTwo = drawable.create(id: 'two', centerPoint: 'center')

          childTwo.draw (surface) ->
            surface.rect(0, 0, 10, 20).attr(fill: '#000000')

          expect(drawable.getDimensions().w).toEqual(10)
          expect(drawable.getDimensions().h).toEqual(20)

          expect(childTwo.upperLeft().x).toBeCloseTo(0, 1)
          expect(childTwo.upperLeft().y).toBeCloseTo(0, 1)

          expect(drawable.upperLeft().x).toBeCloseTo(-5, 1)
          expect(drawable.upperLeft().y).toBeCloseTo(-10, 1)

          childTwo.rotateTo(270)

          expect(drawable.getDimensions().w).toBeCloseTo(10, 2)
          expect(drawable.getDimensions().h).toBeCloseTo(20, 2)

