# RDiscount Changelog

## Version 2.0.7.3 <small>(May 7, 2013)</small>

* Fix usage of deallocated memory when manipulating locale information.
    * Special thanks to Dirkjan Bussink (@dbussink) for identifying this bug and providing the initial fix.
* Fix outdated links. Notably the API reference.
* Setup continuous integration.

## Version 2.0.7.2 <small>(Apr 6, 2013)</small>

* Fix compile error on Windows.
* Disallow install on Ruby 1.9.2, due to known bugs in Ruby.
    * Please upgrade to Ruby 1.9.3 or later.

## Version 2.0.7.1 <small>(Feb 26, 2013)</small>

* Discount upgraded from 2.0.7 (non-final) -> 2.0.7
* Fix encoding of Unicode characters in URLs.

## Version 2.0.7 <small>(Jan 29, 2013)</small>

### New Features

* Discount upgraded from 1.6.8 -> 2.0.7 (non-final)
    * Footnotes - from *PHP Markdown Extra*
    * Superscript tweaks
        * Be more picky about what comes before a ^ if we’re superscripting.
        * Modify superscript grabbing so that it grabs parenthetical and alphanumeric blocks.
    * Other bug fixes
        * Table-of-contents generation will no longer crash for header items containing links.
        * Adjacent new-style [link]s are no longer incorrectly combined.

### Known Issues

* Fails to build with MinGW or MinGW-64.
* Regression: Tags containing dashes and underscores are not escaped correctly.
    * This will be fixed in RDiscount 2.1.5

## Version 1.6.8 <small>(Jan 25, 2011)</small>

* Discount upgraded from 1.6.5 -> 1.6.8
* Fix escaping of tags containing dashes and underscores.

## Earlier Releases

* Inspect the Git history.
