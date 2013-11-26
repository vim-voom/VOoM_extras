" VOoM test suite.
" WARNING: ALWAYS RUN THIS IN A SEPARATE, DISPOSABLE INSTANCE OF VIM.
" Enable PyLog (:Voomlog) to retain progress and error messages.
" Use small test outlines:
"       ../voom_samples/test_outline.txt
" Each VoomTest_{action} function can be run separately.
" Must be run in a Tree buffer.
" NOTE: 'encoding' should be utf-8 or other Unicode. Otherwise tests for some modes will fail.

" Test all modes. This can be executed in blank Vim.
" For each test outline in ../test_outlines/:
"   - open the file
"   - execute the command :Voom {markup}
"   - run all tests
"   - wipe out Tree buffer
com! VoomTestTestAllModes call VoomTest_TestAllModes()

" Run all tests for the current outline. The current buffer must be Tree.
com! VoomTestRunAllTests call VoomTest_RunAllTests()

" About test files. {{{
"
" First line must be not headline: Cut/Paste test adds blank line on top
"
" Node 2 (Tree lnum 2) contains VO.levels.
"
" rest, markdown, asciidoc:
" Last file line must be blank. Copy/Paste/Cut test adds blank line if there is none.
"
" asciiDoc:
" No problems when all heads are 2-style because it's default.
" 1-style changes to 2-style after Cut/Paste All.
"
" }}}

" TODO
" fix mode-specific error messages, at least do summary: passed/failed
" test for Voomgrep
" test for Mark/Unmark
" test for wrong ticks -- autocmd breakage
" test for special regions, fenced code blocks


python import time
let s:cpo_ = &cpo | set cpo&vim
let [s:vb_ , s:t_vb_] = [&vb, &t_vb]

let s:script_dir = expand("<sfile>:p:h")
let s:voom_samples_dir = fnamemodify(s:script_dir.'/../test_outlines', ':p')
let s:voom_samples_names = [
            \ ['test_outline.txt', ''],
            \ ['test_outline.txt', 'fmr1'],
            \ ['test_outline.fmr2', 'fmr2'],
            \ ['test_outline.wiki', 'wiki'],
            \ ['test_outline.vimwiki', 'vimwiki'],
            \ ['test_outline.org', 'org'],
            \ ['test_outline.hashes', 'hashes'],
            \ ['test_outline.org', 'viki'],
            \ ['test_outline.cwiki', 'cwiki'],
            \ ['test_outline.rst', 'rest'],
            \ ['test_outline.latex', 'latex'],
            \ ['test_outline.markdown', 'markdown'],
            \ ['test_outline.pandoc', 'pandoc'],
            \ ['test_outline.t2t', 'txt2tags'],
            \ ['test_outline.asciidoc', 'asciidoc'],
            \ ['test_outline.asciidoc1', 'asciidoc'],
            \ ['test_outline.html', 'html'],
            \ ['test_outline.otl', 'thevimoutliner'],
            \ ['test_outline.otl', 'vimoutliner'],
            \ ['test_outline.taskpaper', 'taskpaper'],
            \ ['test_outline_python.py', 'python']
            \]


func! VoomTest_RunAllTests() "{{{1
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    let [voom_bodies, voom_trees] = voom#GetBodiesTrees()
    if bufType!='Tree'
        call voom#ErrorMsg("VOoM: must be in Tree buffer")
        return
    endif

    py print '\n\n=======', _VOoM.VOOMS[int(vim.eval("l:body"))].bname, '======='
    py print '-----STARTING ALL TESTS-----------------------------------'
    call VoomTest_OutlineMetrics()
    call VoomTest_OutlineTraversal()
    call VoomTest_Sort()
    call VoomTest_DiscardChanges(body,tree)
    call VoomTest_DownUp()
    call VoomTest_DiscardChanges(body,tree)
    call VoomTest_CutAllPasteAll()
    call VoomTest_DiscardChanges(body,tree)
    call VoomTest_CutPaste()
    call VoomTest_DiscardChanges(body,tree)
    "return
    call VoomTest_CopyPasteCut()
    call VoomTest_DiscardChanges(body,tree)
    call VoomTest_RightLeftRight()
    call VoomTest_LeftRight()
    call VoomTest_DiscardChanges(body,tree)
    call VoomTest_NewHeadline()
    call VoomTest_DiscardChanges(body,tree)
    py print '-----FINISHED ALL TESTS-----------------------------------'
