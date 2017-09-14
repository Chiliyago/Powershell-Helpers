function Optimize-Partitions
{
	<#
	.SYNOPSIS
		 Will identify downstream folder partitions for folders that contains too many files.
		 Too many files is determined by the $MaxFolderSize param.

	.DESCRIPTION
		When you have a directory structure where down stream files are excessive you will want to
		partition that top-level directory in such a way that will reduce the number of files to
		a certain threshold.  That threshold is defined by the $MaxFolderSize parameter.

		You provide the path to that file with the $ReportFilePath parameter.


	.EXAMPLE
		PS C:\> <example usage>
		Explanation of what the example does
	.INPUTS
		This function will analyze the *_Reportcli.xml file created by the Get-FileCountRollup.
		Use the $ReportFilePath param to provide the full path to the *_Reportcli.xml file.
	.OUTPUTS
		Pipeline output of objects containing recomended partition locations.
	.NOTES
		This function is used in conjunction with Get-FileCountrollup.ps1.

	#>
	[CmdletBinding()]
	param (
		# Parameter help description
		[Parameter(
			Mandatory=$true,
			ParameterSetName="By clixml Report File",
			Position=0,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true,
			HelpMessage="The report clixml file generated the Get-FileCountrollup cmdlet")]
			[ValidateNotNullOrEmpty()]
			[string] $ReportFilePath,

		# This is the maximum number of downstream files allowed
		[Parameter(
				Mandatory=$false,
				ParameterSetName="By clixml Report File",
				Position=1,
				ValueFromPipeline=$false,
				ValueFromPipelineByPropertyName=$false,
				HelpMessage="Problem Folder Count Threshold. Default is 34000")]
				[ValidateNotNullOrEmpty()]
				[string] $MaxFolderSize = 34000,

		[Parameter(
			Mandatory=$false,
			ParameterSetName="By clixml Report File",
			Position=1,
			ValueFromPipeline=$false,
			ValueFromPipelineByPropertyName=$false,
			HelpMessage="Number of files each iteration will seek. Default is 2000")]
			[ValidateNotNullOrEmpty()]
			[string] $SeekResolution = 2000


	)

	begin {
		[System.Collections.ArrayList]$Report = New-Object System.Collections.ArrayList($null)
	}

	process {

		if(-not (Test-Path $ReportFilePath)){
			 Write-Error "No clixml file located at the provided ReportFilePath parameter."
		}else{
			 Write-Verbose "Importing clixml file: $ReportFilePath"
			 $FileCountRollups = (Import-Clixml -Path $ReportFilePath)
		}


		$problemFolders = $FileCountRollups | Where-Object {$_.DownStreamFiles -gt $MaxFolderSize } | Sort-Object Path
        
        if($problemFolders.Count -gt 0){

		    foreach ($problemFolder in $problemFolders){

			Write-Verbose ("Analyzing Problem Folder:" + $problemFolder.Path)
			$PartitionFound = $false

			# Start by grabbing all the DownStreamFiles and work our way down from there
			$grab = $problemFolder.DownStreamFiles

			do{
				 Write-Verbose ("Seeking folders with Downstream Count > " + $grab)

				 $subFldrs = $FileCountRollups | Where-Object -FilterScript {
					  $_.Path -ne $problemFolder.Path -and
					  $_.Path.Startswith($problemFolder.Path) -and
					  $_.DownStreamFiles -gt $grab
				 } | Sort-Object -Descending -Property DownStreamFiles

				 Write-Verbose ("`tRetreived " + (($subFldrs | Measure-Object).Count) + " subfolders")


				 if($subFldrs.Count -gt 0){

					  $partitionCalc = ($problemFolder.DownStreamFiles) - (($subFldrs | Measure-Object -Property DownStreamFiles -Sum).sum)

					  if($partitionCalc -le $MaxFolderSize){

							$PartitionFound = $true

							$obj = [PSCustomObject]@{
									ProblemFolder=$problemFolder.Path;
									ProblemFolderDownStreamFileCount = $problemFolder.DownStreamFiles
									PartitionReductionCount = $partitionCalc
									PartitionCount= $subFldrs.Count
									Partitions=$subFldrs}

						Write-Verbose ("Found partition set for problem folder: " + $problemFolder.Path)

						$Report.Add($obj) | Out-Null


					  }else{
							Write-Verbose "This partition set reduces the problem folder by $partitionCalc. Not enough!"
					  }

				} else{
					Write-Information "`tNo subfolders retreived."
				}


				$grab-= $SeekResolution

			}until(($PartitionFound -eq $true))

	  }
        
        }else{
            Write-Verbose "No folders found containing more than $MaxFolderSize downstream files."    
        }

	  Write-Output $Report
	}

	end {
	}
}

