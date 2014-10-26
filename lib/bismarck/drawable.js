var Animate, Drawable,
  __hasProp = {}.hasOwnProperty,
  __slice = [].slice;

Animate = require('./animate');

Drawable = (function() {
  function Drawable(canvas, options) {
    var defaults, key, value;
    this.canvas = canvas;
    if (options == null) {
      options = {};
    }
    defaults = {
      centerPoint: 'northwest',
      position: {
        x: 0,
        y: 0
      },
      angle: 0,
      scale: 1
    };
    for (key in defaults) {
      if (!__hasProp.call(defaults, key)) continue;
      value = defaults[key];
      switch (key) {
        case 'centerPoint':
          this.setCenterPoint(value || defaults[key]);
          break;
        default:
          this[key] = value || defaults[key];
      }
    }
    for (key in options) {
      if (!__hasProp.call(options, key)) continue;
      value = options[key];
      switch (key) {
        case 'centerPoint':
          this.setCenterPoint(value || defaults[key]);
          break;
        default:
          this[key] = value || defaults[key];
      }
    }
    this._resources = this.canvas.resources();
    this._children = [];
  }

  Drawable.prototype.resources = function() {
    return this._resources;
  };

  Drawable.prototype.snapBBox = function() {
    return this._scale.getBBox(true);
  };

  Drawable.prototype.create = function(options) {
    var drawable;
    drawable = new Drawable(this.canvas, options);
    drawable.attachTo(this._scale);
    drawable.parentDrawable = this;
    this._children.push(drawable);
    return drawable;
  };

  Drawable.prototype.remove = function() {
    return this._translateRotate.remove();
  };

  Drawable.prototype.attachTo = function(snapElement) {
    this._translateRotate = snapElement.group().addClass('-translate');
    this._scale = this._translateRotate.group().addClass('-scale');
    this._translateRotate.attr({
      id: this.id,
      bismarck: 'drawable'
    });
    this._currentBBox = this.snapBBox();
    return this.snapElement = this._translateRotate;
  };

  Drawable.prototype.forceSize = function(w, h) {
    var me;
    if (this._forcedSize) {
      this._forcedSize.remove();
    }
    this._forcedDims = {
      w: w,
      h: h
    };
    this._forcedSize = this._translateRotate.rect(0, 0, w, h).attr({
      fill: 'rgba(0,0,0,0)'
    });
    me = this._forcedSize.node;
    return this._translateRotate.node.insertBefore(me, this._translateRotate.node.childNodes[0]);
  };

  Drawable.prototype.useExisting = function(_translateRotate) {
    var childNodes, currentNode;
    this._translateRotate = _translateRotate;
    if (!this._translateRotate.attr('bismarck')) {
      throw "Not a Bismarck element!";
    }
    childNodes = this._translateRotate.node.childNodes;
    this._scale = Snap(childNodes[0]);
    if (childNodes[1]) {
      this.centerPointCross = Snap(childNodes[1]);
    }
    currentNode = this._translateRotate.node.parentNode;
    while (currentNode) {
      switch (currentNode.getAttribute('bismarck')) {
        case 'drawable':
          this.parentDrawable = new Drawable(this.canvas, {});
          this.parentDrawable.useExisting(Snap(currentNode));
          currentNode = null;
          break;
        case 'canvas':
          currentNode = null;
          break;
        default:
          if (currentNode.nodeName === 'svg') {
            currentNode = null;
          } else {
            currentNode = currentNode.parentNode;
          }
      }
    }
    return angular.extend(this, this._translateRotate.data('settings'));
  };

  Drawable.prototype.showCenterPoint = function() {
    this.centerPointCross = this._translateRotate.group();
    this.centerPointCross.line(0, -5, 0, 5).attr({
      stroke: 'black'
    });
    this.centerPointCross.line(-5, 0, 5, 0).attr({
      stroke: 'black'
    });
    return this.recalc();
  };

  Drawable.prototype.moveTo = function(x, y) {
    this.position = {
      x: x,
      y: y
    };
    return this.recalc();
  };

  Drawable.prototype.rotateTo = function(angle) {
    this.angle = angle;
    return this.recalc();
  };

  Drawable.prototype.scaleTo = function(scale) {
    this.scale = scale;
    return this.recalc();
  };

  Drawable.prototype.alignTo = function() {
    var args, how, object;
    object = arguments[0], how = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    if (how == null) {
      how = 'center';
    }
    switch (how) {
      case 'center':
        return this.moveTo.apply(this, [object.position.x, object.position.y].concat(__slice.call(args)));
      case 'horizontal':
        return this.moveTo.apply(this, [this.position.x, object.position.y].concat(__slice.call(args)));
      case 'vertical':
        return this.moveTo.apply(this, [object.position.x, this.position.y].concat(__slice.call(args)));
    }
  };

  Drawable.prototype.centerInParent = function() {
    this._centerInParent = true;
    this.setCenterPoint('center');
    return this.recalc(true);
  };

  Drawable.prototype.recalc = function(down) {
    var child, matrix, offset, parent, upperLeft, _i, _len, _ref, _results;
    if (down == null) {
      down = false;
    }
    if (Animate._animationsEnabled) {
      if (this._centerInParent) {
        parent = this.parentDrawable.getDimensions();
        this.position = {
          x: parent.w / 2,
          y: parent.h / 2
        };
      }
      if (this.oldScale !== this.scale) {
        matrix = new Snap.Matrix();
        matrix.scale(this.scale);
        this._scale.transform(matrix);
        this.oldScale = this.scale;
      }
      offset = this.getOffset();
      upperLeft = this.upperLeft();
      if (this.centerPointCross != null) {
        matrix = new Snap.Matrix();
        matrix.translate(offset.x + upperLeft.x, offset.y + upperLeft.y);
        this.centerPointCross.transform(matrix);
      }
      matrix = new Snap.Matrix();
      matrix.translate(this.position.x, this.position.y);
      matrix.rotate(this.angle, 0, 0);
      if (!this._forcedSize) {
        matrix.translate(-offset.x - upperLeft.x, -offset.y - upperLeft.y);
      }
      this._translateRotate.transform(matrix);
      if (false) {
        this._translateRotate.data('settings', {
          centerPoint: this.centerPoint,
          position: this.position,
          angle: this.angle,
          scale: this.scale,
          _currentBBox: this._currentBBox,
          _centerInParent: this._centerInParent,
          _forcedDims: this._forcedDims,
          _children: this._children
        });
      }
      if (down) {
        _ref = this._children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          _results.push(child.recalc(true));
        }
        return _results;
      } else {
        if (this.parentDrawable != null) {
          return this.parentDrawable.recalc();
        }
      }
    }
  };

  Drawable.prototype.moveForward = function() {
    var i, l, me, parent, _i, _results;
    me = this._translateRotate.node;
    parent = me.parentNode;
    l = parent.childNodes.length - 1;
    _results = [];
    for (i = _i = 0; 0 <= l ? _i <= l : _i >= l; i = 0 <= l ? ++_i : --_i) {
      if (parent.childNodes[i] === me && i < l) {
        _results.push(parent.insertBefore(parent.childNodes[i + 1], me));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Drawable.prototype.moveBackward = function() {
    var i, me, parent, _i, _ref, _results;
    me = this._translateRotate.node;
    parent = me.parentNode;
    _results = [];
    for (i = _i = 0, _ref = parent.childNodes.length; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      if (parent.childNodes[i] === me && i > 0) {
        _results.push(parent.insertBefore(me, parent.childNodes[i - 1]));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Drawable.prototype.moveToFront = function() {
    var me;
    me = this._translateRotate.node;
    return me.parent.appendChild(me);
  };

  Drawable.prototype.moveToBack = function() {
    var me;
    me = this._translateRotate.node;
    return me.parent.insertBefore(me, me.parent.childNodes[0]);
  };

  Drawable.prototype.on = function() {
    var args, code, event, target, targetSelector;
    event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    code = args.pop();
    targetSelector = args.shift();
    target = this._translateRotate;
    if (targetSelector != null) {
      target = target.select(targetSelector);
    }
    return target[event](code);
  };

  Drawable.prototype.draw = function(code) {
    code(this._scale);
    this.recalc();
    return this._currentBBox = this.snapBBox();
  };

  Drawable.prototype.scaleAndRotateCoords = function(coords) {
    var cos, newH, newW, pairs, rad2ang, radianAngle, sin;
    pairs = coords.w != null ? ['w', 'h'] : ['x', 'y'];
    coords[pairs[0]] *= this.scale;
    coords[pairs[1]] *= this.scale;
    rad2ang = Math.PI / 180;
    radianAngle = rad2ang * this.angle;
    cos = Math.cos(radianAngle);
    sin = Math.sin(radianAngle);
    newW = coords[pairs[0]] * cos + coords[pairs[1]] * sin;
    newH = coords[pairs[1]] * cos + coords[pairs[0]] * sin;
    coords[pairs[0]] = newW;
    coords[pairs[1]] = newh;
    return coords;
  };

  Drawable.prototype.getOffset = function() {
    var coordPart, output, source, _i, _len, _ref;
    output = {};
    source = this._children.length > 0 ? this.getDimensions() : this._currentBBox;
    _ref = this.centerPoint;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      coordPart = _ref[_i];
      output[coordPart.which] = coordPart.convert(source[coordPart.dim]);
    }
    return output;
  };

  Drawable.prototype.upperLeft = function() {
    var child, furthestUpperLeft, offset, _i, _len, _ref;
    if (this._children.length === 0) {
      return {
        x: 0,
        y: 0
      };
    } else {
      furthestUpperLeft = {
        x: null,
        y: null
      };
      _ref = this._children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        offset = child.getOffset();
        offset.x = -offset.x + child.position.x;
        offset.y = -offset.y + child.position.y;
        if (!furthestUpperLeft.x) {
          furthestUpperLeft.x = offset.x;
          furthestUpperLeft.y = offset.y;
        } else {
          furthestUpperLeft.x = Math.min(furthestUpperLeft.x, offset.x);
          furthestUpperLeft.y = Math.min(furthestUpperLeft.y, offset.y);
        }
      }
      return furthestUpperLeft;
    }
  };

  Drawable.prototype.setCenterPoint = function() {
    var args, coordMap, data;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (args.length === 1) {
      args = (function() {
        switch (args[0]) {
          case 'center':
            return ['50%', '50%'];
          case 'northwest':
            return [0, 0];
        }
      })();
    }
    this.coordinates = {};
    data = [
      {
        index: 0,
        which: 'x',
        dim: 'w'
      }, {
        index: 1,
        which: 'y',
        dim: 'h'
      }
    ];
    coordMap = function(datum) {
      var percent;
      datum.value = args[datum.index];
      if ((datum.value.substr != null) && datum.value.substr(-1) === '%') {
        percent = Number(datum.value.slice(0, -1)) / 100.0;
        datum.convert = function(value) {
          return value * percent;
        };
      } else {
        datum.convert = function(value) {
          return datum.value;
        };
      }
      return datum;
    };
    return this.centerPoint = data.map(coordMap);
  };

  Drawable.prototype.getDimensions = function() {
    if (this._forcedDims) {
      return this._forcedDims;
    } else {
      if (this._children.length > 0) {
        return this.getDimensionsWithChildren();
      } else {
        return this._currentBBox;
      }
    }
  };

  Drawable.prototype.getDimensionsWithChildren = function() {
    var bbox, child, childBBox, childOffset, _i, _len, _ref;
    bbox = {
      sx: null,
      sy: null,
      ex: null,
      ey: null
    };
    _ref = this._children;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      childBBox = child.getDimensions();
      childOffset = child.getOffset();
      childBBox.x = child.position.x - childOffset.x;
      childBBox.y = child.position.y - childOffset.y;
      if (bbox.sx === null) {
        bbox.sx = childBBox.x;
        bbox.sy = childBBox.y;
        bbox.ex = childBBox.x + childBBox.w;
        bbox.ey = childBBox.y + childBBox.h;
      } else {
        bbox.sx = Math.min(bbox.sx, childBBox.x);
        bbox.sy = Math.min(bbox.sy, childBBox.y);
        bbox.ex = Math.max(bbox.ex, childBBox.x + childBBox.w);
        bbox.ey = Math.max(bbox.ey, childBBox.y + childBBox.h);
      }
    }
    return {
      w: bbox.ex - bbox.sx,
      h: bbox.ey - bbox.sy
    };
  };

  Drawable.prototype.append = function(drawable) {
    return this._translateRotate.append(drawable._scaleRotate);
  };

  return Drawable;

})();

module.exports = Drawable;
