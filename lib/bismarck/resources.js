var Resources,
  __slice = [].slice;

Resources = (function() {
  function Resources(canvas) {
    this.canvas = canvas;
    this.resources = {};
    this.bboxes = {};
  }

  Resources.prototype.attachTo = function(snapElement) {
    return this.resourceGroup = snapElement.group().attr({
      display: 'none'
    });
  };

  Resources.prototype.copyIDsFrom = function() {
    var id, ids, node, snapElement, _i, _len, _results;
    snapElement = arguments[0], ids = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    _results = [];
    for (_i = 0, _len = ids.length; _i < _len; _i++) {
      id = ids[_i];
      node = snapElement.select("#" + id);
      node.transform('');
      this.resourceGroup.append(node);
      _results.push(this.resources[id] = node);
    }
    return _results;
  };

  Resources.prototype.clone = function(id) {
    return this.resources[id].use();
  };

  Resources.prototype.copy = function(id) {
    return this.resources[id].clone();
  };

  Resources.prototype.bbox = function(id) {
    var _base;
    return (_base = this.bboxes)[id] || (_base[id] = this.resources[id].getBBox());
  };

  return Resources;

})();

module.exports = Resources;
