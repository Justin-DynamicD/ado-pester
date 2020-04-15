param (
  [Parameter(Mandatory = $false)][string]$AzureIPRangeURL = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519",
  [Parameter(Mandatory = $false)][Alias("azServices")][array]$AzureServiceNames, # example 'AzureDataLake'
  [Parameter(Mandatory = $false)][switch]$Pretty,
  [Parameter(Mandatory = $false)][switch]$FetchRawJson
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