" PrevInsertComplete.vim: Recall and insert mode completion for previously inserted text. 
"
" DESCRIPTION:
" USAGE:
"							       *i_CTRL-X_CTRL-A*
" <i_CTRL-X_CTRL-A>	Find previous insertions (|i_CTRL-A|, ".) whose
"			contents match the keyword before the cursor. First, a
"			match at the beginning is tried; if that returns no
"			results, it may match anywhere. 
" INSTALLATION:
" DEPENDENCIES:
"   - CompleteHelper.vim autoload script. 
"
" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"  - Repetition via <C-x><C-a>
"  - add "42s ago" as menu, factored out from wbVC
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
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
let s:insertions = []
function! PrevInsertComplete#RecordInsertion()
    let l:text = s:GetInsertion()
    if l:text =~# '^\_s*$' || s:strchars(l:text) < g:PrevInsertComplete_MinLength
	" Do not record whitespace-only and short insertions. 
	return
    endif

    let l:histIdx = index(s:insertions, l:text)
    if l:histIdx == -1
	call insert(s:insertions, l:text, 0)
	silent! call remove(s:insertions, g:PrevInsertComplete_HistorySize, -1)
    else
	" Like in the Vim histories, the same history item replaces the previous
	" ones and is put at the top. 
	call remove(s:insertions, l:histIdx)
	call insert(s:insertions, l:text, 0)
    endif
endfunction

function! PrevInsertComplete#FindMatches( pattern )
    " Use default comparison operator here to honor the 'ignorecase' setting. 
    return
    \	map(
    \	    filter(copy(s:insertions), 'v:val =~ a:pattern'),
    \	    'CompleteHelper#Abbreviate({"word": v:val})'
    \	)
endfunction
function! PrevInsertComplete#PrevInsertComplete( findstart, base )
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
    return "\<C-x>\<C-u>"
endfunction
inoremap <script> <expr> <Plug>(PrevInsertComplete) <SID>PrevInsertCompleteExpr()
if ! hasmapto('<Plug>(PrevInsertComplete)', 'i')
    imap <C-x><C-a> <Plug>(PrevInsertComplete)
endif

augroup PrevInsertComplete
    autocmd!
    autocmd InsertLeave * call PrevInsertComplete#RecordInsertion()
augroup END

function! Debug()
    echo s:insertions
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
