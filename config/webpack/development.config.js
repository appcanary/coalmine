var webpack = require('webpack');
var _ = require('underscore');

var config = module.exports = require('./main.config.js');

config = _.extend(config, {
  debug: true,
  displayErrorDetails: true,
  outputPathinfo: true,
  devtool: 'sourcemap',
});
