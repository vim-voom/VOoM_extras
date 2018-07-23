" VOoM test suite.
" WARNING: ALWAYS RUN THIS IN A SEPARATE, DISPOSABLE INSTANCE OF VIM.
" Enable PyLog (:Voomlog) to retain progress and error messages.
" Use small test outlines:   ../voom_samples/test_outline.txt
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


" Run all tests for the current outline. The current buffer must be VOoM Tree.
com! VoomTestRunAllTests call VoomTest_RunAllTests()



"----- s:PYCMD, ENDPYTHON ----
" To make this script work with both Python 2 and 3, Python code regions are written as follows:
"       exe s:PYCMD . ' << ENDPYTHON'
"       python-code-here
"       ENDPYTHON
" Instead of usual 'python << EOF ... EOF'.
" To get Python syntax hi for such regions, add to after/syntax/vim.vim:
" :syntax region vimPythonRegion matchgroup=vimScriptDelim start=/^\s*exe.\+ << ENDPYTHON/ end=/^ENDPYTHON/ contains=@vimPythonScript
"
let s:PYCMD = voom#GetVar('s:PYCMD')
"let s:PYCMD = 'python'
"let s:PYCMD = 'python3'
let s:STARTPYTHON = s:PYCMD . ' << ENDPYTHON'

" globals, used to capture Vim redir
let s:VOOM_REDIR = ''
let s:temp_redir = ''

exe s:PYCMD . ' << ENDPYTHON'
import time
_time = time.perf_counter
import sys
if sys.version_info[0] > 2:
    xrange = range
ENDPYTHON


let s:cpo_ = &cpo | set cpo&vim
let [s:vb_ , s:t_vb_] = [&vb, &t_vb]

let s:script_dir = expand("<sfile>:p:h")
let s:voom_samples_dir = fnamemodify(s:script_dir.'/../test_outlines', ':p')
let s:voom_samples_names = [
            \ ['test_outline.txt', 'fmr'],
            \ ['test_outline.txt', 'fmr1'],
            \ ['test_outline.fmr2', 'fmr2'],
            \ ['test_outline.fmr3', 'fmr3'],
            \ ['test_outline.wiki', 'wiki'],
            \ ['test_outline.vimwiki', 'vimwiki'],
            \ ['test_outline.inverseAtx', 'inverseAtx'],
            \ ['test_outline.dokuwiki3', 'dokuwiki'],
            \ ['test_outline.org', 'org'],
            \ ['test_outline.hashes', 'hashes'],
            \ ['test_outline.org', 'viki'],
            \ ['test_outline.cwiki', 'cwiki'],
            \ ['test_outline.rst', 'rest'],
            \ ['test_outline.latex', 'latex'],
            \ ['test_outline.dtx', 'latexDtx'],
            \ ['test_outline.markdown', 'markdown'],
            \ ['test_outline.pandoc', 'pandoc'],
            \ ['test_outline.t2t', 'txt2tags'],
            \ ['test_outline.asciidoc', 'asciidoc'],
            \ ['test_outline.asciidoc1', 'asciidoc'],
            \ ['test_outline.html', 'html'],
            \ ['test_outline.otl', 'thevimoutliner'],
            \ ['test_outline.otl', 'vimoutliner'],
            \ ['test_outline.taskpaper', 'taskpaper'],
            \ ['paragraphBlank.txt', 'paragraphBlank'],
            \ ['paragraphIndent.txt', 'paragraphIndent'],
            \ ['paragraphNoIndent.txt', 'paragraphNoIndent'],
            \ ['python_test_outline.py', 'python']
            \]


func! VoomTest_TestAllModes(...) "{{{1
" For each mode: load test file, create outline, run all tests.
" The test file is loaded in the current window.
" Vim register v will contain Vim output.
" Vim register p will contain Python output (PyLog buffer lines) with comments stripped.

    " PyLog must be displayed
    Voomlog
    " delete all outlines
    VoomQuitAll

exe s:PYCMD . ' << ENDPYTHON'
if not vim.eval('&enc') == 'utf-8':
    print("# WARNING: Vim 'encoding' is not utf-8")
if not int(vim.eval('g:voom_verify_oop')):
    print('# WARNING: outline verification is disabled (g:voom_verify_oop)')
ENDPYTHON

    " go to PyLog, get last line number, go back
    let logBnr = voom#GetVar('s:voom_logbnr')
    exe bufwinnr(logBnr).'wincmd w'
    let logLnum = line('$')
    exe winnr('#').'wincmd w'

