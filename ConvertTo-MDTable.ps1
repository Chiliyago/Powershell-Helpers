function ConvertTo-MDTable{
       <#
       .SYNOPSIS
           Convets serilized objects to Mark Down Table
       .DESCRIPTION
           Provide a clixml path and the objects will be converted to
           Mark-down table format
       .EXAMPLE
           PS C:\> ConvertTo-MDTable -CliXMLFilePath "1 Weekly updates_ReportCli.xml" -Verbose
           Explanation of what the example does
       .INPUTS
           csixml file of serialized object. Make sure the clixml is
           simple containing  only one type of object array
       .OUTPUTS
           mark down table
       .NOTES

       #>

       param(
        [Parameter(
            Mandatory=$true,
            ParameterSetName="By clixml Report File",
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="The report clixml file generated from a prior execution of this cmdlet")]
            [ValidateNotNullOrEmpty()]
            [string] $CliXMLFilePath
       )

       begin{
            if($CliXMLFilePath){
                if(-not (Test-Path $CliXMLFilePath)){
                    Write-Error "No clixml file located at the provided ReportFilePath parameter."
                }else{
                    Write-Verbose "Importing clixml file: $CliXMLFilePath"
                    $CliXML = (Import-Clixml -Path $CliXMLFilePath)
                }
            }

            Write-Verbose "Converting cliXml to pipe delimited csv"
            $csv = $CliXML | ConvertTo-Csv -Delimiter "|" -NoTypeInformation

            Write-Verbose "Removing all quotes"
            $csv = $csv -replace "`"",""

            Write-Verbose "Adding title underline"
            $colCount = $csv[0].Split("|").Count
            $underline = ( "|" + ("---|" * $colCount) )
            $csv += $underline

            Write-Verbose "Re-ording items down one position"
            for( $i=$csv.Count-1; $i -gt 0 ; $i-- ){

                if($i -gt 1){
                    Write-Verbose ("`tReplacing $i with $($i-1)")
                    $csv[$i]=$csv[$i-1]
                }
            }
            Write-Verbose "Adding title underline to position 1"
            $csv[1]=$underline

            Write-Output $csv
       }

       process{

       }

       end{

       }
}



<#
$csv = $xml | ConvertTo-Csv -Delimiter "|" -NoTypeInformation
$csv = $csv -replace "`"",""

$colCount = $csv[0].Split("|").Count
$underline = ("|" + ("---|"*3))
$csv += $underline
$csv

for( $i=$csv.Count-1; $i -gt 0 ; $i-- ){

    if($i -gt 1){
        Write-Host "Replacing $i with" ($i-1)
        $csv[$i]=$csv[$i-1]
    }
}
$csv[1]=$underline
$csv
#$csv += $underline
#$csv[1] = $csv[($csv.Count-1)]
#>