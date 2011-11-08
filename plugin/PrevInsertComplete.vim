" PrevInsertComplete.vim: Recall and insert mode completion for previously inserted text. 
"
" DESCRIPTION:
" USAGE:
"							       *i_CTRL-X_CTRL-A*
" <i_CTRL-X_CTRL-A>	Find previous insertions (|i_CTRL-A|, ".) whose
"			contents match the keyword before the cursor. First, a
"			match at the beginning is tried; if that returns no
"			results, it may match anywhere. 
"			Further use of CTRL-X CTRL-A will append insertions done
"			after the previous recall. 
"									    *qa*
" [count]qa		Recall and append previous [count]'th insertion. 
"								      *q_CTRL-A*
" [count]q<CTRL-A>	Lists the last 9 insertions, then prompts for a number.
"			The chosen insertion is appended [count] times. 
"
" INSTALLATION:
" DEPENDENCIES:
"   - CompleteHelper.vim autoload script. 
"   - CompleteHelper/Repeat.vim autoload script. 
"   - ingodate.vim autoload script. 
"
" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	002	10-Oct-2011	Implement repetition with following history
"				items. 
"	001	06-Oct-2011	file creation
let s:save_cpo = &cpo
set cpo&vim

" Avoid installing twice or when in unsupported Vim version. 
if exists('g:loaded_PrevInsertComplete') || (v:version < 700)
    finish
endif
let g:loaded_PrevInsertComplete = 1

if ! exists('g:PrevInsertComplete_MinLength')
    let g:PrevInsertComplete_MinLength = 10
endif
if ! exists('g:PrevInsertComplete_HistorySize')
    let g:PrevInsertComplete_HistorySize = 100
endif


if exists('*strchars')
function! s:strchars( expr )
    return strchars(a:expr)
endfunction
else
function! s:strchars( expr )
    return len(split(a:expr, '\zs'))
endfunction
endif
function! s:GetInsertion()
    " Unfortunately, we cannot simply use register "., because it contains all
    " editing keys, so also <Del> and <BS>, which show up in raw form "<80>kD",
    " and which insert completion does not interpret. Instead, we rely on the
    " range delimited by the marks '[ and '] (last one exclusive). 
    let l:startPos = getpos("'[")[1:2]
    let l:endPos = [line("']"), (col("']") - 1)]
    return CompleteHelper#ExtractText(l:startPos, l:endPos, {})
endfunction
let s:insertions = ['fifth', 'fourth', 'third', 'second', 'first'] " XXX: DEBUG
let s:insertionTimes = [0, 0, 0, 0, 0, 0]
function! PrevInsertComplete#RecordInsertion( text )
    if a:text =~# '^\_s*$' || s:strchars(a:text) < g:PrevInsertComplete_MinLength
	" Do not record whitespace-only and short insertions. 
	return
    endif

    let l:histIdx = index(s:insertions, a:text)
    if l:histIdx == -1
	call insert(s:insertions, a:text, 0)
	call insert(s:insertionTimes, localtime(), 0)
	silent! call remove(s:insertions, g:PrevInsertComplete_HistorySize, -1)
    else
	" Like in the Vim histories, the same history item replaces the previous
	" ones and is put at the top. 
	call remove(s:insertions, l:histIdx)
	call remove(s:insertionTimes, l:histIdx)
	call insert(s:insertions, a:text, 0)
	call insert(s:insertionTimes, localtime(), 0)
    endif
endfunction

function! s:ComputeReltime( matchObj )
    let a:matchObj.menu = ingodate#HumanReltime(localtime() - a:matchObj.menu, {'shortformat': 1, 'rightaligned': 1})
    return a:matchObj
endfunction
if v:version >= 703 || v:version == 702 && has('patch295')
function! PrevInsertComplete#FindMatches( pattern )
    " Use default comparison operator here to honor the 'ignorecase' setting. 
    return
    \	map(
    \	    filter(
    \		map(copy(s:insertions), '{"word": v:val, "menu": s:insertionTimes[v:key]}'),
    \		'v:val.word =~ a:pattern'
    \	    ),
    \	    'CompleteHelper#Abbreviate(s:ComputeReltime(v:val))'
    \	)
endfunction
else
function! PrevInsertComplete#FindMatches( pattern )
    " Use default comparison operator here to honor the 'ignorecase' setting. 
    return
    \	map(
    \	    filter(copy(s:insertions), 'v:val =~ a:pattern'),
    \	    'CompleteHelper#Abbreviate({"word": v:val})'
    \	)