exe s:PYCMD . ' << ENDPYTHON'
TestAllModes_time_start = _time()
print('++++++++++ STARTED: VoomTest_TestAllModes() ++++++++++')
print('# s:PYCMD = %s' % repr(vim.eval('s:PYCMD')))
ENDPYTHON

    " this is to avoid exceeding max possible level after Move Right
    let g:voom_inverseAtx_max = 10
    let g:voom_inverseAtx_char = '@'

    " messages may affect comparison
    let shm_ = &shm
    set shm=atI
    " too many echo messages, screen fills
    let more_ = &more
    set nomore
    " there is too much bleeping, suppress it
    let [vb_ , t_vb_] = [&vb, &t_vb]
    set vb t_vb=
    " modeline must be on when testing python markup mode (ts=4).
    " Debian default config is nomodeline, ts=8.
    let modeline_ = &modeline
    set modeline

    " edit file names, so that only file names will appear in redir var
    exec 'cd' s:voom_samples_dir

    " FIXME: silent has no effect on what is being redir-ed.
    " When we don't want something redir-ed, the current solution is to stop redir.
    " This is not good because error messages may be missed.
    let s:VOOM_REDIR = ''
    let kwargs = {'skipRedir': 1, 'skipRedirUnl': 1}
    redir =>> s:VOOM_REDIR

    for it in s:voom_samples_names
        let path = s:voom_samples_dir . it[0]
        if !filereadable(path)
            call voom#ErrorMsg('TEST FILE NOT READABLE: '.path)
            continue
        endif
        echo "\n"
        echo '  TEST FILE: "'. it[0] .'", MARKUP MODE: "'. it[1] .'"'
        redir END
        "silent exec 'edit ' . path
        silent exec 'edit ' . it[0]
        redir =>> s:VOOM_REDIR
        exec 'Voom ' . it[1]
        let tree = bufnr('')
        if voom#BufNotTree(tree)
            call voom#ErrorMsg('FAILED TO CREATE OUTLINE FOR: '.it[0])
            return
        endif
        """ run all tests for this outline
        call VoomTest_RunAllTests(kwargs)
        """ delete outline
        if bufnr('')==tree
            bw
        else
            call voom#ErrorMsg('WRONG BUFFER AFTER FINISHING TESTS FOR: '.it[0])
            return
        endif
    endfor
    unlet! it

    redir END

    " save Vim output in register v
    let @v = s:VOOM_REDIR

    " restore some setings
    let [&vb, &t_vb, &shm, &more]=[vb_, t_vb_, shm_, more_]
    let &modeline = modeline_
    unlet! g:voom_inverseAtx_max  g:voom_inverseAtx_char

exe s:PYCMD . ' << ENDPYTHON'
print('++++++++++ FINISHED: VoomTest_TestAllModes() ++++++++++ # %.6f sec' %(_time()-TestAllModes_time_start))
ENDPYTHON

    exec 'cd' s:script_dir

    " Compare Python output to reference file. Comments after # must be stripped.
    let py_out = getbufline(logBnr, logLnum+1, '$')
    let py_out_nocomments = []
    for it in py_out
        call add(py_out_nocomments, substitute(it, '#.*', '#', ''))
    endfor
    unlet! it
    exe s:PYCMD "print('')"
    exe s:PYCMD "print('comparing Python output to TestAllModes_python.ok.txt ...')"
    let py_out_ok = readfile('TestAllModes_python.ok.txt')
    let py_out_ok_nocomments = []
    for it in py_out_ok
        call add(py_out_ok_nocomments, substitute(it, '#.*', '#', ''))
    endfor
    if py_out_ok_nocomments ==# py_out_nocomments
        exe s:PYCMD "print('OK')"
    else
        exe s:PYCMD "print('ERROR: PYTHON OUTPUT IS DIFFERENT !!!')"
    endif
    " save Python output in register p
    let @p = join(py_out_nocomments, "\n")

    " Compare Vim output to reference file.
    exe s:PYCMD "print('comparing Vim output to TestAllModes_vim.ok.txt ...')"
    let vim_out_ok = readfile('TestAllModes_vim.ok.txt')
    let vim_out = split(s:VOOM_REDIR, '\n', 1)
    if vim_out_ok ==# vim_out
        exe s:PYCMD "print('OK')"
    else
        exe s:PYCMD "print('ERROR: VIM OUTPUT IS DIFFERENT !!!')"
    endif
    exe s:PYCMD "print('')"

endfunc


func! VoomTest_RunAllTests(...) "{{{1
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    let [voom_bodies, voom_trees] = voom#GetBodiesTrees()
    if bufType!='Tree'
        call voom#ErrorMsg("VOoM: must be in Tree buffer")
        return
    endif
    let [mmode, MTYPE, body, tree] = voom#GetModeBodyTree(bufnr(''))

    let kwargs = (a:0 > 0 && !empty(a:1)) ? a:1 : 0
    let l:bodyfilename = bufname(body)

exe s:PYCMD . ' << ENDPYTHON'
#print('\n\n======= %s =======' % (_VOoM2657.VOOMS[int(vim.eval('l:body'))].bname))
print('')
print('======================================================================')
print('  TEST FILE: "%s", MARKUP MODE: "%s"' % ( vim.eval('l:bodyfilename'),
        _VOoM2657.VOOMS[int(vim.eval('l:body'))].mmode) )
