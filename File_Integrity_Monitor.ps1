Add-Type -AssemblyName System.Windows.Forms
function Add-FileToBaseline{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)] $baselinefilepath,
        [Parameter(Mandatory)] $TargetFilePath
    )
    try{
        if((Test-Path -Path $baselinefilepath) -eq $false) {
            Write-Error -Message "$($baselinefilepath) does not exist" -ErrorAction Stop
        }
        if((Test-Path -Path $TargetFilePath) -eq $false) {
            Write-Error -Message "$($TargetFilePath) does not exist" -ErrorAction Stop
        }

        $currentbaseline= Import-Csv -Path $baselinefilepath -Delimiter ","

        if ($TargetFilePath -in $currentbaseline.path) {
            
            do{
                $Overwrite = Read-Host -Prompt "File already exists, would you like to overwrite it [Y/N] : "
                if ($Overwrite -in @("Y", "Yes", 'y')){

                    Write-Output "file will be overwitten" 

                    $currentbaseline | Where-Object path -ne $TargetFilePath | Export-Csv -Path $baselinefilepath -Delimiter "," -NoTypeInformation

                    
                    $hash= Get-FileHash -Path $TargetFilePath

                    "$($TargetFilePath),$($hash.hash)"| Out-File -FilePath $baselinefilepath -Append

                    Write-Output "file added successfully into the baseline"

                }elseif ($Overwrite -in @("N", "No", 'n')) {

                    Write-Output "file will not be overwritten"

                }else{
                    Write-Output "Invalid entry, please enter 'Y' to overwrite or 'N' to not overwrite"
                }
        }while($Overwrite -notin @("Y", "Yes", 'y',"N", "No", 'n'))

        } else{

            $hash= Get-FileHash -Path $TargetFilePath

            "$($TargetFilePath),$($hash.hash)"| Out-File -FilePath $baselinefilepath -Append

            Write-Output "file added successfully into the baseline"
        }

        $currentbaseline= Import-Csv -Path $baselinefilepath -Delimiter ","
        $currentbaseline | Export-Csv -Path $baselinefilepath -Delimiter "," -NoTypeInformation
        
    }catch{
        Write-Error $_.Exception.Message
    }
}
function Verify-Baseline {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)] $baselinefilepath
    )   
    try{
        if((Test-Path -Path $baselinefilepath) -eq $false) {
            Write-Error -Message "$($baselinefilepath) does not exist" -ErrorAction Stop
        }

        $baselineFiles= Import-Csv -Path $baselinefilepath -Delimiter ","

        foreach($file in $baselineFiles) {
            if((Test-Path -Path $file.path) -eq $true) {
                $currenthash= Get-FileHash -Path $file.path
                if($currenthash.hash -eq $file.hash) {
                    Write-Output "$($file.path) is still the same"
                }else{
                    Write-Output "$($file.path) hash is different, something has changed"
                }
            }else{
                Write-Output "$($file.path) not found"
            }
        }

    }catch{
        Write-Error $_.Exception.Message
    }
}

function Create-Baseline {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)] $baselinefilepath
    )
    
    try{

        if((Test-Path -Path $baselinefilepath)) {
            Write-Error -Message "$($baselinefilepath) already exists with the same name" -ErrorAction Stop
        }else{
            "path,hash"| Out-File -FilePath $baselinefilepath -Force
        }

        if($baselinefilepath.Substring(($baselinefilepath.Length-4,4)) -ne ".csv") {
            Write-Error -Message "$baselinefilepath must be a .csv file" -ErrorAction stop
        }

    }catch{
        Write-Error $_.Exception.Message
    }
}

$baselinefilepath=""

do {

    Write-Host "File monitor v1.0 (made by Hamza)" -ForegroundColor Green

    Write-Host "Please select one of the following options or press q or quit to exit" -ForegroundColor Green 
    Write-Host "1. Set baseline file, current set baseline in $($baselinefilepath)" -ForegroundColor Green
    Write-Host "2. Add path to baseline" -ForegroundColor Green
    Write-Host "3. CHeck files against baseline" -ForegroundColor Green
    Write-Host "4. Create new baseline" -ForegroundColor Green 
    $entry = Read-Host -Prompt "Please enter a selection" 

    switch ($entry) {
        "1" {

            $inputfilepick= New-Object System.Windows.Forms.OpenFileDialog
            $inputfilepick.Filter= "CSV (*.csv) | *.csv"
            $inputfilepick.ShowDialog()
            $baselinefilepath=$inputfilepick.FileName

            if (Test-Path -Path $baselinefilepath) {
                Write-Output $baselinefilepath
                #if($baselinefilepath.Substring(($baselinefilepath.Length-4,4)) -eq ".csv") {
#
                #}else{
                #    $baselinefilepath=""
                #    Write-Error -Message "$baselinefilepath must be a .csv file" -ErrorAction stop
                #}

            }else{

                $baselinefilepath=""
                Write-Output "Invalid File Path "
            }
          }
        "2" { 
            $inputfilepick= New-Object System.Windows.Forms.OpenFileDialog
            $inputfilepick.ShowDialog()
            $filetomonitorpath=$inputfilepick.FileName
            Add-FileToBaseline -baselinefilepath $baselinefilepath -TargetFilePath $filetomonitorpath
         }
        "3" { 
            Verify-Baseline -baselinefilepath $baselinefilepath
         }
        "4" { 
            $inputfilepick= New-Object System.Windows.Forms.SaveFileDialog
            $inputfilepick.Filter= "CSV (*.csv) | *.csv"
            $inputfilepick.ShowDialog()
            $NewBaselineFilePath=$inputfilepick.FileName
            Create-Baseline -baselinefilepath $NewBaselineFilePath
         }
        "q" {  }
        "quit" { 
        }
        Default {
            Write-Host "Invalid Entry" -ForegroundColor Red
        }
    }

}while($entry -notin @('q', 'quit'))
