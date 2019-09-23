var tape = require('tape');
var mjsre = require('../lib/main.js').typeset;

tape('Passing data long to output', function(t) {
  t.plan(1);
  let tex = 'x + y';
  let data = {
    math: tex,
    format: "TeX",
    mmlNode: true
  };
  mjsre(data, function(result, input) {
    t.equal(input.format, 'TeX', 'Input data is passed to output');
  });
});
