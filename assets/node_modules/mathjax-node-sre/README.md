# mathjax-node-sre [![Build Status](https://travis-ci.org/pkra/mathjax-node-sre.svg?branch=master)](https://travis-ci.org/pkra/mathjax-node-sre)

[![Greenkeeper badge](https://badges.greenkeeper.io/pkra/mathjax-node-sre.svg)](https://greenkeeper.io/)

This module extends [mathjax-node](https://github.com/mathjax/MathJax-node) using [speech-rule-engine](https://github.com/zorkow/speech-rule-engine).

It can be used as a drop-in replacement for mathjax-node.

Use

    npm install mathjax-node-sre

to install mathjax-node-sre and its dependencies.

# features

mathjax-node-sre provides three features.

## drop-in replacement for mathjax-node

mathjax-node-sre can be used as a drop-in replacement of mathjax-node, so just import `start`, `config`, and `typeset` as you would with mathjax-node.

In addition to the usual mathjax-node configuration options, mathjax-node-sre accepts

```
speakText: false,               // adds spoken annotations to output
speakRuleset: "mathspeak",      // set speech ruleset; default (= chromevox rules) or mathspeak
speakStyle: "default",          // set speech style for mathspeak rules:  default, brief, sbrief)
semantic: false,                // adds semantic tree information to output
minSTree: false,                // if true the semantic tree is minified
enrich: false                   // replace the math input with MathML resulting from SRE enrichment
speech: 'deep'                  // sets depth of speech; 'shallow' or 'deep'
```

## post-processor

mathjax-node-sre provides a `postprocessor` which expects mathjax-node output together with a configuration object containing the above options (except `enrich`) to add speech-text to mathjax-node output.

For example,

```
const mj = require('mathjax-node').typeset;
const postprocessor = require('mathjax-node-sre').postprocessor;

mj({math: 'x + y', format: "TeX", mml: true},function(result){
  postprocessor({speakText: true}, result, function(output){
    console.log(output.speakText) // => x plus y
  })
});
```

## pre-processor

mathjax-node-sre provides a `preprocessor` which expects mathjax-node input and replaces the input with the result of (if necessary converting to) MathML and enriching the MathML with SRE.

For example:

```
var preprocessor = require('mathjax-node-sre').preprocessor;
preprocessor({ math: 'x^2', format: "TeX"}, function(output){
    console.log(output.math) // => <math xmlns="http://www.w3.org/1998/Math/MathML" display="block" alttext="x^2"><msup data-semantic-type="superscript" data-semantic-role="latinletter" data-semantic-id="2" data-semantic-children="0,1"><mi data-semantic-type="identifier" data-semantic-role="latinletter" data-semantic-font="italic" data-semantic-id="0" data-semantic-parent="2">x</mi><mn data-semantic-type="number" data-semantic-role="integer" data-semantic-font="normal" data-semantic-id="1" data-semantic-parent="2">2</mn></msup></math>
})
```
