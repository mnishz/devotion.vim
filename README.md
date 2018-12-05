# devotion.vim
~~This plugin monitors how much time you spend on vimrc editing at work~~.  
This plugin measures how much you devote your time to Vim.  
[日本語版](https://github.com/mnishz/devotion.vim#%E6%A6%82%E8%A6%81)は下のほうにあります。

# Overview
This plugin monitors your activitiy for Vim using autocommand-events and logs it for each file.
When you type any commmand, the total time is added up and echoed.
## Monitoring file
- Running time of Vim.
- View (normal mode) time of "vim" filetype including vimrc.
- Edit (insert mode) time of "vim" filetype including vimrc.
- View (normal mode) time of "help" filetype.
- Edit (insert mode) time of "help" filetype.
## Features
- Pure Vim script
- Stand-alone

# Screenshot
![screenshot](https://raw.github.com/wiki/mnishz/devotion.vim/images/screenshot.png)

# How to use
1. Install this plugin using some plugin manager.
    - If you don't use plugin manager, `:h packages` will be helpful.
1. Edit vimrc or \*.vim (Vim script) file or read some help.
1. Type `:DevotionToday`
    - It shows how much time you spend on Vim today.

# Commands
- DevotionRange
    - It shows how much time you spend on Vim between *start_time* and *stop_time*.
    - Parameter format: %Y%m%d%H%M%S (Number)
    - Example: from 2018/12/31 12:34:56 to 2019/01/01 00:00:00. (*stop_time* itself is exclueded.)
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
- g:devotion#log\_file
    - Path and name of log files.
    - Default: $XDG\_DATA\_HOME/devotioin/devotion\_log (use '~/.local/share' if $XDG\_DATA\_HOME is empty)
- g:devotion#debug\_enabled
    - Logs for debugging if v:true.
    - Default: v:false

# TODOs
## High
- [x] Add test!
- [ ] Improve test
- [ ] Travis CI
- [ ] License
## Mid
- [ ] Add vim style document.
- [ ] Write out all logs at some interval.
- [ ] Improve event detection method.
## Low
- [ ] Loss of trailing digits

# Misc.
- Pull request to improve this plugin or English wording/expression of the document is welcome! I'd like to know more effective Vim script coding. Thank you.

# 概要
あなたが vimrc 弄りに~~費やしてしまった~~捧げた時間を測ってくれるプラグインです。
その他にも Vim script や help を参照、編集していた時間も測ります。
各ファイルごとに参照時間、編集時間を測りログに残します。
各コマンドを実行することでログからそれぞれの時間を計算し、表示します。
## 監視対象ファイル
- Vim の実行時間
- "vim" ファイルタイプ (vimrc 含む) の参照 (ノーマルモード) 時間
- "vim" ファイルタイプ (vimrc 含む) の編集 (挿入モード) 時間
- "help" ファイルタイプの参照 (ノーマルモード) 時間
- "help" ファイルタイプの編集 (挿入モード) 時間
## 特徴
- Pure Vim script
- スタンドアローン

# スクリーンショット
[Screenshot](https://github.com/mnishz/devotion.vim#screenshot) を参照

# 使い方
1. プラグインマネージャか何かを使って devotion.vim をインストールします。
    - プラグインマネージャを使っていない場合は、`:h packages` が参考になると思います。
1. vimrc や \*.vim (Vim スクリプト) ファイルを編集、もしくはヘルプを読みます。
1. `:DevotionToday` と入力します。
    - 今日どれくらいの時間を Vim のために捧げたか表示します。

# コマンド
- DevotionRange
    - 2 つの引数 *start_time* および *stop_time* を持ち、この間に費やした時間を表示します。
    - 引数フォーマット: %Y%m%d%H%M%S (数値)
    - 例: 2018/12/31 12:34:56 から 2019/01/01 00:00:00 まで (*stop_time* 自身は含まれません。)
        - `:DevotionRange 20181231123456 20190101000000`
- DevotionToday
    - 今日の 00:00:00 および明日の 00:00:00 で DevotionRange を呼び出します。
- DevotionLastDay
    - 最後に Vim を使った日の 00:00:00 および今日の 00:00:00 で DevotionRange を呼び出します。
- DevotionThisWeek
    - 今週の日曜日から来週の日曜日まで
- DevotionLastWeek
    - 先週の日曜日から今週の日曜日まで
- DevotionThisMonth
    - 今月の最初の日から来月の最初の日まで
- DevotionLastMonth
    - 先月の最初の日から今月の最初の日まで
- DevotionThisYear
    - 今年の最初の日から来年の最初の日まで
- DevotionLastYear
    - 昨年の最初の日から今年の最初の日まで

# 監視フロー
[autoload\devotion.vim](https://github.com/mnishz/devotion.vim/blob/master/autoload/devotion.vim#L147) を参照

# オプション
- g:devotion#log\_file
    - ログファイルのパスおよびファイル名
    - 初期値: $XDG\_DATA\_HOME/devotioin/devotion\_log ($XDG\_DATA\_HOME が空の場合は '~/.local/share')
- g:devotion#debug\_enabled
    - v:true の場合、デバッグ用のログを出力する。
    - 初期値: v:false

# TODOs
[英語版](https://github.com/mnishz/devotion.vim#todos) を参照

# その他
Vim script のより良い書き方を学びたいので改善点などあればプルリクエスト歓迎です。英訳や言葉遣いに関しても不自然な点があればご指摘いただけると嬉しいです。
