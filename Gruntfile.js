module.exports = function(grunt) {
  var scripts = [
    'assets/js/lib/jquery.js',
    'assets/js/lib/jquery.activity-indicator-1.0.0.js',
    'assets/js/filemanager.js',
    'assets/js/peach.js',
    'assets/js/ui.js'
  ];
  grunt.initConfig({
    concat: {
      options: {
        separator: ';',
      },
      build: {
        files: {
          'assets/dist/peach.js': scripts
        }
      }
    },
    uglify: {
      build: {
        files: {
          'assets/dist/peach.min.js': ['assets/dist/peach.js']
        }
      }
    },
    cssmin: {
      build: {
        files: {
          'assets/dist/peach.css': ['assets/css/style.css']
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.registerTask('default', ['concat', 'uglify', 'cssmin']);
};
