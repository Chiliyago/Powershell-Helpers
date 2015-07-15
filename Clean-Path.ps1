
Function global:Clean-Path()
{
    [Cmdletbinding()]
    param
    (
        [parameter(Mandatory=$true, Position=0)]
        [bool]$Update
    )

    $origPath = $ENV:PATH

    $sortedPath = $origPath.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries) | Select-Object -Unique | Sort-Object ;
    $final = $sortedPath -join ";"

    Write-Host "Original Path String Length: `t" $origPath.Length;

    if($Update -eq $true){
        Write-Host "New Path String Length: `t`t" $final.Length;
        Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH –Value $final
    }
    Write-Host "---------------------------------------------------------------"


    [System.Collections.ArrayList]$pathItems = New-Object System.Collections.ArrayList($null)


    $i=0;
    $sortedPath | foreach{

     $info = @{};
     $info.Position = $i;
     $info.Exists = Test-Path -Path $_;
     $info.FolderPath = $_;
     $psInfoObj = New-Object -TypeName PSObject -Property $info;
     $pathItems.Add($psInfoObj) | Out-Null;

     
     $i++;
    }

    return $pathItems;
}