print('-----STARTING ALL TESTS-----------------------------------')
ENDPYTHON

    echo '    TEST: VoomTest_OutlineMetrics()'
    call VoomTest_OutlineMetrics()
    call VoomTest_DiscardChanges(body, tree, kwargs)

    echo '    TEST: VoomTest_OutlineTraversal()'
    call VoomTest_OutlineTraversal(kwargs)
    call VoomTest_DiscardChanges(body, tree, kwargs)

    echo '    TEST: VoomTest_Sort()'
    call VoomTest_Sort(kwargs)
    call VoomTest_DiscardChanges(body, tree, kwargs)

    echo '    TEST: VoomTest_DownUp()'
    call VoomTest_DownUp()
    call VoomTest_DiscardChanges(body, tree, kwargs)

    echo '    TEST: VoomTest_CutAllPasteAll()'
    call VoomTest_CutAllPasteAll()
    call VoomTest_DiscardChanges(body, tree, kwargs)

    echo '    TEST: VoomTest_CutPaste()'
    call VoomTest_CutPaste()
    call VoomTest_DiscardChanges(body, tree, kwargs)

    echo '    TEST: VoomTest_CopyPasteCut()'
    call VoomTest_CopyPasteCut()
    call VoomTest_DiscardChanges(body, tree, kwargs)

    if MTYPE < 2
        echo '    TEST: VoomTest_RightLeftRight()'
        call VoomTest_RightLeftRight()
        call VoomTest_DiscardChanges(body, tree, kwargs)

        echo '    TEST: VoomTest_LeftRight()'
        call VoomTest_LeftRight()
        call VoomTest_DiscardChanges(body, tree, kwargs)
    endif

    echo '    TEST: VoomTest_NewHeadline()'
    call VoomTest_NewHeadline()
    call VoomTest_DiscardChanges(body, tree, kwargs)

    if MTYPE == 0
        echo '    TEST: VoomTest_SpecialMarks()'
        call VoomTest_SpecialMarks()
        call VoomTest_DiscardChanges(body, tree, kwargs)
    endif

    exe s:PYCMD "print('-----FINISHED ALL TESTS-----------------------------------')"
endfunc


"--- individual tests --- {{{1

func! VoomTest_OutlineMetrics(...) abort "{{{1
" Compare VO.levels to the reference list in the first node (Tree lnum 2).
    exe s:PYCMD "print('    TEST: VoomTest_OutlineMetrics()')"
    exe s:PYCMD "time_start = _time()"
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
        if line =~# '\CID_LEVELS VO\.levels=[1'
            let l:levels = substitute(line,'\C^.*VO\.levels=','','' )
            break
        endif
    endfor

exe s:PYCMD . ' << ENDPYTHON'
body = int(vim.eval("l:body"))
VO = _VOoM2657.VOOMS[body]
Z = int(vim.eval("l:Z"))
#assert len(VO.bnodes)==Z
if not len(VO.bnodes)==Z:
    print('ERROR: not len(VO.bnodes)==Z')
#assert len(VO.bnodes)==len(VO.levels)
if not len(VO.bnodes)==len(VO.levels):
    print('ERROR: not len(VO.bnodes)==len(VO.levels)')
if vim.eval("exists('l:levels')")=='1':
    exec('levels = %s' %(vim.eval('l:levels')))
    #assert levels == VO.levels
    if not levels == VO.levels:
        print('ERROR: not levels == VO.levels')
else:
    print('ERROR: did not find line with levels')
ENDPYTHON

    exe s:PYCMD "print('             DONE # %.6f sec' % (_time()-time_start))"
endfunc


func! VoomTest_OutlineTraversal(...) abort "{{{1
" Test voom_vim.py outline traversal functions.
    exe s:PYCMD "print('    TEST: VoomTest_OutlineTraversal()')"
    exe s:PYCMD "time_start = _time()"
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

exe s:PYCMD . ' << ENDPYTHON'
body = int(vim.eval("l:body"))
VO = _VOoM2657.VOOMS[body]
Z = int(vim.eval("l:Z"))
#print(Z)

for ln in xrange(1,Z+1):
    siblings = _VOoM2657.nodeSiblings(VO,ln)
    continue
    siblings_groups = _VOoM2657.getSiblingsGroups(VO,siblings)
    lnum1, lnum2 = siblings[0], siblings[-1]
    lnum2 = lnum2 + _VOoM2657.nodeSubnodes(VO,lnum2)
    L = []
    for l in siblings_groups: L.extend(l)
    L.sort()
    #print(L)
    #print(range(lnum1,lnum2+1))
    assert L==range(lnum1,lnum2+1)
ENDPYTHON

    " :Voomunl is good for testing traversal functions
    " Problem: Unl's go to Vim redir, despite silent, suppress because too many
    " TODO: capture redir if Vim errors
    let skipRedirUnl = (a:0 > 0 && !empty(a:1)) ? get(a:1, 'skipRedirUnl', 0) : 0
    if skipRedirUnl
        redir END
    endif

    for ln in range(1,Z)
        exe 'normal! '.ln.'G'
        silent Voomunl
    endfor

    if skipRedirUnl
        redir =>> s:VOOM_REDIR
    endif

    exe s:PYCMD "print('             DONE # %.6f sec' % (_time()-time_start))"
endfunc


