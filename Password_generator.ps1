function Get-RandomPassword{
    [CmdletBinding()]
    Param(
       
        [Parameter()]
        [int]$PasswordLength=10,
        [Parameter()]
        [bool]$UpperCase=$true,
        [Parameter()]
        [bool]$LowerCase=$true,
        [Parameter()]
        [bool]$NumericCase=$false,
        [Parameter()]
        [bool]$SpecialCase=$false
)

    $charSet=$null

    if ($UpperCase){
        $upperCaseSet=(65..90) | foreach{[char] $_}
        $charSet+=$upperCaseSet
    }
    if ($LowerCase){
        $lowerCaseSet=(97..122) | foreach{[char] $_}     
        $charSet+=$lowerCaseSet
    }
    if ($NumericCase){
        Write-Output "HI"
        $numericSet=(48..57) | foreach{[char] $_}
        $charSet+=$numericSet
    }
    if ($SpecialCase){
        $specialSet=(33,35,36,37,38,42,63) | foreach{[char] $_}
        $charSet+=$specialSet
    }
    return -join(Get-Random -Count $PasswordLength -InputObject $charSet)

}

#Testing

Get-RandomPassword  -PasswordLength 50 -SpecialCase:$true
