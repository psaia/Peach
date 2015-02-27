fs = require "fs"
path = require "path"
assert = require "assert"
Peach = require(path.join("../", "assets/js/peach.js"))

simpleDump = fs.readFileSync("#{__dirname}/sample/simple-wp.sql", encoding:"utf8")
complexDump = fs.readFileSync("#{__dirname}/sample/complex-wp.sql", encoding:"utf8")

describe "domain detection", ->
  it "should find the domain in the wp options table or return false", ->
    domain = Peach.wp_domain(simpleDump)
    domain2 = Peach.wp_domain("123zxcm:3jsj")
    domain3 = Peach.wp_domain("")
    assert.equal domain, "http://atestsite.dev"
    assert.equal domain2, false
    assert.equal domain3, false

describe "replacements and deserialization", ->
  it "should handle single or double quote sql files", ->
    conversion = Peach.migrate 's:5:"12345";', '12345', 'abcde'
    assert.equal conversion.char_diff, 0
    assert.equal conversion.new_haystack, 's:5:"abcde";'

    conversion = Peach.migrate "s:5:'12345';", '12345', 'abcde'
    assert.equal conversion.char_diff, 0
    assert.equal conversion.new_haystack, "s:5:'abcde';"

  it "should handle a url with segments", ->
    conversion = Peach.migrate('s:71:\"http://12345678987654.com/wp-content/uploads/member-benefits-banner.jpg\";', "http://12345678987654.com", "http://12345678987654321112.org")
    assert.equal conversion.new_haystack, "s:77:\"http://12345678987654321112.org/wp-content/uploads/member-benefits-banner.jpg\";"

  it "convert dump with basic replacements", ->
    conversion = Peach.migrate(simpleDump, Peach.wp_domain(simpleDump), "http://somethingelse.dev")
    assert.equal conversion.char_diff, 4
    assert.equal conversion.old_domain, "http://atestsite.dev"
    assert.equal conversion.new_domain, "http://somethingelse.dev"
    assert.equal conversion.replaced_count, 2, "basic replacements"
    assert.equal conversion.serialized_count, 4, "serialization replacements"

  it "complex serialization (longer domain change)", ->
    conversion = Peach.migrate(complexDump, Peach.wp_domain(complexDump), "http://petesaia.com")
    assert.equal conversion.char_diff, 2
    assert.equal conversion.old_domain, "http://sample.com"
    assert.equal conversion.new_domain, "http://petesaia.com"
    assert.equal conversion.replaced_count, 1
    assert.equal conversion.serialized_count, 4

  it "complex serialization (shorter domain change)", ->
    conversion = Peach.migrate(complexDump, Peach.wp_domain(complexDump), "http://smll.com")
    assert.equal conversion.char_diff, -2
    assert.equal conversion.old_domain, "http://sample.com"
    assert.equal conversion.new_domain, "http://smll.com"
    assert.equal conversion.replaced_count, 1
    assert.equal conversion.serialized_count, 4

  it "should replace and change serialized string/int when double quotes are used throughout - to a larger domain", ->
    dump = 's:4:\"text\";s:33:\"<a href=\"http://123.com\">test</a>\";s:6:\"filter\";'

    conversion = Peach.migrate(dump, "http://123.com", "http://123456.com")
    assert.equal conversion.char_diff, 3
    assert.equal conversion.old_domain, "http://123.com"
    assert.equal conversion.new_domain, "http://123456.com"
    assert.equal conversion.replaced_count, 0
    assert.equal conversion.serialized_count, 1
    assert.equal conversion.new_haystack, 's:4:\"text\";s:36:\"<a href=\"http://123456.com\">test</a>\";s:6:\"filter\";'

  it "should replace and change serialized string/int when double quotes are used throughout - to a smaller domain", ->
    dump = "s:4:\"text\";s:36:\"<a href=\"http://123456.com\">test</a>\";s:6:\"filter\";"

    conversion = Peach.migrate(dump, "http://123456.com", "http://123.com")
    assert.equal conversion.char_diff, -3
    assert.equal conversion.old_domain, "http://123456.com"
    assert.equal conversion.new_domain, "http://123.com"
    assert.equal conversion.replaced_count, 0
    assert.equal conversion.serialized_count, 1
    assert.equal conversion.new_haystack, 's:4:\"text\";s:33:\"<a href=\"http://123.com\">test</a>\";s:6:\"filter\";'

  it "should replace and change serialized string/int when non-escaped double quotes are used throughout", ->
    dump = 's:4:"text";s:36:"<a href="http://123456.com">test</a>";s:6:"filter";'

    conversion = Peach.migrate(dump, "http://123456.com", "http://123.com")
    assert.equal conversion.char_diff, -3
    assert.equal conversion.old_domain, "http://123456.com"
    assert.equal conversion.new_domain, "http://123.com"
    assert.equal conversion.replaced_count, 0
    assert.equal conversion.serialized_count, 1
    assert.equal conversion.new_haystack, 's:4:"text";s:33:"<a href="http://123.com">test</a>";s:6:"filter";'
