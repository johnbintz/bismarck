Animate =
  _animationsEnabled: true
  currentTime: -> +new Date
  moveFromTo: (object, from, to, distance) ->
    dx = to.x - from.x
    dy = to.y - from.y
    x = from.x + (dx * distance)
    y = from.y + (dy * distance)

    object.moveTo(x, y)

class Animate.Synchronizer
  constructor: ->
    @animations = []
    @recalcs = []
    @removers = []
    @isRunning = false
    @fpsLimit = 30

  addAnimation: (recalc, animation) ->
    @animations.push(animation)
    @recalcs.push(recalc)
    @removers.push => @removeAnimation(animation)
    @run()

    => @removeAnimation(animation)

  removeAnimation: (animation) ->
    index = @animations.indexOf(animation)
    @animations.splice(index, 1)
    @recalcs.splice(index, 1)
    @removers.splice(index, 1)
    if @animations.length == 0
      @isRunning = false

  run: =>
    if not @isRunning
      @isRunning = true

    window.requestAnimationFrame =>
      if @animations.length > 0
        startTime = Animate.currentTime()
        Animate._animationsDisabled = false
        for i in [0..@animations.length - 1]
          if @animations[i]
            @animations[i](startTime, @removers[i])
        Animate._animationsDisabled = true
        r.recalc() for r in @recalcs
        endTime = Animate.currentTime()
        if @isRunning
          calc = Math.max(0, (1 / @fpsLimit - ((endTime - startTime) / 1000)) * 1000)
          setTimeout(@run, calc)
      else
        @isRunning = false

Animate.synchronizer = new Animate.Synchronizer()

Animate.once = (recalc, options, code) ->
  startTime = Animate.currentTime()
  endTime = startTime + options.duration

  Animate.synchronizer.addAnimation recalc, (currentTime, stop) ->
    index = Math.min(1, (currentTime - startTime) / options.duration)
    result = code(index)

    stop() if not result or currentTime >= endTime

Animate.loop = (recalc, options, code) ->
  startTime = Animate.currentTime()

  Animate.synchronizer.addAnimation recalc, (currentTime, stop) ->
    index = Math.min(1, (currentTime - startTime) % options.duration / options.duration)
    result = code(index)

    stop() if not result

module.exports = Animate
