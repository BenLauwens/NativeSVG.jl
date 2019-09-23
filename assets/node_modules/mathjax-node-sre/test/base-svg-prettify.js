var tape = require('tape');
var mjsre = require('../lib/main.js').typeset;

tape('Base: SVG prettify', function(t) {
  t.plan(1);
  var input = 'x';
  mjsre({math: input, format: "TeX", svg: true,speakText: true},function(result){
    t.ok(result.svg.indexOf('\n') !== -1, 'SVG string contains linebreaks');
  });
});
