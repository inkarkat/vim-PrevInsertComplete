" PrevInsertComplete/Persist.vim: Persistence of previous insertions across Vim sessions.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2012-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! PrevInsertComplete#Persist#Load()
    if exists('g:PREV_INSERTIONS')
	try
	    " Persistent global variables cannot be of type List, so we actually
	    " store the string representation, and eval() it back to a List.
	    execute 'let g:PrevInsertComplete#Insertions =' g:PREV_INSERTIONS

	    if exists('g:PREV_INSERTION_TIMES')
		try
		    execute 'let g:PrevInsertComplete#InsertionTimes =' g:PREV_INSERTION_TIMES
		catch /^Vim\%((\a\+)\)\=:/
		    " Just ignore the insertion dates when they are corrupted.
		    let g:PrevInsertComplete#InsertionTimes = repeat([0], len(g:PrevInsertComplete#Insertions))
		endtry
	    else
		" Somehow, the insertion dates weren't persisted. So what.
		let g:PrevInsertComplete#InsertionTimes = repeat([0], len(g:PrevInsertComplete#Insertions))
	    endif
	catch /^Vim\%((\a\+)\)\=:/
	    call ingo#msg#ErrorMsg('Corrupted persistent insertion history in g:PREV_INSERTIONS')
	finally
	    " Free the memory occupied by the persistence variables. They will
	    " be re-populated by PrevInsertComplete#Persist#Save() before Vim
	    " exits.
	    unlet! g:PREV_INSERTIONS
	    unlet! g:PREV_INSERTION_TIMES
	endtry
    endif

    if exists('g:PREV_NAMED_INSERTIONS')
	try
	    execute 'let g:PrevInsertComplete#Recall#NamedInsertions =' g:PREV_NAMED_INSERTIONS
	catch /^Vim\%((\a\+)\)\=:/
	    call ingo#msg#ErrorMsg('Corrupted persistent named insertions in g:PREV_NAMED_INSERTIONS')
	finally
	    unlet! g:PREV_NAMED_INSERTIONS
	endtry
    endif

    if exists('g:PREV_RECALLED_INSERTIONS')
	try
	    execute 'let g:PrevInsertComplete#Recall#RecalledInsertions =' g:PREV_RECALLED_INSERTIONS
	catch /^Vim\%((\a\+)\)\=:/
	    call ingo#msg#ErrorMsg('Corrupted persistent recalled insertions in g:PREV_RECALLED_INSERTIONS')
	finally
	    unlet! g:PREV_RECALLED_INSERTIONS
	endtry
    endif
endfunction

function! PrevInsertComplete#Persist#Save()
    let l:size = len(g:PrevInsertComplete#Insertions)
    " Need to truncate to actual size for the List slicing from behind.
    let l:size = (l:size < g:PrevInsertComplete_PersistSize ? l:size : g:PrevInsertComplete_PersistSize)

    let g:PREV_INSERTIONS      = string(g:PrevInsertComplete#Insertions[(-1 * l:size):-1])
    let g:PREV_INSERTION_TIMES = string(g:PrevInsertComplete#InsertionTimes[(-1 * l:size):-1])

    if g:PrevInsertComplete_PersistNamed
	let g:PREV_NAMED_INSERTIONS = string(g:PrevInsertComplete#Recall#NamedInsertions)
    endif

    if g:PrevInsertComplete_PersistRecalled
	let g:PREV_RECALLED_INSERTIONS = string(g:PrevInsertComplete#Recall#RecalledInsertions)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
