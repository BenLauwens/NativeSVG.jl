const mathjax = require('mathjax-node');
const sre = require('speech-rule-engine');

// New configuration values are:
//
// speakText: true,               // adds spoken annotations to output
// speakRuleset: "mathspeak",      // set speech ruleset; default (= chromevox rules) or mathspeak
// speakStyle: "default",          // set speech style for mathspeak rules:  default, brief, sbrief)
// semantic: false,                // adds semantic tree information to output
// minSTree: false,                // if true the semantic tree is minified
// enrich: false                   // replace the math input with MathML resulting from SRE enrichment
// speech: 'deep'                  // sets depth of speech; 'shallow' or 'deep'

// How to use them:
// in main, pre-processor: the `data` parameter is the usual mathjax-node configuration object, with (possibly) the above additions.
// in post-processor: the `config` only consists of the above values

// `result` data extends the mathjax-node `result` data.
// Additional values are
//
// speakText:                      // string with spoken annotation


const main = function (data, callback) {
    const speechConfig = {
        speech: data.speech ||'deep',
        semantics: true,
        domain: data.speakRuleset || 'mathspeak',
        style: data.speakStyle || 'default',
        semantic: data.semantic,
        minSTree: data.minSTree,
        speakText: true
    };
    if (data.speakText === false) speechConfig.speakText = false;
    // backup data
    data.originalData = {
        mml: data.mml,
        mmlNode: data.mmlNode,
        svgNode: data.svgNode,
        htmlNode: data.htmlNode
    }
    // modify configuration
    if (data.svg) data.svgNode = true;
    if (data.html) data.htmlNode = true;
    data.mmlNode = true;
    data.mml = true;

    mathjax.typeset(data, function (result, input) {
        postprocessor(speechConfig, result, input, callback);
    })
};

const postprocessor = function (speechConfig, result, input, callback) {
    if (result.error) throw result.error;
    if (!result.mml && !result.mmlNode) throw new Error('No MathML found. Please check the mathjax-node configuration');
    if (!result.svgNode && !result.htmlNode && !result.mmlNode) throw new Error('No suitable output found. Either svgNode, htmlNode or mmlNode are required.');
    if (!result.mml) result.mml = result.mmlNode.outerHTML;
    if (!speechConfig.speech) speechConfig.speech =  'deep';
    // add semantic tree
    if (speechConfig.semantic) {
        result.streeJson = sre.toJson(result.mml);
        const xml = sre.toSemantic(result.mml).toString();
        result.streeXml = speechConfig.minSTree ? xml : sre.pprintXML(xml);
    }
    // return if no speakText is requested
    if (!speechConfig.speakText) {
        callback(result, input);
        return
    }
    // enrich output
    sre.setupEngine(speechConfig);
    result.speakText = sre.toSpeech(result.mml);
    if (result.svgNode) {
        result.svgNode.querySelector('title').innerHTML = result.speakText;
        // update serialization
        // HACK add lost xlink namespaces TODO file jsdom bug
        if (result.svg) result.svg = result.svgNode.outerHTML
            .replace(/><([^/])/g, ">\n<$1")
            .replace(/(<\/[a-z]*>)(?=<\/)/g, "$1\n")
            .replace(/(<(?:use|image) [^>]*)(href=)/g, ' $1xlink:$2');
    }
    if (result.htmlNode) {
        result.htmlNode.firstChild.setAttribute("aria-label", result.speakText);
        // update serialization
        if (result.html) result.html = result.htmlNode.outerHTML;
    }
    if (result.mmlNode) {
        result.mmlNode.setAttribute("alttext", result.speakText);
        // update serialization
        if (result.mml) result.mml = result.mmlNode.outerHTML;
    }
    // remove intermediary outputs
    if (input.originalData) {
        if (!input.originalData.mml) delete result.mml;
        if (!input.originalData.mmlNode) delete result.mmlNode;
        if (!input.originalData.svgNode) delete result.svgNode;
        if (!input.originalData.htmlNode) delete result.htmlNode;
        delete input.originalData;
    }
    callback(result, input);
}

const preprocessor = function (data, callback) {
    // setup SRE
    const speechConfig = {
        semantics: true,
        domain: data.speakRuleset || 'mathspeak',
        style: data.speakStyle || 'default',
        semantic: data.semantic,
        minSTree: data.minSTree,
        speakText: true,
        speech: 'deep'
    };
    if (data.speakText === false) speechConfig.speakText = false
    sre.setupEngine(speechConfig);
    // if MathML, enrich and continue
    if (data.format === "MathML") {
        data.speakText = sre.toSpeech(data.math);
        data.math = sre.toEnriched(data.math).toString();
        data.math = data.math.replace(/alttext="(.*?)"/,'alttext="' + data.speakText + '"');
        callback(data);
    } else {
        // convert to MathML, enrich and continue
        const newdata = {
            math: data.math,
            format: data.format,
            mml: true
        };
        mathjax.typeset(newdata, function (result) {
            if (result.error) throw result.error;
            data.speakText = sre.toSpeech(result.mml);
            data.math = sre.toEnriched(result.mml).toString();
            data.math = data.math.replace(/alttext="(.*?)"/,'alttext="' + data.speakText + '"');
            data.format = 'MathML';
            callback(data);
        });
    }
}


exports.start = mathjax.start;
exports.config = mathjax.config;
const cbTypeset = function (data, callback) {
    if (data.enrich) {
        preprocessor(data, function (result) {
            main(result, callback);
        })
    } else main(data, callback);
};
// main API, callback and promise compatible
exports.typeset = function (data, callback) {
    if (callback) cbTypeset(data, callback);
    else return new Promise(function (resolve, reject) {
        cbTypeset(data, function (output, input) {
            if (output.errors) reject(output.errors);
            else resolve(output, input);
        });
    });
};
exports.postprocessor = postprocessor;
exports.preprocessor = preprocessor;
