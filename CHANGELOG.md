# RDiscount Changelog

## Version 2.0.7.1

### Fixes

* Discount upgraded from 2.0.7 (non-final) -> 2.0.7
* Fix encoding of Unicode characters in URLs.

### Known Issues

* Fails to build with MinGW or MinGW-64.
* Regression: Tags containing dashes and underscores are not escaped correctly.
    * This will be fixed in RDiscount 2.1.5


## Version 2.0.7 <small>(Jan 2013)</small>

* Discount upgraded from 1.6.8 -> 2.0.7 (non-final)
    * Footnotes - from *PHP Markdown Extra*
    * Superscript tweaks
        * Be more picky about what comes before a ^ if we’re superscripting.
        * Modify superscript grabbing so that it grabs parenthetical and alphanumeric blocks.
    * Other bug fixes
        * Table-of-contents generation will no longer crash for header items containing links.
        * Adjacent new-style [link]s are no longer incorrectly combined.


## Version 1.6.8 <small>(Jan 2011)</small>

* Discount upgraded from 1.6.5 -> 1.6.8
* Fix escaping of tags containing dashes and underscores.