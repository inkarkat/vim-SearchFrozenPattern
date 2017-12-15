" SearchFrozenPattern.vim: Freeze the current search pattern and keep searching for it.
"
" DEPENDENCIES:
"   - SearchFrozenPattern.vim autoload script
"   - SearchRepeat.vim autoload script
"   - ingo/err.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_SearchFrozenPattern') || (v:version < 700)
    finish
endif
let g:loaded_SearchFrozenPattern = 1
let s:save_cpo = &cpo
set cpo&vim

"- commands --------------------------------------------------------------------

command! -nargs=? SearchFreeze if ! SearchFrozenPattern#FreezeCommand(<q-args>) | echoerr ingo#err#Get() | endif



"- mappings --------------------------------------------------------------------

nnoremap <silent> <Plug>(SearchFrozenPatternNext) :<C-u>if ! SearchFrozenPattern#Search(0, v:count1)<Bar>echoerr ingo#err#Get()<Bar>endif<CR>
nnoremap <silent> <Plug>(SearchFrozenPatternPrev) :<C-u>if ! SearchFrozenPattern#Search(1, v:count1)<Bar>echoerr ingo#err#Get()<Bar>endif<CR>
if ! hasmapto('<Plug>(SearchFrozenPatternNext)', 'n')
    nmap gof <Plug>(SearchFrozenPatternNext)
endif
if ! hasmapto('<Plug>(SearchFrozenPatternPrev)', 'n')
    nmap gOf <Plug>(SearchFrozenPatternPrev)
endif


nnoremap <silent> <Plug>(SearchFrozenPatternFreeze) :<C-u>if ! SearchFrozenPattern#FreezeMapping()<Bar>echoerr ingo#err#Get()<Bar>endif<CR>
if ! hasmapto('<Plug>(SearchFrozenPatternFreeze)', 'n')
    nmap <Leader>/f <Plug>(SearchFrozenPatternFreeze)
endif


"- Integration into SearchRepeat.vim -------------------------------------------

let g:SearchFrozenPattern#SearchRepeatOptions = {'hlsearch': 0, 'isResetToStandardSearch': 0}
try
    call SearchRepeat#Define(
    \	'<Plug>(SearchFrozenPatternNext)', '<Plug>(SearchFrozenPatternPrev)',
    \   '<Leader>/f', 'f', 'frozen', 'Freeze current search pattern', ':SearchFreeze [/{pattern}/[{offset}]]',
    \	2,
    \   g:SearchFrozenPattern#SearchRepeatOptions
    \)
catch /^Vim\%((\a\+)\)\=:E117:/	" catch error E117: Unknown function
endtry

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