endfunc


func! VoomTest_TestAllModes() "{{{1
" For each mode: load test file, create outline, run all tests.
" The test file is loaded in the current window.
    " make sure PyLog is displayed
    Voomlog
    " delete all outlines
    VoomQuitAll
    if &enc!=#'utf-8'
        py print "WARNING: Vim 'encoding' is not utf-8"
    endif
    for i in s:voom_samples_names
        let path = s:voom_samples_dir . i[0]
        if !filereadable(path)
            call voom#ErrorMsg('TEST FILE NOT READABLE: '.path)
            continue
        endif
        exec 'edit ' . path
        exec 'Voom ' . i[1]
        let tree = bufnr('')
        if voom#BufNotTree(tree)
            call voom#ErrorMsg('FAILED TO CREATE OUTLINE FOR: '.i[0])
            return
        endif
        " run all tests for this outline
        let [vb_ , t_vb_] = [&vb, &t_vb]
        set vb t_vb=
        try
            call VoomTest_RunAllTests()
        finally
            let [&vb, &t_vb]=[vb_, t_vb_]
        endtry
        " delete outline
        if bufnr('')==tree
            bw
        else
            call voom#ErrorMsg('WRONG BUFFER AFTER FINISHING TESTS FOR: '.i[0])
            return
        endif
    endfor
endfunc


"--- individual tests --- {{{1

func! VoomTest_OutlineMetrics() abort "{{{1
" Compare VO.levels to the refrenence list in the first node (Tree lnum 2).
    py print '<<< Outline Metrics >>>'
    py time_start = time.clock()
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')
    let [bufType, body, bln1, bln2] = voom#GetVoomRange(2,0)
    let lines = getbufline(body,bln1,bln2)
    for line in lines
        if line =~# '\CVO\.levels=['
            let l:levels = substitute(line,'\C^.*VO\.levels=','','' )
            break
        endif
    endfor

python << EOF
body = int(vim.eval("l:body"))
VO = _VOoM.VOOMS[body]
Z = int(vim.eval("l:Z"))
#assert len(VO.bnodes)==Z
if not len(VO.bnodes)==Z:
    print 'ERROR: not len(VO.bnodes)==Z'
#assert len(VO.bnodes)==len(VO.levels)
if not len(VO.bnodes)==len(VO.levels):
    print 'ERROR: not len(VO.bnodes)==len(VO.levels)'
if vim.eval("exists('l:levels')")=='1':
    exec 'levels = %s' %(vim.eval('l:levels'))
    #assert levels == VO.levels
    if not levels == VO.levels:
        print 'ERROR: not levels == VO.levels'
else:
    print 'ERROR: did not find line with levels'
EOF
    py print '        DONE', time.clock()-time_start, 'sec'
endfunc


func! VoomTest_OutlineTraversal() abort "{{{1
" Test voom_vim.py outline traversal functions.
    py print '<<< Outline Traversal >>>'
    py time_start = time.clock()
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

python << EOF
body = int(vim.eval("l:body"))
VO = _VOoM.VOOMS[body]
Z = int(vim.eval("l:Z"))
#print Z

for ln in xrange(1,Z+1):
    siblings = _VOoM.nodeSiblings(VO,ln)
    continue
    siblings_groups = _VOoM.getSiblingsGroups(VO,siblings)
    lnum1, lnum2 = siblings[0], siblings[-1]
    lnum2 = lnum2 + _VOoM.nodeSubnodes(VO,lnum2)
    L = []
    for l in siblings_groups: L.extend(l)
    L.sort()
    #print L
    #print range(lnum1,lnum2+1)
    assert L==range(lnum1,lnum2+1)
EOF

    " test Voomunl
    for ln in range(1,Z)
        exe 'normal! '.ln.'G'
        silent Voomunl
    endfor
    py print '        DONE', time.clock()-time_start, 'sec'
