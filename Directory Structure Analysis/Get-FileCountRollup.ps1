function Get-FileCountRollup
{
    <#
    .SYNOPSIS
        Starting with the top level folder this function will count all downstream files in each sub directory.
    .DESCRIPTION
    .EXAMPLE
        PS C:\> Get-FileCountRollup -RootFolder "\\share\C$\folder\\subfolder" -Verbose | Format-Table

        Use this format when you already ran it using -RootFolder option and have a report file
        to feed into it.

        PS C:\> Get-FileCountRollup -ReportFilePath 'C:SomeFolder_ReportCli.xml' -Verbose

        1) Will locate all folders below the provided root folder and count all downstream files.
        Those list of folders analyzed will be written to a clixml file with the same name suffixed by _SubFolderList.

        2) Will count the files in each folder as well as all files in all subfolders below it.

        The final report file will be written to a clixml file with the same name suffixed by _Report.


    .INPUTS
        $RootFolder is the starting point from wich the recursion will begin.
    .OUTPUTS
        *_SubFolderList.xml is a clixml file containing all folders analyzed
        *_Reportcli.xml is a clixml file containing the all analyzed folders including file counts

        Pipeline output will be a list of folders, a count files in folder, and finally a count of all downstream files as shown below.

        FileCount DownStreamFiles Path
        --------- --------------- ----
        12              28        \\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\ADMIN\1 Weekly updates\Archieve
        10              10        \\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\ADMIN\1 Weekly updates\Archieve\Completed
        6               6         \\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\ADMIN\1 Weekly updates\Archieve\Statistic

    .NOTES
        General notes
    #>

    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$true,
            ParameterSetName="By Root Folder",
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Starting folder from which to begin the analysis")]
            [ValidateNotNullOrEmpty()]
            [string] $RootFolder,

        [Parameter(
            Mandatory=$true,
            ParameterSetName="By clixml Report File",
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The report clixml file generated from a prior execution of this cmdlet")]
            [ValidateNotNullOrEmpty()]
            [string] $ReportFilePath

    )

    begin{
        [System.Collections.ArrayList]$ReportInfo = New-Object System.Collections.ArrayList($null)
    }

    process{

        if($ReportFilePath){
            if(-not (Test-Path $ReportFilePath)){
                Write-Error "No clixml file located at the provided ReportFilePath parameter."
            }else{
                Write-Verbose "Importing clixml file: $ReportFilePath"
                $ReportInfo = (Import-Clixml -Path $ReportFilePath)
            }
        }

        # Perform scan of Directory Structure
        if($RootFolder){
            # Retreive the name portion of the full path
            $outFileName = $RootFolder.Split("\")[-1]

            Write-Verbose "Retreiving all sub-folder paths below: $RootFolder"
            $subFolders = Get-ChildItem $rootFolder -Recurse -Directory | Select-Object -ExpandProperty FullName

             # Adding the root folder to the collection because it is not included in Get-ChildItem cmdltet above
            $subFolders+= ((Get-Item $rootFolder | Select-Object -ExpandProperty FullName) + "\")


            $FolderListFileName = ($outFileName + "_SubFolderList.xml")
            Write-Verbose "Exporting sorted list of sub-folders to: $FolderListFileName"
            $subFolders | Sort-Object $_ | Export-Clixml $FolderListFileName -Force


            Write-Verbose "Retreiving files from all downstream folders... Warning: This may take a while depending how deep the search goes!"
            $folderFiles = Get-ChildItem -Path $subFolders -File

            Write-Verbose "Counting files by folder"
            $GroupdFolders = $folderFiles | Group-Object Directory |
                Select-Object   @{Name="FileCount";Expression={$_.count}}, `
                                @{Name="Folder";Expression={$_.name}}

            Write-Verbose "Counting downstream files per folder."
            foreach($GroupFldr in $GroupdFolders){

                # Recursivly Count of downstream files
                $childFileCount = (($GroupdFolders | Where-Object {$_.Folder.StartsWith($GroupFldr.Folder)}) | Measure-Object -Property FileCount -Sum).Sum

                # Create PSObject with the following properties and add to $ReportInfo
                $obj = [PSCustomObject]@{
                    FileCount=$GroupFldr.FileCount;
                    DownStreamFiles= $childFileCount;
                    Path=$GroupFldr.Folder}

                $obj.PSObject.TypeNames.Insert(0,'Directory.Structure.File.Count.Rollup')

                $ReportInfo.Add($obj) | Out-Null

            }

            $ReportFileName = ($outFileName + "_ReportCli.xml")
            Write-Verbose "Exporting report to: $ReportFileName"
            $ReportInfo | Export-Clixml $ReportFileName
        }

        $ReportInfo | Sort-Object path | Write-Output

    }

    end {
        #No post-processing required
    }


}



