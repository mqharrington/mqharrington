 # DELL COMMAND MONITOR
 
 
# Get chassis information
get-ciminstance -Namespace root/dcim/sysman -ClassName DCIM_Chassis | Select-Object model, tag
# (get-ciminstance -Namespace root/dcim/sysman -ClassName DCIM_Chassis).tag
 
 
# get warranty information
Get-CimInstance -Namespace root/dcim/sysman -ClassName dcim_AssetExtendedWarrantyInformation
Get-CimInstance -Namespace root/dcim/sysman -ClassName dcim_AssetWarrantyInformation
 
 
 
 
 
# This is each location in WMI where Dell Command Monitor stores a HeathState status for hardware
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_BATTERY | Select-Object ElementName, HealthState 
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_COMPUTERSYSTEM | Select-Object ElementName, HealthState
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_DESKTOPMONITOR | Select-Object ElementName, HealthState
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_FAN | Select-Object ElementName, HealthState
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_PCIDEVICE | Select-Object ElementName, HealthState
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_PROCESSOR | Select-Object ElementName, HealthState
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_SENSOR | Select-Object ElementName, HealthState
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_MEMORY | Select-Object ElementName, HealthState


get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_FLATPANEL | Select-Object ElementName, HealthState
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_NUMERICSENSOR | Select-Object ElementName, HealthState
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_SERIALPORT | Select-Object ElementName, HealthState
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_USBPORT | Select-Object ElementName, HealthState
 
 
 
# This returns all attirbutes about each hardware component
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_BATTERY 
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_COMPUTERSYSTEM
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_DESKTOPMONITOR
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_FAN
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_FLATPANEL
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_MEMORY
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_NUMERICSENSOR
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_PCIDEVICE
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_PROCESSOR
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_SENSOR
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_SERIALPORT
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_USBPORT
 
 
# Some may return far more than 1 state, example:  DCIM_NumericSensor has 66 different states.
# Page 115  https://dl.dell.com/content/manual24896961-dell-command-monitor-version-10-7-reference-guide.pdf?language=en-us&ps=true
 
 
# #################################################################################################################################
 
 
# here is an example of how a customer who may not have SCCM other such tools can still collect data for a large number
# of systems in their environment.
 
 
#  Customer can point this script to any OU in their AD environment
# $pc = (Get-ADComputer -Filter * -SearchBase "ou=acme_workstations,dc=Acme,dc=org").Name
 
# For this example I am using my lab machine
$pc = "P7770"
 
$results = @()
 
 
# ping machines first to make sure they are online
if (Test-Connection -ComputerName $pc -Count 1 ) {
 
 
$results = foreach ($machine in $pc) {
 
    $ComputerInfo = Get-WMIObject -class Win32_ComputerSystem -computername $machine -Property *
    $computerName = $ComputerInfo.name
    $computerModel = $ComputerInfo.Model
    $osInfo= Get-WMIObject -Class Win32_Operatingsystem -ComputerName $machine
    $BiosInfo = Get-WmiObject -Class Win32_BIOS -computername $machine -Property *
    $BIOSVer = $BiosInfo.SMBIOSBIOSVersion
    $BIOSMan = $BiosInfo.Manufacturer
    $ComputerAssetTag = $BiosInfo.SerialNumber
    $DockAssetTag = (Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_Docked).Antecedent.tag
    $FanHealth = (Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_FAN).HealthState
    $DockModel = (Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_Chassis).name
    $BatteryHealth = (Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_Battery).HealthState
    $MonitorInfo = Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_DesktopMonitor -Property *
    $MonitorModel = $MonitorInfo.description
    $MonitorSerial = $MonitorInfo.SerialNumber
 
 
    # Regardless of the order you defined your variables above by using an array you can define how the output is ordered
     [PSCustomObject]@{
        'PCName' = $computerName
        'OS Version' = $osInfo.Version
        'OS Type' = $osInfo.Caption
        'Manufacturer' = $BIOSMan
        'Model' = $computerModel
        'BIOS Version' = $BIOSVer
        'Computer Asset Tag' = $ComputerAssetTag
        'Fan Health State' = $FanHealth
        'Battery Health State' = $BatteryHealth
        'Dock Model' = $DockModel
        'Dock Asset Tag' = $DockAssetTag
        'Monitor Model' = $MonitorModel
        'Monitor Serial#' = $MonitorSerial
 
    }
 
}
}
 
 
$Results | Out-GridView -Title "Computer Information"
 
 
 
 
 