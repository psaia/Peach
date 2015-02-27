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

  /**
   * This method will change the domain within a database dump and populate
   * various properties within this object with information about the
   * conversion.
   *
   * @param {string} haystack  The dump that should be converted.
   * @param {string} old_domain  The domain that will be changed.
   * @param {string} new_domain  The new desired domain.
   * @return {void}
   */
  Peach.migrate = function (haystack, old_domain, new_domain) {
    if (!haystack || !old_domain || !new_domain) {
      throw new Error("A haystack, old domain, and new domain is required.");
    }

    if (!(this instanceof Peach.migrate)) {
      return new Peach.migrate(haystack, old_domain, new_domain);
    }

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

    /**
     * This will preform a normal migration.
     * @return {void}
     */
    init: function () {
      this._set_char_diff();
      this._handle_serializations();
      this._handle_other_domains();
      Peach.log('Migration complete!');
      return this;
    },

    /**
     * A simple convience method for accessing the processed
     * haystack.
     * @return {void}
     */
    processed_file: function () {
      return this.new_haystack;
    },

    /**
     * This method will handle all URL's that are within a
     * serialized object.
     * @return {void}
     */
    _handle_serializations: function () {
      var instance = this;
      var escapedDomain = reg_escape(this.old_domain);
      var lines = this.new_haystack.split(/(\n|\r|\r\n|\n\r)/);

      var replace = function (match, opener, middle, closer) {
        var domain;
        if (middle.indexOf(instance.old_domain) === -1) {
          return match; // Nothing to replace.
        } else {
          instance.serialized_count++;
          domain = middle.replace(
            new RegExp(escapedDomain, "gi"),
            instance.new_domain
          );
          return 's:' + domain.length + ':' + opener + domain + closer;
        }
      };

      for (var i = 0, len = lines.length; i < len; i++) {
        lines[i] = lines[i].replace(/s:\d+:(\\?["'])(.*?)(\\?["'];)/gi, replace);
      }

      this.new_haystack = lines.join("");
      Peach.log(this.serialized_count + ' serialized links found.');
    },

    /**
     * Basic find and replace domains - basically, domains that are not within
     * a serialized string.
     * @return {void}
     */
    _handle_other_domains: function () {
      var instance = this;
      this.new_haystack = this.new_haystack.replace(
        new RegExp(reg_escape(this.old_domain), "gi"),
        function () {
          instance.replaced_count++;
          return instance.new_domain;
        }
      );
      Peach.log('Replaced '+this.replaced_count+' other links.');
    },

    /**
     * This method will output the difference between the old domain and the new domain.
     * @return {int}
     */
    _set_char_diff: function () {
      this.char_diff = this.new_domain.length - this.old_domain.length;
      Peach.log('Domain character difference: '+this.char_diff+'.');
    }
  };

  /**
   * This is a helper function for finding/guessing the "old" domain
   * in an existing WP dump.
   * @param {string} str  A database dump.
   * @return {string} This will always return a string no matter if it finds or not.
   */
  Peach.wp_domain = function (str) {
    if (typeof str !== "string") {
      throw new Error("A string is required.");
    }
    var matches = str.match(/('|"')siteurl('|"')[^"']+('|"')([^'"]+)('|"').+/);
    return (matches && matches[4]) ? matches[4] : '';
  };

  /**
   * Safe logging.
   * @param {string} str, ...
   * @return {void}
   */
  Peach.log = function () {
    if (typeof window !== "undefined" && window.console) {
      window.console.log.apply(window.console, arguments);
    }
  };

  /**
   * This will properly escape a string to be included in regex.
   * @param {string} str
   * @return {void}
   */
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
