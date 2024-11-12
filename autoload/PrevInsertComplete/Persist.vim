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
    try
	" Note: Because the storage variables are passed by-reference to the
	" ingo/plugin/historyrecall module, they cannot be re-assigned. Instead,
	" use extend() to add to the existing, pre-initialized List / Dict. We
	" do not need to clear previous values as
	" PrevInsertComplete#Persist#Load() is invoked only once at startup,
	" where the variables are all empty.
	call extend(g:PrevInsertComplete#Insertions, ingo#plugin#persistence#Load('PREV_INSERTIONS', []))
	call extend(g:PrevInsertComplete#InsertionTimes, ingo#plugin#persistence#Load('PREV_INSERTION_TIMES', repeat([0], len(g:PrevInsertComplete#Insertions))))   " Just ignore the insertion dates when they are corrupted.
	call extend(g:PrevInsertComplete#NamedInsertions, ingo#plugin#persistence#Load('PREV_NAMED_INSERTIONS', {}))
	call extend(g:PrevInsertComplete#RecalledInsertions, ingo#plugin#persistence#Load('PREV_RECALLED_INSERTIONS', []))
    catch /^Load:/
	call ingo#msg#CustomExceptionMsg('Load')
    finally
	" Free the memory occupied by the persistence variables. They will be
	" re-populated by PrevInsertComplete#Persist#Save() before Vim exits.
	unlet! g:PREV_INSERTIONS g:PREV_INSERTION_TIMES g:PREV_NAMED_INSERTIONS g:PREV_RECALLED_INSERTIONS
    endtry
endfunction

function! PrevInsertComplete#Persist#Save()
    let l:size = len(g:PrevInsertComplete#Insertions)
    " Need to truncate to actual size for the List slicing from behind.
    let l:size = (l:size < g:PrevInsertComplete_PersistSize ? l:size : g:PrevInsertComplete_PersistSize)

    call ingo#plugin#persistence#Store('PREV_INSERTIONS', g:PrevInsertComplete#Insertions[(-1 * l:size):-1])
    call ingo#plugin#persistence#Store('PREV_INSERTION_TIMES', g:PrevInsertComplete#InsertionTimes[(-1 * l:size):-1])

    if g:PrevInsertComplete_PersistNamed
	call ingo#plugin#persistence#Store('PREV_NAMED_INSERTIONS', g:PrevInsertComplete#NamedInsertions)
    endif

    if g:PrevInsertComplete_PersistRecalled
	call ingo#plugin#persistence#Store('PREV_RECALLED_INSERTIONS', g:PrevInsertComplete#RecalledInsertions)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
