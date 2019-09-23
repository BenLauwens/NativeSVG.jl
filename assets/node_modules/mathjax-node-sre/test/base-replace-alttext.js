var tape = require('tape');
var mjAPI = require('../lib/main.js');

tape('Speech should replace alttext from source', function(t) {
  t.plan(7);

  mjAPI.start();
  var mml = '<math alttext="0"><mn>1</mn></math>';
  var expected = '100ex';

  mjAPI.typeset({
    math: mml,
    format: 'MathML',
    speakText: true,
    mml: true,
    mmlNode: true,
    svgNode: true,
    htmlNode: true
  }, function(data) {
    // test html output
    var labels = data.htmlNode.querySelectorAll('[aria-label]');
    t.notOk(labels[1], 'html output has only one aria-label');

    var checkLabel = (labels[0].getAttribute('aria-label') === '1');
    t.ok(checkLabel, 'html output has the correct aria-label');

    // test svg output
    var labeled = data.svgNode.querySelector('[aria-label]');
    t.notOk(labeled, 'svg output has no aria-label');

    var labelledbyID = data.svgNode.getAttribute('aria-labelledby');
    t.ok(labelledbyID, 'svg output aria-labelledby ID exists');

    var target = data.svgNode.querySelector('#'+labelledbyID);
    t.equal(target.textContent, '1', 'svg output aria-labelledby target exists');

    // test mml output
    var count = data.mml.match(/alttext/g).length;
    var checkAlt = data.mml.indexOf('alttext=\'1\'') > -1;
    t.notOk( count-1, 'mml output has only one alttext');
    t.notOk( checkAlt, 'mml output has the correct alttext');
  });
});
