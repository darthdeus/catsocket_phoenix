exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: {
        "js/app.js": /^(web\/static\/js)/,
        "js/client.js": /^web\/static\/js\/client.ts/
      }


      // To use a separate vendor.js bundle, specify two files path
      // http://brunch.io/docs/config#-files-
      // joinTo: {
      //  "js/app.js": /^(web\/static\/js)/,
      //  "js/vendor.js": /^(web\/static\/vendor)|(deps)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // order: {
      //   before: [
      //     "web/static/vendor/js/jquery-2.1.1.js",
      //     "web/static/vendor/js/bootstrap.min.js"
      //   ]
      // }

    },
    stylesheets: {
      joinTo: "css/bundle.css",
      order: {
        after: ["web/static/css/app.scss"] // concat app.css last
      }
    },
    // templates: {
    //   joinTo: "js/app.js"
    // }
  },

  conventions: {
    assets: /^(web\/static\/assets)/
  },

  paths: {
    watched: [
      "web/static",
      "test/static"
    ],
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    brunchTypescript: {},
    babel: {
      presets: ['stage-2', 'es2015', 'es2016', 'react'],
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    sass: {
      mode: "native",
      options: {
        includePaths: [
          "node_modules/bootstrap-sass/assets/stylesheets",
          "node_modules/font-awesome/scss",
          "node_modules/prismjs/themes",
          "web/static/js"
        ]
      }
    }
  },

  // modules: {
  //   autoRequire: {
  //     "js/app.js": ["web/static/js/app"]
  //   }
  // },

  npm: {
    enabled: true
  }
};
