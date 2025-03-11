
clear-host

<#
        .Author
        Matthew Harrington


        .SYNOPSIS
        Install Dell Command - Endpoint Configure for Microsoft Intune including .NetFramework 8.0.13 is needed. 
         

        .DESCRIPTION
        This will check to see if the Net Framework is installed and if not then install it.  Then it will install the 
        DCECMI software.  It can all be packaged into an Intunewim package or MECM package.     
         
           

        .PREREQUISITES
        You must have a Dell commercial client with Windows 10 or later operating system.
        The device must be enrolled in Intune's mobile device management (MDM).
      

        .NOTES
        This script is provided as is. It is meant only as a guide. You can modify it to your own needs.   

     
    
    #>



# Create a logging function
function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$LogType = "INFO",
        [string]$LogFilePath = "C:\Logs\DCECMIInstaller.log"
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
    # Write-Log -Message "This is an example of using the write-log function"
}


 

# Use $MyInvocation.MyCommand.Definition to run the installer when you don't know what the path is.
# This will fill find the relative path regardless of where it is.  
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Log -Message "working path is $scriptDir"

# Define installer paths  
$Net8Framework = Join-Path -Path $ScriptDir -ChildPath "dotnet-runtime-8.0.13-win-x64.exe"
$Net8Args = "/install /quiet /norestart /log c:\logs\MicrosoftNetRuntime8.log"
$DCECMIInstaller = Join-Path -Path $ScriptDir -ChildPath "Dell-Command-Endpoint-Configure-for-Microsoft-Intune_G9GM4_WIN_2.0.0.6_A01.EXE"
Write-Log -Message "Installer paths defined"
Write-Log -Message "$Net8Framework"
Write-Log -Message "$DCECMIInstaller"
Write-Log -Message "                  "

 

# Get a list of installed .NET runtimes
$dotnetRuntimes = & dotnet --list-runtimes 2>$null


# Ensure command ran successfully
if ($dotnetRuntimes) {
    # Check if Windows Desktop Runtime 8.0.13 is installed
    $desktopRuntime = $dotnetRuntimes | Where-Object { $_ -match "^Microsoft\.WindowsDesktop\.App 8\.0\.13" }

    if ($desktopRuntime) {
        Write-Log -Message "Windows Desktop Runtime 8.0.13 is installed."
    } else {
        Write-Log -Message "Windows Desktop Runtime 8.0.13 is not installed. Installing now..."

        if (Test-Path $Net8Framework) {
            Start-Process -FilePath $Net8Framework -ArgumentList $Net8Args -Wait -NoNewWindow
            Write-Log -Message "Windows Desktop Runtime 8.0.13 installation completed successfully."
        } else {
            Write-Log -Message "Error: .NET Runtime installer not found at $Net8Framework. Installation failed."
            exit 1
        }
    }
} else {
    Write-Log -LogType ERROR -Message "Failed to retrieve .NET runtime versions. Ensure .NET is installed and accessible."
    exit 1
}



# Check to see if DCECMI is installed, if not install it
$DCECMIARGS = "/s /l=c:\logs\DCECMI_Dell_Package.log"

if (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse -ErrorAction SilentlyContinue | 
    Get-ItemProperty | Where-Object { $_.DisplayName -eq "Dell Command | Endpoint Configure for Microsoft Intune" }) {
    
    Write-Log -Message "DCECMI is already installed. No action taken."
} else {
    Write-Log -Message "DCECMI is not installed. Proceeding with installation."
    
    if (Test-Path $DCECMIInstaller) { 
        Write-Log -Message "DCECMI installer found. Starting installation."
        Write-Log -Message "DCECMI install switches are set to:  $DCECMIARGS"
        Start-Process -FilePath $DCECMIInstaller -ArgumentList "/s /l=c:\logs\DCECMI_Dell_Package.log" -Wait -NoNewWindow 
        Write-Log -Message "DCECMI installation complete."
    } else {
        write-log -LogType ERROR -Message "DCECMI installer not found at $DCECMIInstaller. Installation aborted."
    }
}


  
 














