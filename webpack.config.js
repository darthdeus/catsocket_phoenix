const path = require("path");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const jsdir = path.resolve(__dirname, "priv/static/js");
const HappyPack = require("happypack");

const happyThreadPool = HappyPack.ThreadPool({size: 8});

module.exports = {
  entry: "./web/static/js/app.jsx",

  output: {
    path: jsdir,
    filename: "app.js"
  },

  resolve: {
    modules: ["node_modules", jsdir]
  },

  module: {
    loaders: [
			{
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "happypack/loader?id=woffs",
        // loader: "url-loader?limit=10000&mimetype=application/font-woff"
      },

			{
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "happypack/loader?id=files"
        // loader: "file-loader"
      },

      {
        test: /\.scss$/,
        loader: "happypack/loader?id=scss"
        // loaders: ["style-loader", "css-loader", "resolve-url", "sass-loader"]
      },

      // {
      //   test: require.resolve('react'),
      //   loader: 'imports'
      // },

      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        loader: "happypack/loader?id=jsx"
        // loader: "babel-loader",
        // query: {
        //   presets: ["es2015", "react"]
        // }
      }
    ]
  },

  plugins: [
    new CopyWebpackPlugin([
      { from: "web/static/assets/", to: ".." }
    ]),

    new HappyPack({
      id: "woffs",
      loaders: ["url-loader?limit=10000&mimetype=application/font-woff"],
      threadPool: happyThreadPool,
    }),

    new HappyPack({
      id: "files",
      loaders: ["file-loader"],
      threadPool: happyThreadPool,
    }),

    new HappyPack({
      id: "scss",
      loaders: ["style-loader", "css-loader", "resolve-url", "sass-loader"],
      threadPool: happyThreadPool,
    }),

    new HappyPack({
      id: "jsx",
      loaders: ["babel-loader?cacheDirectory=true&presets[]=es2015&presets[]=react"],
      threadPool: happyThreadPool,
    }),
  ]
};
