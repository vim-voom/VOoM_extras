" WARNING: THIS IS A BAD IDEA! DON'T DO IT!!
" This plugin creates VOoM outlines automatically for files with filetype 'markdown'.
" When a Markdown file aaa.mkd is opened in gvim with
"       gvim aaa.mkd
" the command
"       :Voom markdown
" is executed automatically.
" When another file bbb.mkd is loaded with
"       :e bbb.mkd
" in place of aaa.mkd, the new outline is created automatically in the old Tree window.
" Credits: Based on emails from a user in Feb 2016.


func! VoomAutomatic(markup)
	if !exists("g:vim_entered") || &diff || exists("w:voom_tree")
        return
    endif

    " Do ':Voom markup'. Keep the cursor in the original window.
	call voom#Init(a:markup, 0, 1)

    " Close orphan Tree windows in the current tab page.
    " These are left behind because Voom splits existing Tree window when creating new Tree.
	let bnr_ = bufnr('')
    let [voom_bodies, voom_trees] = voom#GetBodiesTrees()
    for bnr in tabpagebuflist()
        if has_key(voom_trees, bnr) && bufwinnr(voom_trees[bnr]) < 0 && bufwinnr(bnr) > 0
            exe bufwinnr(bnr).'wincmd w'
            wincmd c
            wincmd p
            if bufnr('') != bnr_
                exe bufwinnr(bnr_).'wincmd w'
            endif
        endif
    endfor
endfunc

augroup VOOM_AUTOMATIC
	au!
	if !&diff
		autocmd VimEnter * let g:vim_entered=1
		autocmd VimEnter * if &filetype=="markdown" | call VoomAutomatic('markdown') | endif
        " nested is needed to trigger BufUnload au when closing orphan Trees
		autocmd FileType markdown nested call VoomAutomatic('markdown')
	endif
augroup END
