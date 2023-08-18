



#  There are a lot of PS snippets in the Dell Command | Monitor Version 10.6 User's Guide


#    https://www.configjon.com/dell-bios-settings-management-wmi/


Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_BiosEnumeration



# List all Dell Command Monitor classes in WMI.  This is the most useful command since it shows you everything you can query against.  
Get-CIMClass -Namespace root/DCIM/SYSMAN  | Sort-Object | Where-Object CIMClassname -like *"DCIM_*" | Out-GridView

 
# Get battery information
Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_Battery

$a = Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_Battery
$a | Get-Member -MemberType Property

$a = Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_Battery
$a | Get-Member -MemberType *



Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_BIOSPassword | Select-Object CurrentVAlue

# Get Fan information
Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_FAN  | Select-object HealthState



# Get Thermal Information
Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_ThermalInformation $a = Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_ThermalInformation 
$a | Get-Member -MemberType *# Select certain pieces of information for one class nameGet-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_BIOSEnumeration | Select-Object 'Attributename', 'currentvalue', 'possiblevalues', 'possiblevaluesdescription' | Out-GridView<## Change the value for one class nameGet-CimInstance -Namespace root\dcim\sysman -ClassName DCIM_ThermalInformation |WhereObject {$_.AttributeName -eq "Thermal Mode"} | Invoke-CimMethod -MethodName
ChangeThermalMode -Arguments @{AttributeName=@("Thermal Mode");AttributeValue=@("2")}# Change the password on a machine Get-CimInstance -Namespace root\dcim\sysman -ClassName DCIM_BIOSService | InvokeCimMethod -MethodName SetBIOSAttributes -Arguments
@{AttributeName=@("AdminPwd");AttributeValue=@("Dell123")}# Enable TPM security using the following command:
Get-CimInstance -Namespace root\dcim\sysman -ClassName DCIM_BIOSService | InvokeCimMethod -MethodName SetBIOSAttributes -Arguments @{AttributeName=@("Trusted Platform
Module ");AttributeValue=@("1");AuthorizationToken="<Admin password>"}
# Activate the TPM using the following command:Get-CimInstance -Namespace root\dcim\sysman -ClassName DCIM_BIOSService | InvokeCimMethod -MethodName SetBIOSAttributes -Arguments @{AttributeName=@(" Trusted Platform
Module Activation");AttributeValue=@("2");AuthorizationToken="<Admin password>"}

#>


# get chassis information
Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_Chassis | Select-Object model, tag 
(Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_Chassis).Tag



# Get dock information
Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_Docked | out-file c:\temp\Dock2.txt  # << This will return the serial number of the plugged in docking station.  
(Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_Docked).Antecedent.tag  # <<  gets the dock asset tag
(Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_Docked).Dependent.tag  # << gets the chassis asset tag


 




# get monitor serial number
Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_DesktopMonitor | Select-Object Description, SerialNumber, ScreenWidth, ScreenHeight      -Unique 
$a = Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_DesktopMonitor
$a | Get-Member -MemberType *



(Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_DesktopMonitor).SerialNumber

$line = (Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_DesktopMonitor).SerialNumber
$MonSer = $line[0].SubString(0, 7)
clear-host
$MonSer
Write-Host ""
 
Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_DesktopMonitor | out-file "c:\temp\monitor1.txt"
Invoke-Item "c:\temp\Monitor1.txt"



# Get log information
Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_AlertIndication
Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_LogEntry
Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_RecordLog



# Physical Disk View only enumerates IDE disk drives for Intel controllers
Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_PhysicalDiskView


# Drive Information
Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName dcim_SMARTAttributeInfo | Out-GridView
$a = Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName dcim_SMARTAttributeInfo
$a | Get-Member -MemberType *




# Get warranty information

get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_AssetExtendedWarrantyInformation
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_AssetWarrantyInformation


# whatever
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_vprosettings    


# Chassis information
get-ciminstance -Namespace root/DCIM/SYSMAN -Classname DCIM_Chassis


#  Commonly used classes in DCM

DCIM_Chassis – This class will provide chassis information of any system
DCIM_Battery – This class will give information on the inventory and monitoring information of the battery on any system
DCIM_Memory – This class will provide inventory information on the Processor memory
DCIM_Processor – This class will provide the inventory information on Processor
DCIM_PhysicalMemory – This class will provide the inventory information on Physical Slot memory
DCIM_NumericSensor – This class will provide the inventory and monitoring information on all numeric sensors like Voltage, Current, Temperature and Cooling devices(Fans)
DCIM_Slot – This class provides information on slot information on a system
DCIM_Card – This class provides inventory information on the cards installed on specific slots on the system
DCIM_Chip – This class provides inventory information of all the Chips on the system
DCIM_ControllerView – This class provides inventory and monitoring information of the raid controller
DCIM_PhysicaldiskView - This class provides inventory and monitoring information of Physical Disks connected to the raid controllers
DCIM_VirtualDiskView - This class provides inventory and monitoring information of Logical Disks connected to the raid controllers
DCIM_BiosElement - This class provides inventory information of BIOS
DCIM_BiosEnumeration - This class provides information on all the supported BIOS attributes on the system





#############################################################################

#  Get SSD Information
# Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName SMARTAttributeInfo   #  -Property *

Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_SMARTAttributeInfo | Out-GridView


#  Get Free Disk Space
 gwmi win32_logicaldisk  | Format-Table DeviceId, @{ n = "Size in GB"; e = { [math]::Round($_.Size/1GB, 2) } }, @{ n = "FreeSpace in GB"; e = { [math]::Round($_.FreeSpace/1GB, 2) } } 






#############################################################################

#  EventLog Section

#############################################################################

# Create your own error code so you can query for it
$user1 = [Environment]::UserName
# New-EventLog -LogName System -Source "Dell Command | Monitor"
Write-EventLog -LogName System -Source "Dell Command | Monitor" -EntryType Error -EventId 1999 -Message "Fan HealthState = 25"


# Find exact spelling of DCM in EventLog
Get-EventLog -LogName System |Select-Object Source -Unique   #  It should be Dell Command | Monitor


# Get all Dell Command | Monitor info including ID
cls
get-eventlog -log system -source "Dell Command | Monitor"  | Out-GridView


# Get specific ID information
get-eventlog -log system -source "Dell Command | Monitor" | where {$_.eventID -eq 2030}


#  Get specific ID information using a HashTable
Get get-winevent -FilterHashtable @{Logname='System';ID=2030}  -MaxEvents 100




#############################################################################

#  EventLog Section write to Excel

#  Note:  you need Excell for this to work

#############################################################################

# Get Errors from the System section in the EventLog

clear-host

$servers = Read-Host "Enter Machine Name"   
$EventType = "System"
$EventType = $EventType -replace '"' -replace "'"



#Format Excel sheet
$objExcel = New-Object -comobject Excel.Application
$objExcel.visible = $True 
$objWorkbook = $objExcel.Workbooks.Add()
$objSheet = $objWorkbook.Worksheets.Item(1)
$objSheet.Cells.Item(1,1) = "Computer"
$objSheet.Cells.Item(1,2) = "LogName"
$objSheetFormat = $objSheet.UsedRange
$objSheetFormat.Interior.ColorIndex = 19
$objSheetFormat.Font.ColorIndex = 11
$objSheetFormat.Font.Bold = $True
$row = 1

foreach ($server in $servers)
{
    $row = $row + 1
    $objSheet.Cells.Item($row,1).Font.Bold = $True
    $objSheet.Cells.Item($row,1) = $server
    $AppLog = Get-Eventlog system -Newest 100 # | where {$_.entryType -Match "Error"}  
    $row = $row + 1
    $objSheet.Cells.Item($row,1).Font.Bold = $True
    $objSheet.Cells.Item($row,2) = 'ERROR'
        foreach ($AppEvent in $AppLog)
        {
        $row = $row + 1
        $objSheet.Cells.Item($row,3) = $AppEvent.TimeGenerated
        $objSheet.Cells.Item($row,4) = $AppEvent.Source
        $objSheet.Cells.Item($row,5) = $AppEvent.Message
        }
}
$objSheetFormat = $objSheet.UsedRange
$objSheetFormat.EntireColumn.AutoFit()
$objSheetFormat.RowHeight = 15



#############################################################################
 