endfunc


func! VoomTest_Sort() abort "{{{1
    py print '<<< VoomSort >>>'
    py time_start = time.clock()
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')
python << EOF
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM.VOOMS[body]
Z = int(vim.eval("l:Z"))
# these must not change
nodes_count = nodesCount(body) # number of nodes, also Z
parents_count = parentsCount(body) # number of parents
body_len = len(VO.Body) # number of Body lines
EOF

    " outline should not change after two flips
    normal! zM2Gzv
    py blines_ = VO.Body[:]
    VoomSort deep flip i u
    py if blines_ == VO.Body[:]: print 'ERROR: 1'
    " doesn't work
    "normal! 2GVG
    "echom line("'<") line("'>")
    "'<,'>VoomSort deep flip i u
    "echom line("'<") line("'>")
    2,$VoomSort deep flip i u
    " end of selection is wrong, some kind of Vim problem
    "echom line("'<") line("'>")
    exec "normal! \<Esc>"
    py if blines_ != VO.Body[:]: print 'ERROR: 2'

    " already sorted
    silent VoomSort i u
python << EOF
if not nodesCount(body) == nodes_count: print 'ERROR: 3'
if not parentsCount(body) == parents_count: print 'ERROR: 4'
if not len(VO.Body) == body_len: print 'ERROR: 5'
EOF
    VoomSort deep i u
python << EOF
if not nodesCount(body) == nodes_count: print 'ERROR: 7'
if not parentsCount(body) == parents_count: print 'ERROR: 8'
if not len(VO.Body) == body_len: print 'ERROR: 9'
EOF
    VoomSort deep i u r
python << EOF
if not nodesCount(body) == nodes_count: print 'ERROR: 10'
if not parentsCount(body) == parents_count: print 'ERROR: 11'
if not len(VO.Body) == body_len: print 'ERROR: 12'
EOF
    VoomSort deep shuffle
    VoomSort deep shuffle
    VoomSort deep shuffle
python << EOF
if not nodesCount(body) == nodes_count: print 'ERROR: 13'
if not parentsCount(body) == parents_count: print 'ERROR: 14'
if not len(VO.Body) == body_len: print 'ERROR: 15'
EOF

    " go to node 'VoomSort tests'
    call search('VoomSort tests', 'w')
    if getline('.') !~ 'VoomSort tests'
        py print "ERROR: 16, current line (Tree) is not 'VoomSort tests'"
    endif
    normal! zv
    VoomSort deep
    py if blines_ == VO.Body[:]: print 'ERROR: 17'
    py blines_ = VO.Body[:]
    silent VoomSort deep
    py if blines_ != VO.Body[:]: print 'ERROR: 18'
    VoomSort deep r
    py if blines_ == VO.Body[:]: print 'ERROR: 19'
    py blines_ = VO.Body[:]
    silent VoomSort deep r
    py if blines_ != VO.Body[:]: print 'ERROR: 20'

python << EOF
if not nodesCount(body) == nodes_count: print 'ERROR: 21'
if not parentsCount(body) == parents_count: print 'ERROR: 22'
if not len(VO.Body) == body_len: print 'ERROR: 23'
EOF
    if Z!=line('$') | echoerr 'VoomSort error' | endif
    py print '        DONE', time.clock()-time_start, 'sec'
endfunc


func! VoomTest_DownUp() abort "{{{1
    py print '<<< Down/Up >>>'
    py time_start = time.clock()
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

    " select first node (lnum 2)
    normal! ggzM
    normal! j
    setl fdl=1
    call voom#TreeSelect(1)

python << EOF
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM.VOOMS[body]
Z = int(vim.eval("l:Z"))

tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
# these must never change
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
EOF

    """ move first node all the way DOWN
    let lnum = 1
    while lnum != line('.')
        let lnum = line('.')
        call voom#Oop('down', 'n')
    endwhile
python << EOF
lnum = int(vim.eval('l:lnum'))
if not nodesCount(body) == nodes_count: print 'ERROR: nodes_count', lnum
if not len(VO.Body) == body_len: print 'ERROR: body_len', lnum
if not Z == lnum + _VOoM.nodeSubnodes(VO,lnum): print 'ERROR: Z', lnum
EOF

    """ move first node back all the way UP
    """ Body must revert to original state
    let lnum = 1
    while lnum != line('.')
        let lnum = line('.')
        call voom#Oop('up', 'n')
    endwhile
python << EOF
lnum = int(vim.eval("line('.')"))
if not lnum==2: print "ERROR: line('.') is not 2"
if VO.Body[:] != blines_: print 'ERROR: blines_', lnum
if VO.Tree[:] != tlines_: print 'ERROR: tlines_', lnum
EOF
    py print '        DONE', time.clock()-time_start, 'sec'
endfunc


func! VoomTest_CutAllPasteAll() abort "{{{1
    py print '<<< CutAll/PasteAll >>>'
    py time_start = time.clock()
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

python << EOF
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM.VOOMS[body]
Z = int(vim.eval("l:Z"))
# number of Body lines before first headline
header_len = VO.bnodes[1]-1

tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
# these must not change
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
EOF

    """ Do Cut/Paste for the entire outline.
       "This tests Paste into empty outline (reST, makrdown issues.)
    normal! 2GVG
    normal dd
    "call voom#Oop('cut', 'v')
    if 1!=line('$') | echoerr 'Cut All error, Tree size not 1' | endif
    py if len(VO.Body)!=header_len: print 'ERROR: wrong Body size after CutAll'
    "call voom#OopPaste()
    normal pp
    exec "normal! \<Esc>"
    py if VO.Body[:] != blines_: print 'ERROR: Body changed after CutAll/PasteAll'
    py print '        DONE', time.clock()-time_start, 'sec'
endfunc


func! VoomTest_CutPaste() abort "{{{1
    py print '<<< Cut/Paste >>>'
    py time_start = time.clock()
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

python << EOF
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM.VOOMS[body]
Z = int(vim.eval("l:Z"))
# number of Body lines before first headline
header_len = VO.bnodes[1]-1

tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
# these must not change
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
EOF

    """ Do Cut/Paste for all top level nodes. Body must not change
    " select first outline node (lnum 2)
    normal! ggzM
    setl fdl=1
    normal! j
    call voom#TreeSelect(1)

    let lnum = 1
    while lnum != line('.')
        let lnum = line('.')
        "call voom#Oop('cut', 'n')
        normal dd
        if line('$') >= Z | echoerr 'Cut error' | endif
        "call voom#OopPaste()
        normal pp
        " exit Visual after Paste
        exec "normal! \<Esc>"
        py if VO.Body[:] != blines_: print 'ERROR: Body changed (lnum %s)' %vim.eval('l:lnum')
        if line('$') != Z | echoerr 'Paste error' | endif
        normal! j
    endwhile
    exec "normal! \<Esc>"
    py print '        DONE', time.clock()-time_start, 'sec'
endfunc


func! VoomTest_CopyPasteCut() abort "{{{1
    py print '<<< Copy/Paste/Cut >>>'
    py time_start = time.clock()
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

python << EOF
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM.VOOMS[body]
Z = int(vim.eval("l:Z"))

tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
# these must not change
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
EOF

    """ Do Copy/Paste/Cut for all visible nodes. Body must not change.
    " select first outline node (lnum 2)
    normal! ggzM
    normal! j
    setl fdl=1
    call voom#TreeSelect(1)

    let lnum = 1
    while lnum != line('.')
        let lnum = line('.')
        call voom#Oop('copy', 'n')
        call voom#OopPaste()
        if Z==line('$') | echoerr 'Copy/Paste error' | endif
        call voom#Oop('cut', 'n')
        py if VO.Body[:] != blines_: print 'ERROR: at lnum %s' %vim.eval('l:lnum')
        if Z!=line('$') | echoerr 'Copy/Paste/Cut error' | endif
        normal! j
    endwhile

    py print '        DONE', time.clock()-time_start, 'sec'
endfunc


