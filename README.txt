This repository contains supplementary materials for VOoM:
a test suite, sample outlines, sample add-ons.

VOoM is a plugin for text editor Vim that turns Vim into a full-featured
two-pane outliner: http://www.vim.org/scripts/script.php?script_id=2657

test_suite
==========
VOoM test suite. It requires test outlines in folder `test_outlines`.
This is a very crude script:
    Do not it install it as Vim plugin!
    Always run it in a separate, disposable instance of Vim!

Running the test suit is a good way to ensure that VOoM works with your
particular versions of Vim and Python and there are no conflicts with your
custom Vim settings and other Vim plugins.

How to run:

 * Download and extract this repository somewhere, for example in
   ~/Downloads/VOoM_extras/ .

 * Launch new instance of vim or gvim. Encoding should be utf-8.

 * Run these commands:
    :so ~/Downloads/VOoM_extras/test_suite/voom_test_suite.vim
    :VoomTestTestAllModes

 * There are will be some warnings and error messages from VOoM.
   There should be no Vim or Python errors.
   When finished, the last lines in the __PyLog__ buffer should be:
~~~~~~
comparing Python output to TestAllModes_python.ok.txt ...
OK
comparing Vim output to TestAllModes_vim.ok.txt ...
OK
~~~~~~

 * If you use both Python 2 and 3, repeat this with another Python version by
   setting g:voom_python_versions to [2] or [3]. This can be done by doing
       :let g:voom_python_versions=[3]
   in .vimrc or immediately after starting Vim (assuming that nothing in
   .vimrc or plugins calls VOoM functions during Vim startup).



test_outlines
=============
This folder contains small dummy outlines for testing and illustrative
purposes.

The main file is `test_outline.txt`. It has start fold markers with levels.
Files `test_outline.*` in other markups formats are created from
`test_outline.txt` by running Python 2 script `test_outline.txt_CONVERT.PY`.

Files such as `asciidoc.asciidoc` are for manual testing of
various markup-specific gotchas and idiosyncrasies.

Files `test_outline.*` and some other are used by the test suite.


big_outlines
============
Big outline files for stress-testing purposes.


addons
======
Sample add-ons for VOoM that show how to extend and modify VOoM functionality.


markup_modes
============
New or modified markup modes not included in the current VOoM distribution.


misc
====
Miscellaneous stuff.


License: CC0, see http://creativecommons.org/publicdomain/zero/1.0/

