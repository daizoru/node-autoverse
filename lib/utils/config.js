(function() {
  var extend, fs, readConfig, yaml;

  yaml = require("js-yaml");

  fs = require("fs");

  extend = function(dest, from) {
    var props;
    props = Object.getOwnPropertyNames(from);
    return props.forEach(function(name) {
      var destination;
      if (name in dest && typeof dest[name] === "object") {
        return extend(dest[name], from[name]);
      } else {
        destination = Object.getOwnPropertyDescriptor(from, name);
        return Object.defineProperty(dest, name, destination);
      }
    });
  };

  readConfig = function(config_file, env) {
    var config, e, settings, settings_env;
    if (!env) {
      env = process.env.NODE_ENV || "development";
    }
    try {
      config = require(config_file);
      settings = config["default"] || {};
      settings_env = config[env] || {};
      extend(settings, settings_env);
      return settings;
    } catch (_error) {
      e = _error;
      log.error(e);
      return {};
    }
  };

  module.exports.readConfig = readConfig;

}).call(this);
