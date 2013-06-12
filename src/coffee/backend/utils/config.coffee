yaml = require "js-yaml"  # register .yaml require handler
fs = require "fs"

extend = (dest, from) ->
  props = Object.getOwnPropertyNames from
  props.forEach (name) ->
    if name of dest and typeof dest[name] is "object"
      extend dest[name], from[name]
    else
      destination = Object.getOwnPropertyDescriptor from, name
      Object.defineProperty dest, name, destination

readConfig = (config_file, env) ->
  env = process.env.NODE_ENV or "development"  unless env
  try
    config = require config_file
    settings = config["default"] or {}
    settings_env = config[env] or {}
    extend settings, settings_env
    return settings
  catch e
    log.error e
    return {}

module.exports.readConfig = readConfig