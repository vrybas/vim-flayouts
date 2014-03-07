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

command GldiffUnstaged     call flayouts#GitDiff('unstaged')
command GldiffStaged       call flayouts#GitDiff('staged')
command GlprDiff           call flayouts#PullRequestDiff()


function! flayouts#StatusView()
  tabedit %
  tabmove
  wincmd v
  wincmd l
  call flayouts#GitDiff('unstaged')
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

function! flayouts#GitDiff(type)
  let tmpfile = tempname()
  let diff_param = ""

  if a:type == 'staged'
    let diff_param = " --cached"
  endif

  silent execute 'r !git diff'.diff_param.' > '.tmpfile
  exe "e ".tmpfile
  setlocal bufhidden=wipe filetype=diff
endfunction

function! flayouts#PullRequestView()
  tabedit %
  tabmove
  wincmd v
  wincmd l
  call flayouts#PullRequestDiff()
endfunction

function! flayouts#PullRequestDiff()
  let tmpfile = tempname()
  silent exe '!git request-pull -p master $(git rev-parse --abbrev-ref HEAD) > '.tmpfile
  silent exe '!echo "                                          " >> '.tmpfile
  silent exe '!echo "All commits: =============================" >> '.tmpfile
  silent exe '!echo "                                          " >> '.tmpfile
  silent exe '!git log -p --stat --reverse $(git rev-parse --verify --quiet master)..$(git rev-parse --verify --quiet HEAD) >> '.tmpfile
  redraw!
  exe "e ".tmpfile
  setlocal bufhidden=wipe filetype=diff
endfunction

function! flayouts#ConflictView()
  tabedit %
  tabmove
  exe "Gdiff"
  only
  windo diffoff
  split
  vsplit
  buffer //2
  setlocal readonly nomodifiable
  wincmd l
  buffer //3
  setlocal readonly nomodifiable
  wincmd j
endfunction

function! flayouts#Resolve()
  exe "Gwrite"
  tabclose
endfunction

" vim:set et sw=2:
