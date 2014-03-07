" flayouts.vim - Layouts for Fugitive
" Maintainer:   Vladimir Rybas <http://vrybas.github.io/>
" Version:      0.0.1

if exists('g:loaded_flayouts') || !executable('git') || &cp
  finish
endif
let g:loaded_flayouts = 1

command Glstatus           call flayouts#StatusView()
command Glcommit           call flayouts#Commit()
command Glabort            call flayouts#Abort()

command GlpullRequest      call flayouts#PullRequestView()
command GlresolveConflict  call flayouts#ConflictView()
command Glwrite            call flayouts#Resolve()

command GlprDiff           call flayouts#PullRequestDiff()
command GlopenFromDiff         call flayouts#DiffOpen()


function! flayouts#StatusView()
  tabedit %
  tabmove
  wincmd v
  wincmd l
  exe "Git! diff"
  wincmd h
  exe "Gstatus"
endfunction

function! flayouts#Commit()
  if bufname('%') =~ 'COMMIT_EDITMSG'
    exe "normal! ZZ"
    tabclose
  else
    echoerr "Warning: not a COMMIT_EDITMSG window. Run :Flstatus instead."
  endif
endfunction

function! flayouts#Abort()
  if &filetype == 'gitcommit'
    exe "normal! ZQ"
    tabclose
  else
    echoerr "Warning: not a 'git status' window."
  end
endfunction

function! flayouts#PullRequestView()
  tabedit %
  tabmove
  wincmd v
  wincmd l
  call flayouts#PullRequestDiff()
endfunction

function! flayouts#PullRequestDiff()
  exe "Git! request-pull -p master $(git rev-parse --abbrev-ref HEAD)"
endfunction

function! flayouts#ConflictView()
  tabedit %
  tabmove
  exe "Gsdiff"
  windo diffoff
  wincmd k
endfunction

function! flayouts#Resolve()
  exe "Gwrite"
  tabclose
  exe "Gstatus"
endfunction

function! flayouts#DiffOpen()
  call search('@@','bc')
  exe "normal! ma"
  call search('+++','bc')
  exe "normal! 0f/lvg_y"
  wincmd h
  let filename = @0
  exe "e ".filename
  wincmd l
  exe "normal! 'a0"
  call search('\d')
  "TODO: line number is not always copied. What if line don't contain ','
  exe "normal! vf,hy"
  wincmd h
  let linenumber = @0
  exe linenumber
  exe "Gblame"
  vertical resize 27
  wincmd l
  wincmd l
  exe "normal! f llf,lvf hy"
  wincmd h
  mark a
  let relative_line_number = @0
  exe 'normal! '.relative_line_number.'j'
  exe "normal! V'a\<esc>"
endfunction

function! flayouts#highlightArea()
  call search("\\%V\\_^","e")
  return @/
endfunction

" vim:set et sw=2:
