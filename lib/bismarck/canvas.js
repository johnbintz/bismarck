var Canvas, Drawable, Layout, Resources;

Drawable = require('./drawable');

Resources = require('./resources');

Layout = require('./layout');

Canvas = (function() {
  function Canvas(element, options) {
    this.element = element;
    if (options == null) {
      options = {};
    }
    this.snapElement = Snap(this.element);
    if (!this.snapElement.attr('bismarck')) {
      if (options.id) {
        this.snapElement.attr({
          id: options.id,
          bismarck: 'canvas'
        });
      }
    }
  }

  Canvas.prototype.fromLayout = function(xml, callback) {
    return Layout(xml, this, callback);
  };

  Canvas.prototype.create = function(options) {
    var drawable;
    drawable = new Drawable(this, options);
    drawable.attachTo(this.snapElement);
    return drawable;
  };

  Canvas.prototype.find = function(id) {
    var drawable;
    drawable = new Drawable(this);
    drawable.useExisting(this.snapElement.select("#" + id));
    return drawable;
  };

  Canvas.prototype.resources = function() {
    if (this._resources) {
      return this._resources;
    }
    this._resources = new Resources(this);
    this._resources.attachTo(this.snapElement);
    return this._resources;
  };

  return Canvas;

})();

module.exports = Canvas;
