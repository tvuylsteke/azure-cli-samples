#Source: https://raw.githubusercontent.com/TomHickling/WVD-CI-CD/master/GoldImage/InstallApps.ps1
#Script to download and install software onto a golden image with Azure DevOps

#Pack does this
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#Create temp folder
Write-Host "Creating Temp Folder"
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null

#Install VSCode
Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?Linkid=852157' -OutFile 'c:\temp\VScode.exe'
Invoke-Expression -Command 'c:\temp\VScode.exe /verysilent'

#Start sleep
Start-Sleep -Seconds 10

#InstallNotepadplusplus
Invoke-WebRequest -Uri 'https://notepad-plus-plus.org/repository/7.x/7.7.1/npp.7.7.1.Installer.x64.exe' -OutFile 'c:\temp\notepadplusplus.exe'
Invoke-Expression -Command 'c:\temp\notepadplusplus.exe /S'

#Start sleep
Start-Sleep -Seconds 10

#InstallFSLogix
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
Start-Sleep -Seconds 10
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Invoke-Expression -Command 'C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'

#Start sleep
Start-Sleep -Seconds 10

#InstallTeamsMachinemode
#https://www.masterpackager.com/blog/mst-to-install-microsoft-teams-msi-vdi-to-regular-windows-10
New-Item -Path 'HKLM:\SOFTWARE\Citrix\PortICA' -Force | Out-Null
#Maybe the above key is replace by: https://docs.microsoft.com/en-us/azure/virtual-desktop/teams-on-wvd
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Teams' -Force | Out-Null
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Teams -Name IsWVDEnvironment -PropertyType DWORD -Value 1

Invoke-WebRequest -Uri 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&download=true&managedInstaller=true&arch=x64' -OutFile 'c:\temp\Teams.msi'
Invoke-Expression -Command 'msiexec /i C:\temp\Teams.msi /quiet /l*v C:\temp\teamsinstall.log ALLUSER=1'
Start-Sleep -Seconds 30
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32 -Name Teams -PropertyType Binary -Value ([byte[]](0x01,0x00,0x00,0x00,0x1a,0x19,0xc3,0xb9,0x62,0x69,0xd5,0x01)) -Force