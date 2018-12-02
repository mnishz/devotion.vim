" TODO: Vim global plugin for correcting typing mistakes
" Last Change:  2018/10/22
" Maintainer:   Masato Nishihata
" License:      This file is placed in the public domain.

if exists('g:loaded_devotion')
  finish
endif
let g:loaded_devotion = 1

let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

augroup devotion
  autocmd!
  autocmd BufEnter    * if g:devotion#IsTargetFile() | call g:devotion#BufEnter()    | endif
  autocmd BufLeave    * if g:devotion#IsTargetFile() | call g:devotion#BufLeave()    | endif
  autocmd BufUnload   * if g:devotion#IsTargetFile() | call g:devotion#BufUnload()   | endif
  autocmd InsertEnter * if g:devotion#IsTargetFile() | call g:devotion#InsertEnter() | endif
  autocmd InsertLeave * if g:devotion#IsTargetFile() | call g:devotion#InsertLeave() | endif
  autocmd FocusLost   * call g:devotion#FocusLost()    " check file in the function
  autocmd FocusGained * call g:devotion#FocusGained()  " check file in the function
  autocmd VimEnter    * call g:devotion#VimEnter()
  autocmd VimLeave    * call g:devotion#VimLeave()
augroup END

command! -nargs=+ DevotionRange call g:devotion#Range(<f-args>)
command! DevotionToday     call g:devotion#Today()
command! DevotionLastDay   call g:devotion#LastDay()
command! DevotionThisWeek  call g:devotion#ThisWeek()
command! DevotionLastWeek  call g:devotion#LastWeek()
command! DevotionThisMonth call g:devotion#ThisMonth()
command! DevotionLastMonth call g:devotion#LastMonth()
command! DevotionThisYear  call g:devotion#ThisYear()
command! DevotionLastYear  call g:devotion#LastYear()

let &cpo = s:save_cpo
unlet s:save_cpo
