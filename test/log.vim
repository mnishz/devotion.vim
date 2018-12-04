let s:suite = themis#suite('test for autoload/log.vim')
let s:assert = themis#helper('assert')

let s:file_name = fnamemodify('test/log.vim', ':p')

function! s:suite.before_each() abort
  let l:log_files = glob(g:devotion#log_file . '*', v:true, v:true)
  for log_file in l:log_files
    call delete(log_file)
  endfor
endfunction

function! s:suite.log_empty_test() abort
  let l:result = g:devotion#log#AddUpElapsedTime(19700101000000, 19700102000000)
  call s:assert.empty(l:result)
endfunction

function! s:suite.log_simple_test() abort
  let l:timer = g:devotion#timer#Timer.New('edit')
  call l:timer.Initialize(s:file_name)
  let l:timer.elapsed_time = 1.0
  call g:devotion#log#LogElapsedTime(l:timer, 20000101000000)

  let l:timer = g:devotion#timer#Timer.New('view')
  call l:timer.Initialize(s:file_name)
  let l:timer.elapsed_time = 2.0
  call g:devotion#log#LogElapsedTime(l:timer, 20000102000000)

  let l:timer = g:devotion#timer#Timer.New('vim')
  call l:timer.Initialize(s:file_name)
  let l:timer.elapsed_time = 4.0
  call g:devotion#log#LogElapsedTime(l:timer, 20000103000000)

  let l:result = g:devotion#log#AddUpElapsedTime(20000101000000, 20000102000000)
  " filetype is not set because actual autocmd does
  let l:expected = [{'file': s:file_name, 'filetype': '',
        \ 'vim': 0.0, 'edit': 1.0, 'view': 0.0, 'total': 1.0}]
  call s:assert.equals(l:result, l:expected)

  let l:result = g:devotion#log#AddUpElapsedTime(20000102000000, 20000103000000)
  let l:expected = [{'file': s:file_name, 'filetype': '',
        \ 'vim': 0.0, 'edit': 0.0, 'view': 2.0, 'total': 2.0}]
  call s:assert.equals(l:result, l:expected)

  let l:result = g:devotion#log#AddUpElapsedTime(20000103000000, 20000104000000)
  let l:expected = [{'file': s:file_name, 'filetype': '',
        \ 'vim': 4.0, 'edit': 0.0, 'view': 0.0, 'total': 4.0}]
  call s:assert.equals(l:result, l:expected)

  let l:result = g:devotion#log#AddUpElapsedTime(20000101000000, 20000104000000)
  let l:expected = [{'file': s:file_name, 'filetype': '',
        \ 'vim': 4.0, 'edit': 1.0, 'view': 2.0, 'total': 7.0}]
  call s:assert.equals(l:result, l:expected)

  let l:result = g:devotion#log#AddUpElapsedTime(19700101000000, 19700102000000)
  call s:assert.empty(l:result)

  let l:result = g:devotion#log#AddUpElapsedTime(21000101000000, 21000102000000)
  call s:assert.empty(l:result)
endfunction

function! s:suite.log_multi_file_test() abort
  let l:timer = g:devotion#timer#Timer.New('edit')
  call l:timer.Initialize(s:file_name)
  let l:timer.elapsed_time = 1.0
  call g:devotion#log#LogElapsedTime(l:timer, 20180101000000)
  let l:timer.elapsed_time = 2.0
  call g:devotion#log#LogElapsedTime(l:timer, 20180201000000)

  let l:result = g:devotion#log#AddUpElapsedTime(20170101000000, 20180101000000)
  call s:assert.empty(l:result)

  let l:result = g:devotion#log#AddUpElapsedTime(20180201000000, 20180301000000)
  let l:expected = [{'file': s:file_name, 'filetype': '',
        \ 'vim': 0.0, 'edit': 2.0, 'view': 0.0, 'total': 2.0}]
  call s:assert.equals(l:result, l:expected)

  let l:result = g:devotion#log#AddUpElapsedTime(20180101000000, 20180301000000)
  let l:expected = [{'file': s:file_name, 'filetype': '',
        \ 'vim': 0.0, 'edit': 3.0, 'view': 0.0, 'total': 3.0}]
  call s:assert.equals(l:result, l:expected)
endfunction

function! s:initialize_range_test() abort
  let l:timer = g:devotion#timer#Timer.New('edit')
  call l:timer.Initialize(s:file_name)
  let l:timer.elapsed_time = 1.0
  call g:devotion#log#LogElapsedTime(l:timer, 20180110000000)
  let l:timer.elapsed_time = 2.0
  call g:devotion#log#LogElapsedTime(l:timer, 20180120000000)
  let l:timer.elapsed_time = 4.0
  call g:devotion#log#LogElapsedTime(l:timer, 20180130000000)
endfunction

function! s:suite.log_range_1_test() abort
  call <SID>initialize_range_test()

  let l:result = g:devotion#log#AddUpElapsedTime(20180101000000, 20180105000000)
  call s:assert.empty(l:result)  " 1-1

  let l:result = g:devotion#log#AddUpElapsedTime(20180101000000, 20180110000000)
  call s:assert.empty(l:result)  " 1-2

  let l:result = g:devotion#log#AddUpElapsedTime(20180101000000, 20180115000000)
  let l:expected = [{'file': s:file_name, 'filetype': '',
        \ 'vim': 0.0, 'edit': 1.0, 'view': 0.0, 'total': 1.0}]
  call s:assert.equals(l:result, l:expected)  " 1-3-1
  let l:result = g:devotion#log#AddUpElapsedTime(20180101000000, 20180120000000)
  call s:assert.equals(l:result, l:expected)  " 1-3-2

  let l:result = g:devotion#log#AddUpElapsedTime(20180101000000, 20180125000000)
  let [l:expected[0].edit, l:expected[0].total] = [3.0, 3.0]
  call s:assert.equals(l:result, l:expected)  " 1-4-1
  let l:result = g:devotion#log#AddUpElapsedTime(20180101000000, 20180130000000)
  call s:assert.equals(l:result, l:expected)  " 1-4-2

  let l:result = g:devotion#log#AddUpElapsedTime(20180101000000, 20180201000000)
  let [l:expected[0].edit, l:expected[0].total] = [7.0, 7.0]
  call s:assert.equals(l:result, l:expected)  " 1-5
endfunction

function! s:suite.log_range_2_test() abort
  call <SID>initialize_range_test()

  let l:result = g:devotion#log#AddUpElapsedTime(20180110000000, 20180115000000)
  let l:expected = [{'file': s:file_name, 'filetype': '',
        \ 'vim': 0.0, 'edit': 1.0, 'view': 0.0, 'total': 1.0}]
  call s:assert.equals(l:result, l:expected)  " 2-2

  let l:result = g:devotion#log#AddUpElapsedTime(20180110000000, 20180120000000)
  call s:assert.equals(l:result, l:expected)  " 2-3-1
  let l:result = g:devotion#log#AddUpElapsedTime(20180110000000, 20180125000000)
  let [l:expected[0].edit, l:expected[0].total] = [3.0, 3.0]
  call s:assert.equals(l:result, l:expected)  " 2-3-2

  let l:result = g:devotion#log#AddUpElapsedTime(20180110000000, 20180130000000)
  call s:assert.equals(l:result, l:expected)  " 2-4

  let l:result = g:devotion#log#AddUpElapsedTime(20180110000000, 20180201000000)
  let [l:expected[0].edit, l:expected[0].total] = [7.0, 7.0]
  call s:assert.equals(l:result, l:expected)  " 2-5
endfunction

function! s:suite.log_range_3_test() abort
  call <SID>initialize_range_test()

  let l:result = g:devotion#log#AddUpElapsedTime(20180120000000, 20180125000000)
  let l:expected = [{'file': s:file_name, 'filetype': '',
        \ 'vim': 0.0, 'edit': 2.0, 'view': 0.0, 'total': 2.0}]
  call s:assert.equals(l:result, l:expected)  " 3-3

  let l:result = g:devotion#log#AddUpElapsedTime(20180120000000, 20180130000000)
  call s:assert.equals(l:result, l:expected)  " 3-4

  let l:result = g:devotion#log#AddUpElapsedTime(20180120000000, 20180201000000)
  let [l:expected[0].edit, l:expected[0].total] = [6.0, 6.0]
  call s:assert.equals(l:result, l:expected)  " 3-5
endfunction

function! s:suite.log_range_4_test() abort
  call <SID>initialize_range_test()

  let l:result = g:devotion#log#AddUpElapsedTime(20180130000000, 20180201000000)
  let l:expected = [{'file': s:file_name, 'filetype': '',
        \ 'vim': 0.0, 'edit': 4.0, 'view': 0.0, 'total': 4.0}]
  call s:assert.equals(l:result, l:expected)  " 4-4, 4-5
endfunction

function! s:suite.log_range_5_test() abort
  call <SID>initialize_range_test()

  let l:result = g:devotion#log#AddUpElapsedTime(20180201000000, 20180301000000)
  call s:assert.empty(l:result)  " 5-5
endfunction

function! s:suite.log_invaid_args_test() abort
  call <SID>initialize_range_test()

  let l:result = g:devotion#log#AddUpElapsedTime(20180110000000, 20180110000000)
  call s:assert.empty(l:result)
  let l:result = g:devotion#log#AddUpElapsedTime(20180120000000, 20180110000000)
  call s:assert.empty(l:result)
endfunction

function! s:suite.log_get_last_day_test() abort
  let l:timer = g:devotion#timer#Timer.New('edit')
  call l:timer.Initialize(s:file_name)
  let l:timer.elapsed_time = 1.0
  call g:devotion#log#LogElapsedTime(l:timer, 20180101000000)
  call g:devotion#log#LogElapsedTime(l:timer, 20180110000000)
  call g:devotion#log#LogElapsedTime(l:timer, 20180210000000)
  call g:devotion#log#LogElapsedTime(l:timer, 20180301000000)
  call s:assert.equals(g:devotion#log#GetLastDay(20180105000000), 20180101000000)
  call s:assert.equals(g:devotion#log#GetLastDay(20180120000000), 20180110000000)
  call s:assert.equals(g:devotion#log#GetLastDay(20180210000000), 20180110000000)
  call s:assert.equals(g:devotion#log#GetLastDay(20000101000000), 0)
endfunction
