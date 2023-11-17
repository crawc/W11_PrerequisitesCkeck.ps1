######################################################################
# ChatGPT 3.5 improved 11-16-2023                                                                      #
# Version: 1.2                                                                                   #
############################################################################################################################################
# This script checks if your computer is compatible with Windows 11                               #
# Original Code: Christopher Mogis                                                                      #
# Date: 06/30/2022                                                                                #
# https://github.com/ChrisMogis/W11_PrerequisitesCkeck.ps1                                      #
######################################################################

# Variable
$Information = "https://www.microsoft.com/en-US/windows/windows-11-specifications"

# Store failed checks in an array
$FailedChecks = @()

# Function to display error message and add to the failed checks array
function DisplayError($message) {
    $FailedChecks += $message
    Write-Host "$message : Not OK" -ForegroundColor "red"
}

# Function to display success message
function DisplaySuccess($message) {
    Write-Host "$message : OK" -ForegroundColor "green"
}

# Architecture x64 check
$Arch = (Get-CimInstance -Class CIM_ComputerSystem).SystemType
$ArchValue = "x64-based PC"
if ($Arch -ne $ArchValue) {
    DisplayError "Architecture x64"
} else {
    DisplaySuccess "Architecture x64"
}

# Screen Resolution check
$ScreenInfo = (Get-CimInstance -ClassName Win32_VideoController).CurrentVerticalResolution
$MinResolution = 720
if ($ScreenInfo -le $MinResolution) {
    DisplayError "Screen resolution support"
} else {
    DisplaySuccess "Screen resolution support"
}

# CPU Composition check
$Core = (Get-CimInstance -Class CIM_Processor | Select-Object -ExpandProperty NumberOfCores)
$CoreValue = 2
$Frequency = (Get-CimInstance -Class CIM_Processor | Select-Object -ExpandProperty MaxClockSpeed)
$FrequencyValue = 1000
if ($Core -ge $CoreValue -and $Frequency -ge $FrequencyValue) {
    DisplaySuccess "Processor is compatible with Windows 11"
} else {
    DisplayError "Processor is compatible with Windows 11"
}

# TPM check
$TPM2 = (Get-Tpm).ManufacturerVersionFull20 -notcontains "not supported"
if (-not $TPM2) {
    DisplayError "TPM module"
} else {
    DisplaySuccess "TPM module"
}

# Secure Boot check
$SecureBootSupported = $null
try {
    $SecureBootSupported = Confirm-SecureBootUEFI -ErrorAction Stop
} catch {
    # Confirm-SecureBootUEFI is not supported, handle accordingly
}

if ($SecureBootSupported -ne $null) {
    if (-not $SecureBootSupported) {
        DisplayError "Secure boot"
    } else {
        DisplaySuccess "Secure boot"
    }
} else {
    Write-Host "Secure boot check is not supported on this platform." -ForegroundColor "yellow"
}

# RAM check
$Memory = (Get-CimInstance -Class CIM_ComputerSystem).TotalPhysicalMemory
$MinMemory = 4GB
if ($Memory -lt $MinMemory) {
    DisplayError "RAM installed"
} else {
    DisplaySuccess "RAM installed"
}

# Storage check
$ListDisk = Get-CimInstance -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
$MinSizeLimit = 64GB
foreach ($Disk in $ListDisk) {
    $DiskFreeSpace = ($Disk.FreeSpace / 1GB).ToString('F2')
}

if ($DiskFreeSpace -lt $MinSizeLimit) {
    DisplayError "Available space on Hard drive"
} else {
    DisplaySuccess "Available space on Hard drive"
}

# Display the result and information message at the end
if ($FailedChecks.Count -eq 0) {
    Write-Host "Result: PASSED!" -ForegroundColor "green"
} else {
    Write-Host "Result: FAILED!" -ForegroundColor "red"
    Write-Host "Please refer to $Information for more information."
}