func! VoomTest_RightLeftRight() abort "{{{1
" Move right all the way.
" Move left all the way.
" Move right to restore indent. Ouline must not change.
" g:voom_always_allow_move_left (_VOoM.AAMLEFT) is set to False, otherwise the test fails.
    py print '<<< Right/Left/Right >>>'
    py time_start = time.clock()
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

    " Start with all folds open.
    " Select the first node in Tree (lnum 2).
    " Since a branch is closed after first Move Right, the result is that the
    " test is run for all first children of the first node and all top level nodes.
    normal! ggzR
    normal! j
    " open folds if max level > 1
    normal! zv

python << EOF
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM.VOOMS[body]
Z = int(vim.eval("l:Z"))
tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
# make sure we move Right and Left at least once
didRight, didLeft = False,False
# these must not change
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
EOF

    py AAMLEFT_ = _VOoM.AAMLEFT
    py _VOoM.AAMLEFT = False
    let fdm_ = getbufvar(body, '&fdm')
    let tlnums_tested = []
    let lnum = 0
    while lnum != line('.')
        let lnum = line('.')
        call add(tlnums_tested, lnum)
        let ind_ = s:Ind()
        """ Move Right until no longer possible
        py blines = VO.Body[:]
        let ind = -99
        while ind != s:Ind()
            let ind = s:Ind()
            call voom#Oop('right', 'n')
            py if not didRight and VO.Body[:] != blines: didRight = True
        endwhile
        """ Move Left until no longer possible
        py blines = VO.Body[:]
        let ind = -99
        while ind != s:Ind()
            let ind = s:Ind()
            call voom#Oop('left', 'n')
            py if not didLeft and VO.Body[:] != blines: didLeft = True
        endwhile
        """ Move Right until Tree line indent is restored
        while ind_ != s:Ind()
            let ind = s:Ind()
            call voom#Oop('right', 'n')
            " unable to move right anymore
            if ind == s:Ind() | break | endif
        endwhile
        """ Body must not change
        py if VO.Body[:] != blines_: print 'ERROR: Body changed (lnum %s)' %vim.eval('l:lnum')
        if Z!=line('$') | echoerr 'Right/Left error' | endif
        if fdm_!=getbufvar(body,'&fdm') | echoerr 'Right/Left fdm error' | endif
        normal! j
    endwhile
    py _VOoM.AAMLEFT = AAMLEFT_

    py if not didRight: print 'ERROR: Move Right was not tested'
    py if not didLeft:  print 'ERROR: Move Left was not tested'
    py print '        DONE', time.clock()-time_start, 'sec'
    py print '       ', vim.eval('l:tlnums_tested')
endfunc


func! VoomTest_LeftRight() abort "{{{1
" g:voom_always_allow_move_left (_VOoM.AAMLEFT) is set to True
" For each top level node: go to first child, move left and move right.
" If Body changed because, correct by restoring siblings by moving them left.
" This also tests o J D U c.
    py print '<<< Left/Right >>>'
    py time_start = time.clock()
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

    " Select the first node in Tree (lnum 2).
    " Since a branch is closed after first Move Right, the result is that the
    " test is run for all first children of the first node and all top level nodes.
    normal! ggzR
    normal! j
    call voom#TreeSelect(1)
    " close all top-level nodes
    normal C
    call voom#TreeZV()

