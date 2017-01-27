const path = require('path');

const jsdir = path.resolve(__dirname, 'priv/static/js');

module.exports = {
  entry: "./web/static/js/app.jsx",

  output: {
    path: jsdir,
    filename: 'app.js'
  },

  resolve: {
    modules: ['node_modules', jsdir]
  },

  module: {
    loaders: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015', 'react']
        }
      }
    ]
  }
};
