" This is a sample VOoM add-on.
" It creates global command :VoomPrintStats which prints information about the
" current outline if the current buffer is a VOoM buffer (Tree or Body).

" This file can be sourced at any time like a regular Vim script. E.g., it can
" be dropped in folder ~/.vim/plugin/ . Of course, VOoM has to be installed for
" the command :VoomPrintStats to work.

" NOTE: Python 3 is needed. To make it work with Python 2, change python3 to python.


com! VoomPrintStats call Voom_PrintStats()

func! Voom_PrintStats()
    """"""" standard code for every VOoM add-on command
    " Determine if the current buffer is a VOoM Tree buffer, Body buffer, or neither.
    let [bufType,body,tree] = voom#GetTypeBodyTree()
    " Error, outline is not available (Body is unloaded, outline update failed).
    if body==-1 | return | endif
    """ Do different things depending on the type of the current buffer.
    " Current buffer is not a VOoM buffer (neither Tree nor Body).
    " The error message is printed automatically. It can be suppressed by
    " providing an optional argument: voom#GetTypeBodyTree(1)
    if bufType==#'None'
        "call voom#ErrorMsg("VOoM: current buffer is not a VOoM buffer")
        return
    " Current buffer is a VOoM Body. Outline is updated automatically if needed.
    elseif bufType==#'Body'
        call voom#WarningMsg("in VOoM Body buffer")
    " Current buffer is a VOoM Tree.
    elseif bufType==#'Tree'
        call voom#WarningMsg("in VOoM Tree buffer")
    endif
    " Get Vim-side outline data. NOTE: Do not modify these dictionaries!
    let [voom_bodies, voom_trees] = voom#GetBodiesTrees()


    """"""" script-specific code
    " Get Python-side data. This creates Vim local variables.
    python3 voom_PrintStats()

    echo 'VOoM version:' g:voom_did_load_plugin
    echo '__PyLog__ buffer number:' voom#GetVar('s:voom_logbnr')
    " print outline information
    echo 'VOoM outline for:' getbufline(tree,1)[0][1:]
    echo 'Current buffer is:' bufType
    echo 'Body buffer number:' body
    echo 'Tree buffer number:' tree
    echo 'number of nodes:' l:nodesNumber
    echo 'nodes with/without children:' l:nodesWithChildren '/' l:nodesWithoutChildren
    echo 'max level:' l:maxLevel
    echo 'selected node number:' voom_bodies[body].snLn
    echo 'selected node headline text:' l:selectedHeadline
    echo 'selected node level:' l:selectedNodeLevel
endfunc


python3 << EOF

# NOTE: main module "voom_vimplugin2657.voom_vim" is imported in Vim as _VOoM2657

def voom_PrintStats():
    body, tree = int(vim.eval('l:body')), int(vim.eval('l:tree'))
    VO = _VOoM2657.VOOMS[body]
    bnodes, levels = VO.bnodes, VO.levels
    vim.command("let l:maxLevel=%s" %(max(levels)))
    vim.command("let l:nodesNumber=%s" %(len(bnodes)))
    nodesWithChildren = len([i for i in range(1,len(bnodes)+1) if _VOoM2657.nodeHasChildren(VO,i)])
    vim.command("let l:nodesWithChildren=%s" %nodesWithChildren)
    nodesWithoutChildren = len([i for i in range(1,len(bnodes)+1) if not _VOoM2657.nodeHasChildren(VO,i)])
    vim.command("let l:nodesWithoutChildren=%s" %nodesWithoutChildren)
    snLn = VO.snLn
    treeline = VO.Tree[snLn-1]
    if snLn>1:
        selectedHeadline = treeline[treeline.find('|')+1:]
    else:
        selectedHeadline = "top-of-buffer"
    vim.command("let [l:selectedNode,l:selectedHeadline]=[%s,'%s']" %(snLn, selectedHeadline.replace("'","''")))
    vim.command("let l:selectedNodeLevel=%s" %levels[snLn-1])

EOF

