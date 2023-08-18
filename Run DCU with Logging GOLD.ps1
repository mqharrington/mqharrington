 

Clear-Host

# Customize Dell Command Update from PowerShell
# Matt Harrington




# Use a log function to log what takes place

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
        [string]$Path="C:\ProgramData\Dell\CommandUpdate\dcuconfig.log",
        
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
            # Nothing to see here yet.
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
 

# ########################################################################################################################################

write-log -Level Info "Dell Command Update custom configuration script beginning..."


# Find the installation location of Dell Command Update.  If not found EXIT script. 
$x86 = Test-Path -Path "C:\Program Files\Dell\CommandUpdate\Dcu-Cli.exe"if ($x86 -like "*False*") {sleep -Milliseconds 1} ELSE {$DCUEXEPath = "C:\Program Files\Dell\CommandUpdate\Dcu-Cli.exe"}$x64 = Test-Path -Path "C:\Program Files (x86)\Dell\CommandUpdate\Dcu-Cli.exe"if ($x64 -like "*False*") {sleep -Milliseconds 1} ELSE {$DCUEXEPath = "C:\Program Files (x86)\Dell\CommandUpdate\Dcu-Cli.exe"}if ($DCUEXEPath -like "") 
{
    write-log -Level Error "Dell Command Update is not installed.   Program will EXIT."
    EXIT
    }  




# Check to see if Dell Command Update is running.  If it is running close the program.
$FindDCU = get-process | Where-Object name -like "DellCommandUpdate"
if ($FindDCU) 
    {
        Stop-Process -name "DellCommandUpdate"
        write-log -Level Warn  "Dell Command Update was running so the program was closed. We can now proceed."
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
    Exist 1
    }

else {Write-log -Level Info "First run pop-up disabled...will continue."}




# #####################################################################################################################################################

# SHOWN BELOW IS JUST AN EXAMPLE OF WHAT CUSTOMERS CAN DO.  THEY WOULD NEED TO READ THE DCU DOC'S TO FIND THEIR EXACT SETTINGS FOR THEIR ENVIRONMENTS #

# #####################################################################################################################################################


write-log -Level Info "now setting all Dell Command Update custom settings"
 
# Start-Process -Wait   -FilePath $DCUEXEPath -ArgumentList "/configure -biosPassword='Dell123'"

Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -autoSuspendBitLocker=enable" 
write-log -Level Info  "auto suspend bitlocker was enabled"  
  
Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -updateType=bios,firmware,driver"
write-log -Level Info  "update types set to BIOS, firmware and driver"

Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -scheduleManual"
write-log -Level Info  "updates set to manual"

Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -scheduleAction=DownloadAndNotify"
write-log -Level Info  "DCU set to download and notify"

Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -DownloadLocation=C:\ProgramData\Dell\UpdateService\Downloads"
write-log -Level Info  "DCU download location set to default:  c:\programdata\Dell\UpdateService\Downloads"

Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -updateSeverity=security,critical,recommended"
write-log -Level Info  "Severity set to security, critical and recommended"

Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -userConsent=disable"
write-log -Level Info  "user consent set to disable"

Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -scheduledReboot=30"
write-log -Level Info  "Reboot time set to 30 minutes"

Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -lockSettings=disable"  #can be set to "enable" if needed
write-log -Level Info  "DCU lock settings set to disable"

Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -reboot=disable"
write-log -Level Info  "Reboot set to disable"





# #####################################################################################################################################################

# The following are new settings released in version 4.6.  These can be found on the Update Settings page within DCU

# #####################################################################################################################################################



if ($DCUVersion -gt "4.5") {

# These are exmaples of how  you can set these new settings.   You will need to test and play with each setting for your environment



Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -scheduleAction=DownloadInstallAndNotify"
write-log -Level Info  "When updates are found is set to:  Download and install updates (Notify after complete)"

Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -systemRestartDeferral=enable -deferralRestartInterval=3 -deferralRestartCount=9"
write-log -Level Info  "Reboot deferral set to interval=3 count=9" 


Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -installationDeferral=enable  -deferralInstallInterval=2 -deferralInstallCount=2"
write-log -Level Info  "Installation deferral set to interval=2 count=2"  

Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure /configure -updatesNotification=disable"  # can be set to enable as well
write-log -Level Info  "Disable all notifictions set to disable" 

}


# #####################################################################################################################################################


# Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -updateDeviceCategory=network,storage,chipset"
# write-log -Level Info  "Category set to network, storage and chipset"

write-log -Level Info "Starting DCU scan of system..."
Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/scan -silent -outputLog=C:\ProgramData\Dell\CommandUpdate\scanOutput.log"
write-log -Level Info  "/Scan file run and saved to: c:\programdata\Dell\CommandUpdate\scanoutput.log"

Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "/configure -exportSettings=C:\ProgramData\Dell\CommandUpdate"
write-log -Level Info "Export settings written to c:\programdata\Dell\CommandUpdate"

#write-log -Level Info "Running /ApplyUpdates, this may take time, please wait."
#Start-Process -Wait -WindowStyle Hidden -FilePath $DCUEXEPath -ArgumentList "6 -silent -outputlog=C:\ProgramData\Dell\CommandUpdate\DCUApplyUpdates.log"#write-log -Level Info "Dell Command Update /ApplyUpdates has been run, log file created here:  C:\ProgramData\Dell\CommandUpdate\DCUApplyUpdates.log."

write-log -Level Info  "Dell Command Update custom settings have been set.  You can view the settings in this file:  C:\ProgramData\Dell\CommandUpdate\DellCommandUpdateSettings.xml"



Exit 0

