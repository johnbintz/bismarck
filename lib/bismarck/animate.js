var Animate,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Animate = {
  _animationsEnabled: true,
  currentTime: function() {
    return +(new Date);
  },
  moveFromTo: function(object, from, to, distance) {
    var dx, dy, x, y;
    dx = to.x - from.x;
    dy = to.y - from.y;
    x = from.x + (dx * distance);
    y = from.y + (dy * distance);
    return object.moveTo(x, y);
  }
};

Animate.Synchronizer = (function() {
  function Synchronizer() {
    this.run = __bind(this.run, this);
    this.animations = [];
    this.recalcs = [];
    this.removers = [];
    this.isRunning = false;
    this.fpsLimit = 30;
  }

  Synchronizer.prototype.addAnimation = function(recalc, animation) {
    this.animations.push(animation);
    this.recalcs.push(recalc);
    this.removers.push((function(_this) {
      return function() {
        return _this.removeAnimation(animation);
      };
    })(this));
    this.run();
    return (function(_this) {
      return function() {
        return _this.removeAnimation(animation);
      };
    })(this);
  };

  Synchronizer.prototype.removeAnimation = function(animation) {
    var index;
    index = this.animations.indexOf(animation);
    this.animations.splice(index, 1);
    this.recalcs.splice(index, 1);
    this.removers.splice(index, 1);
    if (this.animations.length === 0) {
      return this.isRunning = false;
    }
  };

  Synchronizer.prototype.run = function() {
    if (!this.isRunning) {
      this.isRunning = true;
    }
    return window.requestAnimationFrame((function(_this) {
      return function() {
        var calc, endTime, i, r, startTime, _i, _j, _len, _ref, _ref1;
        if (_this.animations.length > 0) {
          startTime = Animate.currentTime();
          Animate._animationsDisabled = false;
          for (i = _i = 0, _ref = _this.animations.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            if (_this.animations[i]) {
              _this.animations[i](startTime, _this.removers[i]);
            }
          }
          Animate._animationsDisabled = true;
          _ref1 = _this.recalcs;
          for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
            r = _ref1[_j];
            r.recalc();
          }
          endTime = Animate.currentTime();
          if (_this.isRunning) {
            calc = Math.max(0, (1 / _this.fpsLimit - ((endTime - startTime) / 1000)) * 1000);
            return setTimeout(_this.run, calc);
          }
        } else {
          return _this.isRunning = false;
        }
      };
    })(this));
  };

  return Synchronizer;

})();

Animate.synchronizer = new Animate.Synchronizer();

Animate.once = function(recalc, options, code) {
  var endTime, startTime;
  startTime = Animate.currentTime();
  endTime = startTime + options.duration;
  return Animate.synchronizer.addAnimation(recalc, function(currentTime, stop) {
    var index, result;
    index = Math.min(1, (currentTime - startTime) / options.duration);
    result = code(index);
    if (!result || currentTime >= endTime) {
      return stop();
    }
  });
};

Animate.loop = function(recalc, options, code) {
  var startTime;
  startTime = Animate.currentTime();
  return Animate.synchronizer.addAnimation(recalc, function(currentTime, stop) {
    var index, result;
    index = Math.min(1, (currentTime - startTime) % options.duration / options.duration);
    result = code(index);
    if (!result) {
      return stop();
    }
  });
};

module.exports = Animate;
