Animate = require('./animate')

class Drawable
  constructor: (@canvas, options = {}) ->
    defaults =
      centerPoint: 'northwest'
      position: {x: 0, y: 0}
      angle: 0
      scale: 1

    for own key, value of defaults
      switch key
        when 'centerPoint'
          @setCenterPoint(value || defaults[key])
        else
          this[key] = value || defaults[key]

    for own key, value of options
      switch key
        when 'centerPoint'
          @setCenterPoint(value || defaults[key])
        else
          this[key] = value || defaults[key]

    @_resources = @canvas.resources()
    @_children = []

  resources: -> @_resources
  snapBBox: -> @_scale.getBBox(true)

  create: (options) ->
    drawable = new Drawable(@canvas, options)
    drawable.attachTo(@_scale)
    drawable.parentDrawable = this
    @_children.push(drawable)
    drawable

  remove: ->
    @_translateRotate.remove()

  attachTo: (snapElement) ->
    @_translateRotate = snapElement.group().addClass('-translate')
    @_scale = @_translateRotate.group().addClass('-scale')

    @_translateRotate.attr(id: @id, bismarck: 'drawable')
    @_currentBBox = @snapBBox()
    @snapElement = @_translateRotate

  forceSize: (w, h) ->
    @_forcedSize.remove() if @_forcedSize

    @_forcedDims = { w: w, h: h }
    @_forcedSize = @_translateRotate.rect(0, 0, w, h).attr(fill: 'rgba(0,0,0,0)')

    me = @_forcedSize.node
    @_translateRotate.node.insertBefore(me, @_translateRotate.node.childNodes[0])

  useExisting: (@_translateRotate) ->
    throw "Not a Bismarck element!" if not @_translateRotate.attr('bismarck')
    childNodes = @_translateRotate.node.childNodes

    @_scale = Snap(childNodes[0])
    if childNodes[1]
      @centerPointCross = Snap(childNodes[1])

    currentNode = @_translateRotate.node.parentNode
    while currentNode
      switch currentNode.getAttribute('bismarck')
        when 'drawable'
          @parentDrawable = new Drawable(@canvas, {})
          @parentDrawable.useExisting(Snap(currentNode))
          currentNode = null
        when 'canvas'
          currentNode = null
        else
          # stop!
          if currentNode.nodeName == 'svg'
            currentNode = null
          else
            currentNode = currentNode.parentNode

    angular.extend(this, @_translateRotate.data('settings'))

  showCenterPoint: ->
    @centerPointCross = @_translateRotate.group()
    @centerPointCross.line(0, -5, 0, 5).attr(stroke: 'black')
    @centerPointCross.line(-5, 0, 5, 0).attr(stroke: 'black')

    @recalc()

  moveTo: (x, y) ->
    @position = {x: x, y: y}
    @recalc()

  rotateTo: (angle) ->
    @angle = angle
    @recalc()

  scaleTo: (scale) ->
    @scale = scale
    @recalc()

  alignTo: (object, how = 'center', args...) ->
    switch how
      when 'center'
        @moveTo(object.position.x, object.position.y, args...)
      when 'horizontal'
        @moveTo(@position.x, object.position.y, args...)
      when 'vertical'
        @moveTo(object.position.x, @position.y, args...)

  centerInParent: ->
    @_centerInParent = true
    @setCenterPoint('center')
    @recalc(true)

  recalc: (down = false) ->
    if Animate._animationsEnabled
      if @_centerInParent
        parent = @parentDrawable.getDimensions()

        @position = { x: parent.w / 2, y: parent.h / 2}

      if @oldScale != @scale
        matrix = new Snap.Matrix()
        matrix.scale(@scale)
        @_scale.transform(matrix)
        @oldScale = @scale

      offset = @getOffset()
      upperLeft = @upperLeft()

      if @centerPointCross?
        matrix = new Snap.Matrix()
        matrix.translate(offset.x + upperLeft.x, offset.y + upperLeft.y)
        @centerPointCross.transform(matrix)

      matrix = new Snap.Matrix()

      matrix.translate(@position.x, @position.y)
      matrix.rotate(@angle, 0, 0)

      if not @_forcedSize
        matrix.translate(-offset.x - upperLeft.x, -offset.y - upperLeft.y)

      @_translateRotate.transform(matrix)

      if false
        @_translateRotate.data('settings', {
          centerPoint: @centerPoint
          position: @position
          angle: @angle
          scale: @scale
          _currentBBox: @_currentBBox
          _centerInParent: @_centerInParent
          _forcedDims: @_forcedDims
          _children: @_children
        })

      if down
        child.recalc(true) for child in @_children
      else
        @parentDrawable.recalc() if @parentDrawable?

  moveForward: ->
    me = @_translateRotate.node
    parent = me.parentNode

    l = parent.childNodes.length - 1

    for i in [0..l]
      if parent.childNodes[i] == me and i < l
        parent.insertBefore(parent.childNodes[i + 1], me)

  moveBackward: ->
    me = @_translateRotate.node
    parent = me.parentNode

    for i in [0..parent.childNodes.length]
      if parent.childNodes[i] == me and i > 0
        parent.insertBefore(me, parent.childNodes[i - 1])

  moveToFront: ->
    me = @_translateRotate.node
    me.parent.appendChild(me)

  moveToBack: ->
    me = @_translateRotate.node
    me.parent.insertBefore(me, me.parent.childNodes[0])

  on: (event, args...) ->
    code = args.pop()
    targetSelector = args.shift()

    target = @_translateRotate
    if targetSelector?
      target = target.select(targetSelector)

    target[event](code)

  draw: (code) ->
    code(@_scale)
    @recalc()

    @_currentBBox = @snapBBox()

  scaleAndRotateCoords: (coords) ->
    pairs = if coords.w? then ['w', 'h'] else ['x', 'y']

    coords[pairs[0]] *= @scale
    coords[pairs[1]] *= @scale

    rad2ang = Math.PI / 180

    radianAngle = rad2ang * @angle
    cos = Math.cos(radianAngle)
    sin = Math.sin(radianAngle)

    newW = coords[pairs[0]] * cos + coords[pairs[1]] * sin
    newH = coords[pairs[1]] * cos + coords[pairs[0]] * sin

    coords[pairs[0]] = newW
    coords[pairs[1]] = newh

    coords

  getOffset: ->
    output = {}

    source = if @_children.length > 0
      @getDimensions()
    else
      @_currentBBox

    for coordPart in @centerPoint
      output[coordPart.which] = coordPart.convert(source[coordPart.dim])

    output

  upperLeft: ->
    if @_children.length == 0
      { x: 0, y: 0 }
    else
      furthestUpperLeft = { x: null, y: null }
      for child in @_children
        offset = child.getOffset()
        offset.x = -offset.x + child.position.x
        offset.y = -offset.y + child.position.y

        if !furthestUpperLeft.x
          furthestUpperLeft.x = offset.x
          furthestUpperLeft.y = offset.y
        else
          furthestUpperLeft.x = Math.min(furthestUpperLeft.x, offset.x)
          furthestUpperLeft.y = Math.min(furthestUpperLeft.y, offset.y)

      furthestUpperLeft

  setCenterPoint: (args...) ->
    if args.length == 1
      args = switch args[0]
        when 'center'
          ['50%', '50%']
        when 'northwest'
          [0,0]

    @coordinates = {}

    data = [
      { index: 0, which: 'x', dim: 'w' },
      { index: 1, which: 'y', dim: 'h' }
    ]

    coordMap = (datum) ->
      datum.value = args[datum.index]
      if datum.value.substr? and datum.value.substr(-1) == '%'
        percent = Number(datum.value.slice(0, -1)) / 100.0

        datum.convert = (value) -> value * percent
      else
        datum.convert = (value) -> datum.value

      datum

    @centerPoint = data.map(coordMap)

  getDimensions: ->
    if @_forcedDims
      @_forcedDims
    else
      if @_children.length > 0
        @getDimensionsWithChildren()
      else
        @_currentBBox

  getDimensionsWithChildren: ->
    bbox =
      sx: null
      sy: null
      ex: null
      ey: null

    for child in @_children
      childBBox = child.getDimensions()
      childOffset = child.getOffset()

      childBBox.x = child.position.x - childOffset.x
      childBBox.y = child.position.y - childOffset.y

      if bbox.sx == null
        bbox.sx = childBBox.x
        bbox.sy = childBBox.y
        bbox.ex = childBBox.x + childBBox.w
        bbox.ey = childBBox.y + childBBox.h
      else
        bbox.sx = Math.min(bbox.sx, childBBox.x)
        bbox.sy = Math.min(bbox.sy, childBBox.y)
        bbox.ex = Math.max(bbox.ex, childBBox.x + childBBox.w)
        bbox.ey = Math.max(bbox.ey, childBBox.y + childBBox.h)

    { w: bbox.ex - bbox.sx, h: bbox.ey - bbox.sy }

  append: (drawable) ->
    @_translateRotate.append(drawable._scaleRotate)

module.exports = Drawable

