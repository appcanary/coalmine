$(document).ready(function() {
  if ($('#docs pre').length > 0) {
    var hljs = require('highlight.js/lib/highlight.js')
    hljs.registerLanguage('bash', require('highlight.js/lib/languages/bash'));
    hljs.registerLanguage('json', require('highlight.js/lib/languages/json'));

    $('#docs pre').each(function(i, block) {
      hljs.highlightBlock(block);
    });
  }
});
