param($TestPath = "c:\temp")

$numberOfDirs = 20000 #20000
$numberOfFilesPerDir = 2
Measure-Command {
	for ($i=0;$i -lt $numberOfDirs; $i++){
		#write-host $i
		if(!(Test-Path -Path "$TestPath\Folder$i" )){
			New-Item -ItemType Directory -Path $TestPath -Name "Folder$i"
		}		
		for  ($j=0;$j -lt $numberOfFilesPerDir; $j++){
			New-Item -ItemType File -Path "$TestPath\Folder$i\file$j.txt"
		}
	}
} | select @{n="time";e={$_.Minutes,"Minutes",$_.Seconds,"Seconds",$_.Milliseconds,"Milliseconds" -join " "}}


