<#

Auto folder organizer:
A daemon that periodically checks a folder for files with a specified extension
and puts them in a specific folder

Made by: discollizard

---
TODO: make it able to read a file with key-value pairs indicating which extensions go where
TODO: make it able to scan files by regex instead of extension
TODO: make it function with other time magnitudes other than minutes
---

usage: ado {.extension} {.source-folder} {.destination-folder} {interval-minutes}

example: ado .txt c:\users\amelia\desktop c:\users\amelia\documents\my_writings 10

#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = [System.Drawing.SystemIcons]::Application
$notifyIcon.Text = "Auto folder organizer"

$contextMenu = New-Object System.Windows.Forms.ContextMenu
$menuExit = New-Object System.Windows.Forms.MenuItem "Stop process"

$contextMenu.MenuItems.Add($menuExit)

$notifyIcon.ContextMenu = $contextMenu

$notifyIcon.Visible = $true

$menuExit.add_Click({
    $notifyIcon.Visible = $false
    $notifyIcon.Dispose()
    [System.Windows.Forms.Application]::Exit()
})

$username = $env:USERNAME 

while($True){
    [ System.Windows.Forms.Application ]::DoEvents()
    Get-ChildItem -Path $($args[1]) -Filter "*$($args[0])" | Move-Item -Destination $($args[2]) -Force
    Start-Sleep -Seconds $($args[3] * 60)
}



