" SearchFrozenPattern.vim: Freeze the current search pattern and keep searching for it.
"
" DEPENDENCIES:
"   - SearchRepeat.vim autoload script
"   - SearchSpecial.vim autoload script
"   - SearchSpecial/Offset.vim autoload script
"   - ingo/cmdargs/pattern.vim autoload script
"   - ingo/err.vim autoload script
"   - ingo/escape.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

let s:pattern = ''
let s:offset = ''

function! SearchFrozenPattern#Search( count, isBackward )
    if empty(s:pattern)
	if ! s:Freeze('')
	    return 0
	endif
    endif

    return s:Search(a:count, a:isBackward)
endfunction

function! SearchFrozenPattern#FreezeCommand( arguments )
    return (s:Freeze(a:arguments) ? s:Search(1, 0) : 0)
endfunction
function! SearchFrozenPattern#FreezeMapping()
    if s:Freeze('')
	echomsg printf('Search pattern /%s/ is now frozen', ingo#escape#OnlyUnescaped(@/, '/'))
	return 1
    endif

    return 0
endfunction


function! s:Freeze( arguments )
    if empty(a:arguments)
	if empty(@/)
	    call ingo#err#Set('No previous search pattern')
	    return 0
	endif

	let [s:pattern, s:offset] = [@/, '']
    else
	let [l:pattern, l:offset] = ingo#cmdargs#pattern#ParseUnescaped(a:arguments, '\(.*\)')
	if empty(l:pattern)
	    if empty(@/)
		call ingo#err#Set('No previous search pattern')
		return 0
	    endif
	    let [s:pattern, s:offset] = [@/, l:offset]
	else
	    let [s:pattern, s:offset] = [l:pattern, l:offset]
	endif
    endif

    " Integration into SearchRepeat.vim
    silent! call SearchRepeat#Set("\<Plug>(SearchFrozenPatternNext)", "\<Plug>(SearchFrozenPatternPrev)", 2, {'hlsearch': 0})

    return 1
endfunction

function! s:Search( count, isBackward )
    let [l:offsetSearchFlags, l:BeforeFirstSearchAction, l:AfterFinalSearchAction] = SearchSpecial#Offset#GetAction(s:offset)
    return SearchSpecial#SearchWithout(s:pattern, a:isBackward, '', 'frozen', '', a:count,
    \   {
    \       'isAutoOffset': 0,
    \       'additionalSearchFlags': l:offsetSearchFlags,
    \       'BeforeFirstSearchAction': l:BeforeFirstSearchAction,
    \       'AfterFinalSearchAction': l:AfterFinalSearchAction,
    \   }
    \)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
