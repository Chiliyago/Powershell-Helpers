

function Get-PathVariables() {
   <#
    .SYNOPSIS
        Returns the items in your Environment PATH variable.
        Tests and reports the existance of each Path

    .EXAMPLE
        $vars = Get-PathVariables

        Write-Host "Original Environment Variables"
        $vars.OriginalEnvironmentVars

        Write-Host "Obsolete Variables"
        $vars.ObsoleteVars



    #>
	[Cmdletbinding()]
	param
	(

	)
	begin {

	}

	process {
		$origPath = $ENV:PATH

        $sortedPath = $origPath.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries) | Select-Object -Unique | Sort-Object ;

		[System.Collections.ArrayList]$pathItems = New-Object System.Collections.ArrayList($null)

		$i = 0;
		$sortedPath | ForEach-Object {

			$obj = [PSCustomObject]@{
				Exists     = (Test-Path -Path $_);
				FolderPath = $_;
			}

			$pathItems.Add( $obj ) | Out-Null;


			$i++;
		}




        if ($Update) {
            Write-Verbose "New Path String Length: `t`t" $final.Length;
            Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $final
        }

        $outObj = [PSCustomObject]@{
            OriginalEnvironmentVars = ($pathItems | Sort-Object FolderPath);
            ObsoleteVars = ($pathItems | Where-Object {$_.Exists -eq $false})

        }

        Write-Output $outObj

	}
}
