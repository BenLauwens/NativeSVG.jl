var tape = require('tape');
var mjsre = require("../lib/main.js");

tape('Base: typeset promise API', function (t) {
    t.plan(2);

    var tex = '';
    mjsre.start();

    // promise resolved
    mjsre.typeset({
        math: tex,
        format: "TeX",
        mml: true
    }).then((result) => t.ok(result.mml, 'Typset promise resolved on success'));

    mjsre.typeset({
        math: tex,
        format: "MathML",
        mml: true
    }).catch((error) => t.ok(error, 'Typeset promise rejected on error'));
});
