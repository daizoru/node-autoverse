#!/usr/bin/env coffee
# STANDARD LIBRARY MODULES
{inspect,log} = require 'util'
path = require 'path'

# THIRD-PARTIES MODULES
zappa     = require 'zappajs'
assets    = require 'connect-assets'
daemon    = require 'start-stop-daemon'
{async,delay,repeat} = require 'ragtime'

Model    = require './model'

# PROJECT MODULES
{info,warn,error,debug} = require './utils/logger'

# root dir of the lib
rootDir = path.normalize(__dirname + "/../")

log "rootDir: "+rootDir

# <SNIPPETS>
isFunction  = (obj) -> !!(obj and obj.constructor and obj.call and obj.apply)
isUndefined = (obj) -> typeof obj is 'undefined'
isArray     = (obj) -> Array.isArray obj
# </SNIPPETS>

settings =
  server:
    port: 3000
    autostart: true
    syncInterval: 1000 # in ms
    assets:
      src: "public"
      buildDir: "public/bin"
    asyncThrottle: 1 # in milliseconds

options =
  crashTimeout: 1000
  daemonFile: "/tmp/autoverse/autoverse-server.dmn"
  outFile: "/tmp/autoverse/autoverse-server.log"
  errFile: "/tmp/autoverse/autoverse-server.err"

daemon options, ->
  # server state - reinitialized at reboot

  model = new Model()
  
  debug "starting http server.."
  zappa settings.server.port, ->

    server = @

    @io.set 'log level', 1

    @express.static rootDir + 'public'
    @use "/textures", @express.static __dirname + '/textures'

    render_context =
      siteTitle: "<A U T O V E R S E> [status: ok]"
      mainTitle: "AUTOVERSE"
      
      layout: 'layout'

    @use 'partials'
    @use 'bodyParser'


    # a few shared function
    @shared '/shared.js': ->
      root = window ? global
      root.startsWith = (a,b)      -> b is a.substring 0, b.length
      root.delay      = (t,f)      -> setTimeout f, t
      root.async      = (f)        -> setTimeout f, 1
      root.repeat     = (t,f)      -> setInterval f, t
      root.P          = (p=0.5)    -> + (Math.random() < p)
      root.randomInt  = (min, max) -> Math.round(min + Math.random() * (max - min))
    @use assets
      src: rootDir + settings.server.assets.src
      build: no # BUG in connect-assets
      buildDir: rootDir + settings.server.assets.buildDir
      minifyBuilds: false
      helperContext: render_context

    @view index: ->
      html ->
        body ->
   
    @view layout: ->
      doctype 5
      html ->
        head ->
          # public/app.coffee dynamically built by connect-assets
          title @siteTitle
          script src: '/socket.io/socket.io.js'
          script src: '/zappa/jquery.js'
          script src: '/zappa/zappa.js'
          script src: '/shared.js'
          text @js 'app'
          text @css 'app'
          #script src: 'js/main.js'

        body @body

    @get '/': ->
      # Note: this does not work with `hardcode` (Coffee[CK]up limitation).
      @render 'index', render_context


    @get '/makeRobot': ->

      @send data