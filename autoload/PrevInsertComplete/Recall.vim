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

let s:namedInsertions = {}
let s:recalledInsertions = []
let s:recalledWhat = ''

function! s:HasName( register ) abort
    return (a:register !=# ingo#register#Default())
endfunction
function! PrevInsertComplete#Recall#RecallRepeat( count, repeatCount, register )
    let l:isOverriddenCount = (a:repeatCount > 0 && a:repeatCount != g:repeat_count)
    let l:isOverriddenRegister = (g:repeat_reg[1] !=# a:register)

    if l:isOverriddenRegister
	" Reset the count if the actual register differs from the original
	" register, as count may be the last insertion number or the multiplier.
	return PrevInsertComplete#Recall#Recall(1, 0, a:register)
    elseif l:isOverriddenCount
	" An overriding count (without a register) selects the previous
	" [count]'th insertion for repeat.
	return PrevInsertComplete#Recall#Recall(a:count, a:repeatCount, ingo#register#Default())
    else
	return PrevInsertComplete#Recall#Recall(a:count, a:repeatCount, a:register)
    endif
endfunction
function! PrevInsertComplete#Recall#Recall( count, repeatCount, register )
    if ! s:HasName(a:register)
	let l:multiplier = 1
	let s:insertion = get(g:PrevInsertComplete_Insertions, a:count - 1, '')

	if empty(s:insertion)
	    if len(g:PrevInsertComplete_Insertions) == 0
		call ingo#err#Set('No insertions yet')
	    else
		call ingo#err#Set(printf('There %s only %d insertion%s in the history',
		\   len(g:PrevInsertComplete_Insertions) == 1 ? 'is' : 'are',
		\   len(g:PrevInsertComplete_Insertions),
		\   len(g:PrevInsertComplete_Insertions) == 1 ? '' : 's'
		\))
	    endif
	    return 0
	endif
	let l:what = (a:count - 1) . "\n" . s:insertion
    elseif a:register =~# '[1-9]'
	let l:multiplier = a:count
	let s:insertion = get(s:recalledInsertions, str2nr(a:register) - 1, '')
	if empty(s:insertion)
	    if len(s:recalledInsertions) == 0
		call ingo#err#Set('No recalled insertions yet')
	    else
		call ingo#err#Set(printf('There %s only %d recalled insertion%s',
		\   len(s:recalledInsertions) == 1 ? 'is' : 'are',
		\   len(s:recalledInsertions),
		\   len(s:recalledInsertions) == 1 ? '' : 's'
		\))
	    endif
	    return 0
	endif
	let l:what = '"' . a:register . "\n" . s:insertion
	if a:register ==# '1'
	    " Put any recalled insertion other that the last recall itself back
	    " at the top, even if the last recalled insertion was the same one.
	    " This creates a "cycling" effect so that one can use "3q<A-a> or
	    " q<C-a>"3 to recall the third-to-last element, and subsequent
	    " repeats will recall the second-to-last, last, and then again
	    " 3-2-1-3-2-1-...
	    let s:recalledWhat = ''
	endif
    elseif has_key(s:namedInsertions, a:register)
	let l:multiplier = a:count
	let s:insertion = s:namedInsertions[a:register]
	let l:what = '"' . a:register . "\n" . s:insertion
    else
	call ingo#err#Set(a:register =~# '[a-zA-Z]' ?
	\   printf('Nothing named "%s yet', a:register) :
	\   printf('Not a valid name: "%s; must be {a-zA-Z} or {1-9}', a:register)
	\)
	return 0
    endif

    call s:Recall(l:what, a:repeatCount, a:register, l:multiplier)
    return 1
endfunction
function! s:Recall( what, repeatCount, register, multiplier )
    if ! empty(a:what) && a:what !=# s:recalledWhat
	" It's not a repeat of the last recalled thing; put it at the first
	" position of the recall stack.
	call insert(s:recalledInsertions, s:insertion)
	if len(s:recalledInsertions) > 9
	    call remove(s:recalledInsertions, 9, -1)
	endif
	let s:recalledWhat = a:what
    endif

    " This doesn't work with special characters like <Esc>.
    "execute 'normal! a' . s:insertion . "\<Esc>"
    call ingo#register#KeepRegisterExecuteOrFunc(function('PrevInsertComplete#Recall#Insert'), s:insertion, a:multiplier)
    silent! call repeat#set("\<Plug>(PrevInsertRecallRepeat)", a:repeatCount)
    silent! call repeat#setreg("\<Plug>(PrevInsertRecallRepeat)", a:register)
