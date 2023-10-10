# Folder to monitor
$Path = "C:\test"

# Program to start
$Program = "C:\Program Files\Google\Chrome\Application\chrome.exe"

# Program arguments
$ProgramArguments = "https://github.com/bspiewa/file-monitor"

# Files to monitor
$FileFilter = "*.txt"

# List of file properties to monitor (e.g.: CreationTime, FileName, LastAccess, LastWrite)
$AttributeFilter = [System.IO.NotifyFilters]::LastWrite

# List of file changes to monitor (e.g.: All, Changed, Created, Deleted, Renamed)
$ChangeTypes = [System.IO.WatcherChangeTypes]::Changed

# Timeout for FileSystemWatcher object AND Interval for TimerFSW object to invoke FSW [in milliseconds]
$TimeStep = 1000

# FileSystemWatcher object to watch the folder
$watcher = New-Object -TypeName IO.FileSystemWatcher -ArgumentList "$Path", $FileFilter -Property @{
    IncludeSubdirectories = $false
    NotifyFilter = $AttributeFilter
}

# Setup GUI
[void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
$form1 = New-Object System.Windows.Forms.form
$NotifyIcon= New-Object System.Windows.Forms.NotifyIcon
$ContextMenu = New-Object System.Windows.Forms.ContextMenu
$EditMenuItem = New-Object System.Windows.Forms.MenuItem
$ExitMenuItem = New-Object System.Windows.Forms.MenuItem
$TimerFSW = New-Object System.Windows.Forms.Timer
$TrayIcon = New-Object System.Drawing.Icon("$PSScriptRoot\icon.ico")

# Make form window not visible
$form1.ShowInTaskbar = $false
$form1.WindowState = "minimized"

# Setup system tray Icon
$NotifyIcon.Icon = $TrayIcon
$NotifyIcon.ContextMenu = $ContextMenu
$NotifyIcon.ContextMenu.MenuItems.Add($EditMenuItem)
$NotifyIcon.ContextMenu.MenuItems.Add($ExitMenuItem)
$NotifyIcon.Visible = $True
$NotifyIcon.Text = "File Monitor"
$NotifyIcon.ShowBalloonTip(10000,"File Monitor started","Monitoring folder '$Path' for '$FileFilter' files changes",[System.Windows.Forms.ToolTipIcon]"Info")

# Setup Timer to run FileSystemWatcher in loop
$TimerFSW.Interval = $TimeStep
$TimerFSW.add_Tick({MonitorRun})
$TimerFSW.Start()

# Define Edit menu option
$EditMenuItem.Text = "Edit script"
$EditMenuItem.add_Click({notepad "$PSCommandPath" })

# Define Exit menu option
$ExitMenuItem.Text = "Exit"
$ExitMenuItem.add_Click({
    $TimerFSW.Stop()
    $watcher.Dispose()
    $NotifyIcon.Visible = $false
    $form1.Close()
})

# Function to be called by definied $ChangeTypes
function Invoke-ChangeAction {
    param (
        [Parameter(Mandatory)]
        [System.IO.WaitForChangedResult]
        $ChangeInformation
    )

    Write-Information "Change detected:"
    $ChangeString = Out-String -InputObject $ChangeInformation
    Write-Host $ChangeString
    Start-Process -FilePath "$Program" -ArgumentList $ProgramArguments
}

function MonitorRun {
    $result = $watcher.WaitForChanged($ChangeTypes, $TimeStep)
    if (-Not $result.TimedOut) { 
        $ProcessId = (Start-Process -FilePath "$Program" -ArgumentList $ProgramArguments -PassThru).Id
        $NotifyIcon.ShowBalloonTip(10000,"File change detected","Stared '$program' with PID=$ProcessId",[System.Windows.Forms.ToolTipIcon]"Warning")
    }
}

[void][System.Windows.Forms.Application]::Run($form1)