endfunction
endif
let s:repeatCnt = 0
function! PrevInsertComplete#PrevInsertComplete( findstart, base )
    if s:repeatCnt
	if a:findstart
	    return col('.') - 1
	else
	    let l:histIdx = index(s:insertions, s:addedText)
"****D echomsg '***1' l:histIdx s:addedText
	    if l:histIdx == -1 || l:histIdx == 0
		return []
	    endif
"****D echomsg '***2' get(s:insertions, (l:histIdx - 1), '')
	    return [{'word': get(s:insertions, (l:histIdx - 1), '')}]
	endif
    endif

    if a:findstart
	" Locate the start of the keyword. 
	let l:startCol = searchpos('\k*\%#', 'bn', line('.'))[1]
	if l:startCol == 0
	    let l:startCol = col('.')
	endif
	return l:startCol - 1 " Return byte index, not column. 
    else
	" Find matches starting with (after optional non-keyword characters) a:base. 
	let l:matches = PrevInsertComplete#FindMatches('^\%(\k\@!.\)*\V' . escape(a:base, '\'))
	if empty(l:matches)
	    " Find matches containing a:base. 
	    let l:matches = PrevInsertComplete#FindMatches('\V' . escape(a:base, '\'))
	endif
	return l:matches
    endif
endfunction

function! s:PrevInsertCompleteExpr()
    set completefunc=PrevInsertComplete#PrevInsertComplete

    let s:repeatCnt = 0
    let [s:repeatCnt, s:addedText, l:fullText] = CompleteHelper#Repeat#TestForRepeat()
"****D echomsg '****' string( [s:repeatCnt, s:addedText, l:fullText] )
    return "\<C-x>\<C-u>"
endfunction
inoremap <script> <expr> <Plug>(PrevInsertComplete) <SID>PrevInsertCompleteExpr()
if ! hasmapto('<Plug>(PrevInsertComplete)', 'i')
    imap <C-x><C-a> <Plug>(PrevInsertComplete)
endif

augroup PrevInsertComplete
    autocmd!
    autocmd InsertLeave * call PrevInsertComplete#RecordInsertion(s:GetInsertion())
augroup END

function! PrevInsertComplete#Recall( position, multiplier )
    let l:insertion = get(s:insertions, (a:position - 1), '')
    if empty(l:insertion)
	if len(s:insertions) == 0
	    let v:errmsg = 'No insertions yet'
	else
	    let v:errmsg = printf('There %s only %d insertion%s in the history',
	    \   len(s:insertions) == 1 ? 'is' : 'are',
	    \   len(s:insertions),
	    \   len(s:insertions) == 1 ? '' : 's'
	    \)
	endif
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None

	return
    endif

    " This doesn't work with special characters like <Esc>. 
    "execute 'normal! a' . l:insertion . "\<Esc>"

    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers. 
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')
    call setreg('"', l:insertion, 'v')
    try
	execute 'normal!' a:multiplier . 'p'
    finally
	call setreg('"', l:save_reg, l:save_regmode)
	let &clipboard = l:save_clipboard
    endtry

    " Execution of the recall command counts as an insertion itself. However, we
    " do not consider the a:multiplier here. 
    call PrevInsertComplete#RecordInsertion(l:insertion)
endfunction
function! PrevInsertComplete#List()
    if len(s:insertions) == 0
	let v:errmsg = 'No insertions yet'
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
	return
    endif

    echohl Title
    echo '      #  insertion'
    echohl None
    for i in range(min([9, len(s:insertions)]), 1, -1)
	echo '      ' . i . '  ' . EchoWithoutScrolling#TranslateLineBreaks(s:insertions[i - 1])
    endfor
    echo 'Type number (<Enter> cancels): ' 
    call inputsave()
    let l:choice = nr2char(getchar())
    call inputrestore()
    if l:choice =~# '\d'
	call PrevInsertComplete#Recall(l:choice, v:count1)
    endif
endfunction
nnoremap <silent> <Plug>(PrevInsertRecall) :<C-u>call PrevInsertComplete#Recall(v:count1, 1)<CR>
if ! hasmapto('<Plug>(PrevInsertRecall)', 'n')
    nmap qa <Plug>(PrevInsertRecall)
endif
nnoremap <silent> <Plug>(PrevInsertList) :<C-u>call PrevInsertComplete#List()<CR>
if ! hasmapto('<Plug>(PrevInsertList)', 'n')
    nmap q<C-a> <Plug>(PrevInsertList)
endif


function! Debug()
    echo s:insertions
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
