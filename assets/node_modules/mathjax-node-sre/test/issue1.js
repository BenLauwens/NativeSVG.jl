var tape = require('tape');
var mjsre = require('../lib/main.js').typeset;

tape('SVG output: xlink:href namespace prefix', function(t) {
  t.plan(1);
  var input = 'x';
  mjsre({math: input, format: "TeX", svg: true},function(result){
      t.ok(result.svg.indexOf('xlink:href') > -1, 'SVG href has xlink prefix');
  });
});

tape('SVG output: add xlink to href in <image>', function(t) {
  t.plan(1);
  var mml = '<math><mglyph src="equation.svg" width="319pt" height="14pt"></mglyph></math>';
  var expected = /xlink:href/;

  mjsre({
    math: mml,
    format: "MathML",
    svg: true
  }, function(data) {
    t.ok(data.svg.match(expected));
  });
});
