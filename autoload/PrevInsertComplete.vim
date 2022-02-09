" PrevInsertComplete.vim: Recall and insert mode completion for previously inserted text.
"
" DEPENDENCIES:
"   - CompleteHelper.vim plugin
"   - ingo-library.vim plugin
"
" Copyright: (C) 2011-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! s:ComputeReltime( matchObj )
    let a:matchObj.menu = (a:matchObj.menu <= 0 ?
    \	'' :
    \   ingo#date#HumanReltime(localtime() - a:matchObj.menu, {'shortformat': 1, 'rightaligned': 1})
    \)
    return a:matchObj
endfunction
if v:version >= 703 || v:version == 702 && has('patch295')
function! PrevInsertComplete#FindMatches( pattern )
    " Use default comparison operator here to honor the 'ignorecase' setting.
    return
    \	map(
    \	    filter(
    \		map(copy(g:PrevInsertComplete#Insertions), '{"word": v:val, "menu": g:PrevInsertComplete#InsertionTimes[v:key]}'),
    \		'v:val.word =~ a:pattern'
    \	    ),
    \	    'CompleteHelper#Abbreviate#Word(s:ComputeReltime(v:val))'
    \	)
endfunction
else
function! PrevInsertComplete#FindMatches( pattern )
    " Use default comparison operator here to honor the 'ignorecase' setting.
    return
    \	map(
    \	    filter(copy(g:PrevInsertComplete#Insertions), 'v:val =~ a:pattern'),
    \	    'CompleteHelper#Abbreviate#Word({"word": v:val})'
    \	)
endfunction
endif
let s:repeatCnt = 0
function! PrevInsertComplete#PrevInsertComplete( findstart, base )
    if s:repeatCnt
	if a:findstart
	    return col('.') - 1
	else
	    let l:histIdx = index(g:PrevInsertComplete#Insertions, s:addedText)
"****D echomsg '***1' l:histIdx s:addedText
	    if l:histIdx == -1 || l:histIdx == 0
		return []
	    endif
"****D echomsg '***2' get(g:PrevInsertComplete#Insertions, (l:histIdx - 1), '')
	    return [{'word': get(g:PrevInsertComplete#Insertions, (l:histIdx - 1), '')}]
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

function! PrevInsertComplete#Expr()
    set completefunc=PrevInsertComplete#PrevInsertComplete

    let s:repeatCnt = 0
    let [s:repeatCnt, s:addedText, l:fullText] = CompleteHelper#Repeat#TestForRepeat()
"****D echomsg '****' string( [s:repeatCnt, s:addedText, l:fullText] )
    return "\<C-x>\<C-u>"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