func! VoomTest_Sort(...) abort "{{{1
    exe s:PYCMD "print('    TEST: VoomTest_Sort()')"
    exe s:PYCMD "time_start = _time()"
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

exe s:PYCMD . ' << ENDPYTHON'
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM2657.VOOMS[body]
Z = int(vim.eval("l:Z"))
# these must not change
nodes_count = nodesCount(body) # number of nodes, also Z
parents_count = parentsCount(body) # number of parents
body_len = len(VO.Body) # number of Body lines
ENDPYTHON

    " Use :silent to supress 'already sorted' messages. This is to ensure that
    " Vim output will not change by chance.
    " Initial outline is assumed to be:
    "   not deep-sorted
    "   has headline 'VoomSort tests'

    " outline should not change after two flips
    normal! zM2Gzv
    exe s:PYCMD "blines_ = VO.Body[:]"
    VoomSort deep flip i
    exe s:PYCMD "if blines_ == VO.Body[:]: print('ERROR: 1')"
    " doesn't work
    "normal! 2GVG
    "echom line("'<") line("'>")
    "'<,'>VoomSort deep flip i
    "echom line("'<") line("'>")
    2,$VoomSort deep flip i
    " end of selection is wrong, some kind of Vim problem
    "echom line("'<") line("'>")
    exec "normal! \<Esc>"
    exe s:PYCMD "if blines_ != VO.Body[:]: print('ERROR: 2')"

    VoomSort deep i

exe s:PYCMD . ' << ENDPYTHON'
if not nodesCount(body) == nodes_count: print('ERROR: 3')
if not parentsCount(body) == parents_count: print('ERROR: 4')
if not len(VO.Body) == body_len: print('ERROR: 5')
ENDPYTHON

    VoomSort deep i r

exe s:PYCMD . ' << ENDPYTHON'
if not nodesCount(body) == nodes_count: print('ERROR: 6')
if not parentsCount(body) == parents_count: print('ERROR: 7')
if not len(VO.Body) == body_len: print('ERROR: 8')
ENDPYTHON

    " go to node 'VoomSort tests'
    call search('VoomSort tests', 'w')
    if getline('.') !~ 'VoomSort tests'
        exe s:PYCMD "print('''ERROR: 9, current line (Tree) is not 'VoomSort tests' ''')"
    endif
    normal! zv
    VoomSort deep
    " this assertion assumes that intial outline is not deep-sorted
    exe s:PYCMD "if blines_ == VO.Body[:]: print('ERROR: 10 (ignore if intial outline is deep-sorted)')"
    exe s:PYCMD "blines_ = VO.Body[:]"
    " already sorted
    silent VoomSort deep
    exe s:PYCMD "if blines_ != VO.Body[:]: print('ERROR: 11')"
    VoomSort deep r
    exe s:PYCMD "if blines_ == VO.Body[:]: print('ERROR: 12')"
    exe s:PYCMD "blines_ = VO.Body[:]"
    " already sorted
    silent VoomSort deep r
    exe s:PYCMD "if blines_ != VO.Body[:]: print('ERROR: 13')"

exe s:PYCMD . ' << ENDPYTHON'
if not nodesCount(body) == nodes_count: print('ERROR: 14')
if not parentsCount(body) == parents_count: print('ERROR: 15')
if not len(VO.Body) == body_len: print('ERROR: 16')
ENDPYTHON

    " Problem: shuffle will sometimes give 'already sorted' message,
    " which breaks comparison. Thus redir must be suspended.
    normal! zM2Gzv
    let skipRedir = (a:0 > 0 && !empty(a:1)) ? get(a:1, 'skipRedir', 0) : 0
    if skipRedir
        redir END
        " posssible Vim errors need to be captured
        let s:temp_redir = ''
        redir => s:temp_redir
    endif

    "" test that 'already sorted' messages are ignored
    "silent VoomSort deep r
    silent VoomSort shuffle
    silent VoomSort deep shuffle
    silent VoomSort shuffle deep bytes i

    if skipRedir
        redir END
        " check s:temp_redir for errors
        let temp_redir_is_bad = 0
        let temp_redir_lines = split(s:temp_redir, '\n')
        for it in temp_redir_lines
            if it !~ '\m^\s*$' && it !~#'\m^\s*VOoM (sort): already sorted\s*$'
                let temp_redir_is_bad = 1
                break
            endif
        endfor
        unlet! it
        if temp_redir_is_bad
            let s:VOOM_REDIR = s:VOOM_REDIR . s:temp_redir
        endif
        redir =>> s:VOOM_REDIR
    endif

exe s:PYCMD . ' << ENDPYTHON'
if not nodesCount(body) == nodes_count: print('ERROR: 17')
if not parentsCount(body) == parents_count: print('ERROR: 18')
if not len(VO.Body) == body_len: print('ERROR: 19')
ENDPYTHON

    if Z!=line('$') | echoerr 'VoomSort error' | endif
    exe s:PYCMD "print('             DONE # %.6f sec' % (_time()-time_start))"
endfunc


