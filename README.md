# devotion.vim
It measures how much time you spend for Vim.
[日本語版]()は下のほうにあります。

# Overview
This plugin monitors your activitiy for Vim using autocommand-events and logs it for each file.
When you type any commmand, the total time is added up and echoed.
## Target
- Running time of Vim.
- View time of vim filetype.
- Edit time of vim filetype.
- View time of help filetype.
- Edit time of help filetype.
## Features
- Pure Vim script
- Stand-alone

# Screenshot

# How to use
1. Install this plugin using some plugin manager.
    - If you don't use plugin manager, `:h packages` will be helpful.
1. Edit vimrc or *.vim or read some help.
1. Type `:DevotionToday`
    - It shows how much time you spend today for Vim.

# Commands
- DevotionRange
    - It shows how much time you spend for Vim between *start_time* and *stop_time*.
    - Parameter format: %Y%m%d%H%M%S (Number)
    - Example: from 2018/12/31 12:34:56 to 2019/01/01 00:00:00. (stop_time is exclueded.)
        - `:DevotionRange 20181231123456 20190101000000`
- DevotionToday
    - It calls DevotionRange with today's 00:00:00 and tomorrows's 00:00:00.
- DevotionLastDay
    - It calls DevotionRange with 00:00:00 of the last day you use Vim and today's 00:00:00.
- DevotionThisWeek
    - Sunday of this week, sunday of next week
- DevotionLastWeek
    - Sunday of previous week, sunday of this week
- DevotionThisMonth
    - The first day of this month, the first day of next month
- DevotionLastMonth
    - The first day of previous month, the first day of this month
- DevotionThisYear
    - The first day of this year, the first day of next year
- DevotionLastYear
    - The first day of previous year, the first day of this year

# Sequence
See [autoload\devotion.vim]().

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
- Please let me know or create a pull request if there are improper expression or unnatural wording.
- Pull request to improve this plugin is also welcome! Thank you.

# 概要
## 対象
## 特徴
# スクリーンショット
# 使い方
# コマンド
# シーケンス
# オプション
# その他