endfunction
function! PrevInsertComplete#Recall#Insert( insertion, multiplier )
    call setreg('"', a:insertion, 'v')
    execute 'normal!' a:multiplier . 'p'
endfunction
function! PrevInsertComplete#Recall#List( multiplier, register )
    let l:validNames = filter(
    \   split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '\zs'),
    \   'has_key(s:namedInsertions, v:val)'
    \)
    let l:recalledNum = len(s:recalledInsertions)

    if len(g:PrevInsertComplete_Insertions) + len(l:validNames) + l:recalledNum == 0
	call ingo#err#Set('No insertions yet')
	return 0
    endif

    let l:hasName = s:HasName(a:register)
    echohl Title
    echo ' #  insertion'
    echohl None
    for l:i in range(1, l:recalledNum)
	echo '"' . l:i . '  ' . ingo#avoidprompt#TranslateLineBreaks(s:recalledInsertions[l:i - 1])
    endfor
    for l:i in l:validNames
	echo '"' . l:i . '  ' . ingo#avoidprompt#TranslateLineBreaks(s:namedInsertions[l:i])
    endfor
    for l:i in range(min([9, len(g:PrevInsertComplete_Insertions)]), 1, -1)
	echo ' ' . l:i . '  ' . ingo#avoidprompt#TranslateLineBreaks(g:PrevInsertComplete_Insertions[l:i - 1])
    endfor

    let l:validNamesAndRecalls = join(l:validNames, '') . join(range(1, l:recalledNum), '')
    echo printf('Type number%s (<Enter> cancels) to insert%s: ', (empty(l:validNamesAndRecalls) ? '' : ' or "{name}'), (l:hasName ? ' and assign to "' . a:register : ''))
    let l:choice = ingo#query#get#ValidChar({'validExpr': "[123456789\<CR>" . (empty(l:validNamesAndRecalls) ? '' : '"' . l:validNamesAndRecalls) . ']'})
    let l:what = ''
    let l:repeatCount = a:multiplier
    if empty(l:choice) || l:choice ==# "\<CR>"
	return 1
    elseif l:choice ==# '"'
	let l:choice = ingo#query#get#ValidChar({'validExpr': "[\<CR>" . l:validNamesAndRecalls . ']'})
	if empty(l:choice) || l:choice ==# "\<CR>"
	    return 1
	elseif l:choice =~# '\d'
	    let s:insertion = s:recalledInsertions[str2nr(l:choice) - 1]
	    let l:repeatCount = str2nr(l:choice)    " Counting last insertions here.
	    let l:repeatRegister = l:choice
	    if l:choice !=# '1'
		" Put any recalled insertion other that the last recall itself
		" back at the top.
		let l:what = '"' . l:choice . "\n" . s:insertion
	    endif
	elseif l:choice =~# '\a'
	    let s:insertion = s:namedInsertions[l:choice]
	    let l:repeatRegister = l:choice
	    " Don't put the same name and identical contents at the top again if
	    " it's already there.
	    let l:what = '"' . l:choice . "\n" . s:insertion
	else
	    throw 'ASSERT: Unexpected l:choice: ' . l:choice
	endif
    elseif l:choice =~# '\d'
	let l:repeatRegister = a:register   " Use the named register this is being assigned to, or the default register.
	let s:insertion = g:PrevInsertComplete_Insertions[str2nr(l:choice) - 1]
	" Don't put the same count and identical contents at the top again if
	" it's already there.
	let l:what = l:choice . "\n" . s:insertion
    elseif l:choice =~# '\a'  | " Take {a-zA-Z} as a shortcut for "{a-zA-z}; unlike with the {1-9} recalled insertions, there's no clash here.
	let l:repeatRegister = l:choice
	let s:insertion = s:namedInsertions[l:choice]
	" Don't put the same name and identical contents at the top again if
	" it's already there.
	let l:what = '"' . l:choice . "\n" . s:insertion
    else
	throw 'ASSERT: Unexpected l:choice: ' . l:choice
    endif

    if l:hasName
	let s:namedInsertions[a:register] = s:insertion
    endif

    call s:Recall(l:what, l:repeatCount, l:repeatRegister, a:multiplier)
    return 1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
