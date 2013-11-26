# voom_mode_dsl.py
# Last Modified: 2013-11-01
# VOoM -- Vim two-pane outliner, plugin for Python-enabled Vim 7.x
# Website: http://www.vim.org/scripts/script.php?script_id=2657
# Author: Vlad Irnov (vlad DOT irnov AT gmail DOT com)
# License: CC0, see http://creativecommons.org/publicdomain/zero/1.0/

"""
VOoM markup mode for .dsl files: plain text dictionary sources used by
GoldenDict, http://goldendict.org/
"""
# There is only level 1.
# Any line that starts with a non-whitespace char is a headline.


def hook_makeOutline(VO, blines):
    """Return (tlines, bnodes, levels) for Body lines blines.
    blines is either Vim buffer object (Body) or list of buffer lines.
    """
    # every line that doesn't start with a space or tab is level 1 headline
    Z = len(blines)
    tlines, bnodes, levels = [], [], []
    tlines_add, bnodes_add, levels_add = tlines.append, bnodes.append, levels.append
    for i in xrange(Z):
        bline = blines[i]
        if not bline or bline[0] in ('\t',' '):
            continue
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


