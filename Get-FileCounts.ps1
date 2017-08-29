$rootFolder = "c:\temp"

Get-ChildItem $rootFolder `
    -Recurse -Directory | 
        Select-Object `
            FullName, `
            @{Name="FileCount";Expression={(Get-ChildItem $_ -File | 
        Measure-Object).Count }} 