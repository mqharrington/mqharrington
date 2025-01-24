


clear-host

<#
        .Author
        Matthew Harrington


        .SYNOPSIS
        Install the SupportAssist agent including deployment 'key'.  Install the windowsdesktop-runtime-8.0.11-win-x64.exe
        if not already installed.  
         

        .DESCRIPTION
        This can be packaged into an Intunewin file along with the prebuilt SupportAssist-x64.exe installer and associated files.  
        You will call this file with Intune.  Or you can run this .ps1 with all associated files manually.  
           

        .PREREQUISITES
        You have built your SupportAssist installer from Tech Direct and asigned it a deployment 'key'.
        This Youtube video will show you how it is done. 
        https://github.com/mqharrington/mqharrington 
      

        .NOTES
        This script is designed to be deployed as part of a Intunewin package or as a standalone installer.  
        From within Intune on the package properites you can run it like this:
        powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NonInteractive -NoLogo -File ".\CallSAInstaller.ps1"

     
    
    #>



# Create a logging function
function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$LogType = "INFO",
        [string]$LogFilePath = "C:\Logs\SAEnterprise.log"
    )

    # Ensure the log directory exists
    $logDirectory = [System.IO.Path]::GetDirectoryName($LogFilePath)
    if (!(Test-Path -Path $logDirectory)) {
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    }

    # Format the timestamp as MM/dd/yyyy HH:mm:ss
    $timestamp = Get-Date -Format "MM/dd/yyyy HH:mm:ss"

    # Format the log entry with log type
    $logEntry = "$timestamp [$LogType] - $Message"

    # Write to log file
    Add-Content -Path $LogFilePath -Value $logEntry

    # Example of how to use it
    # Write-Log -LogType INFO -Message "This is an example of using the write-log function"
}




# Use $MyInvocation.MyCommand.Definition to run the installer when you don't know what the path is.
# This will fill find the relative path regardless of where it is.  
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
write-log -LogType INFO -Message "working path is $scriptDir"

# Define installer paths.  
$RuntimeInstaller = Join-Path -Path $ScriptDir -ChildPath "windowsdesktop-runtime-8.0.11-win-x64.exe"
$SupportAssistInstaller = Join-Path -Path $ScriptDir -ChildPath "SupportAssistInstaller-x64.exe"
$TransformPath = Join-Path -Path $ScriptDir -ChildPath "SupportAssistConfiguration.mst"


# Define registry path to check software installation.  Windowsdesktop-runtime-8.0.11-win-x64.exe installed the following
# uninstall key so this will be used. 
$RuntimeRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{C0790AA0-0F40-4836-85B2-677B87625E63}"
$RuntimeArgs = "/quiet /norestart /log C:\Logs\WinRuntime8.0.11.log"


# Check if Windows Desktop Runtime is installed.  If not install it.  If found move onto next step.  
if (Test-Path $RuntimeRegistryPath) {
    write-log -LogType INFO -Message "Windows Desktop Runtime is already installed. Proceeding to SupportAssist installation..."
} else {
    write-log -LogType WARNING -Message "Windows Desktop Runtime not found. Installing now..."
    
    # Check if the installer exists before running it
    if (Test-Path $RuntimeInstaller) {
        Start-Process -FilePath $RuntimeInstaller -ArgumentList $RuntimeArgs -Wait
        write-log -LogType INFO -Message "Windows Desktop Runtime installation complete."
    } else {
        write-log -LogType ERROR -Message "Error: Runtime installer not found at $RuntimeInstaller or the install failed.  Check log file."
        exit 1
    }
}

# Proceed to install SupportAssist
write-log -LogType INFO -Message "Proceeding with SupportAssist installation..."

# Create array of the needed command line switches
$SupportAssistArgs = @(
    "TRANSFORMS=`"$TransformPath`"",
    "DEPLOYMENTKEY=`"Dell123#`""
) -join " "


# Check if the SupportAssist installer exists before running it
if (Test-Path $SupportAssistInstaller) {
    Start-Process -FilePath $SupportAssistInstaller -ArgumentList $SupportAssistArgs -Wait -NoNewWindow -PassThru
    write-log -LogType INFO -Message "SupportAssist installation complete."
     
} else {
    write-log -LogType INFO -Message "Error: SupportAssist installer not found at $SupportAssistInstaller."
    write-log -LogType INFO -Message "Installation failed !!"
    exit 1
}



