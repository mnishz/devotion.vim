scriptencoding utf-8

" constants

let s:TIME_FOUND = 0  | lockvar s:TIME_FOUND
let s:TIME_UNDER = -1 | lockvar s:TIME_UNDER
let s:TIME_OVER  = -2 | lockvar s:TIME_OVER

" local utilities

function! s:TimeSearch(logs, time) abort
  if eval(a:logs[0]).t > a:time | return s:TIME_UNDER | endif
  if eval(a:logs[-1]).t < a:time | return s:TIME_OVER | endif

  " binary search for the first target timestamp
  let l:top_idx = -1
  let l:btm_idx = len(a:logs)
  while l:btm_idx - l:top_idx > 1
    let l:mid_idx = l:top_idx + (l:btm_idx - l:top_idx) / 2
    if eval(a:logs[l:mid_idx]).t >= a:time
      let l:btm_idx = l:mid_idx
    else
      let l:top_idx = l:mid_idx
    endif
  endwhile

  return l:btm_idx
endfunction

function! s:LoadLogFiles(start_time, stop_time) abort
  let l:logs = []
  let l:first_month = a:start_time[0:5]
  let l:last_month = a:stop_time[0:5]
  let l:files = sort(glob(g:devotion#log_file . '*', v:true, v:true))
  for file in l:files
    let l:file_month = file[-6:-1]
    if (l:first_month <= l:file_month) && (l:file_month <= l:last_month)
      let l:logs += readfile(file)
    endif
  endfor
  return l:logs
endfunction

" log related functions

function! g:devotion#log#LogElapsedTime(timer, curr_time) abort
  if !empty(a:timer.GetElapsedTime())
    let l:data = {
          \ 't':  a:curr_time,
          \ 'e':  a:timer.GetElapsedTime(),
          \ 'tt': a:timer.GetTimerType(),
          \ 'ft': g:devotion#GetEventBufferFileType(),
          \ 'f':  a:timer.GetFileName(),
          \}
    let l:split_file = g:devotion#log_file . '_' . a:curr_time[0:5]
    call writefile([string(l:data)], l:split_file, 'a')
  endif
endfunction

function! g:devotion#log#AddUpElapsedTime(start_time, stop_time) abort
  " this function adds up from start_time to stop_time, but excludes stop_time
  if a:start_time < 19700101000000 | echo 'date should be 1970/01/01 or later' | return [] | endif
  if a:start_time >= a:stop_time | echo 'stop_time should be larger than start_time' | return [] | endif
  let l:logs = <SID>LoadLogFiles(a:start_time, a:stop_time)
  if empty(l:logs) | echo 'no log to load...' | return [] | endif
  let l:max_idx = len(l:logs) - 1
  let l:first_idx = <SID>TimeSearch(l:logs, a:start_time)
  let l:last_idx = <SID>TimeSearch(l:logs, a:stop_time)

  " code to exclude stop_time, ummmmmmm...
  " if we had a function to convert date/time -> Unix time, we wouldn't need
  " the following code...

  " no   start  stop   any entry  first  last
  " 1-1  UNDER  UNDER  not found
  " 1-2         0      not found
  " 1-3         MID    found      0      MID-1
  " 1-4         MAX    found      0      MAX-1
  " 1-5         OVER   found      0      MAX
  " 2-1  0      UNDER  N/A
  " 2-2         0      found      0      0
  " 2-3         MID    found      0      MID-1
  " 2-4         MAX    found      0      MAX-1
  " 2-5         OVER   found      0      MAX
  " 3-1  MID    UNDER  N/A
  " 3-2         0      N/A
  " 3-3         MID    found      MID    MID
  " 3-4         MAX    found      MID    MAX-1
  " 3-5         OVER   found      MID    MAX
  " 4-1  MAX    UNDER  N/A
  " 4-2         0      N/A
  " 4-3         MID    N/A
  " 4-4         MAX    found      MAX    MAX
  " 4-5         OVER   found      MAX    MAX
  " 5-1  OVER   UNDER  N/A
  " 5-2         0      N/A
  " 5-3         MID    N/A
  " 5-4         MAX    N/A
  " 5-5         OVER   not found

  " 5-1, 5-2, 5-3, 5-4
  if (l:first_idx == s:TIME_OVER) && (l:last_idx != s:TIME_OVER) | echoerr 'devotion N/A case' | endif
  " 2-1, 3-1, 3-2, 4-1, 4-2, 4-3
  if (l:first_idx >= s:TIME_FOUND) && (l:last_idx != s:TIME_OVER) && (l:first_idx > l:last_idx) | echoerr 'devotion N/A case' | endif

  let l:found = v:false
  " 2-2, 2-3, 2-4, 2-5, 3-3, 3-4, 3-5, 4-4, 4-5
  if l:first_idx >= s:TIME_FOUND | let l:found = v:true | endif
  " 1-3, 1-4, 1-5
  if (l:first_idx == s:TIME_UNDER) && ((l:last_idx > 0) || (l:last_idx == s:TIME_OVER))
    let l:found = v:true
  endif

  let l:first_idx = (l:first_idx == s:TIME_UNDER) ? 0 : l:first_idx
  if l:last_idx == s:TIME_OVER  " 1-5, 2-5, 3-5, 4-5
    let l:last_idx = l:max_idx
  elseif l:first_idx == l:last_idx  " 2-2, 3-3, 4-4
    let l:last_idx = l:first_idx
  else
    let l:last_idx -= 1
  endif

  let l:result_list = []
  if l:found
    let l:NOT_FOUND = -1 | lockvar l:NOT_FOUND
    for log_str_line in l:logs[l:first_idx:l:last_idx]
      let l:log_dict = eval(log_str_line)
      let l:result_idx = l:NOT_FOUND
      for idx in range(len(l:result_list))
        if l:result_list[idx].file ==# l:log_dict.f
          let l:result_idx = idx
          break
        endif
      endfor
      if l:result_idx == l:NOT_FOUND
        let l:result_list += [{
              \ 'file': l:log_dict.f,
              \ 'filetype': l:log_dict.ft,
              \ 'view': 0.0,
              \ 'edit': 0.0,
              \ 'vim': 0.0,
              \ 'total': 0.0
              \ }]
        let l:result_idx = -1  " assume it to be the last one
      endif
      " TODO: loss of trailing digits?
      let l:result_list[l:result_idx][l:log_dict.tt] += l:log_dict.e
      let l:result_list[l:result_idx].total += l:log_dict.e
    endfor
  endif

  return l:result_list
endfunction

function! g:devotion#log#GetLastDay(today) abort
  let l:last_day = 0
  let l:logs = []
  let l:files = sort(glob(g:devotion#log_file . '*', v:true, v:true))
  let l:file_found = v:false

  for idx in range(len(l:files) - 1, 0, -1)
    if l:files[idx][-6:-1] <= a:today[0:5]
      let l:logs = readfile(l:files[idx])
      if !empty(l:logs) && eval(l:logs[0]).t < a:today
        let l:file_found = v:true
        break
      endif
    endif
  endfor

  if l:file_found
    let l:idx = <SID>TimeSearch(l:logs, a:today)
    if l:idx == s:TIME_OVER
      let l:idx = len(l:logs) - 1
    elseif (l:idx == s:TIME_UNDER) || (l:idx == 0)
      echoerr 'unexpected index for the last day'
      return 0
    else
      let l:idx -= 1
    endif
    let l:last_day = eval(l:logs[l:idx]).t
    let l:last_day = l:last_day - (l:last_day % 1000000)
  endif

  return l:last_day
endfunction

function! g:devotion#log#LogAutocmdEvent(event, curr_time) abort
  if g:devotion#debug_enabled
    let l:data = a:event
    let l:data .= ' ' . a:curr_time
    let l:data .= ' ' . g:devotion#GetEventBufferFileName()
    call writefile([l:data], g:devotion#debug_file, 'a')
  endif
endfunction

function! g:devotion#log#LogTimerEvent(timer, function) abort
  if g:devotion#debug_enabled
    let l:data = '  ' . a:timer.GetTimerType() . ' ' . a:function . ' '
    let l:data .= a:timer.GetFileName() . ' ' . a:timer.GetState() . ' '
    let l:data .= string(a:timer.GetElapsedTimeWoCheck())
    call writefile([l:data], g:devotion#debug_file, 'a')
  endif
endfunction

function! g:devotion#log#LogUnexpectedState(timer) abort
  if g:devotion#debug_enabled
    call writefile(['    !!!! unexpected state !!!!'], g:devotion#debug_file, 'a')
    call writefile(['    ' . string(a:timer)], g:devotion#debug_file, 'a')
    echoerr 'devotion: unexpected state'
  endif
endfunction

function! g:devotion#log#LogNegativeElapsedTime(time) abort
  if g:devotion#debug_enabled
    call writefile(['    !!!! negative elapsed time ' . a:time . ' !!!!'], g:devotion#debug_file, 'a')
    echoerr 'devotion: negative elapsed time'
  endif
endfunction