func! VoomTest_DownUp(...) abort "{{{1
" Move first node all the way Down. Then move it all the way Up. Check that
" Body has not changed.
    exe s:PYCMD "print('    TEST: VoomTest_DownUp()')"
    exe s:PYCMD "time_start = _time()"
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

exe s:PYCMD . ' << ENDPYTHON'
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM2657.VOOMS[body]
Z = int(vim.eval("l:Z"))

tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
# these must never change
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
ENDPYTHON

    """ move first node all the way DOWN
    let lnum = 1
    while lnum != line('.')
        let lnum = line('.')
        call voom#Oop('down', 'n')
    endwhile

exe s:PYCMD . ' << ENDPYTHON'
lnum = int(vim.eval('l:lnum'))
if not nodesCount(body) == nodes_count: print('ERROR: nodes_count %s' %lnum)
if not len(VO.Body) == body_len: print('ERROR: body_len %s' %lnum)
if not Z == lnum + _VOoM2657.nodeSubnodes(VO,lnum): print('ERROR: Z %s' %lnum)
ENDPYTHON

    """ move first node back all the way UP
    """ Body must revert to original state
    let lnum = 1
    while lnum != line('.')
        let lnum = line('.')
        call voom#Oop('up', 'n')
    endwhile

exe s:PYCMD . ' << ENDPYTHON'
lnum = int(vim.eval("line('.')"))
if not lnum==2: print("ERROR: line('.') is not 2")
if VO.Body[:] != blines_: print('ERROR: blines_ %s' %lnum)
if VO.Tree[:] != tlines_: print('ERROR: tlines_ %s' %lnum)
ENDPYTHON

    exe s:PYCMD "print('             DONE # %.6f sec' % (_time()-time_start))"
endfunc


func! VoomTest_CutAllPasteAll(...) abort "{{{1
    exe s:PYCMD "print('    TEST: VoomTest_CutAllPasteAll()')"
    exe s:PYCMD "time_start = _time()"
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

exe s:PYCMD . ' << ENDPYTHON'
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM2657.VOOMS[body]
Z = int(vim.eval("l:Z"))
# number of Body lines before first headline
header_len = VO.bnodes[1]-1

tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
# these must not change
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
ENDPYTHON

    """ Do Cut/Paste for the entire outline.
       "This tests Paste into empty outline (reST, makrdown issues.)
    normal! 2GVG
    normal dd
    "call voom#Oop('cut', 'v')
    if 1!=line('$') | echoerr 'Cut All error, Tree size not 1' | endif
    exe s:PYCMD "if len(VO.Body)!=header_len: print('ERROR: wrong Body size after CutAll')"
    "call voom#OopPaste()
    normal pp
    exec "normal! \<Esc>"
    exe s:PYCMD "if VO.Body[:] != blines_: print('ERROR: Body changed after CutAll/PasteAll')"
    exe s:PYCMD "print('             DONE # %.6f sec' % (_time()-time_start))"
endfunc


func! VoomTest_CutPaste(...) abort "{{{1
    exe s:PYCMD "print('    TEST: VoomTest_CutPaste()')"
    exe s:PYCMD "time_start = _time()"
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

exe s:PYCMD . ' << ENDPYTHON'
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM2657.VOOMS[body]
Z = int(vim.eval("l:Z"))
# number of Body lines before first headline
header_len = VO.bnodes[1]-1

tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
# these must not change
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
ENDPYTHON

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
        exe s:PYCMD "if VO.Body[:] != blines_: print('ERROR: Body changed (lnum %s)' %vim.eval('l:lnum'))"
        if line('$') != Z | echoerr 'Paste error' | endif
        normal! j
    endwhile
    exec "normal! \<Esc>"
    exe s:PYCMD "print('             DONE # %.6f sec' % (_time()-time_start))"
endfunc


func! VoomTest_CopyPasteCut(...) abort "{{{1
    exe s:PYCMD "print('    TEST: VoomTest_CopyPasteCut()')"
    exe s:PYCMD "time_start = _time()"
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

exe s:PYCMD . ' << ENDPYTHON'
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM2657.VOOMS[body]
Z = int(vim.eval("l:Z"))

tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
# these must not change
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
ENDPYTHON

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
        exe s:PYCMD "if VO.Body[:] != blines_: print('ERROR: at lnum %s' %vim.eval('l:lnum'))"
        if Z!=line('$') | echoerr 'Copy/Paste/Cut error' | endif
        normal! j
    endwhile

    exe s:PYCMD "print('             DONE # %.6f sec' % (_time()-time_start))"
endfunc


func! VoomTest_RightLeftRight(...) abort "{{{1
" Move right all the way.
" Move left all the way.
" Move right to restore indent. Ouline must not change.
" _VOoM2657.ALWAYS_ALLOW_MOVE_LEFT (g:voom_always_allow_move_left) must be False, otherwise the test fails.
" NOTE: The test cannot handle markups that have a maximum possible level and
" it is exceeded after Move Right: ass-backward formats (dokuwiki, inverseAtx), latex.
    exe s:PYCMD "print('    TEST: VoomTest_RightLeftRight()')"
    exe s:PYCMD "time_start = _time()"
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

