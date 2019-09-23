var tape = require('tape');
var mjAPI = require('../lib/main.js');

tape('Base Config Default', function(t) {
  t.plan(1);

  mjAPI.start();
  var mml = '<math><mn>1</mn></math>';

  mjAPI.typeset({
    math: mml,
    format: 'MathML',
    mml: true,
    svgNode: true,
  }, function(data) {
    var target = data.svgNode.querySelector('title');
    t.equal(target.textContent, '1', 'speakText: true');
  });
});
