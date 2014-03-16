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

command -nargs=* GlpullRequest    call flayouts#PullRequest(<f-args>)
command -nargs=* GlpullRequestTab call flayouts#PullRequestTab(<f-args>)

command -nargs=* GllogPatch       call flayouts#LogPatch(<f-args>)
command -nargs=* GllogPatchTab    call flayouts#LogPatchTab(<f-args>)

command GllogPatchPr              call flayouts#LogPatchPr()
command GllogPatchPrTab           call flayouts#LogPatchPrTab()

command GlopenFromDiff            call flayouts#OpenFromDiff()

command GlresolveConflictTab      call flayouts#ConflictView()
command Glwrite                   call flayouts#Resolve()

function! flayouts#StatusTab()
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

function! flayouts#PullRequest(...)
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

function! flayouts#PullRequestTab(...)
  tabedit %
  tabmove
  wincmd v
  wincmd l
  call call(function("flayouts#PullRequest"), a:000)
endfunction

function! flayouts#LogPatch(...)
  let number_of_commits = exists('a:1') ? a:1 : 100
  exe "Git! log -p --stat -".number_of_commits." %"
endfunction

function! flayouts#LogPatchTab(...)
  if &filetype == 'git'
    let chunk_filename = flayouts#chunk_filename()
    wincmd s
    wincmd j
    exe "e ".chunk_filename
  else
    tabedit %
    tabmove
    wincmd v
    wincmd l
  end

    call call(function("flayouts#LogPatch"), a:000)
endfunction

function! flayouts#LogPatchPr()
  let base_branch = exists('a:1') ? a:1 : g:flayouts_base_branch
  let head_branch = substitute(system("git rev-parse --abbrev-ref HEAD"), "\n", "", "")

  exe "Git! log -p --stat ".base_branch."..".head_branch." %"
endfunction


function! flayouts#LogPatchPrTab()
  if &filetype == 'git'
    let chunk_filename = flayouts#chunk_filename()
    wincmd s
    wincmd j
    exe "e ".chunk_filename
  else
    tabedit %
    tabmove
    wincmd v
    wincmd l
  end

  call flayouts#LogPatchPr()
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
  let chunk_filename    = flayouts#chunk_filename()
  let chunk_start_line  = flayouts#chunk_start_line()
  let chunk_end_line    = flayouts#chunk_end_line()

  wincmd h
  exe "e ".chunk_filename
  exe chunk_start_line
  mark a
  exe 'normal! '.chunk_end_line.'j'
  exe "normal! V'a"
endfunction

function! flayouts#chunk_filename()
  call search('@@','bc')
  exe "normal! ma"
  call search('+++','bc')
  exe "normal! 0f/lvg_y"
  return @0
endfunction

function! flayouts#chunk_start_line()
  call search('\d')
  exe "normal! vf,hy"
  return @0
endfunction

function! flayouts#chunk_end_line()
  exe "normal! f llf,lvf hy"
  return @0
endfunction

" vim:set et sw=2:
