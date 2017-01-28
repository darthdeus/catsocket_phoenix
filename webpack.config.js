const path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin');
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
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&mimetype=application/font-woff"
      },

			{
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "file-loader"
      },

      {
        test: /\.scss$/,
        loaders: ["style-loader", "css-loader", "resolve-url", "sass-loader"]
      },

      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015', 'react']
        }
      }
    ]
  },

  plugins: [
    new CopyWebpackPlugin([
      { from: 'web/static/assets/', to: '..' }
    ])
  ]
};
