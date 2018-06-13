cls

New-Item "c:\install-log" -type Directory -force | Out-Null
$LogFile = "c:\install-log\JDScript.log"

# Get username/password & machine name
$userName = "artifactInstaller"
[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
$password = $([System.Web.Security.Membership]::GeneratePassword(12,4))
$cn = [ADSI]"WinNT://$env:ComputerName"

# Create new user
$user = $cn.Create("User", $userName)
$user.SetPassword($password)
$user.SetInfo()
$user.description = "Choco artifact installer"
$user.SetInfo()

# Add user to the Administrators group
$group = [ADSI]"WinNT://$env:ComputerName/Administrators,group"
$group.add("WinNT://$env:ComputerName/$userName")

# Create pwd and new $creds for remoting
$secPassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("$env:COMPUTERNAME\$($username)", $secPassword)

# Ensure that current process can run scripts. 
"Enabling remoting" | Out-File $LogFile -Append
Enable-PSRemoting -Force -SkipNetworkProfileCheck

"Changing ExecutionPolicy" | Out-File $LogFile -Append
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Install Choco
"Installing Chocolatey" | Out-File $LogFile -Append
$sb = { iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) }
Invoke-Command -ScriptBlock $sb -ComputerName $env:COMPUTERNAME -Credential $credential | Out-Null

"Disabling UAC" | Out-File $LogFile -Append
$sb = { Set-ItemProperty -path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -name EnableLua -value 0 }
Invoke-Command -ScriptBlock $sb -ComputerName $env:COMPUTERNAME -Credential $credential

#"Install each Chocolatey Package"
$command = "C:\ProgramData\chocolatey\bin\choco install solr --version 6.6.2 -y -force"
$command | Out-File $LogFile -Append
$sb = [scriptblock]::Create("$command")

# Use the current user profile
try
{
    Invoke-Command -ScriptBlock $sb -ComputerName $env:COMPUTERNAME -Credential $credential | Out-Null
}
catch
{
    $_.Exception | format-list -force | Out-File $LogFile -Append
}

$command = "cd C:\tools\solr-6.6.2\bin;solr start"
$command | Out-File $LogFile -Append
$sb = [scriptblock]::Create("$command")

try
{
    Invoke-Command -ScriptBlock $sb -ComputerName $env:COMPUTERNAME -Credential $credential | Out-Null
}
catch
{
    $_.Exception | format-list -force | Out-File $LogFile -Append
}

Disable-PSRemoting -Force

# Delete the artifactInstaller user
$cn.Delete("User", $userName)

# Delete the artifactInstaller user profile
gwmi win32_userprofile | where { $_.LocalPath -like "*$userName*" } | foreach { $_.Delete() }