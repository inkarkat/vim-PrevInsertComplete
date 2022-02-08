" PrevInsertComplete/Recall.vim: Recall of previously inserted text.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"   - repeat.vim (vimscript #2136) plugin (optional)
"
" Copyright: (C) 2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim


function! PrevInsertComplete#Recall#Recall( position, multiplier )
    let s:insertion = get(g:PrevInsertComplete_Insertions, (a:position - 1), '')
    if empty(s:insertion)
	if len(g:PrevInsertComplete_Insertions) == 0
	    call ingo#msg#ErrorMsg('No insertions yet')
	else
	    call ingo#msg#ErrorMsg(printf('There %s only %d insertion%s in the history',
	    \   len(g:PrevInsertComplete_Insertions) == 1 ? 'is' : 'are',
	    \   len(g:PrevInsertComplete_Insertions),
	    \   len(g:PrevInsertComplete_Insertions) == 1 ? '' : 's'
	    \))
	endif
    else
	call PrevInsertComplete#Recall#Do( a:multiplier )
    endif
endfunction
function! PrevInsertComplete#Recall#Do( multiplier )

    " This doesn't work with special characters like <Esc>.
    "execute 'normal! a' . s:insertion . "\<Esc>"
    call ingo#register#KeepRegisterExecuteOrFunc(function('PrevInsertComplete#Recall#Insert'), s:insertion, a:multiplier)

    " Execution of the recall command counts as an insertion itself. However, we
    " do not consider the a:multiplier here.
    call PrevInsertComplete#Record#Insertion(s:insertion)

    silent! call repeat#set("\<Plug>(PrevInsertRecallRepeat)", a:multiplier)
endfunction
function! PrevInsertComplete#Recall#Insert( insertion, multiplier )
    call setreg('"', a:insertion, 'v')
    execute 'normal!' a:multiplier . 'p'
endfunction
function! PrevInsertComplete#Recall#List( multiplier )
    if len(g:PrevInsertComplete_Insertions) == 0
	call ingo#msg#ErrorMsg('No insertions yet')
	return
    endif

    echohl Title
    echo ' #  insertion'
    echohl None
    for i in range(min([9, len(g:PrevInsertComplete_Insertions)]), 1, -1)
	echo ' ' . i . '  ' . ingo#avoidprompt#TranslateLineBreaks(g:PrevInsertComplete_Insertions[i - 1])
    endfor
    echo 'Type number (<Enter> cancels): '
    let l:choice = nr2char(getchar())
    if l:choice =~# '\d'
	redraw	" Somehow need this to avoid the hit-enter prompt.
	call PrevInsertComplete#Recall#Recall(l:choice, a:multiplier)
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