exe s:PYCMD . ' << ENDPYTHON'
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM2657.VOOMS[body]
Z = int(vim.eval("l:Z"))
tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
# make sure we move Right and Left at least once
didRight, didLeft = False,False
# these must not change
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
ENDPYTHON

    exe s:PYCMD "ALWAYS_ALLOW_MOVE_LEFT_ = _VOoM2657.ALWAYS_ALLOW_MOVE_LEFT"
    exe s:PYCMD "_VOoM2657.ALWAYS_ALLOW_MOVE_LEFT = False"
    let fdm_ = getbufvar(body, '&fdm')
    let tlnums_tested = []
    let lnum = 0
    while lnum != line('.')
        let lnum = line('.')
        call add(tlnums_tested, lnum)
        let ind_ = s:Ind()
        """ Move Right until no longer possible
        exe s:PYCMD "blines = VO.Body[:]"
        let ind = -99
        while ind != s:Ind()
            let ind = s:Ind()
            call voom#Oop('right', 'n')
            exe s:PYCMD "if not didRight and VO.Body[:] != blines: didRight = True"
        endwhile
        """ Move Left until no longer possible, result depends on g:voom_always_allow_move_left
        exe s:PYCMD "blines = VO.Body[:]"
        let ind = -99
        while ind != s:Ind()
            let ind = s:Ind()
            call voom#Oop('left', 'n')
            exe s:PYCMD "if not didLeft and VO.Body[:] != blines: didLeft = True"
        endwhile
        """ Move Right until Tree line indent is restored
        while ind_ != s:Ind()
            let ind = s:Ind()
            call voom#Oop('right', 'n')
            " unable to move right anymore
            if ind == s:Ind() | break | endif
        endwhile
        """ Body must not change
        exe s:PYCMD "if VO.Body[:] != blines_: print('ERROR: Body changed (lnum %s)' %vim.eval('l:lnum'))"
        if Z!=line('$') | echoerr 'Right/Left error' | endif
        if fdm_!=getbufvar(body,'&fdm') | echoerr 'Right/Left fdm error' | endif
        normal! j
    endwhile
    exe s:PYCMD "_VOoM2657.ALWAYS_ALLOW_MOVE_LEFT = ALWAYS_ALLOW_MOVE_LEFT_"

    exe s:PYCMD "if not didRight: print('ERROR: Move Right was not tested')"
    exe s:PYCMD "if not didLeft:  print('ERROR: Move Left was not tested')"
    exe s:PYCMD "print('             DONE # %.6f sec' % (_time()-time_start))"
    exe s:PYCMD "print('              %s' %vim.eval('l:tlnums_tested'))"
endfunc


func! VoomTest_LeftRight(...) abort "{{{1
" _VOoM2657.ALWAYS_ALLOW_MOVE_LEFT (g:voom_always_allow_move_left) is True.
" For each top level node: go to first child, move left and move right.
" If Body changed: assume it is because siblings below became children afer the
" first move left. Correct by restoring siblings by moving them left.
" This also tests o J D U c.
    exe s:PYCMD "print('    TEST: VoomTest_LeftRight()')"
    exe s:PYCMD "time_start = _time()"
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

exe s:PYCMD . ' << ENDPYTHON'
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM2657.VOOMS[body]
Z = int(vim.eval("l:Z"))
tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
# make sure we move Right and Left at least once
didRight, didLeft = False,False
# these must not change
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
ENDPYTHON

    exe s:PYCMD "ALWAYS_ALLOW_MOVE_LEFT_ = _VOoM2657.ALWAYS_ALLOW_MOVE_LEFT"
    exe s:PYCMD "_VOoM2657.ALWAYS_ALLOW_MOVE_LEFT = True"
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
            exe s:PYCMD "print('ERROR: wrong line after oJDU (lnum %s)' %vim.eval('l:lnum'))"
        endif
        """ Move Left
        exe s:PYCMD "blines = VO.Body[:]"
        call voom#Oop('left', 'n')
        exec "normal! \<Esc>"
        exe s:PYCMD "if not didLeft and VO.Body[:] != blines: didLeft = True"
        """ Move Right
        exe s:PYCMD "blines = VO.Body[:]"
        call voom#Oop('right', 'n')
        exec "normal! \<Esc>"
        " Body must not change if there were no siblings that become children on Move Left
        if ln_D==ln_o
            exe s:PYCMD "if VO.Body[:] != blines_: print('ERROR: Body changed 1 (lnum %s)' %vim.eval('l:ln_o'))"
            if Z!=line('$') | echoerr 'Left/Right error' | endif
        else
            exe s:PYCMD "if not didRight: didRight = True"
            exe s:PYCMD "if VO.Body[:] == blines_: print('ERROR: Body did not change (lnum %s)' %vim.eval('l:ln_o'))"
            " restore original siblings of ln_o: select them, Move Left
            exe 'normal! '.ln_D.'GzvV'.ln_J.'Gzv'
            exec "normal! \<Esc>"
            call voom#Oop('left', 'v')
            exec "normal! \<Esc>"
            " Body must not change
            exe s:PYCMD "if VO.Body[:] != blines_: print('ERROR: Body changed 2 (lnum %s)' %vim.eval('l:ln_o'))"
            if Z!=line('$') | echoerr 'Left/Right error' | endif
            if fdm_!=getbufvar(body,'&fdm') | echoerr 'Left/Right fdm error' | endif
        endif
        normal c
        if line('.') != lnum
            exe s:PYCMD "print('ERROR: wrong line after c (lnum %s)' %vim.eval('l:ln_o'))"
        endif
        normal! j
    endwhile
    exe s:PYCMD "_VOoM2657.ALWAYS_ALLOW_MOVE_LEFT = ALWAYS_ALLOW_MOVE_LEFT_"

    exe s:PYCMD "if not didRight: print('ERROR: Move Right was not tested')"
    exe s:PYCMD "if not didLeft:  print('ERROR: Move Left was not tested')"
    exe s:PYCMD "print('             DONE # %.6f sec' % (_time()-time_start))"
    exe s:PYCMD "print('              %s' %vim.eval('l:tlnums_tested'))"
