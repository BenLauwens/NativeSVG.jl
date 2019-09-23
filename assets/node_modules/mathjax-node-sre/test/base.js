var tape = require('tape');
var mjsre = require('../lib/main.js').typeset;

tape('Base check', function(t) {
  t.plan(1);
  var input = 'x';
  mjsre({math: input, format: "TeX", svg: true},function(result){
    t.ok(result.svg, 'basic test');
  });
});
