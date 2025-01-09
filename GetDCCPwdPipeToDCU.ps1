


clear-host

<#
        .Author
        Matthew Harrington
        mqharrington@gmail.com
        pacific standard timezone

        .SYNOPSIS
        Query MSGraph to get the current Admin BIOS password that was set by Dell Command | Endpoint Configure for Microsoft Intune (DCECMI)
        And if DCU is installed pipe the password into DCU so it can update the system. 
         

        .DESCRIPTION
        When run this will connect to your MSGraph provided you have rights and find the current password 
        based on the serial number of the device.    


        .PREREQUISITES
        DCECMI has been packaged in Intune and deployed to your environment. 
        A CCTK file has been created using DCC and imported into Intune.
        Disable per-device BIOS password protection was set to NO on your CCTK file package.
        Dell Command Update is installed on the target systems.
        User running this script has required rights in Intune/MSGraph.
      

        .NOTES
        Once run all $variables are resident so you can highlight any $variable and press F8 to get data.  Example: Once this script
        has been run and you have collected the data you want you can highlight the variable called $allHardwarePasswordInfo
        then press F8, it will return all current and previous passwords for all of your systems in MSGraph.

     
    
    #>



# Log function

function Write-Log {
    param (
        [string]$Message,
        [string]$LogFilePath = "C:\ProgramData\Dell\CommandUpdate\DCECMIPWDEntry.log",
        [ValidateSet("INFO", "WARNING", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    # Ensure the log directory exists
    $logDirectory = [System.IO.Path]::GetDirectoryName($LogFilePath)
    if (!(Test-Path -Path $logDirectory)) {
        New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
    }

    # Create the log message
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp [$Level] : $Message"

    # Append the log message to the log file
    Add-Content -Path $LogFilePath -Value $logMessage

    # Output the log message to the console
    Write-Output $logMessage

}




# Function to run dcu-cli.exe

function Run-DcuCli {
    param (
        [string] $DcuCliPath = "$DCUEXEPath",
        [string] $Switches = "",
        [switch] $WaitForExit = $true
    )

    # Start the dcu-cli.exe process with the provided switches
    $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processStartInfo.FileName = $DcuCliPath
    $processStartInfo.Arguments = $Switches
    $processStartInfo.RedirectStandardOutput = $true
    $processStartInfo.RedirectStandardError = $true
    $processStartInfo.UseShellExecute = $false
    $processStartInfo.CreateNoWindow = $true

    $process = [System.Diagnostics.Process]::Start($processStartInfo)

    if ($WaitForExit) {
        # Wait for the dcu-cli.exe process to complete
        $process.WaitForExit()

        # Capture the exit code
        $exitCode = $process.ExitCode

        # Close the process and dispose of resources
        $process.Close()
        $process.Dispose()

        return $exitCode
    }
    else {
        # If not waiting for exit, return the process object
        return $process
    }
}





# Find the installation location of Dell Command Update.  If not found EXIT script. 
$x86 = Test-Path -Path "C:\Program Files\Dell\CommandUpdate\Dcu-Cli.exe"if ($x86 -like "*False*") {sleep -Milliseconds 1} ELSE {$DCUEXEPath = "C:\Program Files\Dell\CommandUpdate\Dcu-Cli.exe"}$x64 = Test-Path -Path "C:\Program Files (x86)\Dell\CommandUpdate\Dcu-Cli.exe"if ($x64 -like "*False*") {sleep -Milliseconds 1} ELSE {$DCUEXEPath = "C:\Program Files (x86)\Dell\CommandUpdate\Dcu-Cli.exe"}if ($DCUEXEPath -like "") 
{
     
    EXIT
    }  


# Check to see if Dell Command Update is running.  If it is running close the program.
$FindDCU = get-process | Where-Object name -like "DellCommandUpdate"
if ($FindDCU) 
    {
        Stop-Process -name "DellCommandUpdate"
        write-log -Level WARNING  "Dell Command Update was running so the program was closed. We can now proceed."
    } ELSE
        {write-log -Level Info "Dell Command Update was not running, we will proceed."} 



# Get the current version of Dell Command Update
$DCUVersion = (get-ItemProperty HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings).ProductVersion
Write-Log -Level Info "Dell Command Update version:  $DCUVersion"

 
# Disable DCU first run popup in registry  
$registryPath = "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\CFG"
$Name = "ShowSetupPopup"
$Value = "0"
Set-ItemProperty -Type Dword -Path $registryPath -Name $Name -Value $Value

# If disabling the first run popup fails exit script
if ($? -eq $false)
    {write-log -Level Error "Failed to Disable first run pop-up, script will exit."
    Exit 1
    }

else {Write-log -Level Info "First run pop-up disabled...will continue."}

# #############################################################################################################


# In this section we will connect to MSGraph and query the serial number of the device and then
# look it up to see if there is a current password that was set by Dell Command | Endpoint Configure for Microsoft Intune



# Authenticate with Microsoft Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All" -NoWelcome


# Get the serial number of the machine that will be used to query MSGraph
$serialNumber = (get-ciminstance -classname win32_bios).SerialNumber



# Create an array to store all the hardware password info
$allHardwarePasswordInfo = @()

# This is the path within MSGraph that contains all of the DCICMI password information
$uri = "https://graph.microsoft.com/beta/deviceManagement/hardwarePasswordInfo"



do {
    # Query MSGraph using the $uri path above
    $response = Invoke-MgGraphRequest -Method GET -Uri $uri

    # Append the results to the array
    $allHardwarePasswordInfo += $response.value

    # Check if there is a next page (@odata.nextLink)
    $uri = $response.'@odata.nextLink'

} while ($uri)  

# Checking the serial number we have entered
$device = $allHardwarePasswordInfo | Where-Object { $_.serialNumber -eq $serialNumber }

# Check if device exists and has previous passwords
if ($device -and $device.CurrentPassword) {
    # Retrieve the last password in the previousPasswords array
    $CurrentPassword = $device.previousPasswords[-1]
}    

# If a password was found pipe it into DCU and then run /applyupdates
 if (-not [string]::IsNullOrEmpty($currentpassword)) {
    Write-log "A password was found in MSGraph and piped to DCU so updates can install"
    
    $exitCode = Run-DcuCli -DcuCliPath "$DCUEXEPath" -Switches "/configure -biosPassword=$CurrentPassword" 
    Start-Sleep -Seconds 1
    $exitCode = Run-DcuCli -DcuCliPath "$DCUEXEPath" -Switches "/ApplyUpdates -outputlog=c:\temp\DCUAPPLYUPDATES.LOG" 

} else {
    Write-log "No current password was found in MSGraph for system $serialnumber no action was taken."
}

 






