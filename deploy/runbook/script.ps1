$connectionName = "AzureRunAsConnection"

try

{
    # Get the connection "AzureRunAsConnection "

    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName

    "Logging in to Azure..."
    $connectionResult =  Connect-AzAccount -Tenant $servicePrincipalConnection.TenantID `
                             -ApplicationId $servicePrincipalConnection.ApplicationID   `
                             -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint `
                             -ServicePrincipal
    "Logged in."

}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$mypath = "$env:USERPROFILE\Documents\AzureVM-Size-State-IP_$(get-date -format `"yyyyMMdd_hhmmsstt`").csv"
$mydata = @()

$ARMsubscriptions = Get-AzSubscription 

foreach($ARMsub in $ARMsubscriptions)
{
 Select-AzSubscription -SubscriptionName $ARMsub.Name
$vms = get-azvm -Status
$nics = get-aznetworkinterface | ?{ $_.VirtualMachine -NE $null}

foreach($nic in $nics)
  {
$info = "" | Select VmName, HostName, IpAddress, PowerState, OperatingSystemType, Subscription, Tags
$vm = $vms | ? -Property Id -eq $nic.VirtualMachine.id
$info.VMName = $vm.Name
$info.IpAddress = $nic.IpConfigurations.PrivateIpAddress -join " "
$info.HostName = $vm.OSProfile.ComputerName
$info.PowerState = $vm.PowerState
$info.OperatingSystemType = $vm.StorageProfile.OSDisk.OsType
$info.Subscription = $ARMsub.Name
$info.Tags = [system.String]::Join(" ", $vm.tags)
$mydata+=$info
  }
}

$mydata | Export-Csv -notypeinformation -Path $mypath

