var tape = require('tape');
var mjsre = require('../lib/main.js').typeset;

tape('Base check: speech-rule-engine semanticTree', function(t) {
  t.plan(2);
  var tex = 'x';
  mjsre({
    math: tex,
    format: "TeX",
    mml: true,
    speakText: true,
    semantic: true
  }, function(data) {
    t.ok(data.streeJson, 'semantic tree JSON');
    t.ok(data.streeXml, 'semantic tree XML');
  });
});
