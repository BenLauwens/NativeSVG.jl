var tape = require('tape');
var mjsre = require('../lib/main.js').typeset;
var preprocessor = require('../lib/main.js').preprocessor;

tape('Base check: preprocessor', function(t) {
  t.plan(4);
  let tex = 'x + y';
  let data = {
    math: tex,
    format: "TeX",
    mmlNode: true,
    enrich: true
  };
  mjsre(data, function(result) {
    t.equal(result.mmlNode.getAttribute('data-semantic-role'), 'addition', '`enrich:true` provides enriches MathML');
  });
  preprocessor(data, function(output){
    t.equal(output.format, 'MathML', 'Format correct');
    t.equal(typeof output.speakText, 'string', 'pre-processing sets SpeakText string')
    t.ok(output.math.indexOf('data-semantic-role') > -1, 'MathML is enriched')
  })
});
