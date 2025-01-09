

Clear-Host


<#

        .AUTHOR
        Matt Harrington

        .SYNOPSIS
        Install DCU with preconfigured custom settings.

        .DESCRIPTION
        This script will install Dell Command Update and then using dcu-cli.exe configure the settings within DCU.

        .SWITCHES
        None. 

        .OUTPUTS
        Log file created in "C:\ProgramData\Dell\CommandUpdate\DCUCustomInstall.log".
 
 
        .NOTES
        If running with SCCM put both the DCU installer and this .ps1 file in the same folder when creating your Package. 
        SCCM will run the .PS1 script and the code below will find the DCU .EXE file.
 

    #>

function Write-Log
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [Alias('LogPath')]
        [string]$Path="C:\ProgramData\Dell\CommandUpdate\DCUCustomInstall.log",  # <--- Can be set to any location you want
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Error","Warn","Info")]
        [string]$Level="Info"
        
  
    )

    Begin
    {
        # Set VerbosePreference to Continue so that verbose messages are displayed.
        $VerbosePreference = 'Continue'
    }
    Process
    {
        
         # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
        if (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
            }

        else {
             
            }

        # Format Date for our Log File
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                Write-Error $Message
                $LevelText = 'ERROR:'
                }
            'Warn' {
                Write-Warning $Message
                $LevelText = 'WARNING:'
                }
            'Info' {
                Write-Verbose $Message
                $LevelText = 'INFO:'
                }
            }
        
        # Write log entry to $Path
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append
    }
    End
    {
    }
} 





# Use $MyInvocation to find the working directory
if ($MyInvocation.MyCommand.Path -ne $null) {
    $scriptPath = $MyInvocation.MyCommand.Path
    $scriptDirectory = Split-Path -Path $scriptPath -Parent
    Write-Log -Level Info "working directory set to: $scriptdirectory"
} 

else {
    # If $MyInvocation.MyCommand.Path is null, use the current directory
    $scriptDirectory = (Get-Location).Path
    Write-Log -Level Info "working directory set to: $scriptdirectory"
}




# Path to the .EXE file
$exeFilePath = "$scriptdirectory\DCU_Setup_5_2_0.exe"
write-log "Dell Command Update file is here: $exeFilePath"

# Run the .EXE file with the /s switch for silent installation
Start-Process -FilePath $exeFilePath -ArgumentList "/S /v/qn" -Wait
write-log "Dell Command Update 5.2 was installed"


Start-Sleep -Seconds 5

# Now configure Dell Command Update with custom settings




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
  
# #############################################################################################################




# Get the current version of Dell Command Update
$DCUVersion = (get-ItemProperty HKLM:\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings).ProductVersion
Write-Log -Level Info "Dell Command Update version:  $DCUVersion"


# #############################################################################################################

# THIS IS ONLY AN EXAMPLE.  YOU NEED TO VIEW THE REFERENCE GUIDE TO FIND THE SETTINGS YOU OR YOUR CUSTOMER NEED



$exitCode = Run-DcuCli -DcuCliPath "$DCUEXEPath" -Switches "/configure -autoSuspendBitLocker=enable" 
write-log  "/configure -autoSuspendBitLocker=enable EXITCODE=$EXITCODE"


$exitCode = Run-DcuCli -DcuCliPath "$DCUEXEPath" -Switches "/configure -updateType=bios,firmware,driver" 
write-log  "/configure -updateType=bios,firmware,driver EXITCODE=$EXITCODE"

$exitCode = Run-DcuCli -DcuCliPath "$DCUEXEPath" -Switches "/configure -scheduleManual" 
write-log  "/configure -scheduleManual EXITCODE=$EXITCODE"

$exitCode = Run-DcuCli -DcuCliPath "$DCUEXEPath" -Switches "/configure -maxRetry=3" 
write-log  "/configure maxRetry EXITCODE=$EXITCODE"

$exitCode = Run-DcuCli -DcuCliPath "$DCUEXEPath" -Switches "/configure -delayDays=20" 
write-log  "/configure delayDays EXITCODE=$EXITCODE"

$exitCode = Run-DcuCli -DcuCliPath "$DCUEXEPath" -Switches "/configure -exportSettings=C:\ProgramData\Dell\CommandUpdate" 
write-log  "/configure -exportSettings=C:\ProgramData\Dell\CommandUpdate EXITCODE=$EXITCODE"



 
# Path to the .REG file
$regFilePath = "$scriptdirectory\DCUNoPopUpWindow.reg"
write-log "custom reg file is here:  $regFilePath"
 

# Run the .REG file
Start-Process -NoNewWindow -FilePath "C:\Windows\regedit.exe" -ArgumentList "/s $regFilePath"


 

<#
start-sleep -Seconds 2
 
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

#>


write-log "DCUNoPopUpWindow.reg file was imported into the registry"
write-log "Dell Command Update configuration complete"
Write-log "Installation complete"

 
