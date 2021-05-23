" Vimwiki support for having your wiki directory as a git repo.
" Last Change: 2021 May 23
" Maintainer: Mads Røskar <madshvero@gmail.com>

if exists("g:loaded_vimwiki_git")
  "finish
  echo "vimwiki git already loaded"
endif
let g:loaded_vimwiki_git = 1

" Options
"" Whether or not to show output of git commands in a new split
if !exists('g:vimwikigitsync_output_split')
  let g:vimwikigitsync_output_split = 1
endif

"" The wiki index
if !exists('g:vimwikigitsync_index')
  let g:vimwikigitsync_home = '~/vimwiki/index.wiki'
endif

" The directory in which the wiki is
if !exists('g:vimwikigitsync_wiki_dir')
  let g:vimwikigitsync_wiki_dir = '~/vimwiki'
endif

" Commit message to use
if !exists('g:vimwikigitsync_commit_msg')
  let g:vimwikigitsync_commit_msg = 'VimwikiGitSync automatic commit'
endif

" Code taken from
augroup vimwiki
  au! BufRead g:vimwikigitsync_index lcd g:vimwikigitsync_wiki_dir
  au BufRead g:vimwikigitsync_index !git pull
  au! BufWritePost g:vimwikigitsync_wiki_dir . '/*' silent call s:CommitAndPush()
augroup END

command! -nargs=0 VimwikiGit call s:cmd()

" Git pull from origin
function! s:GitPull()
  call s:esil('git pull origin master')
endfunction

" Function for the command to call commit and push
function! s:cmd()
  let l:result = s:CommitAndPush()

  if g:vimwikigitsync_output_split == 1
    call s:WriteOutputSplit(l:result)
  endif
endfunction

function s:WriteOutputSplit(outputList)
  let l:content = a:outputList
  call filter(l:content, {s -> s != ''})

  " Create a buffer and add output lines to it
  let l:name = '__VimwikiGitSync__'
  if bufwinnr(l:name) == -1
    execute 'split ' . l:name
  else
    execute bufwinnr(l:name) . 'wincmd w'
  endif
  " Clear all buffer data
  normal! gg"_dG
  set buftype=nofile
  call append(0, l:content)
endfunction

" Run commands to git commit and push, and returns list of output lines
function! s:CommitAndPush()
  let l:commit_msg = "Banana :)"

  let l:results = [
        \ s:esil('git add -A'),
        \ s:esil('git commit -m "' . g:vimwikigitsync_commit_msg . '"'),
        \ s:esil('git push origin master')
        \ ]

  return Flatten(l:results)

endfunction

" Run system command silently in the background
function s:esil(command)
  let l:cmd = a:command
  let result = system(l:cmd . ' &')
  return split(result, '\n')
endfunction

" Code by https://github.com/dahu
" Taken from https://gist.github.com/dahu/3322468
function! Flatten(list)
  let val = []
  for elem in a:list
    if type(elem) == type([])
      call extend(val, Flatten(elem))
    else
      call extend(val, [elem])
    endif
    unlet elem
  endfor
  return val
endfunction
