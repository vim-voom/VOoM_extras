# voom_mode_blocks.py
# Last Modified: 2014-06-10
# VOoM -- Vim two-pane outliner, plugin for Python-enabled Vim 7.x
# Website: http://www.vim.org/scripts/script.php?script_id=2657
# Author: Vlad Irnov (vlad DOT irnov AT gmail DOT com)
# License: CC0, see http://creativecommons.org/publicdomain/zero/1.0/

"""
VOoM markup mode for blocks of non-blank lines separated by blank lines, that
is paragraphs. The first line of each paragraph is level 1 headline.
Levels >1 are not possible.

Move Right (>>) results in errors that can be ignored: Body buffer is
unchanged, outline is corrected automatically unless g:voom_verify_oop is
disabled.

This mode is useful for sorting paragraphs of text with :VoomSort.

There are must be a blank line after the last paragraph, that is end-of-file.
Otherwise there are will be errors when the last paragraph is moved.

"""


def hook_makeOutline(VO, blines):
    """Return (tlines, bnodes, levels) for Body lines blines.
    blines is either Vim buffer object (Body) or list of buffer lines.
    """
    # A line is headline level 1 if it is: preceded by a blank line (or is
    # first buffer line) and is non-blank.
    Z = len(blines)
    tlines, bnodes, levels = [], [], []
    tlines_add, bnodes_add, levels_add = tlines.append, bnodes.append, levels.append
    bline_ = ''
    for i in xrange(Z):
        bline = blines[i].strip()
        if bline_ or not bline:
            bline_ = bline
            continue
        bline_ = bline
        tlines_add('  |%s' %bline)
        bnodes_add(i+1)
        levels_add(1)
    return (tlines, bnodes, levels)


def hook_newHeadline(VO, level, blnum, tlnum):
    """Return (tree_head, bodyLines).
    tree_head is new headline string in Tree buffer (text after |).
    bodyLines is list of lines to insert in Body buffer.
    """
    return ('NewHeadline', ['NewHeadline'])


### DO NOT DEFINE THIS HOOK -- level never changes, it is always 1
# There is an error when a level change is attempted, but Body is not modified.
#def hook_changeLevBodyHead(VO, h, levDelta):
#    """Increase of decrease level number of Body headline by levDelta."""
#    return h


