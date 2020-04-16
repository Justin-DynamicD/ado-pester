<#
.SYNOPSIS
  This script will fetch and return Azure IP Ranges, as updated weekly.
.DESCRIPTION
  This script will pull all the ip address ranges for Azure services, as defined by Microsoft. The
  file pulled is maintained by MS and updated weekly, this merely automates the data fetch.
.EXAMPLE
  Get-AzureServiceIPs

  This will will fetch every subnet range defined by MS.
  
  Note: MS does have a service simply labeled AzureCloud that appears to be a complete IP range list deduped. Not tested
.EXAMPLE
  Get-AzureServiceIPs -Name "AzureDataLake"

  This will download only IP ranges associated with AzureDataLake. This entry is an array, so mulitple services can be requested if desired.
  Resultng IP ranges are deduped.
.EXAMPLE
  Get-AzureServiceIPs -Pretty

  This will download all IPs but display them an a format with a header and footer, making it easier to read for users, useful for those who requested multiple services.
  Resulting IP Ranges are _not_ deduped for readability
.EXAMPLE
  NGet-AzureServiceIPs -FetchRawJson | out-file .\iplist.json

  This will bypass all filtering and other switches and return the raw json that is provided by MS.  The output is then piped to a file in this example.
#>

param (
  [Parameter(Mandatory = $false)][string]$AzureIPRangeURL = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519",
  [Parameter(Mandatory = $false)][Alias("azServices", "Name")][array]$AzureServiceNames,
  [Parameter(Mandatory = $false)][switch]$Pretty,
  [Parameter(Mandatory = $false)][Alias("Raw")][switch]$FetchRawJson
)

# download IP list
$requestedSubnets = [System.Collections.ArrayList]@()
$AzureIPRangesPage = Invoke-WebRequest -Uri $AzureIPRangeURL -Method Get -UseBasicParsing
[PSCustomObject]$AzureIPRanges = Invoke-RestMethod -Uri ($AzureIPRangesPage.Links | Where-Object {$_.outerhtml -like "*Click here*"}).href[0]

# if we just want the raw data ... end it here
if ($FetchRawJson) {
  Write-Output $AzureIPRanges.values | ConvertTo-Json
}

# if we want to filter the ip ranges, continue
else {
  # pull ip ranges for desired services
  Foreach ($azService in $Azureipranges.values) {
    if (!$AzureServiceNames -or ($azService.name -in $AzureServiceNames)) {
      if ($Pretty) {$requestedSubnets += $azService.name; $requestedSubnets += "----------"}
      Foreach ($ipsubnet in $azService.properties.addressPrefixes) {
        $requestedSubnets += $ipsubnet
      }
      if ($Pretty) {$requestedSubnets += ""}
    }
  }
  # dedupe
  if (!Pretty) {$requestedSubnets = $requestedSubnets | Select-Object -Unique}
  Write-Output $requestedSubnets
}
