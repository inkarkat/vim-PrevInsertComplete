" PrevInsertComplete.vim: Recall and insert mode completion for previously inserted text.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"
" Copyright: (C) 2011-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_PrevInsertComplete') || (v:version < 700)
    finish
endif
let g:loaded_PrevInsertComplete = 1
let s:save_cpo = &cpo
set cpo&vim

"- configuration ---------------------------------------------------------------

if ! exists('g:PrevInsertComplete_MinLength')
    let g:PrevInsertComplete_MinLength = 6
endif
if ! exists('g:PrevInsertComplete_HistorySize')
    let g:PrevInsertComplete_HistorySize = 100
endif

if ! exists('g:PrevInsertComplete_PersistSize')
    let g:PrevInsertComplete_PersistSize = g:PrevInsertComplete_HistorySize
endif
if ! exists('g:PrevInsertComplete_PersistNamed')
    let g:PrevInsertComplete_PersistNamed = 1
endif
if ! exists('g:PrevInsertComplete_PersistRecalled')
    let g:PrevInsertComplete_PersistRecalled = 1
endif


"- internal data ---------------------------------------------------------------

let g:PrevInsertComplete#Insertions = []
let g:PrevInsertComplete#InsertionTimes = []
let g:PrevInsertComplete#NamedInsertions = {}
let g:PrevInsertComplete#RecalledInsertions = []


"- autocmds --------------------------------------------------------------------

augroup PrevInsertComplete
    autocmd!
    autocmd InsertLeave * call PrevInsertComplete#Record#Do()

    if g:PrevInsertComplete_PersistSize > 0 || g:PrevInsertComplete_PersistNamed || g:PrevInsertComplete_PersistRecalled
	" As the viminfo is only processed after sourcing of the runtime files, the
	" persistent global variables are not yet available here. Defer this until Vim
	" startup has completed.
	autocmd VimEnter    * call PrevInsertComplete#Persist#Load()

	" Do not update the persistent variables after each insertion; their
	" size is not negligible. Instead, clear them after reading them and
	" only write them when exiting Vim, before the viminfo file is written.
	autocmd VimLeavePre * call PrevInsertComplete#Persist#Save()
    endif
augroup END


"- mappings --------------------------------------------------------------------

inoremap <script> <expr> <Plug>(PrevInsertComplete) PrevInsertComplete#Expr()
if ! hasmapto('<Plug>(PrevInsertComplete)', 'i')
    imap <C-x><C-a> <Plug>(PrevInsertComplete)
endif


call ingo#plugin#historyrecall#Register('insertion',
\   g:PrevInsertComplete#Insertions, g:PrevInsertComplete#NamedInsertions, g:PrevInsertComplete#RecalledInsertions,
\   function('PrevInsertComplete#Recall#Do')
\)

nnoremap <silent> <Plug>(PrevInsertRecall)
\ :<C-u>call setline('.', getline('.'))<Bar>
\if ! ingo#plugin#historyrecall#Recall('insertion', v:count1, v:count, v:register)<Bar>echoerr ingo#err#Get()<Bar>endif<CR>
if ! hasmapto('<Plug>(PrevInsertRecall)', 'n')
    nmap q<A-a> <Plug>(PrevInsertRecall)
endif
nnoremap <silent> <Plug>(PrevInsertList)
\ :<C-u>if !&ma<Bar><Bar>&ro<Bar>call setline('.', getline('.'))<Bar>endif<Bar>
\if ! ingo#plugin#historyrecall#List('insertion', v:count1, v:register)<Bar>echoerr ingo#err#Get()<Bar>endif<CR>
if ! hasmapto('<Plug>(PrevInsertList)', 'n')
    nmap q<C-a> <Plug>(PrevInsertList)
endif

nnoremap <silent> <Plug>(PrevInsertRecallRepeat)
\ :<C-u>if !&ma<Bar><Bar>&ro<Bar>call setline('.', getline('.'))<Bar>endif<Bar>
\if ! ingo#plugin#historyrecall#RecallRepeat('insertion', v:count1, v:count, v:register)<Bar>echoerr ingo#err#Get()<Bar>endif<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
