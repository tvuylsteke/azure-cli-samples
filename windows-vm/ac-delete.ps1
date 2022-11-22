param($TestPath = "c:\temp")
# Get all data subfolders which contain extracterd artifacts
Start-transcript -IncludeInvocationHeader
Measure-Command {


#$TestPath = "c:\temp"
Write-verbose "Starting GCI"
$SubFolders = Get-ChildItem -Directory $TestPath
Write-host $TestPath
Write-verbose "Stopping GCI"
} | select @{n="time";e={$_.Minutes,"Minutes",$_.Seconds,"Seconds",$_.Milliseconds,"Milliseconds" -join " "}}



Measure-Command {



try {



foreach ($SubFolder in $SubFolders) {
try {
Write-Verbose "Removing folder $($SubFolder.FullName) ..."
Remove-Item $SubFolder.FullName -Force -Recurse
Write-Verbose "Creating empty folder..."
New-Item -ItemType Directory -Path $SubFolder.FullName
}
catch {
Write-host "Unable to archive folder: $($_.Exception.Message)"
}
}
}
catch {
Write-host $_.Exception.Message
}
finally {
Write-Host "Disconnecting..."
Write-Host "Finished!"
# Stop logging

}



} | select @{n="time";e={$_.Minutes,"Minutes",$_.Seconds,"Seconds",$_.Milliseconds,"Milliseconds" -join " "}}
Stop-Transcript -ErrorAction SilentlyContinue | Out-Null