endfunc


func! VoomTest_NewHeadline(...) abort "{{{1
    exe s:PYCMD "print('    TEST: VoomTest_NewHeadline()')"
    exe s:PYCMD "time_start = _time()"
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let [mmode, MTYPE, body, tree] = voom#GetModeBodyTree(bufnr(''))
    let Z = line('$')

exe s:PYCMD . ' << ENDPYTHON'
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM2657.VOOMS[body]
Z = int(vim.eval("l:Z"))

tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
nodes_count = nodesCount(body) # number of nodes, also Z
body_len = len(VO.Body) # number of Body lines
ENDPYTHON

    " After inserting NewHeadline cursor is in Body.
    " bnodes and levels are wrong, but Tree lines should be correct.

    " Insert after line 1
    normal! ggzM
    call voom#OopInsert('')
    exe s:PYCMD "voomTest_NewHeadline(VO)"
    call voom#ToTree(tree)
    call voom#OopInsert('as_child')
    exe s:PYCMD "voomTest_NewHeadline(VO)"
    " insert after first fold
    call voom#ToTree(tree)
    normal! j
    call voom#OopInsert('')
    exe s:PYCMD "voomTest_NewHeadline(VO)"
    call voom#ToTree(tree)
    call voom#OopInsert('as_child')
    exe s:PYCMD "voomTest_NewHeadline(VO)"
    " insert after last node
    call voom#ToTree(tree)
    normal! Gzv
    call voom#OopInsert('')
    exe s:PYCMD "voomTest_NewHeadline(VO)"
    call voom#ToTree(tree)
    call voom#OopInsert('as_child')
    exe s:PYCMD "voomTest_NewHeadline(VO)"
    call voom#ToTree(tree)
    
    " total 6 nodes have been inserted
    " check that number of nodes is correct after all inserts
    if MTYPE < 2
        exe s:PYCMD "assert nodes_count + 6 == nodesCount(body)"
    " insert as child is not allowed (paragraph modes)
    else
        exe s:PYCMD "assert nodes_count + 3 == nodesCount(body)"
    endif

    exe s:PYCMD "print('             DONE # %.6f sec' % (_time()-time_start))"
endfunc


func! VoomTest_SpecialMarks(...) abort "{{{1
" Tests for adding/removing special node marks: xo= after fold markers.
    "let [mmode, MTYPE, body, tree] = voom#GetModeBodyTree(bufnr(''))
    "" return if special nodes marks are not supported
    "if MTYPE != 0 | return | endif

    exe s:PYCMD "print('    TEST: VoomTest_SpecialMarks()')"
    exe s:PYCMD "time_start = _time()"
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    if bufType=='None' | return | endif
    if bufType!='Tree'
        echoerr "not a Tree buffer"
        return
    endif
    let Z = line('$')

exe s:PYCMD . ' << ENDPYTHON'
body,tree = int(vim.eval("l:body")), int(vim.eval("l:tree"))
VO = _VOoM2657.VOOMS[body]
Z = int(vim.eval("l:Z"))
tlines_ = VO.Tree[:]
blines_ = VO.Body[:]
ENDPYTHON

    """ Mark all nodes, Unmark all nodes, restore original marks.
    """ This does not change selected node, startup node, open fold marks.
    " save lnums of marked nodes
    normal! gg0zM
    let markedNodes = []
    let lnum = search('\m\C^.x', 'W')
    while lnum > 0
        call add(markedNodes, lnum)
        let lnum = search('\m\C^.x', 'W')
    endwhile
    " get <LocalLeader>
    if exists("g:maplocalleader")
        let locLeader = g:maplocalleader
    else
        let locLeader = '\'
    endif
    " mark all nodes
    normal! ggVG
    exe 'normal '.locLeader.'m'
    " check there are no unmarked nodes
    normal! gg
    if search('\m\C^. ', 'W') > 0
        exe s:PYCMD "print('ERROR: failed to mark all nodes')"
    endif
    " unmark all nodes
    normal! ggVG
    exe 'normal '.locLeader.'M'
    " check there are no marked nodes
    normal! gg
    if search('\m\C^.x', 'W') > 0
        exe s:PYCMD "print('ERROR: failed to unmark all nodes')"
    endif
    " restore original marks
    "echo markedNodes
    for i in markedNodes
        exe 'normal! '.i.'Gzv'
        exe 'normal '.locLeader.'m'
    endfor

