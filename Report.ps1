


cls


 

# $pc = (Get-ADComputer -Filter * -SearchBase "ou=acme_workstations,dc=Acme,dc=org").Name



$results = @()
$pc = "PC7560Dell"
 

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
    $BatteryHealth = (Get-CimInstance -Namespace root/DCIM/SYSMAN -ClassName DCIM_Battery).HealthState

     [PSCustomObject]@{
        PCName=$computerName
        'OS Version'=$osInfo.Version
        'OS Type'=$osInfo.Caption
        # 'IP vLan'=$getip
        # 'Description'=$desc
        'Manufacturer'=$BIOSMan
        'Model'=$computerModel
        'BIOS Version'=$BIOSVer
        'Computer Asset Tag'=$ComputerAssetTag
        'Fan Health State' = $FanHealth
        'Battery Health State' = $BatteryHealth
        'Dock Asset Tag'  = $DockAssetTag
        }
     }
 

}


$Results | Out-GridView -Title "Computer Information"