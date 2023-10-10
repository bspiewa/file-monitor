# File Monitor

PowerShell script running in Windows system tray launching executable at specified file-based trigger

## Installation

- Clone repository to desired location (for example run git clone https://github.com/bspiewa/file-monitor from `C:\` directory or copy  `file_monitor.ps1` and `icon.ico` files to `C:\file-monitor`)
- Configure settings in the script as you wish
- Create shortcut with following settings:
  - *Target*: `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -File C:\file-monitor\file_monitor.ps1`
  - *Start in*: `C:\file-monitor`
  - *Run*: `Minimized`

## Usage

- Run the script from shorcut - script icon will appear in system tray with options "Edit script" and "Exit".
- You can also add shortcut to your startup settings `shell:startup`

## Script test

Change any .txt file in directory `C:\test`. Google Chrome page will appear pointing to this repository page

## Author

Bartosz Spiewak (@bspiewa)
