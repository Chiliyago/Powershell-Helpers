# Directory File Structure Analysis Scripts

The scripts in this folder provide the ability to analyze deep directory
structures.

## Get-FileCountRollup
Use this function to  recurse all sub folders and count the number of
files in each folder as well as recursively count all files in all sub-folders beneath it!

This function will output the following to the file system and to the PowerShell Pipeline.

- ***_SubFolderList.xml** is a clixml file containing all folders analyzed

- ***_Reportcli.xml** is a clixml file containing the all analyzed folders including file counts

- **Pipeline** output will be a list of folders, a count files in folder, and finally a count of all downstream files as shown below.

FileCount|DownStreamFiles|Path
|---|---|---|
12|28|\\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\ADMIN\1 Weekly updates\Archieve
10|10|\\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\ADMIN\1 Weekly updates\Archieve\Completed
6|6|\\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\ADMIN\1 Weekly updates\Archieve\Statistic
1|29|\\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\ADMIN\1 Weekly updates

---


## Optimize-Partitions

Use this function after you use Get-FileCountRollup.  Get-FileCountRollup will output a clixml file using the name of the top level folder suffixed with  _Reportcli.  Feed that file into this function using the $ReportFilePath parameter.  Read the help in the function for details on the other two defaulted parameters.

```powershell
$optimzed =  Optimize-partitions -ReportFilePath 'C:\SomeReport_ReportCli.xml' -Verbose

# Get a count of the analyzed problem files
$optimized.Count

# Get the Optimization recommendation for the first problem files.
$optimized[0]


ProblemFolder                    : \\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\COUNTRIES
ProblemFolderDownStreamFileCount : 88108
PartitionReductionCount          : 30024
PartitionCount                   : 14
Partitions                       : {@{FileCount=8; DownStreamFiles=12711; Path=\\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\COUNTRIES\Archives}, @{FileCount=4;
                                   DownStreamFiles=6026; Path=\\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\COUNTRIES\ISRAEL}, @{FileCount=5; DownStreamFiles=5959;
                                   Path=\\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\COUNTRIES\TURKEY}, @{FileCount=4; DownStreamFiles=5063;
                                   Path=\\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\COUNTRIES\GHANA}...}

# Review all the partitions
$optimized[0].Partitions

FileCount DownStreamFiles Path
--------- --------------- ----
       29           13841 \\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\PERSONNEL\Former Personnel\Lorraine
       20           13532 \\ukuxbfs01\DeptDirs$\EMEA Product Regulatory Compliance\PERSONNEL\Former Personnel\Lorraine\Planning
```