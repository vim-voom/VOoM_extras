This repository contains supplementary materials for VOoM:
sample outlines, a test suite, sample addons.

VOoM is a plugin for text editor Vim that turns Vim into a full-featured
two-pane outliner: http://www.vim.org/scripts/script.php?script_id=2657


test_outlines
=============
This folder contains small dummy outlines for testing and illustrative
purposes.

The main file is `test_outline.txt`. It has fold markers with levels.
Files `test_outline.*` in other markups formats are created from
`test_outline.txt` by running Python script `test_outline.txt_convert.py`.

Files such as `asciidoc.asciidoc` are for manual testing of
various markup-specific gotchas and idiosyncrasies.

Files `test_outline.*` and some other are used by the test suite.


big_outlines
============
Big outline files for stress-testing purposes.


test_suite
==========
VOoM test suite.
It requires test outlines located in folder `test_outlines`.


addons
======
Sample addons that show how to extend and modify VOoM functionality.


markup_modes
============
New or modified markup modes not included in the current VOoM disribution.


misc
====


