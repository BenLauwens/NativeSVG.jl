var tape = require('tape');
var mjAPI = require('../lib/main.js');

tape('Base: result should return minimal object', function(t) {
  t.plan(5);

  mjAPI.start();
  var tex = 'x';

  mjAPI.typeset({
    math: tex,
    format: 'TeX',
    speakText: true,
    svg: true,
    html: true
  }, function(result, input) {
    t.notOk(result.mml, 'mml not returned');
    t.notOk(result.mmlNode, 'mmlNode not returned');
    t.notOk(result.svgNode, 'svgNode not returned');
    t.notOk(result.htmlNode, 'htmlNode not returned');
    t.notOk(input.originalData, 'backup data not returned');
  });
});
