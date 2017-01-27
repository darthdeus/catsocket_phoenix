const path = require('path');

const jsdir = path.resolve(__dirname, 'priv/static/js');

module.exports = {
  entry: "./web/static/js/app.js",

  output: {
    path: jsdir,
    filename: 'app.js'
  },

  resolve: {
    modules: ['node_modules', jsdir]
  },

  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: 'babel-loader'
      }
    ]
  }
};
