# Version="1.0.0.0"
# Product="" 　　　
# Copyright="Kenji Oshio" 
# Company=""
# Create New VM accoding to CSV Contents.
#
 
# Generate random number to use as a templorary file name.
$RANDOM = Get-Random 1000
 
#Set File Contents as an argument.
$FILE = $Args[0]
 
# File transfer to Unicode
$FILE_UNI = "$FILE.$RANDOM"
 
# Confirm whether an anargument file is exist or not. 
if(!$FILE) {
    Write-Host "There is no file as an agument."
    Write-Host "Please specify a csv file."
    exit 1
}
 
if(Test-Path $FILE) {
    Write-Host "$FILE の存在が確認できました。"
    } else {
    Write-Host "$FILE の存在が確認できませんでした。"
    Write-Host "処理を中断します。"
    exit 1
}
 
#Change the Charctor code to Unicde.
Get-Content $FILE | Out-File $FILE_UNI -Encoding UNICODE
 
# Esstablish a connection to vCenter
<#$VCenterServer ="Your Server"
$vCenterAdmin ="Your Account"
$vCenterAdminPWD ="Your Password"
Connect-VIServer -Server $VCenterServer -User $vCenterAdmin -Password $vCenterAdminPWD
#> 
# Import a CSV file.
$vms = Import-CSV $FILE_UNI
 
# Create a new VM according to list.
foreach ($vm in $vms) {
 
    #Set a VM configuration parameter.
    $VMName = $vm.VMName
    $OSType = $vm.OSType
    $Template = Get-Template $vm.Template
    $vSphereHost = Get-VMHost $vm.vSphereHost
    $Datastore = Get-Datastore $vm.Datastore
    $AdminFullName = $vm.AdminFullName
    $AdminPassword = $vm.AdminPassword
    $OrganizationName = $vm.OrgName
    $Ipaddress = $vm.Ipaddress
    $Subnetmask = $vm.Subnetmask
    $PrimaryDNS = $vm.PrimaryDNS
    $SecondaryDNS = $VM.SecondaryDNS
    $Gateway = $vm.Gateway
    $TimeZone = $vm.TimeZone
    $WorkGroup = $vm.WorkGroup

    
    # Set the OS config of the VM.
    $custSpec = New-OSCustomizationSpec -Type NonPersistent -OSType $OSType -OrgName $OrganizationName -FullName $AdminFullName -AdminPassword $AdminPassword `
     -Workgroup $WorkGroup -TimeZone $TimeZone -ChangeSid  -NamingScheme vm

    #Set the network configuration of the VM.
    $custSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP `
    -IpAddress $Ipaddress -SubnetMask $Subnetmask -Dns $PrimaryDNS,$SecondaryDNS -DefaultGateway $Gateway 

    # Main Processing: Create a new VM.
    New-VM -Name $VMName -OSCustomizationSpec $custSpec `
    -Template $Template -VMHost $vSphereHost -Datastore $Datastore -RunAsync
 
}
 
#Dissconnet a session to vCenter Server
#Disconnect-VIServer -Confirm:$false
 
# Delete a Unicoded file.
Remove-Item $FILE_UNI