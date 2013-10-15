/*
 * Peach
 * https://github.com/petesaia/Peach
 * A synchronous tool which allows a safe way to find and replace
 * a string within a database dump containing serialized objects.
 *
 * Online version:
 * http://petesaia.github.io/Peach/
 */

(function () {
  'use strict';

  var Peach = {}; 

  if (typeof exports !== 'undefined') {
    exports = module.exports = Peach;
  } else {
    this.Peach = Peach;
  }

  Peach.migrate = function (haystack, old_domain, new_domain) {
    if (!haystack || !old_domain || !new_domain)
        throw new Error("A haystack, old domain, and new domain is required.");
    
    if (!(this instanceof Peach.migrate))
        return new Peach.migrate(haystack, old_domain, new_domain);
    
    this.haystack         = haystack;
    this.new_haystack     = haystack;
    this.old_domain       = old_domain;
    this.new_domain       = new_domain;
    this.serialized_count = 0;
    this.replaced_count   = 0;
    this.char_diff        = null;

    Peach.log('Migrating from '+old_domain+' to '+new_domain+'.');
    this.init();
  };

  Peach.migrate.prototype = {
    init: function () {
      this._set_char_diff();
      this._handle_serializations();
      this._handle_other_domains();
      Peach.log('Migration complete!');
      return this;
    },
    processed_file: function () {
      return this.new_haystack;
    },
    _handle_serializations: function () {
      var that = this;
      var escapedDomain = reg_escape(this.old_domain);
      var lines = this.new_haystack.split(/(\n|\r|\r\n|\n\r)/);
      for (var i = 0, len = lines.length; i < len; i++) {
        lines[i] = lines[i].replace(
          /s:(\d+):\\?\"(.*?)\\?";/gi,
          function (match, p1, p2, offset, string) {
            if (p2.indexOf(that.old_domain) === -1) {
              return match; // Nothing to replace.
            } else {
              that.serialized_count++;
              p2 = p2.replace(new RegExp(escapedDomain, "gi"), that.new_domain);
              return "s:"+p2.length+":\""+p2+"\";";
            }
          }
        );
      }
      this.new_haystack = lines.join("");
      Peach.log(this.serialized_count + ' serialized links found.');
    },
    _handle_other_domains: function () {
      var that = this;
      this.new_haystack = this.new_haystack.replace(
        new RegExp(reg_escape(this.old_domain), "gi"),
        function () {
          that.replaced_count++;
          return that.new_domain;
        }
      );
      Peach.log('Replaced '+this.replaced_count+' other links.');
    },
    _set_char_diff: function () {
      this.char_diff = this.new_domain.length - this.old_domain.length;
      Peach.log('Domain character difference: '+this.char_diff+'.');
    }
  };
  Peach.wp_domain = function (str) {
    if (typeof str !== "string") {
      throw new Error("A string is required.");
    }
    var matches = str.match(/('|"')siteurl('|"')[^"']+('|"')([^'"]+)('|"').+/);
    return (matches && matches[4]) ? matches[4] : '';
  };
  Peach.log = function (str) {
    if (typeof window !== "undefined" && window.console) {
      window.console.log(str);
    }
  };
  function reg_escape(str) {
    var specials = [
      '/', '.', '*', '+', '?', '|',
      '(', ')', '[', ']', '{', '}'
    ];
    for (var i = 0, len = specials.length; len > i; i++) {
      str = str.replace(new RegExp("\\"+specials[i], "gi"), "\\"+specials[i]);
    }
    return str; 
  }
}).call(this);
