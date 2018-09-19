<# 
Map-OneDrive-Directories_v0.1.ps1
Author: Michael Garrison

Purpose: of this scirpt is automate the process of moving special directories in the User directory to OneDrive.  

These directories include: 
"Contacts", "Desktop", "Documents", "Favorites", "Links", "Music", "Pictures", and "Videos".

Step 1:  Check if folder exists in User directory
    
    -- If folder does not exist, move to next folder

Step 2:  Create new directory in OneDrive directory

    -- New-Item -ItemType Directory -Path $fullODPath

Step 3:  Change the Registry values to point to new folder

    -- Set-ItemProperty -Path "HKU:\$($strSID.value)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $name -Value $fullODPath

Step 4:  Move the Files to newly mapped directory

    -- robocopy $srcPath\$name $fullODPath /mov /E /XC /XN /XO

*** Things to add
- Check for OneDrive Installation

#>

Clear-Host  # Clears PowerShell Window
Set-StrictMode -Version 2.0         # Set PowerShell to Version 2.0 for OS compatibility

##*===============================================
##* Variable Declaration
##*===============================================

$userName = Read-Host -Prompt 'Input username'

$SourceDir = Join-Path "C:\Users" $userName
$ODFolder = "OneDrive - The Medicines Company"
$OneDrive = Join-Path $SourceDir $ODFolder # Sets OneDrive Path
$ODReg = Join-Path "%USERPROFILE%" $ODFolder
$chkSrc = Test-Path $SourceDir
$chkOD = Test-Path $OneDrive
$FolderNames = "Desktop","Documents","Favorites","Music","Pictures","Videos"

##*===============================================
##* Function Definitions
##*===============================================   

function Test-RegistryValue {
    param (
     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,
    
    [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Value
    )
    try {
        Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null # Check if registry key exists
        return $true
    } catch {
        return $false
    }
}

function Get-ODPath {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Path,
        
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Value
    )
    process {
        if (Test-RegistryValue -Path $Path -Value $Value) {
            return (Get-ItemProperty -path $regPath -name $Value).$Value
        } else {
            Write-Host "`nERROR: No OneDrive path has been specified, please ensure OneDrive is installed on this computer."
        }
    }
}

function test-Rgistry {
    param (
        [string]$regKeyName, [string]$regKeyPath
    )

    process {
        $ODPath = Join-Path $regKeyPath $regKeyName
        if (Test-Path $regPath) {  # Test that the registry path works
            if ((Test-RegistryValue -Path $regPath -Value $regKeyName) -ne $true) {
                if ($regKeyName -eq "Videos") { # Registry key name is My Video
                    $regKeyName = "My Video"
                } elseif ($regKeyName -eq "Documents") { # Registry key name is Personal
                    $regKeyName = "Personal"
                } else { # Some key values have "My " in front of them
                    $regKeyName = "My` $($regKeyName)"
                }
            } 
            [string]$key = (Get-ItemProperty -path $regPath -name $regKeyName).$regKeyName # Get the current value of the registry key and save as $key string
            Set-ItemProperty -Path $regPath -Name $regKeyName -Value $ODPath
            Write-Host "The Registry key for $regKeyName has now been set." # if not, then set the key below
        } else {
            $false
        }    
    }
}

function Map-One-Drive {
    param (
        [string]$dir, [string]$odPath, [string]$srcPath, [string]$odRegPath
    )

    process {
        
        Write-Host "`n`n------------------------------------------------------------------------------"
        Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        Write-Host "------------------------------------------------------------------------------`n`n"

        $fullODPath = Join-Path $odPath $dir # Store OneDrive path + new directory
        $fullSrcPath = Join-Path $srcPath $dir
        $chkODDir = Test-Path $fullODPath # Create reusable variable to test path
        $chkSrcDir = Test-Path $fullSrcPath # Create reusable variable to test path

        Write-Host "---- Now Mapping $name Directory to OneDrive ----"

        ##*=======================================================================================================
        ##* STEP 1: Check if folder exists in User directory
        ##*=======================================================================================================

        Write-Host "`n`n`nStep 1:  Check if $name exists in User directory"
        Write-Host "----------------------------------------------------------------`n"

        if ($chkSrcDir -eq $false) {
            Write-Host "$name does not exist within the User directory, moving to next folder."
            continue
        } else {
            Write-Host "$name does exist within the User directory, moving to next step."
        }

        ##*=======================================================================================================
        ##* STEP 2: Create folder in OneDrive directory
        ##*=======================================================================================================

        Write-Host "`n`n`nStep 2:  Create new directory in OneDrive directory"
        Write-Host "----------------------------------------------------------------`n"

        if ($chkODDir -eq $false) {
            New-Item -ItemType Directory -Path $fullODPath # Creates a new directory
            Write-Host "`nDirectory created: $fullODPath`n"
        }
        elseif ($chkODDir -eq $true) {
            Write-Host "The $name directory already exists in OneDrive, skipping step.`n"
        }

        ##*=======================================================================================================
        ##* STEP 3: Update path in registry for new folder
        ##*=======================================================================================================

        Write-Host "`n`n`nStep 3:  Change the Registry values to point to new folder"
        Write-Host "----------------------------------------------------------------`n"
        
        test-Rgistry -regKeyName $name -regKeyPath $odRegPath
        
        
        ##*=======================================================================================================
        ##* STEP 4: Move all of the user's data to the new location
        ##*=======================================================================================================

        Write-Host "`n`n`nStep 4:  Move the Files to newly mapped directory"
        Write-Host "----------------------------------------------------------------`n"

        robocopy $fullSrcPath $fullODPath /MOVE /E /XC /XN /XO
    } 
}

##*===============================================
##* Script Initiation
##*===============================================  

if ($chkSrc -eq $true) {
    New-PSDrive HKU registry HKEY_USERS # Set HKU to access SID for other user
    $AdObj = New-Object System.Security.Principal.NTAccount("$userName@contoso.com")
    $strSID = $AdObj.Translate([System.Security.Principal.SecurityIdentifier])
    $regPath = "HKU:\$($strSID.value)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    if ($chkOD -eq $true) {    # Check if OneDrive folder exists
        
        Start-Transcript -Path "C:\temp\Map-OneDrive-log.txt"

        ##*=======================================================================================================
        ##* Create the special folders in OneDrive Directory
        ##*=======================================================================================================

        foreach ($name in $FolderNames) {
            Map-One-Drive -dir $name -odPath $OneDrive -srcPath $SourceDir -odRegPath $ODReg
        }
        Write-Host "`n`n------------------------------------------------------------------------------`n"
        Write-Host "`nYou must log out or reboot to finish mapping the folders`n"
        Stop-Transcript
    } elseif ($chkOD -eq $false) {
        Write-Host "`nERROR: There is no $OneDrive directory on this user account.  Please ensure OneDrive is configured properly before running this script.`n"
    } else {
        Write-Host "`nERROR: Unable to complete script."
    }
} elseif ($chkSrc -eq $false) {
    Write-Host "`nERROR: There is no $SourceDir directory on this computer.  Please ensure you typed the username correctly.`n"
} else {
    Write-Host "`nERROR: Unable to complete script."
}

Write-Host "`nPress any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")