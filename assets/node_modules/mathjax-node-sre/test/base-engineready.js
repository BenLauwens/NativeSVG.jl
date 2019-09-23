var tape = require('tape');
const mj = require('mathjax-node').typeset;
const postprocessor = require('../lib/main.js').postprocessor;
const preprocessor = require('../lib/main.js').preprocessor;

tape('Wait for sre.engineReady()', function(t) {
  t.plan(2);

  const input = {math: '(', format: "TeX", mmlNode: true};
  preprocessor(input, function(output){
    t.ok(output.math.includes('alttext="left-parenthesis"'), 'Preprocessor enrichment ok');
  });

  mj(input, function(result, input){
    postprocessor({speakText: true}, result, input, function(result){
      t.equal(result.speakText, 'left-parenthesis', 'Postprocessor ok');
    })
  });
});
