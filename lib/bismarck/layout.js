var dive, oneOrMore, parseString, svgObjs, xml2js, _,
  __hasProp = {}.hasOwnProperty;

xml2js = require('xml2js');

parseString = require('xml2js').parseString;

_ = require('underscore');

svgObjs = {
  rect: function(options, canvas) {
    var rect;
    rect = canvas.rect(options.x, options.y, options.width, options.height);
    rect.attr(_.omit(options, 'x', 'y', 'width', 'height'));
    return rect;
  }
};

oneOrMore = function(value, code) {
  var node, _i, _len, _results;
  if (value.push != null) {
    _results = [];
    for (_i = 0, _len = value.length; _i < _len; _i++) {
      node = value[_i];
      _results.push(code(node));
    }
    return _results;
  } else {
    return code(value);
  }
};

dive = function(node, drawable, topLevel) {
  var key, value;
  if (topLevel == null) {
    topLevel = null;
  }
  for (key in node) {
    if (!__hasProp.call(node, key)) continue;
    value = node[key];
    switch (key) {
      case 'drawable':
        oneOrMore(value, function(v) {
          var childDrawable;
          childDrawable = drawable.create(v.$);
          topLevel || (topLevel = childDrawable);
          return dive(v, childDrawable, topLevel);
        });
        break;
      case '$':
        break;
      default:
        oneOrMore(value, function(v) {
          drawable.draw(function(svg) {
            return svgObjs[key](v.$, svg);
          });
          return dive(v, drawable, topLevel);
        });
    }
  }
  return topLevel;
};

module.exports = function(xml, canvas, callback) {
  if (callback == null) {
    callback = null;
  }
  return parseString(xml, function(err, result) {
    var diveResult;
    if (err != null) {
      throw err;
    } else {
      diveResult = dive(result, canvas);
      if (callback) {
        return callback(diveResult);
      }
    }
  });
};
