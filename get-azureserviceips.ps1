<#
.SYNOPSIS
  This script will fetch and return Azure IP Ranges, as updated weekly.
.DESCRIPTION
  This script will pull all the ip address ranges for Azure services, as defined by Microsoft. The
  file pulled is maintained by MS and updated weekly, this merely automates the data fetch.
.EXAMPLE
  Get-AzureServiceIPs

  This will will fetch every subnet range defined by MS.  Note that this does not filter overlaps for different services, so some entries will be redundant.
  
  Note: MS does have a service simply labeled AzureCloud that appears to be a complete IP range list deduped.  Use the next example to test.
.EXAMPLE
  NGet-AzureServiceIPs -Name "AzureDataLake"

  This will download only IP ranges associated with AzureDataLake. This entry is an array, so mulitple services can be requested if desired
.EXAMPLE
  NGet-AzureServiceIPs -Pretty

  This will download all IPs but display them an a format with a header and footer, making it easier to read for users, useful for those who requested multiple services.
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
if ($FetchRawJson) {
  Write-Output $AzureIPRanges.values | ConvertTo-Json
}
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
  Write-Output $requestedSubnets
}