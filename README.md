As you probably know, migrating a WordPress database from one domain to another can be a bit of a hassle. Two major things must happen for it to be a seamless migration; Find & replace the domain and fix the serialized url's containing the old domain. This tool does that for you. No need to run a bash script on every migration. Simply drag the sql dump into the square and set a new domain.


# Use

### Frontend
For front-end use see ui.js in the assets directory. It's probably easier just to use the online verson: http://petesaia.github.io/Peach/

### Backend
Peach can be useful for continuous integration when working with Wordpress sites.

```javascript
var dbdump = fs.readFileSync("./old-database.sql");
var Peach = require("peach");

var oldDomain = Peach.wp_domain(dbdump); // Helper to get current domain name.
var migration = Peach.migrate(dbdump, oldDomain, "http://your-new-domain.com");

migration.processed_file(); // The new sql file.

// Extra public properties.
migration.old_domain;
migration.new_domain;
migration.serialized_count; // Number of serializations.
migration.replaced_count; // Number of replacements.
migration.char_diff; // Difference in characters. e.g. -4 || 2 || -4

```
# Testing
Tests are wrtten in mocha.

```bash
npm install
npm test
```