(function() {
  var Model, assets, async, daemon, debug, delay, error, info, inspect, isArray, isFunction, isUndefined, log, options, path, repeat, rootDir, settings, warn, zappa, _ref, _ref1, _ref2;

  _ref = require('util'), inspect = _ref.inspect, log = _ref.log;

  path = require('path');

  zappa = require('zappajs');

  assets = require('connect-assets');

  daemon = require('start-stop-daemon');

  _ref1 = require('ragtime'), async = _ref1.async, delay = _ref1.delay, repeat = _ref1.repeat;

  Model = require('./model');

  _ref2 = require('./utils/logger'), info = _ref2.info, warn = _ref2.warn, error = _ref2.error, debug = _ref2.debug;

  rootDir = path.normalize(__dirname + "/../");

  log("rootDir: " + rootDir);

  isFunction = function(obj) {
    return !!(obj && obj.constructor && obj.call && obj.apply);
  };

  isUndefined = function(obj) {
    return typeof obj === 'undefined';
  };

  isArray = function(obj) {
    return Array.isArray(obj);
  };

  settings = {
    server: {
      port: 3000,
      autostart: true,
      syncInterval: 1000,
      assets: {
        src: "public",
        buildDir: "public/bin"
      },
      asyncThrottle: 1
    }
  };

  options = {
    crashTimeout: 1000,
    daemonFile: "/tmp/autoverse/autoverse-server.dmn",
    outFile: "/tmp/autoverse/autoverse-server.log",
    errFile: "/tmp/autoverse/autoverse-server.err"
  };

  daemon(options, function() {
    var model;
    model = new Model();
    debug("starting http server..");
    return zappa(settings.server.port, function() {
      var render_context, server;
      server = this;
      this.io.set('log level', 1);
      this.express["static"](rootDir + 'public');
      this.use("/textures", this.express["static"](__dirname + '/textures'));
      render_context = {
        siteTitle: "<A U T O V E R S E> [status: ok]",
        mainTitle: "AUTOVERSE",
        layout: 'layout'
      };
      this.use('partials');
      this.use('bodyParser');
      this.shared({
        '/shared.js': function() {
          var root;
          root = typeof window !== "undefined" && window !== null ? window : global;
          root.startsWith = function(a, b) {
            return b === a.substring(0, b.length);
          };
          root.delay = function(t, f) {
            return setTimeout(f, t);
          };
          root.async = function(f) {
            return setTimeout(f, 1);
          };
          root.repeat = function(t, f) {
            return setInterval(f, t);
          };
          root.P = function(p) {
            if (p == null) {
              p = 0.5;
            }
            return +(Math.random() < p);
          };
          return root.randomInt = function(min, max) {
            return Math.round(min + Math.random() * (max - min));
          };
        }
      });
      this.use(assets({
        src: rootDir + settings.server.assets.src,
        build: false,
        buildDir: rootDir + settings.server.assets.buildDir,
        minifyBuilds: false,
        helperContext: render_context
      }));
      this.view({
        index: function() {
          return html(function() {
            return body(function() {});
          });
        }
      });
      this.view({
        layout: function() {
          doctype(5);
          return html(function() {
            head(function() {
              title(this.siteTitle);
              script({
                src: '/socket.io/socket.io.js'
              });
              script({
                src: '/zappa/jquery.js'
              });
              script({
                src: '/zappa/zappa.js'
              });
              script({
                src: '/shared.js'
              });
              text(this.js('app'));
              return text(this.css('app'));
            });
            return body(this.body);
          });
        }
      });
      this.get({
        '/': function() {
          return this.render('index', render_context);
        }
      });
      return this.get({
        '/makeRobot': function() {
          return this.send(data);
        }
      });
    });
  });

}).call(this);
