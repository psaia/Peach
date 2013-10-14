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
    assert.equal domain, "http://atestsite.dev"
    assert.equal domain2, false
    assert.equal domain3, false

describe "replacements and deserialization", ->
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
