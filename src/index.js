require('scss/style.scss');
require('highlight.js');

var Elm = require('Main');
var node = document.getElementById('main')
var app = Elm.Main.embed(node);
