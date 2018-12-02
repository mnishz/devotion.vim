# devotion.vim
It measures how much time you spend on Vim.  
[日本語版](https://github.com/mnishz/devotion.vim#%E6%A6%82%E8%A6%81)は下のほうにあります。

# Overview
This plugin monitors your activitiy for Vim using autocommand-events and logs it for each file.
When you type any commmand, the total time is added up and echoed.
## Monitoring file
- Running time of Vim.
- View (normal mode) time of vim filetype.
- Edit (insert mode) time of vim filetype.
- View (normal mode) time of help filetype.
- Edit (insert mode) time of help filetype.
## Features
- Pure Vim script
- Stand-alone

# Screenshot
![screenshot](https://raw.github.com/wiki/mnishz/devotion.vim/images/screenshot.png)

# How to use
1. Install this plugin using some plugin manager.
    - If you don't use plugin manager, `:h packages` will be helpful.
1. Edit vimrc or *.vim or read some help.
1. Type `:DevotionToday`
    - It shows how much time you spend on Vim today.

# Commands
- DevotionRange
    - It shows how much time you spend on Vim between *start_time* and *stop_time*.
    - Parameter format: %Y%m%d%H%M%S (Number)
    - Example: from 2018/12/31 12:34:56 to 2019/01/01 00:00:00. (stop_time itself is exclueded.)
        - `:DevotionRange 20181231123456 20190101000000`
- DevotionToday
    - It calls DevotionRange with today's 00:00:00 and tomorrow's 00:00:00.
- DevotionLastDay
    - It calls DevotionRange with 00:00:00 of the last day you use Vim and today's 00:00:00.
- DevotionThisWeek
    - From sunday of this week to sunday of next week
- DevotionLastWeek
    - From sunday of previous week to sunday of this week
- DevotionThisMonth
    - From the first day of this month to the first day of next month
- DevotionLastMonth
    - From the first day of previous month to the first day of this month
- DevotionThisYear
    - From the first day of this year to the first day of next year
- DevotionLastYear
    - From the first day of previous year to the first day of this year

# Monitoring flow
See [autoload\devotion.vim](https://github.com/mnishz/devotion.vim/blob/988a4ef08f48f8add8f3939d86bdcb486ee6e4f7/autoload/devotion.vim#L147).

# Options
- g:devotion#log_file
    - Path and name of log files.
    - Default: ~/.local/share/devotioin/devotion_log_YYYYMM
- g:devotion#debug_enabled
    - Logs for debugging if v:true.
    - Default: v:false

# TODOs
## High
- [ ] Add test!
- [ ] Set debug flag to v:false.
## Mid
- [ ] Add vim style document.
- [ ] Write out all logs at some interval.
- [ ] Improve event detection method.
## Low
- [ ] Loss of trailing digits

# Misc.
- Pull request to improve this plugin or wording is welcome! I'd like to know more effective Vim script coding. Thank you.

# 概要
あなたが .vimrc 弄りに~~費やした~~捧げた時間を測ってくれるプラグインです。
その他にも Vim script や help を参照、編集していた時間も測ります。
各ファイルごとに参照時間、編集時間を測りログに残します。
各コマンドを実行することでログからそれぞれの時間を計算し、表示します。
## 監視対象ファイル
## 特徴
# スクリーンショット
# 使い方
# コマンド
# 監視フロー
# オプション
# その他
