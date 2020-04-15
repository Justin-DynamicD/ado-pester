  
#Requires -Modules Pester

param ()

# This list is populated from 'https://docs.microsoft.com/en-us/azure/devops/organizations/security/allow-list-ip-url?view=azure-devops'
# MS does not provide a json download that I can find

$testURLS = [System.Collections.ArrayList]@(
  # signin and licensing
  [PSCustomObject]@{url = "management.core.windows.net"; ports = @(443)}
  [PSCustomObject]@{url = "login.microsoftonline.com"; ports = @(443)}
  [PSCustomObject]@{url = "login.live.com"; ports = @(443)}
  [PSCustomObject]@{url = "go.microsoft.com"; ports = @(443)}
  [PSCustomObject]@{url = "graph.windows.net"; ports = @(443)}
  [PSCustomObject]@{url = "app.vssps.dev.azure.com"; ports = @(443)}
  [PSCustomObject]@{url = "app.vssps.visualstudio.com"; ports = @(443)}
  [PSCustomObject]@{url = "aadcdn.msauth.net"; ports = @(443)}
  [PSCustomObject]@{url = "aadcdn.msftauth.net"; ports = @(443)}
  [PSCustomObject]@{url = "amcdn.msftauth.net"; ports = @(443)}

  # additional signin
  [PSCustomObject]@{url = "windows.net"; ports = @(443)}
  [PSCustomObject]@{url = "visualstudio.com"; ports = @(443)}
  [PSCustomObject]@{url = "microsoft.com"; ports = @(443)}
  [PSCustomObject]@{url = "live.com"; ports = @(443)}
  [PSCustomObject]@{url = "dev.azure.com"; ports = @(443)}
  [PSCustomObject]@{url = "management.core.windows.net"; ports = @(443)}
  [PSCustomObject]@{url = "aex.dev.azure.com"; ports = @(443)}
  [PSCustomObject]@{url = "app.vssps.dev.azure.com"; ports = @(443)}
  [PSCustomObject]@{url = "app.vssps.visualstudio.com"; ports = @(443)}
  [PSCustomObject]@{url = "vstsagentpackage.azureedge.net"; ports = @(443)}
  [PSCustomObject]@{url = "static2.sharepointonline.com"; ports = @(443)}
  #[PSCustomObject]@{url = "vstmrblob.vsassets.io"; ports = @(443)}

  # CDNs
  [PSCustomObject]@{url = "cdn.vsassets.io"; ports = @(443)}
  #[PSCustomObject]@{url = "vsassets.io"; ports = @(443)}
  #[PSCustomObject]@{url = "vsassetscdn.azure.cn"; ports = @(443)}
  #[PSCustomObject]@{url = "gallerycdn.vsassets.io"; ports = @(443)}
  #[PSCustomObject]@{url = "gallerycdn.azure.cn"; ports = @(443)}

  # Azure Artifacts
  #[PSCustomObject]@{url = "blob.core.windows.net"; ports = @(443, 22)}

  # NuGet
  #[PSCustomObject]@{url = "azurewebsites.net"; ports = @(443)}
  [PSCustomObject]@{url = "nuget.org"; ports = @(443)}

  # SSH
  [PSCustomObject]@{url = "ssh.dev.azure.com"; ports = @(22)}
  [PSCustomObject]@{url = "vs-ssh.visualstudio.com"; ports = @(22)}
)

# Pester tests
Describe 'Check all Urls' {
  foreach ($url in $testURLS) {
    Context "$($url.url)" {
      foreach ($port in $url.ports) {
        It "Connect to port ${port}" {
          (Test-NetConnection $url.url -port $port).TcpTestSucceeded | Should -Be $true
        }
      }
    }
  }
}
