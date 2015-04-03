/**
 * @see http://webpack.github.io/docs/configuration.html
 * for webpack configuration options
 */
module.exports = {
  // 'context' sets the directory where webpack looks for module files you list in
  // your 'require' statements
  context: __dirname + '/app/assets/javascripts',

  // 'entry' specifies the entry point, where webpack starts reading all
  // dependencies listed and bundling them into the output file.
  // The entrypoint can be anywhere and named anything - here we are calling it
  // '_application' and storing it in the 'javascripts' directory to follow
  // Rails conventions.
  entry: './init.js',

  // 'output' specifies the filepath for saving the bundled output generated by
  // wepback.
  // It is an object with options, and you can interpolate the name of the entry
  // file using '[name]' in the filename.
  // You will want to add the bundled filename to your '.gitignore'.
  output: {
    filename: '[name].bundle.js',
    // We want to save the bundle in the same directory as the other JS.
    path: __dirname + '/app/assets/javascripts',
  },

  externals: {
    // If you load jQuery through a CDN this will still work
    // jQuery is now available via "require('jquery')"
    jquery: 'var jQuery'
  },

  resolve: {
    "extensions": ["", ".js.jsx", ".js", ".jsx"]
  },

  // The 'module' and 'loaders' options tell webpack to use loaders.
  // @see http://webpack.github.io/docs/using-loaders.html
  module: {
    loaders: [
      { test: /\.jsx?$/, exclude: /node_modules/, loader: 'babel-loader'}
    ]
  }
};
