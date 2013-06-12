module.exports = ->

  @initConfig

    pkg: @file.readJSON 'package.json'

    coffee: 
      build:
        expand: yes
        flatten: no
        cwd: 'src/coffee/backend'
        src: ['**/*.coffee']
        dest: 'lib/'
        ext: '.js'
    
    concat:
      options:
        stripBanners: yes
        #banner: """/*! <%= pkg.name %> - v<%= pkg.version %> -
        #  <%= grunt.template.today("yyyy-mm-dd") %> */"""

      components:
        src: 'components/cannon.js/build/cannon.js'
        dest: 'public/js/vendors/cannon.js'

    uglify:
      options: mangle: no
      #vendor: 
      #  files: 'lib/logger.min.js': 'lib/logger.js'

    watch:
      coffee:
        files: [ 'src/coffee/backend/**/*.coffee' ]
        tasks: [ 'coffee' ]
        options: debounceDelay: 250

    bgShell:
      _defaults: bg: no
      autoverse: cmd: './bin/autoverse'

  @loadNpmTasks 'grunt-contrib-uglify'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-contrib-watch'
  @loadNpmTasks 'grunt-bg-shell'


  @registerTask 'build', [
    'concat:components'
    'coffee'
  ]
  @registerTask 'start', [
    'bgShell:autoverse'
  ]
  @registerTask 'default', [
    'build'
    'start'
  ]