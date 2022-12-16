> :warning: **IMPORTANT**
> This module is early in it´s development phase. Many API function and features are not yet available. You are welcome to contribute on GitHub to accelerate progress further.

# PSScriptInfo

This project has adopted the following policies [![CodeOfConduct](https://img.shields.io/badge/Code%20Of%20Conduct-gray)](https://github.com/hanpq/PSScriptInfo/blob/main/.github/CODE_OF_CONDUCT.md) [![Contributing](https://img.shields.io/badge/Contributing-gray)](https://github.com/hanpq/PSScriptInfo/blob/main/.github/CONTRIBUTING.md) [![Security](https://img.shields.io/badge/Security-gray)](https://github.com/hanpq/PSScriptInfo/blob/main/.github/SECURITY.md)

## Project status
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/hanpq/PSScriptInfo/build.yml?branch=main&label=build&logo=github)](https://github.com/hanpq/PSScriptInfo/actions/workflows/build.yml) [![Codecov](https://img.shields.io/codecov/c/github/hanpq/PSScriptInfo?logo=codecov&token=qJqWlwMAiD)](https://codecov.io/gh/hanpq/PSScriptInfo) [![Platform](https://img.shields.io/powershellgallery/p/PSScriptInfo?logo=ReasonStudios)](https://img.shields.io/powershellgallery/p/PSScriptInfo) [![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSScriptInfo?label=downloads)](https://www.powershellgallery.com/packages/PSScriptInfo) [![License](https://img.shields.io/github/license/hanpq/PSScriptInfo)](https://github.com/hanpq/PSScriptInfo/blob/main/LICENSE) [![docs](https://img.shields.io/badge/docs-getps.dev-blueviolet)](https://getps.dev/modules/PSScriptInfo/getstarted) [![changelog](https://img.shields.io/badge/changelog-getps.dev-blueviolet)](https://github.com/hanpq/PSScriptInfo/blob/main/CHANGELOG.md) ![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/hanpq/PSScriptInfo?label=version&sort=semver) ![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/hanpq/PSScriptInfo?include_prereleases&label=prerelease&sort=semver)

## About

This module lets you update and manage a PSScriptInfo block at the beginning of each script file. This can be used keep track of version specific information about the script. Examples of information to keep in the PSScriptInfo block could be version, unique guid, tags, date created, date updated, changelog, release note, copyright, links to license, project, docs etc.

The PSScriptInfo block is wrapped with the following script block tags "<#PSScriptInfo" and "PSScriptInfo#>". The content within the block is in JSON format for easy parsing and manual updating.

```powershell
<#PSScriptInfo
{
    "Version" : "1.0.0.0",
    "GUID" : "a3002a7c-0870-4b5f-8bed-cd31f7f23432",
    "DateCreated" : "2021-03-29",
    "DateUpdated" : "2021-03-30",
    "ProjectSite" : "https://getps.dev"
}
PSScriptInfo#>

param (
    $param1,
    $param2
)
```


## Installation

### PowerShell Gallery

To install from the PowerShell gallery using PowerShellGet run the following command:

```powershell
Install-Module PSScriptInfo -Scope CurrentUser
```

## Usage

### Add a new PSScriptInfo

To add a new PSScriptInfo block to a file that does not already have a PSScriptInfo block use the <code>Add-PSScriptInfo</code> cmdlet. The cmdlet takes two parameters, filepath that defines the file that you want to add a PSScriptInfo block to and Properties. Properties should be a hashtable where each key will be a root item in the PSScriptInfo block. 

```powershell
Add-PSScriptInfo -FilePath C:\Script\File.ps1 -Properties @{
    Version = "1.0.0.0"
    DateCreated = "2021-03-30"
}
```

Add-PSScriptInfo will throw if there is a existing PSScriptInfo in the file specified. Either specify <code>-force</code> to overwrite the existing PSScriptInfo block or use <code>Update-PSScriptInfo</code> to modify an existing PSScriptInfo block.

### Get a PSScriptInfo block

To read the PSScriptInfo block from a file use the <code>Get-PSScriptInfo</code> cmdlet. This will read the PSScriptInfo block and return a PSCustomObject with all configured properties.

```powershell
Get-PSScriptInfo -FilePath C:\Script\File.ps1

Version      : 1.0.0.0
DateCreated  : 2021-03-30
```

### Remove a PSScriptInfo block

To remove a PSScriptBlock completly use the <code>Remove-PSScriptInfo</code> cmdlet. This cmdlet will remove the whole PSScriptInfo block. (Use <code>Update-PSScriptInfo</code> to remove individual properties from a PSScriptInfo)

```powershell
Remove-PSScriptInfo -FilePath C:\Script\File.ps1
```

### Update a PSScriptInfo block

To update a PSScriptInfo block within a file use the <code>Update-PSScriptInfo</code> cmdlet. The cmdlet has two parameters, filepath and properties. The properties parameter expects a hashtable. Keys that does is not present in the existing PSScriptInfo will be added, keys that already exist will be updated with the specified value except if the value is set to $null, then the property will be removed.

Assuming the file C:\Script\file.ps1 has the following content

```powershell
<#PSScriptInfo
{
    "Version" : "1.0.0.0",
    "GUID" : "a3002a7c-0870-4b5f-8bed-cd31f7f23432",
    "DateCreated" : "2021-03-29",
    "DateUpdated" : "2021-03-30",
    "ProjectSite" : "https://getps.dev"
}
PSScriptInfo#>

function foo {

}
```

The following example will remove the key guid

```powershell
Update-PSScriptInfo -FilePath C:\Script\file.ps1 -Properties @{
    guid = $null
}
```

To add a new key simple add the key in the hashtable

```powershell
Update-PSScriptInfo -FilePath C:\Script\file.ps1 -Properties @{
    LicenseURL = 'https://getps.dev'
}
```

To update an existing value, specify the key with the same name and the new value

```powershell
Update-PSScriptInfo -FilePath C:\Script\file.ps1 -Properties @{
    Version = '1.0.0.1'
    DateUpdated = (get-date)
}
```
