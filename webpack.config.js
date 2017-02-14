const path = require("path");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const HappyPack = require("happypack");

const happyThreadPool = HappyPack.ThreadPool({size: 8});

const jsdir = path.resolve(__dirname, "priv/static/js");

module.exports = {
  entry: [
    "./web/static/js/app.jsx",
    "./web/static/js/client.ts"
  ],

  output: {
    path: jsdir,
    filename: "app.js"
  },

  resolve: {
    extensions: [".js", ".jsx", ".ts", ".tsx"],
    modules: ["node_modules", jsdir]
  },

  module: {
    rules: [
      // {
      //   test: require.resolve('react'),
      //   loader: 'imports'
      // },

			{
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        // loader: "happypack/loader?id=woffs",
        use: "url-loader?limit=10000&mimetype=application/font-woff"
      },

			{
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        // loader: "happypack/loader?id=files"
        use: "file-loader"
      },

      {
        test: /\.scss$/,
        // loader: "happypack/loader?id=scss"
        use: ["style-loader", "css-loader", "resolve-url", "sass-loader"]
      },

      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: "happypack/loader?id=jsx"
        // loader: "babel-loader",
        // query: {
        //   presets: ["es2015", "react"]
        // }
      },


      {
        test: /\.tsx?$/,
        exclude: /node_modules/,
        use: "happypack/loader?id=tsx"
        // loader: "babel-loader",
        // query: {
        //   presets: ["es2015", "react"]
        // }
      },

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

    new HappyPack({
      id: "tsx",
      loaders: ["babel-loader?presets[]=react"],
      threadPool: happyThreadPool,
    }),
  ]
};