exe s:PYCMD . ' << ENDPYTHON'
if VO.Body[:] != blines_: print('ERROR: Body changed after Mark/Unmark all')
if VO.Tree[:] != tlines_: print('ERROR: Tree changed after Mark/Unmark all')
ENDPYTHON

    """ Test adding/removing xo= marks on the last node.
    normal! gg0zM
    " save selected node
    let selectedNode = search('\m\C^=', 'cnW')
    " save startup node
    normal +
    let startupNode = line('.')
    " go to last node
    normal! Gzv
    let lnumZ = line('.')
    let levZ = s:Ind() / 2
    " insert new node as child
    normal AA
    call voom#BodySelect()
    if bufnr('') != tree
        exe s:PYCMD "print('ERROR: wrong buffer (Error 1)')"
        return
    endif
    " go to original last node (now with child), apply xo= marks
    normal P
    exe 'normal '.locLeader.'='
    VoomFoldingSave
    exe 'normal '.locLeader.'M'
    exe 'normal '.locLeader.'m'
    " go to Body, check that there are correct marks after fold marker
    call voom#TreeSelect(0)
    call voom#TreeSelect(0)
    if bufnr('') != body 
        exe s:PYCMD "print('ERROR: wrong buffer (Error 2)')"
        return
    endif
    normal! 0
    if search(split(&fmr, ',')[0] .levZ.'xo=' , 'cnW') != line('.')
        exe s:PYCMD "print('ERROR: failed to apply xo= marks')"
    endif
    " go back to Tree
    call voom#BodySelect()
    if bufnr('') != tree
        exe s:PYCMD "print('ERROR: wrong buffer (Error 3)')"
        return
    endif
    normal! zc
    VoomFoldingRestore
    normal! j
    if line('.') != lnumZ+1
        exe s:PYCMD "print('ERROR: VoomFoldingRestore failed')"
        return
    endif
    " delete child node, restore marks
    normal dd
    if index(markedNodes, lnumZ) == -1
        exe 'normal '.locLeader.'M'
    endif
    " assumes there are were no orphan 'o' marks in the original file
    VoomFoldingCleanup
    exe 'normal! '.startupNode.'Gzv'
    exe 'normal '.locLeader.'='
    exe 'normal! '.selectedNode.'Gzv'
    call voom#TreeSelect(1)

exe s:PYCMD . ' << ENDPYTHON'
if VO.Body[:] != blines_: print('ERROR: Body changed after Mark/Unmark all')
if VO.Tree[:] != tlines_: print('ERROR: Tree changed after Mark/Unmark all')
ENDPYTHON

    exe s:PYCMD "print('             DONE # %.6f sec' % (_time()-time_start))"
endfunc


"--- helpers --- {{{1

func! VoomTest_DiscardChanges(body, tree, ...) "{{{1
    " discard all changes in Body buffer body
    let skipRedir = (a:0 > 0 && !empty(a:1)) ? get(a:1, 'skipRedir', 0) : 0
    call voom#ToBody(a:body)
    if skipRedir
        redir END
    endif
    silent edit!
    if skipRedir
        redir =>> s:VOOM_REDIR
    endif
    normal! ggzM
    call voom#ToTree(a:tree)
    normal! ggzM
endfunc


func! s:Ind() "{{{1
    return stridx(getline('.'),'|')
endfunc


" Python functions {{{1o
" exe s:PYCMD . ' << ENDPYTHON' {{{2

exe s:PYCMD . ' << ENDPYTHON'


def nodesCount(body): #{{{2
    levels = _VOoM2657.VOOMS[body].levels
    return len(levels)


def parentsCount(body): #{{{2
    """return number of parents--nodes with children"""
    levels = _VOoM2657.VOOMS[body].levels
    parents_count = len([i for i in xrange(1,len(levels)) if levels[i-1]<levels[i]])
    return parents_count


def voomTest_NewHeadline(VO): #{{{2
    tlines, bnodes, levels  = VO.makeOutline(VO, VO.Body)
    if not len(VO.Tree)==len(tlines)+1:
        print('ERROR: wrong Tree size')
        return
    tlines[0:0], bnodes[0:0], levels[0:0] = [VO.bname], [1], [1]
    snLn = VO.snLn
    tlines[snLn-1] = '=%s' %tlines[snLn-1][1:]
    if not tlines==VO.Tree[:]:
        print('ERROR: DIFFERENT Tree lines')
        print('snLn line expected: %s' % tlines[snLn-1])
        print('snLn line actual  : %s' % VO.Tree[snLn-1])
        return


# ENDPYTHON {{{2
ENDPYTHON

"--- Timing commands and functions --- {{{1

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
