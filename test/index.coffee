fs = require "fs"
path = require "path"
assert = require "assert"
Peach = null

simpleDump = fs.readFileSync("#{__dirname}/sample/simple-wp.sql", encoding:"utf8")
complexDump = fs.readFileSync("#{__dirname}/sample/complex-wp.sql", encoding:"utf8")

beforeEach ->
  Peach = require(path.join("../", "assets/js/peach.js"))

describe "domain detection", ->
  it "should find the domain in the wp options table or return false", ->
    domain = Peach.wp_domain(simpleDump)
    domain2 = Peach.wp_domain("123zxcm:3jsj")
    domain3 = Peach.wp_domain("")
    assert.equal domain, "http://atestsite12.dev"
    assert.equal domain2, false
    assert.equal domain3, false

describe "replacements and deserialization", ->
  it "convert dump with basic replacements", ->
    # conversion = Peach.migrate(simpleDump, Peach.wp_domain(simpleDump), "http://atestsite12.dev1234").init()
    # assert.equal conversion.char_diff, -4
    # assert.equal conversion.old_domain, "http://atestsite12.dev"
    # assert.equal conversion.new_domain, "http://atestsite12.dev1234"
    # assert.equal conversion.replaced_count, 2
    # assert.equal conversion.serialized_count, 4

  it "complex serialization", ->
    conversion = Peach.migrate(complexDump, Peach.wp_domain(complexDump), "http://petesaia.com").init()
    assert.equal conversion.char_diff, 2
    assert.equal conversion.old_domain, "http://sample.com"
    assert.equal conversion.new_domain, "http://petesaia.com"
    assert.equal conversion.replaced_count, 1
    # assert.equal conversion.serialized_count, 1
    console.log(conversion.new_haystack)

describe "character difference", ->
  it "should equal 45", ->
    peach = Peach.migrate('the haystack does not matter now', 'http://test.com', 'http://test12345.com')
    peach._set_char_diff()
    assert.equal(peach._new_char_int('40'), 35)

  it 'should equal 40', ->
    peach = Peach.migrate('the haystack does not matter now', 'http://test.com', 'http://test.com')
    peach._set_char_diff()
    assert.equal(peach._new_char_int('40'), 40)
