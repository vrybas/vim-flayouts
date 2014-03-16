" flayouts.vim - Layouts for Fugitive
" Maintainer:   Vladimir Rybas <http://vrybas.github.io/>
" Version:      0.0.2

if exists('g:loaded_flayouts') || !executable('git') || &cp
  finish
endif
let g:loaded_flayouts = 1

if !exists('g:flayouts_base_branch')
  let g:flayouts_base_branch = 'origin/master'
endif

command GlstatusTab               call flayouts#StatusTab()
command Glcommit                  call flayouts#Commit()
command Glabort                   call flayouts#Abort()

command Glc                       call flayouts#Glc()

command -nargs=* GlpullRequestSummary    call flayouts#PullRequestSummary(<f-args>)
command -nargs=* GlpullRequestSummaryTab call flayouts#PullRequestSummaryTab(<f-args>)

command -nargs=* GlpullRequestCommits      call flayouts#PullRequestCommits(<f-args>)
command -nargs=* GlpullRequestCommitsTab   call flayouts#PullRequestCommitsTab(<f-args>)

command -nargs=* GllogPatch       call flayouts#LogPatch(<f-args>)
command -nargs=* GllogPatchTab    call flayouts#LogPatchTab(<f-args>)

command GlopenFromDiff            call flayouts#OpenFromDiff()

command GlresolveConflictTab      call flayouts#ConflictView()
command Glwrite                   call flayouts#Resolve()

function! flayouts#StatusTab()
  call flayouts#tabvsplit()
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

function! flayouts#Glc()
  if bufname('%') =~ 'COMMIT_EDITMSG'
    call flayouts#Commit()
  else
    call flayouts#StatusTab()
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

function! flayouts#PullRequestSummary(...)
  let head_branch = system("git rev-parse --abbrev-ref HEAD")
  let base_branch = exists('a:1') ? a:1 : g:flayouts_base_branch
  silent exe "Git! request-pull -p ".base_branch." ".head_branch
  setlocal modifiable
  silent exe '$-2,$d'
  silent exe '1,17d'
  let header = substitute('Summary of commits between "'.head_branch.'" and "'.base_branch.'"', "\n", "", "")
  call setline(1, header)
  setlocal nomodifiable
endfunction

function! flayouts#PullRequestSummaryTab(...)
  call flayouts#tabvsplit()
  call call(function("flayouts#PullRequestSummary"), a:000)
endfunction

function! flayouts#LogPatch(...)
  let filename = exists('a:1') ? a:1 : ''
  let number_of_commits = exists('a:2') ? a:2 : 100
  exe "Git! log -p --stat -".number_of_commits." ".filename
endfunction

function! flayouts#LogPatchTab(...)
  call flayouts#tabvsplit()
  call call(function("flayouts#LogPatch"), a:000)
endfunction

function! flayouts#PullRequestCommits(...)
  let base_branch = exists('a:1') ? a:1 : g:flayouts_base_branch
  let head_branch = substitute(system("git rev-parse --abbrev-ref HEAD"), "\n", "", "")

  exe "Git! log -p --reverse --stat ".base_branch."..".head_branch
endfunction

function! flayouts#PullRequestCommitsTab(...)
  call flayouts#tabvsplit()
  call call(function("flayouts#PullRequestCommits"), a:000)
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

function! flayouts#OpenFromDiff()
  mark z
  let chunk_start_line  = flayouts#chunk_start_line()
  let chunk_end_line    = flayouts#chunk_end_line()
  let chunk_filename    = flayouts#chunk_filename()
  exe "normal! 'z"

  only
  wincmd v
  wincmd h
  exe "e ".chunk_filename
  exe chunk_start_line
  mark a
  exe 'normal! '.chunk_end_line.'j'
  exe "normal! V'a"
endfunction

function! flayouts#chunk_start_line()
  call search('^@@','bc')
  call search('\d')
  exe "normal! vf,hy"
  return @0
endfunction

function! flayouts#chunk_end_line()
  exe "normal! f llf,lvf hy"
  return @0
endfunction

function! flayouts#chunk_filename()
  call search('+++','bc')
  exe "normal! 0f/lvg_y"
  return @0
endfunction

function! flayouts#tabvsplit()
  tabedit %
  tabmove
  wincmd v
  wincmd l
endfunction

" vim:set et sw=2:
