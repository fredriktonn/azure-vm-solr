cls

New-Item "c:\install-log" -type Directory -force | Out-Null
$LogFile = "c:\install-log\install.log"

New-Item $solrRoot -type Directory -force | Out-Null
New-Item $nssmRoot -type Directory -force | Out-Null

"Changing ExecutionPolicy" | Out-File $LogFile -Append
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Install Choco
"Installing Chocolatey" | Out-File $LogFile -Append
Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

"Disabling UAC" | Out-File $LogFile -Append
Set-ItemProperty -path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -name EnableLua -value 0

#"Install each Chocolatey Package"
Set-Location C:\ProgramData\chocolatey\bin | Out-File $LogFile -Append
choco install solr --version 6.6.2 -y -force | Out-File $LogFile -Append
choco install nssm | Out-File $LogFile -Append

Set-Location C:\tools\solr-6.6.2\bin | Out-File $LogFile -Append
solr start | Out-File $LogFile -Append