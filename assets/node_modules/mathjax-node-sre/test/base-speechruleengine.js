var tape = require('tape');
var mjsre = require('../lib/main.js').typeset;

tape('Base check: speech-rule-engine', function(t) {
  t.plan(1);
  var input = 'x';
  mjsre({math: input, format: "TeX", svgNode: true, speakText:true},function(result){
    t.ok(result.speakText, 'basic test');
  });
});
