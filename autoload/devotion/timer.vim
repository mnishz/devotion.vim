scriptencoding utf-8

" constants

let s:STATE_NOT_STARTED = 'not_started' | lockvar s:STATE_NOT_STARTED
let s:STATE_STARTED     = 'started'     | lockvar s:STATE_STARTED
let s:STATE_SUSPENDED   = 'suspended'   | lockvar s:STATE_SUSPENDED

" class

let g:devotion#timer#Timer = {
      \ 'timer_type': '',
      \ 'file_name': '',
      \ 'started_time': [],
      \ 'elapsed_time': 0.0,
      \ 'state': s:STATE_NOT_STARTED,
      \ }

function! g:devotion#timer#Timer.New(timer_type) abort
  let l:timer = copy(self)
  let l:timer.timer_type = a:timer_type
  return l:timer
endfunction

function! g:devotion#timer#Timer.Initialize(file_name) abort
  call g:devotion#log#LogTimerEvent(self, 'Initialize')
  if !empty(self.file_name)
    call g:devotion#log#LogUnexpectedState(self)
  endif
  call self.Clear()
  let self.file_name = a:file_name
endfunction

function! g:devotion#timer#Timer.Clear() abort
  call g:devotion#log#LogTimerEvent(self, 'Clear')
  if self.state != s:STATE_NOT_STARTED
    call g:devotion#log#LogUnexpectedState(self)
  endif
  let self.file_name = ''
  let self.elapsed_time = 0.0
  let self.state = s:STATE_NOT_STARTED
endfunction

function! g:devotion#timer#Timer.Start() abort
  call g:devotion#log#LogTimerEvent(self, 'Start')
  if !self.IsSameFileName()
    call g:devotion#log#LogUnexpectedState(self)
  else
    if self.state != s:STATE_NOT_STARTED
      call g:devotion#log#LogUnexpectedState(self)
    endif
    " continue regardless of state error for Start()
    let self.started_time = reltime()
    let self.state = s:STATE_STARTED
  endif
endfunction

function! g:devotion#timer#Timer.Stop() abort
  call g:devotion#log#LogTimerEvent(self, 'Stop')
  if !self.IsSameFileName() || (self.state != s:STATE_STARTED)
    call g:devotion#log#LogUnexpectedState(self)
  else
    " add only in normal case in contrast to Start()
    call self.CalcAndAddElapsedTime_()
    let self.state = s:STATE_NOT_STARTED
  endif
endfunction

function! g:devotion#timer#Timer.SuspendIfNeeded() abort
  call g:devotion#log#LogTimerEvent(self, 'Suspend')
  if !self.IsSameFileName() || (self.state == s:STATE_SUSPENDED)
    call g:devotion#log#LogUnexpectedState(self)
  else
    if self.state == s:STATE_NOT_STARTED
      " do nothing
    elseif self.state == s:STATE_STARTED
      " add only in normal case in contrast to Restart()
      call self.CalcAndAddElapsedTime_()
      let self.state = s:STATE_SUSPENDED
    endif
  endif
endfunction

function! g:devotion#timer#Timer.RestartIfNeeded() abort
  call g:devotion#log#LogTimerEvent(self, 'Restart')
  if !self.IsSameFileName()
    call g:devotion#log#LogUnexpectedState(self)
  else
    if self.state == s:STATE_STARTED
      call g:devotion#log#LogUnexpectedState(self)
    endif
    " continue regardless of state error for Restart()
    if self.state == s:STATE_NOT_STARTED
      " do nothing
    else
      let self.started_time = reltime()
      let self.state = s:STATE_STARTED
    endif
  endif
endfunction

function! g:devotion#timer#Timer.GetElapsedTime() abort
  call g:devotion#log#LogTimerEvent(self, 'GetElapsed')
  if !self.IsSameFileName()
    call g:devotion#log#LogUnexpectedState(self)
  else
    if self.state != s:STATE_NOT_STARTED
      call g:devotion#log#LogUnexpectedState(self)
    endif
    return self.elapsed_time
  endif
endfunction

function! g:devotion#timer#Timer.GetElapsedTimeWoCheck() abort
  return self.elapsed_time
endfunction

function! g:devotion#timer#Timer.GetTimerType() abort
  return self.timer_type
endfunction

function! g:devotion#timer#Timer.GetFileName() abort
  return self.file_name
endfunction

function! g:devotion#timer#Timer.GetState() abort
  return self.state
endfunction

function! g:devotion#timer#Timer.CalcAndAddElapsedTime_() abort
  let l:curr_elapsed_time = reltimefloat(reltime(self.started_time))
  if l:curr_elapsed_time >= 0.0
    let self.elapsed_time += l:curr_elapsed_time
  else
    call g:devotion#log#LogNegativeElapsedTime(string(l:curr_elapsed_time))
  endif
endfunction

function! g:devotion#timer#Timer.IsSameFileName() abort
  if !empty(self.file_name) && (self.file_name ==# g:devotion#GetEventBufferFileName())
    return v:true
  elseif (self.timer_type ==# 'vim') && (self.file_name ==# 'Vim')
    return v:true
  else
    return v:false
  endif
endfunction

lockvar g:devotion#timer#Timer
