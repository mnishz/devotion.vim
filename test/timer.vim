let s:suite = themis#suite('test for autoload/timer.vim')
let s:assert = themis#helper('assert')

let s:ERR_VALUE = 0.2 | lockvar s:ERR_VALUE

function! s:initialize_test() abort
  let l:timer = g:devotion#timer#Timer.New('test')
  call l:timer.Initialize(fnamemodify('test/timer.vim', ':p'))
  return l:timer
endfunction

function! s:check_result(value, expected, err_value) abort
  let l:min = a:expected - a:err_value
  let l:max = a:expected + a:err_value
  if (l:min <= a:value) && (a:value <= l:max)
    return 1
  else
    return 0
  endif
endfunction

function! s:suite.timer_start_stop_test() abort
  let l:timer = <SID>initialize_test()
  call l:timer.Start()
  sleep 1
  call l:timer.Stop()
  let l:expected = 1.0
  call s:assert.true(<SID>check_result(
        \ l:timer.GetElapsedTimeWoCheck(),
        \ l:expected, s:ERR_VALUE * l:expected))
endfunction

function! s:suite.timer_valid_suspend_test() abort
  let l:timer = <SID>initialize_test()
  call l:timer.Start()
  sleep 1
  call l:timer.SuspendIfNeeded()
  sleep 1
  call l:timer.RestartIfNeeded()
  sleep 1
  call l:timer.Stop()
  let l:expected = 2.0
  call s:assert.true(<SID>check_result(
        \ l:timer.GetElapsedTimeWoCheck(),
        \ l:expected, s:ERR_VALUE * l:expected))
endfunction

function! s:suite.timer_invalid_suspend_test() abort
  let l:timer = <SID>initialize_test()
  call l:timer.Start()
  sleep 1
  call l:timer.Stop()
  sleep 1
  call l:timer.SuspendIfNeeded()
  sleep 1
  call l:timer.RestartIfNeeded()
  sleep 1
  call l:timer.Start()
  sleep 1
  call l:timer.Stop()
  let l:expected = 2.0
  call s:assert.true(<SID>check_result(
        \ l:timer.GetElapsedTimeWoCheck(),
        \ l:expected, s:ERR_VALUE * l:expected))
endfunction
