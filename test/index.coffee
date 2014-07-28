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
    conversion = Peach.migrate('s:71:\"http://ccusa.hfwebdev.com/wp-content/uploads/member-benefits-banner.jpg\";', "http://ccusa.hfwebdev.com", "http://catholiccharitiesusa.org")
    assert.equal conversion.new_haystack, "s:77:\"http://catholiccharitiesusa.org/wp-content/uploads/member-benefits-banner.jpg\";"

    conversion = Peach.migrate("(3826,28,'panels_data','a:3:{s:7:\"widgets\";a:3:{i:0;a:3:{s:12:\"row_1_header\";s:50:\"We\'re working to end poverty in America. Join us. \";s:10:\"row_1_text\";s:245:\"Millions of Americans living in poverty is an unacceptable reality that inspires us to action. With your support, we can make a difference. Together, we can transform the lives of those who are struggling to survive, and enable them to thrive.\";s:4:\"info\";a:4:{s:5:\"class\";s:29:\"CCUSA_GetInvolvedBannerWidget\";s:2:\"id\";s:1:\"1\";s:4:\"grid\";s:1:\"0\";s:4:\"cell\";s:1:\"0\";}}i:1;a:4:{s:4:\"type\";s:6:\"visual\";s:5:\"title\";s:0:\"\";s:4:\"text\";s:556:\"<h5><strong>For over 100 years, CCUSA has lived out its mission to stand up on behalf of those in need and advocate for social structures that provide opportunity for all of our brothers and sisters in need. </strong></h5>\r\n<h6>We need your support as we lead a national movement to end poverty in this land of plenty.</h6>\r\n<p><img class=\"wp-image-978 img-responsive\" alt=\"political disagreements harming blog\" src=\"http://ccusa.hfwebdev.com/wp-content/uploads/political-disagreements-harming-blog.jpg\" width=\"100%\" height=\"auto\" border=\"5px&quot;\" /></p>\";s:4:\"info\";a:4:{s:5:\"class\";s:30:\"WP_Widget_Black_Studio_TinyMCE\";s:2:\"id\";s:1:\"2\";s:4:\"grid\";s:1:\"1\";s:4:\"cell\";s:1:\"0\";}}i:2;a:4:{s:4:\"type\";s:6:\"visual\";s:5:\"title\";s:0:\"\";s:4:\"text\";s:2474:\"<h1><a title=\"Donation Information\" href=\"http://ccusa.hfwebdev.com/donationinfo/\">Donate</a></h1>\r\n<p>With your help, we can build a national movement to end poverty and ensure all are able to achieve their full potential. <a href=\"https://support.catholiccharitiesusa.org/p/salsa/donation/common/public/?donate_page_KEY=8677\">Donate Online Here</a>.</p>\r\n<h1><a href=\"http://salsa3.salsalabs.com/o/50868/p/salsa/web/common/public/signup?signup_page_KEY=7386\">Weekly Digest</a></h1>\r\n<p>Get weekly emails about CCUSA events, resources, and grant opportunities. <a href=\"http://salsa3.salsalabs.com/o/50868/p/salsa/web/common/public/signup?signup_page_KEY=7386\">Sign up here.</a></p>\r\n<h1><a href=\"http://ccusa.hfwebdev.com/professional-interest-section/\">Sections &amp; Networks</a></h1>\r\n<p>For professional development opportunities, best practices, and a supportive network, sign up for our <a href=\"http://salsa3.salsalabs.com/o/50868/p/salsa/web/common/public/signup?signup_page_KEY=7360\">Professional Interest Sections and Networks.</a></p>\r\n<h1><a href=\"http://ccusa.hfwebdev.com/find-help/\">Find A Local Agency &amp; Volunteer</a></h1>\r\n<p>The work of local Catholic Charities agencies would not be possible without the work of individuals and families who give freely of their time, talent, and treasure to support their work. Whether working as a mentor for an underprivileged youth, helping a low-income parent prepare their tax returns, or helping a senior citizen clean up their yard, volunteers are at the heart of the Catholic Charities network. <a href=\"http://ccusa.hfwebdev.com/find-help/\">Contact your local agency for opportunities to volunteer.</a></p>\r\n<h1><a href=\"http://ccusa.hfwebdev.com/affiliate-member/\">Partner With Us As Affiliate Members</a></h1>\r\n<p>There are many ways to partner with CCUSA in our efforts to reduce poverty in America. If you represent a religiously-affiliated institution interested in becoming more involved in our mission of ending poverty and creating opportunity, we invite you to learn more about joining us as an affiliate member. <a href=\"http://ccusa.hfwebdev.com/affiliate-member/\">Learn more here.</a></p>\r\n<h1><a href=\"http://ccusa.hfwebdev.com/member-benefits/\">Member Benefits</a></h1>\r\n<p>Member agencies that pay dues are eligible for benefits in keeping with their membership status. <a href=\"http://ccusa.hfwebdev.com/member-benefits/\">Find out more about member benefits here.</a></p>\r\n<h1> </h1>\";s:4:\"info\";a:4:{s:5:\"class\";s:30:\"WP_Widget_Black_Studio_TinyMCE\";s:2:\"id\";s:1:\"3\";s:4:\"grid\";s:1:\"1\";s:4:\"cell\";s:1:\"1\";}}}s:5:\"grids\";a:2:{i:0;a:2:{s:5:\"cells\";s:1:\"1\";s:5:\"style\";s:0:\"\";}i:1;a:2:{s:5:\"cells\";s:1:\"2\";s:5:\"style\";s:0:\"\";}}s:10:\"grid_cells\";a:3:{i:0;a:2:{s:6:\"weight\";s:1:\"1\";s:4:\"grid\";s:1:\"0\";}i:1;a:2:{s:6:\"weight\";s:17:\"0.601063829787234\";s:4:\"grid\";s:1:\"1\";}i:2;a:2:{s:6:\"weight\";s:19:\"0.39893617021276595\";s:4:\"grid\";s:1:\"1\";}}}'),", "http://ccusa.hfwebdev.com", "http://catholiccharitiesusa.org")
    console.log(conversion.new_haystack)

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
