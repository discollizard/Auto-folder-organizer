<#

Auto folder organizer:
A daemon that periodically checks a folder for files with a specified extension
and puts them in a specific folder

Made by: discollizard

---
TODO: never use powershell again
---

usage: ado {.extension} {.source-folder} {.destination-folder}

example: ado .txt c:\users\amelia\desktop c:\users\amelia\documents\my_writings

#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# $debugMode = $false
$debugMode = $true


# $transactions = if($(Get-Content .\settings.json))
$transactions = if([System.IO.File]::Exists(".\settings.json"))
 { Get-Content .\settings.json | ConvertFrom-Json }
 else 
 {
    Write-Host $args
    if ($args.Count -eq 3) 
        { 
            @(
                @{
                    "source" = $args[1];
                    "destination" = $args[2];
                    "term" = $args[0];
                }
            ) 
        }
    else 
        { throw "No settings.json file found nor enough arguments for a command line use `n example: ado {.extension} {.source-folder} {.destination-folder}" }
    }


$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = New-Object System.Drawing.Icon("./icon.ico")
$notifyIcon.Text = "Auto folder organizer"
$notifyIcon.Visible = $true

$contextMenu = New-Object System.Windows.Forms.ContextMenu
$menuExit = New-Object System.Windows.Forms.MenuItem "Stop process"

$contextMenu.MenuItems.Add($menuExit)

$menuExit.add_Click({    
    $notifyIcon.Visible = $false
    $notifyIcon.Dispose()
    [System.Windows.Forms.Application]::Exit()
})

$notifyIcon.ContextMenu = $contextMenu
$username = $env:USERNAME 

while($notifyIcon.Visible){
    [System.Windows.Forms.Application]::DoEvents()

    foreach($transaction in $transactions){
        try {
            Get-ChildItem -Path $($transaction.source) -Filter "*$($transaction.term)" | Move-Item -Destination $($transaction.destination) -Force
            if($debugMode){
                if($result){
                    Write-Output "Files transfered!: $($transaction.source), extension searched: $($transaction.term)"
                } else {
                    if($debugMode) {
                        Write-Output "Files not found: $($transaction.source), extension searched: $($transaction.term)"
                    }
                } 
            }
        }  catch [System.Management.Automation.ItemNotFoundException] {
            if($debugMode) {
                Write-Output $_
            }
        }
    }

    Start-Sleep -Seconds 3
}