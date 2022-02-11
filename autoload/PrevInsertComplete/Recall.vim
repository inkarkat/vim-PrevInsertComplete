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

function! PrevInsertComplete#Recall#Do( insertion, repeatCount, register, multiplier )
    " This doesn't work with special characters like <Esc>.
    "execute 'normal! a' . s:insertion . "\<Esc>"
    call ingo#register#KeepRegisterExecuteOrFunc(function('PrevInsertComplete#Recall#Insert'), a:insertion, a:multiplier)
    silent! call repeat#set("\<Plug>(PrevInsertRecallRepeat)", a:repeatCount)
    silent! call repeat#setreg("\<Plug>(PrevInsertRecallRepeat)", a:register)
    return 1
endfunction
function! PrevInsertComplete#Recall#Insert( insertion, multiplier )
    call setreg('"', a:insertion, 'v')
    let l:pasteCommand = (ingo#text#IsInsert(g:PrevInsertComplete_RecallInsertStrategy) ? 'P' : 'p')
    execute 'normal!' a:multiplier . l:pasteCommand
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