python << EOF
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM.VOOMS[body]
Z = int(vim.eval("l:Z"))
tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
# make sure we move Right and Left at least once
didRight, didLeft = False,False
# these must not change
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
EOF

    py AAMLEFT_ = _VOoM.AAMLEFT
    py _VOoM.AAMLEFT = True
    let fdm_ = getbufvar(body, '&fdm')
    let tlnums_tested = []
    let lnum = 0
    while lnum != line('.')
        let lnum = line('.')
        " go to first child
        normal o
        let ln_o = line('.')
        if ln_o==lnum
            normal! j
            continue
        endif
        call add(tlnums_tested, ln_o)
        " check if there are siblings
        normal J
        let ln_J = line('.')
        normal D
        let ln_D = line('.')
        normal U
        if line('.') != ln_o
            py print 'ERROR: wrong line after oJDU (lnum %s)' %vim.eval('l:lnum')
        endif
        """ Move Left
        py blines = VO.Body[:]
        call voom#Oop('left', 'n')
        exec "normal! \<Esc>"
        py if not didLeft and VO.Body[:] != blines: didLeft = True
        """ Move Right
        py blines = VO.Body[:]
        call voom#Oop('right', 'n')
        exec "normal! \<Esc>"
        " Body must not change if there were no siblings that become children on Move Left
        if ln_D==ln_o
            py if VO.Body[:] != blines_: print 'ERROR: Body changed 1 (lnum %s)' %vim.eval('l:ln_o')
            if Z!=line('$') | echoerr 'Left/Right error' | endif
        else
            py if not didRight: didRight = True
            py if VO.Body[:] == blines_: print 'ERROR: Body did not change (lnum %s)' %vim.eval('l:ln_o')
            " restore original siblings of ln_o: select them, Move Left
            exe 'normal! '.ln_D.'GzvV'.ln_J.'Gzv'
            exec "normal! \<Esc>"
            call voom#Oop('left', 'v')
            exec "normal! \<Esc>"
            " Body must not change
            py if VO.Body[:] != blines_: print 'ERROR: Body changed 2 (lnum %s)' %vim.eval('l:ln_o')
            if Z!=line('$') | echoerr 'Left/Right error' | endif
            if fdm_!=getbufvar(body,'&fdm') | echoerr 'Left/Right fdm error' | endif
        endif
        normal c
        if line('.') != lnum
            py print 'ERROR: wrong line after c (lnum %s)' %vim.eval('l:ln_o')
        endif
        normal! j
    endwhile
    py _VOoM.AAMLEFT = AAMLEFT_

    py if not didRight: print 'ERROR: Move Right was not tested'
    py if not didLeft:  print 'ERROR: Move Left was not tested'
    py print '        DONE', time.clock()-time_start, 'sec'
    py print '       ', vim.eval('l:tlnums_tested')
endfunc


func! VoomTest_NewHeadline() abort "{{{1
    py print '<<< NewHeadline >>>'
    py time_start = time.clock()
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

python << EOF
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM.VOOMS[body]
Z = int(vim.eval("l:Z"))

tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
EOF

    " After inserting NewHeadline cursor is in Body.
    " bnodes and levels are wrong, but Tree lines should be correct.

    " Insert after line 1
    normal! ggzM
    call voom#OopInsert('')
    py voomTest_NewHeadline(VO)
    call voom#ToTree(tree)
    call voom#OopInsert('as_child')
    py voomTest_NewHeadline(VO)
    " insert after first fold
    call voom#ToTree(tree)
    normal! j
    call voom#OopInsert('')
    py voomTest_NewHeadline(VO)
    call voom#ToTree(tree)
    call voom#OopInsert('as_child')
    py voomTest_NewHeadline(VO)
    " insert after last node
    call voom#ToTree(tree)
    normal! Gzv
    call voom#OopInsert('')
    py voomTest_NewHeadline(VO)
    call voom#ToTree(tree)
    call voom#OopInsert('as_child')
    py voomTest_NewHeadline(VO)
    " total 5 nodes have been inserted
    call voom#ToTree(tree)
    py assert nodes_count + 6 == nodesCount(body)

    py print '        DONE', time.clock()-time_start, 'sec'
endfunc


"--- helpers --- {{{1

func! VoomTest_DiscardChanges(body,tree) "{{{1
    " discard all changes in Body buffer body
    call voom#ToBody(a:body)
    silent edit!
    normal! ggzM
    call voom#ToTree(a:tree)
    normal! ggzM
endfunc


func! s:Ind() "{{{1
    return stridx(getline('.'),'|')
endfunc


" Python << EOF {{{1o
python << EOF

def nodesCount(body): #{{{2
    levels = _VOoM.VOOMS[body].levels
    return len(levels)


def parentsCount(body): #{{{2
    """return number of parents--nodes with children"""
    levels = _VOoM.VOOMS[body].levels
    parents_count = len([i for i in xrange(1,len(levels)) if levels[i-1]<levels[i]])
    return parents_count


