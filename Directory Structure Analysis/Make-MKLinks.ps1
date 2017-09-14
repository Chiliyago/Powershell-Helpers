cls

{
	. .\Optimize-Partitions.ps1
	$o = Optimize-Partitions -ReportFilePath "C:\_OneDrive\Personal\OneDrive\RDP\ShareXfer\EMEAShare-AllFolders with File Counts Report2.xml" -Verbose
}


[System.Collections.ArrayList]$mkLinks = New-Object System.Collections.ArrayList($null)
$localRoot = "C:\Users\svc_boxadmin\BoxSync\Regions\GRA"

foreach($result in $o){
	foreach($partition in $result.Partitions){
		$relativePath = $partition.Path.Split("$")[-1]

		$remotePath = $partition.Path

		$obj = [PSCustomObject]@{
			Path=$remotePath;
			NewMKlink = ("mklink /D '$localRoot$relativePath' '$remotePath'")
			RmMKlink = ("rmdir $localRoot$relativePath" )
			}

		$mkLinks.Add($obj) | Out-Null
	}
}

$mkLinks | Export-Csv Partitions.csv -Force
