/*
 * Peach
 * Author: Pete Saia
 */

(function () {
  'use strict';

  // Create a local.
  var Peach = {}; 

  // Make Peach a module for Node.
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
    this.processed        = false;
    this.identifier       = "§∆";
    
    Peach.log('Migrating from '+old_domain+' to '+new_domain+'.');
  };

  Peach.migrate.prototype = {
    init: function () {
      this._set_char_diff();
      this._handle_serializations();
      this._handle_other_domains();
      this._remove_identifier();
      this._processed = true;
      
      Peach.log('Complete!');
      return this;
    },
    
    get_processed_file: function () {
      return this._processed ? this.new_haystack : null;
    },
    
    _handle_serializations: function () {
      var serials,
          stack,
          domainCount,
          escapedDomain = reg_escape(this.old_domain),
          exp = new RegExp("s:(\\d+):\\\\?\"([^;]*"+escapedDomain+"[^;]*)\\\\?\";", "gi"),
          found = 0;

        while ((serials = exp.exec(this.new_haystack)) != null) {

          // Count the occurences of the domain in the string.
          domainCount = serials[2].match(new RegExp(escapedDomain, "gi")).length;

          // Split the haystack on the current find.
          stack = this._split_stack(exp.lastIndex - serials[0].length, exp.lastIndex);
          
          // Replace all instances.
          stack[1] = stack[1].replace(new RegExp(this.old_domain, "gi"), this.new_domain);

          // Get the new length.
          stack[1] = stack[1].replace(/(s:)?\d+/, function($0, $1) {
            return $1 ?
              ($1 + new RegExp("s:(\\d+):\\\\?\"([^;]*)\\\\?\";", "gi").exec(stack[1])[2].length) :
              $0;
          });

          this.new_haystack = stack.join('');
          found++;
        }
      this.serialized_count = found;
      Peach.log(found + ' serialized links found.');
    },
    
    _handle_other_domains: function () {
      var exp = new RegExp(reg_escape(this.old_domain)+"(.+?(\r|\n|'|\"))?", "gi"),
        matches = 0,
        escapedDomain = reg_escape(this.old_domain),
        that = this;

      this.new_haystack = this.new_haystack.replace(exp, function ($0, $1) {
        if ($0.indexOf(that.identifier) === -1) {
          matches++;
          return $0.replace(new RegExp(escapedDomain, "gi"), that.new_domain);
        }
        return $0;
      });
      this.replaced_count = matches;
      Peach.log('Replaced '+matches+' other links.');
    },
    
    _split_stack: function (from, to) {
      var stack = [];
      stack.push(this.new_haystack.substring(0,from));
      stack.push(this.new_haystack.substring(from, to));
      stack.push(this.new_haystack.substring(to));
      return stack;
    },
    
    _new_char_int: function (charint) {
      var old_int = parseInt(charint, 10),
          new_int;
      if (this.char_diff > 0) {
        new_int = old_int - Math.abs(this.char_diff);
      } else if (this.char_diff < 0) {
        new_int = old_int + Math.abs(this.char_diff);
      } else {
        new_int = old_int;
      }
      return new_int;
    },
    
    _remove_identifier: function () {
      this.new_haystack = this.new_haystack.replace(new RegExp(this.identifier, "g"), '');
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
    var matches = str.match(/('siteurl',')([^']+)/);
    return (matches && matches[2]) ? matches[2] : '';
  }
  
  Peach.log = function (str) {
    if (typeof window !== "undefined" && window.console) {
      window.console.log(str);
    }
  }

  function reg_escape(str) {
    var specials = [
      '/', '.', '*', '+', '?', '|',
      '(', ')', '[', ']', '{', '}'
    ],
      len = specials.length;
    
    for (var i = 0; len > i; i++) {
      str = str.replace(new RegExp("\\"+specials[i], "gi"), "\\"+specials[i]);
    }
    return str; 
  }

  function repeat(str, n) {
    n = n || 1;
    return Array(n+1).join(str);
  }
})();