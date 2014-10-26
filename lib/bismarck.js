var Bismarck, Canvas;

Canvas = require('./bismarck/canvas');

Bismarck = function(element, options) {
  if (typeof element === 'string') {
    return new Canvas(document.getElementById(element), options);
  } else {
    return new Canvas(element, options);
  }
};

Bismarck.debug = false;

module.exports = Bismarck;

if (typeof window !== "undefined" && window !== null) {
  window.Bismarck = Bismarck;
}
