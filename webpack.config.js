const path = require("path");
const CopyWebpackPlugin = require("copy-webpack-plugin");
// const jsdir = path.resolve(__dirname, "priv/static/js");

module.exports = {
  entry: "./web/static/js/app.jsx",

  output: {
    path: path.resolve(__dirname, "priv/static/js"),
    filename: "app.js"
  },

  resolve: {
    // modules: ["node_modules", jsdir],
    modules: ["node_modules", path.resolve(__dirname, "web/static/js")],
    extensions: ['.js', '.jsx', '.ts', '.tsx']
  },

  module: {
    rules: [
			{
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        use: "url-loader?limit=10000&mimetype=application/font-woff"
      },

			{
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        use: "file-loader"
      },

      {
        test: /\.scss$/,
        use: [
          "style-loader",
          "css-loader",
          "sass-loader"
        ]
      },

      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: [
          {
            loader: "babel-loader",
            options: {
              presets: ["es2015", "react"]
            }
          }
        ]
      },

      {
        test: /\.tsx?$/,
        exclude: /node_modules/,
        use: [
          {
            loader: "babel-loader",
            options: {
              presets: ["es2015", "react"]
            }
          }
        ]
      },

      {
        test: /\.tsx?$/,
        exclude: /node_modules/,
        use: [
          {
            loader: "babel-loader",
            options: {
              presets: ["es2015", "react"]
            }
          },
          "ts-loader"
        ]
      }
    ]
  },

  plugins: [
    new CopyWebpackPlugin([
      { from: "web/static/assets/", to: ".." }
    ]),

  ]
};
