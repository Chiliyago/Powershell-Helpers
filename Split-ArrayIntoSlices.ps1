cls
$ids=@(0,1,2,3,4,5,6,7,8,9)
$size=3

<# 
Manual Selection:
    $ids | Select-Object -First 3 -Skip 0
    $ids | Select-Object -First 3 -Skip 3
    $ids | Select-Object -First 3 -Skip 6
    $ids | Select-Object -First 3 -Skip 9
#>

# Select via looping
$idx = 0
while ($($size * $idx) -lt $ids.Length){
    
    $group = $ids | Select-Object -First $size -skip ($size * $idx)
    $group -join ","
    $idx ++
} 

