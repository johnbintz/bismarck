module.exports = (grunt) ->
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  grunt.initConfig {
    watch:
      coffee:
        files: ['src/**/*.coffee']
        tasks: ['browserify', 'coffee', 'uglify']
    browserify:
      dist:
        files:
          'dist/bismarck.js': 'src/bismarck.coffee'
        options:
          transform: ['coffeeify']
          browserifyOptions:
            debug: true
            extensions: ['.coffee', '.litcoffee']
    coffee:
      lib:
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'
        options:
          bare: true
    karma:
      unit:
        configFile: 'karma.conf.js'
        autoWatch: true
    uglify:
      options:
        mangle: false
      dist:
        files:
          'dist/bismarck.min.js': 'dist/bismarck.js'
    concurrent:
      default:
        tasks: ['karma', 'watch']
        options:
          logConcurrentOutput: true
          limit: 2
  }

  grunt.registerTask 'default', ['browserify', 'uglify', 'coffee', 'concurrent:default']

