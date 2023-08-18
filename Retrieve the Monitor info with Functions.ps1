





clear-host


<#
        .Author
        Matthew Harrington

        .SYNOPSIS
        Run DDM.EXE and extract the Dell monitor and asset tag.

        .DESCRIPTION
        Running DDM.EXE this will extract out the Dell monitor and asset tag of the monitor.
        It will create a file called c:\temp\MakeTag.txt



    Running DDM.EXE /Log c:\temp\ddm.txt /ReadAssetAttributes creates a file called ddm.txt.  It will look similar to this:

    Dell Display Management Console
    Log C:\temp\ddm.txt = Ok
    ReadAssetAttributes = DEL4222,Dell C2422HE,CN073K0,2020 ISO week 41,941

    As you can see it is not in the most perfect format.   So the script below will extract out
    just the Dell Monitor and asset tag.  In the example above it is Dell C2422HE, CN073k0

    
    #>



# Create a logging function
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
        # [string]$Path="C:\ProgramData\Dell\DDM\DDM.log",
        [string]$Path="C:\Temp\DDMOutput.log",
        
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
 
 # ############################################################################################




function Run-DDM {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PathToExe,
        
        [Parameter(Mandatory=$false)]
        [string]$Switches
    )
    
    $arguments = @()
    if ($Switches) {
        $arguments += $Switches
    }
    
    Start-Process -FilePath $PathToExe -ArgumentList $arguments -Wait
}


# ############################################################################################



# Remove previous files if they exist
if (test-path c:\temp\ddm.txt) { remove-item c:\temp\ddm.txt }
if (test-path c:\temp\MakeTag.txt) { remove-item c:\temp\MakeTag.txt }
if (test-path c:\temp\fwv.txt) { remove-item c:\temp\fwv.txt }
Start-Sleep -Seconds 1


# Get the PCName
$PCName = $env:COMPUTERNAME
Write-Log -level INFO "Hostname is $PCName"


# Find the installation location of Dell Display Manager.  If not found EXIT script. 
$x86 = Test-Path -Path "C:\Program Files\Dell\Dell Display Manager 2\ddm.exe"
if ($x86 -like "*False*") {sleep -Milliseconds 1} ELSE {$DDMPath = "C:\Program Files\Dell\Dell Display Manager 2\ddm.exe"
Write-Log -level INFO "Dell Display Manager installed here: C:\Program Files\Dell\Dell Display Manager 2\ddm.exe"
}

$x64 = Test-Path -Path "C:\Program Files (x86)\Dell\Dell Display Manager 2\ddm.exe"
if ($x64 -like "*False*") {sleep -Milliseconds 1} ELSE {$DDMPath = "C:\Program Files (x86)\Dell\Dell Display Manager 2\ddm.exe"
Write-Log -level INFO "Dell Display Manager installed here: C:\Program Files (x86)\Dell\Dell Display Manager 2\ddm.exe"
}

if ($DDMPath -like "") 
{
    Write-Log  -Level Error "Dell Display Manager is not installed.   Program will EXIT."
    EXIT
    }  


# ############################################################################################

# Using the Run-DDM function run ddm.exe
Run-DDM -PathToExe $DDMPath -Switches "/Log C:\temp\ddm.txt /ReadAssetAttributes"
Write-Log -level INFO "ddm.exe /Log c:\temp\ddm.txt /ReadAssetAttributes was run"

# Wait until the file exists
Start-Sleep -Seconds 1
$file = "C:\temp\ddm.txt"

while (-not (Test-Path $file)) {
    Start-Sleep -Seconds 1
}


# ############################################################################################

# Using the Run-DDM function run ddm.exe
Run-DDM -PathToExe $DDMPath -Switches "/Log C:\temp\fwv.txt /ReadFirmwareVersion"
Write-Log -level INFO "ddm.exe /Log c:\temp\ddm.txt /ReadFirmwareVersion was run"

# Wait until the file exists
Start-Sleep -Seconds 1
$file2 = "C:\temp\fwv.txt"

while (-not (Test-Path $file2)) {
    Start-Sleep -Seconds 1
}



# ############################################################################################

# Read the content of the file
$content = Get-Content -Path "C:\temp\ddm.txt"


# Remove the first two lines and leading white spaces
$content = $content | Select-Object -Skip 2 | ForEach-Object {$_.TrimStart()}
Write-Log -Level INFO "First 2 lines of file c:\temp\ddm.txt where removed"

# Overwrite the file with the updated content
$content | Set-Content -Path $file

# Wait until the file exists
Start-Sleep -Seconds 1
$file = "C:\temp\ddm.txt"

while (-not (Test-Path $file)) {
    Start-Sleep -Seconds 1
}




# Read the content of the file
$content2 = Get-Content -Path "C:\temp\fwv.txt"


# Remove the first two lines and leading white spaces
$content2 = $content2 | Select-Object -Skip 2 | ForEach-Object {$_.TrimStart()}
Write-Log -Level INFO "First 2 lines of file c:\temp\fwv.txt where removed"

# Overwrite the file with the updated content
$content2 | Set-Content -Path $file2

# Wait until the file exists
Start-Sleep -Seconds 1
$file2 = "C:\temp\fwv.txt"

while (-not (Test-Path $file2)) {
    Start-Sleep -Seconds 1
}






# ############################################################################################


# Now let's return only the Model and asset tag of the monitor
$file = "C:\temp\ddm.txt"
$content = Get-Content -Path $file
$string = "$content"


# Split the string by commas
$splitString = $string -split ","

# Extract the desired portion
$result = $splitString[1..2] -join ","

# Display the result
$result | out-file -FilePath "c:\temp\MakeTagFW.txt"



# path to output file
$filePath = "C:\Temp\MakeTagFW.txt"

# Append the hostname to the file
Add-Content -Path $filePath -Value $PCName 

$getFM = Get-Content "c:\temp\fwv.txt" 
$getFM | Out-File -FilePath "c:\temp\MakeTagFW.txt" -Append

 
# Write to local log
Write-Log -Level INFO "Program completed"


 
 
  
 

