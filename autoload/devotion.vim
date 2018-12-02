scriptencoding utf-8

" variables

let s:devotion_dir = empty($XDG_DATA_HOME) ? '~/.local/share' : $XDG_DATA_HOME
let s:devotion_dir = expand(s:devotion_dir . '/devotion/')
if !isdirectory(s:devotion_dir) | call mkdir(s:devotion_dir, 'p') | endif

let g:devotion#log_file = expand(s:devotion_dir . 'devotion_log')
let g:devotion#debug_enabled = v:true
let g:devotion#debug_file = expand(s:devotion_dir . 'debug_log')

let s:vim_timer  = g:devotion#timer#Timer.New('vim')
let s:view_timer = g:devotion#timer#Timer.New('view')
let s:edit_timer = g:devotion#timer#Timer.New('edit')

let s:just_after_VimEnter = v:false  " workaround

" global utilities

function! g:devotion#GetEventBufferFileName() abort
  return expand('<afile>:p')
endfunction

function! g:devotion#GetEventBufferFileType() abort
  return getbufvar(str2nr(expand('<abuf>')), '&filetype')
endfunction

function! g:devotion#GetEventBufType() abort
  return getbufvar(str2nr(expand('<abuf>')), '&buftype')
endfunction

function! g:devotion#IsTargetFile() abort
  let l:bt = g:devotion#GetEventBufType()
  let l:ft = g:devotion#GetEventBufferFileType()
  if (empty(l:bt) || (l:bt ==# 'help')) && ((l:ft ==# 'vim') || (l:ft ==# 'help'))
    return v:true
  else
    return v:false
  endif
endfunction

" local utilities

function! s:CompareTotalTime(lhs, rhs) abort
  if a:lhs.total == a:rhs.total
    return 0
  elseif a:lhs.total < a:rhs.total
    return 1
  else
    return -1
  endif
endfunction

" command functions

function! g:devotion#Range(start_time, stop_time) abort
  let l:data = g:devotion#log#AddUpElapsedTime(a:start_time, a:stop_time)
  echo 'You devoted your following time to Vim between '
  echon a:start_time[0:3] . '/' . a:start_time[4:5] . '/' . a:start_time[6:7] . ' '
  echon a:start_time[8:9] . ':' . a:start_time[10:11] . ':' . a:start_time[12:13] . ' and '
  echon a:stop_time[0:3] . '/' . a:stop_time[4:5] . '/' . a:stop_time[6:7] . ' '
  echon a:stop_time[8:9] . ':' . a:stop_time[10:11] . ':' . a:stop_time[12:13] . ".\n"
  if empty(l:data)
    echo 'no entry...'
  else
    call sort(l:data, 's:CompareTotalTime')
    for entry in l:data
      if entry.file ==# 'Vim'
        echo entry.file
        " TODO: wording
        echo '  Opened: ' . string(entry.vim)
      else
        echo entry.file . ' (filetype: ' . entry.filetype . ')'
        echo '  Viewed: ' . string(entry.view)
        echo '  Edited: ' . string(entry.edit)
      endif
    endfor
  endif
endfunction

function! g:devotion#Today() abort
  let l:today = localtime()
  let l:tomorrow = l:today + (60 * 60 * 24)
  let l:today = eval(strftime('%Y%m%d000000', l:today))
  let l:tomorrow = eval(strftime('%Y%m%d000000', l:tomorrow))
  call g:devotion#Range(l:today, l:tomorrow)
endfunction

function! g:devotion#LastDay() abort
  let l:today = eval(strftime('%Y%m%d000000'))
  let l:last_day = g:devotion#log#GetLastDay(l:today)
  if l:last_day == 0 | echo 'no entry...' | return | endif
  call g:devotion#Range(l:last_day, l:today)
endfunction

function! g:devotion#ThisWeek() abort
  let l:today = localtime()
  let l:this_sunday = l:today - str2nr(strftime('%w', l:today)) * 60 * 60 * 24
  let l:next_sunday = l:this_sunday + 7 * 60 * 60 * 24
  let l:this_sunday = eval(strftime('%Y%m%d000000', l:this_sunday))
  let l:next_sunday = eval(strftime('%Y%m%d000000', l:next_sunday))
  call g:devotion#Range(l:this_sunday, l:next_sunday)
endfunction

function! g:devotion#LastWeek() abort
  let l:today = localtime()
  let l:this_sunday = l:today - str2nr(strftime('%w', l:today)) * 60 * 60 * 24
  let l:last_sunday = l:this_sunday - 7 * 60 * 60 * 24
  let l:last_sunday = eval(strftime('%Y%m%d000000', l:last_sunday))
  let l:this_sunday = eval(strftime('%Y%m%d000000', l:this_sunday))
  call g:devotion#Range(l:last_sunday, l:this_sunday)
endfunction

function! g:devotion#ThisMonth() abort
  let l:this_month = eval(strftime('%Y%m01000000'))
  if l:this_month[4:5] == 12
    let l:next_month = l:this_month + 10000000000 - 1100000000
  else
    let l:next_month = l:this_month + 100000000
  endif
  call g:devotion#Range(l:this_month, l:next_month)
endfunction

function! g:devotion#LastMonth() abort
  let l:this_month = eval(strftime('%Y%m01000000'))
  if l:this_month[4:5] == 1
    let l:last_month = l:this_month - 10000000000 + 1100000000
  else
    let l:last_month = l:this_month - 100000000
  endif
  call g:devotion#Range(l:last_month, l:this_month)
endfunction

function! g:devotion#ThisYear() abort
  let l:this_year = eval(strftime('%Y0101000000'))
  let l:next_year = l:this_year + 10000000000
  call g:devotion#Range(l:this_year, l:next_year)
endfunction

function! g:devotion#LastYear() abort
  let l:this_year = eval(strftime('%Y0101000000'))
  let l:last_year = l:this_year - 10000000000
  call g:devotion#Range(l:last_year, l:this_year)
endfunction

" autocmd functions
"
" autocmd event       vim_timer   view_timer   edit_timer
"
" VimEnter            Initialize
"                     Start
"                      |
" BufEnter             |          Initialize   Initialize
"                      |          Start
"                      |           |
" FocusLost           Suspend     Suspend
"                      *           *
" FocusGained         Restart     Restart
"                      |           |
" InsertEnter          |          Stop         Start
"                      |                        |
" FocusLost           Suspend                  Suspend
"                      *                        *
" FocusGained         Restart                  Restart
"                      |                        |
" EnsertLeave          |          Start        Stop
"                      |           |
" BufLeave/BufUnload   |          Stop/Log     Log
"                      |
" VimLeave            Stop/Log

function! g:devotion#BufEnter() abort
  call g:devotion#log#LogAutocmdEvent('BufEnter   ')
  call s:view_timer.Initialize(devotion#GetEventBufferFileName())
  call s:view_timer.Start()
  call s:edit_timer.Initialize(devotion#GetEventBufferFileName())
endfunction

function! g:devotion#BufLeave() abort
  call g:devotion#log#LogAutocmdEvent('BufLeave   ')
  call s:view_timer.Stop()
  call g:devotion#log#LogElapsedTime(s:view_timer)
  call g:devotion#log#LogElapsedTime(s:edit_timer)
  call s:view_timer.Clear()
  call s:edit_timer.Clear()
endfunction

function! g:devotion#BufUnload() abort
  call g:devotion#log#LogAutocmdEvent('BufUnload  ')
  " each case can happen, BufUnload might be a little irregular
  "   BufEnter -> BufLeave -> BufUnload
  "   BufEnter -> BufUnload for the target file
  "   BufEnter -> BufUnload for another file -> BufUnload for the target file
  " just check the file name
  if s:view_timer.IsSameFileName()
    call s:view_timer.Stop()
    call g:devotion#log#LogElapsedTime(s:view_timer)
    call s:view_timer.Clear()
  endif
  if s:edit_timer.IsSameFileName()
    call g:devotion#log#LogElapsedTime(s:edit_timer)
    call s:edit_timer.Clear()
  endif
endfunction

function! g:devotion#InsertEnter() abort
  call g:devotion#log#LogAutocmdEvent('InsertEnter')
  call s:view_timer.Stop()
  call s:edit_timer.Start()
endfunction

function! g:devotion#InsertLeave() abort
  call g:devotion#log#LogAutocmdEvent('InsertLeave')
  call s:view_timer.Start()
  call s:edit_timer.Stop()
endfunction

function! g:devotion#FocusLost() abort
  call g:devotion#log#LogAutocmdEvent('FocusLost  ')
  call s:vim_timer.SuspendIfNeeded()
  if g:devotion#IsTargetFile()
    call s:view_timer.SuspendIfNeeded()
    call s:edit_timer.SuspendIfNeeded()
  endif
endfunction

function! g:devotion#FocusGained() abort
  call g:devotion#log#LogAutocmdEvent('FocusGained')
  if !s:just_after_VimEnter  " workaround
    call s:vim_timer.RestartIfNeeded()
  else
    let s:just_after_VimEnter = v:false
  endif
  if g:devotion#IsTargetFile()
    call s:view_timer.RestartIfNeeded()
    call s:edit_timer.RestartIfNeeded()
  endif
endfunction

function! g:devotion#VimEnter() abort
  call g:devotion#log#LogAutocmdEvent('VimEnter   ')
  call s:vim_timer.Initialize('Vim')
  call s:vim_timer.Start()
  let s:just_after_VimEnter = v:true  " workaround
endfunction

function! g:devotion#VimLeave() abort
  call g:devotion#log#LogAutocmdEvent('VimLeave   ')
  call s:vim_timer.Stop()
  call g:devotion#log#LogElapsedTime(s:vim_timer)
  call s:vim_timer.Clear()
endfunction