def voomTest_NewHeadline(VO): #{{{2
    tlines, bnodes, levels  = VO.makeOutline(VO, VO.Body)
    if not len(VO.Tree)==len(tlines)+1:
        print 'ERROR: wrong Tree size'
        return
    tlines[0:0], bnodes[0:0], levels[0:0] = [VO.bname], [1], [1]
    snLn = VO.snLn
    tlines[snLn-1] = '=%s' %tlines[snLn-1][1:]
    if not tlines==VO.Tree[:]:
        print 'ERROR: DIFFERENT Tree lines'
        print 'snLn line expected:', tlines[snLn-1]
        print 'snLn line actual  :', VO.Tree[snLn-1]
        return


# EOF {{{2
EOF

"--- Timing tests --- {{{1

" Time outline update on Tree BufEnter.
com! VoomTimeTreeBufEnter call VoomTime_TreeBufEnter()

" Time outline creation with the command :Voom.
com! -nargs=? VoomTimeVoom call VoomTime_Voom(<q-args>)


func! VoomTime_TreeBufEnter() abort "{{{2
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if body==-1
        return
    elseif body==0
        call voom#ErrorMsg("VOoM: current buffer is not a VOoM buffer")
        return
    elseif bufType!=#'Tree'
        call voom#ErrorMsg("VOoM: must be in Tree buffer")
        return
    endif

    " Time Tree BufEnter when Body is changed but outline is not changed.
    " Delete a line in Body and undo to change b:changedtick.
    normal! ggzM
    call voom#ToBody(body)
    normal! ggzM
    call voom#ToTree(tree)
    let times = ''
    for i in range(10)
        if bufnr('')!=tree | echoerr 'NOT TREE' | endif
        call voom#ToBody(body)
        if bufnr('')!=body | echoerr 'NOT BODY' | endif
        let &ul=&ul
        silent normal! ddu
        call voom#BodyBufLeave()
        noa wincmd p
        let start = reltime()
        call voom#TreeBufEnter()
        let times = times."\n".reltimestr(reltime(start))
        call voom#ToTree(tree)
    endfor
    echo times
    echo '--------------------'

    " Time Tree BufEnter when Tree buffer is redrawn.
    " Insert a headline on top and undo to trigger redrawing of Tree (Tree size is changed).
    normal! ggzM
    let times = ''
    for i in range(10)
        if bufnr('')!=tree | echoerr 'NOT TREE' | endif
        let &ul=&ul
        " insert headline
        normal aa
        if bufnr('')!=body | echoerr 'NOT BODY' | endif
        silent normal! u
        call voom#BodyBufLeave()
        noa wincmd p
        let start = reltime()
        call voom#TreeBufEnter()
        let times = times."\n".reltimestr(reltime(start))
    endfor
    echo times
    echo '--------------------'
endfunc


func! VoomTime_Voom(mmode) abort "{{{2
    let bnr = bufnr('')
    let [bufType,body,tree] = voom#GetTypeBodyTree(1)
    if bufType !=# 'None'
        call voom#ErrorMsg('Cannot run test: delete the VOoM outline first')
        return
    endif
    let mmode = substitute(a:mmode, '\s\+$', '', 'g')

    let times = ''
    for i in range(5)
        let t0 = reltime()
        exe 'Voom '.mmode
        let t1 = reltimestr(reltime(t0))
        let times = times."\n".t1
        let [bufType,body,tree] = voom#GetTypeBodyTree()
        if bufnr('')!=tree | echoerr 'NOT TREE' | endif
        bw
        if bufnr('')!=bnr
            echoerr 'NOT BODY'
            return
        endif
        let [bufType,body,tree] = voom#GetTypeBodyTree(1)
        if bufType !=# 'None'
            echoerr 'Failed to delete outline'
            return
        endif
    endfor
    exe 'Voom '.mmode
    echo times
endfunc


func! VoomTime_OopDown() abort "{{{2
" The current buffer is Tree. Move the current node all the way down.
    let start = reltime()
    let lnum = line('.')-1
    while lnum != line('.')
        let lnum = line('.')
        call voom#Oop('down', 'n')
    endwhile
    echo reltimestr(reltime(start))
endfunc


"--- the end --- {{{1
let &cpo = s:cpo_
unlet s:cpo_
