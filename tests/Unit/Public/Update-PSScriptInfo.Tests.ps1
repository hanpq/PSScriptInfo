BeforeDiscovery {
    $ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
    $ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
            ($_.Directory.Name -eq 'source') -and
            $(try
                {
                    Test-ModuleManifest $_.FullName -ErrorAction Stop
                }
                catch
                {
                    $false
                })
        }
    ).BaseName

    Import-Module $ProjectName -Force
}

InModuleScope $ProjectName {
    Describe -Name 'Update-PSScriptInfo.ps1' -Fixture {
        BeforeAll {
        }
        Context 'When parsing files failed' {
            It -Name 'Should throw' {
                Mock -CommandName New-Variable -MockWith { throw }
                { Update-PSScriptInfo -FilePath C:\Script\file.ps1 -Properties @{Version = '1.0.0.0' } } | Should -Throw
            }
        }
        Context 'When file does not exist' {
            It -Name 'Should throw' {
                { Update-PSScriptInfo -FilePath C:\Script\file.ps1 -Properties @{Version = '1.0.0.0' } } | Should -Throw
            }
        }
        Context 'When file exist but parameter properties is not of type hashtable' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
            }
            It -Name 'Should throw' {
                { Update-PSScriptInfo -FilePath $file.fullname -Properties 'foo' } | Should -Throw
            }
        }
        Context 'When file exist but Get-PSScriptInfo fails' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo { throw }
            }
            It -Name 'Should throw' {
                { Update-PSScriptInfo -FilePath $file.fullname -Properties @{Version = '1.0.0.0' } } | Should -Throw
            }
        }
        Context 'When file exist and PSScriptInfo is valid: Change' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo {
                    return ([pscustomobject]@{Version = '1.0.0.0' })
                }
                function Remove-PSScriptInfo
                {
                }
                Mock Remove-PSScriptInfo -MockWith {}
                function Set-PSScriptInfo
                {
                    param($FilePath, $JSON)
                }
                Mock Set-PSScriptInfo {
                    $JSON | ConvertFrom-Json
                }
            }
            It -Name 'Should not throw' {
                { Update-PSScriptInfo -FilePath $file.fullname -Properties @{Version = '2.0.0.0' } } | Should -Not -Throw
            }
            It -Name 'Should have expected content' {
                $Result = Update-PSScriptInfo -FilePath $file.fullname -Properties @{Version = '2.0.0.0' }
                $Result.Version | Should -Be '2.0.0.0'
            }
        }
        Context 'When file exist and PSScriptInfo is valid: Remove' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo {
                    return ([pscustomobject]@{Version = '1.0.0.0'; Author = 'Jane Doe' })
                }
                function Remove-PSScriptInfo
                {
                }
                Mock Remove-PSScriptInfo -MockWith {}
                function Set-PSScriptInfo
                {
                    param($FilePath, $JSON)
                }
                Mock Set-PSScriptInfo {
                    $JSON | ConvertFrom-Json
                }
            }
            It -Name 'Should not throw' {
                { Update-PSScriptInfo -FilePath $file.fullname -Properties @{Version = '2.0.0.0'; Author = $null } } | Should -Not -Throw
            }
            It -Name 'Should have expected content' {
                $Result = Update-PSScriptInfo -FilePath $file.fullname -Properties @{Version = '2.0.0.0'; Author = $null }
                $Result.Version | Should -Be '2.0.0.0'
                $Result.PSObject.Properties.Name | Should -Not -Contain 'Author'
            }
        }
        Context 'When file exist and PSScriptInfo is valid: Add' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo {
                    return ([pscustomobject]@{Version = '1.0.0.0' })
                }
                function Remove-PSScriptInfo
                {
                }
                Mock Remove-PSScriptInfo -MockWith {}
                function Set-PSScriptInfo
                {
                    param($FilePath, $JSON)
                }
                Mock Set-PSScriptInfo {
                    $JSON | ConvertFrom-Json
                }
            }
            It -Name 'Should not throw' {
                { Update-PSScriptInfo -FilePath $file.fullname -Properties @{Version = '2.0.0.0'; Author = 'Jane Doe' } } | Should -Not -Throw
            }
            It -Name 'Should have expected content' {
                $Result = Update-PSScriptInfo -FilePath $file.fullname -Properties @{Version = '2.0.0.0'; Author = 'Jane Doe' }
                $Result.Version | Should -Be '2.0.0.0'
                $Result.PSObject.Properties.Name | Should -Contain 'Author'
                $Result.Author | Should -Be 'Jane Doe'
            }
        }
        Context 'When ConvertFrom-Json fails' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo {
                    return ([pscustomobject]@{Version = '1.0.0.0' })
                }
                Mock ConvertTo-Json -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Update-PSScriptInfo -FilePath $file.fullname -Properties @{Version = '2.0.0.0'; Author = 'Jane Doe' } } | Should -Throw
            }
        }
        Context 'When Remove-PSScriptInfo fails' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo {
                    return ([pscustomobject]@{Version = '1.0.0.0' })
                }
                function Remove-PSScriptInfo
                {
                }
                Mock Remove-PSScriptInfo -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Update-PSScriptInfo -FilePath $file.fullname -Properties @{Version = '2.0.0.0'; Author = 'Jane Doe' } } | Should -Throw
            }
        }
        Context 'When Set-PSScriptInfo fails' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo {
                    return ([pscustomobject]@{Version = '1.0.0.0' })
                }
                function Remove-PSScriptInfo
                {
                }
                Mock Remove-PSScriptInfo -MockWith {}
                function Set-PSScriptInfo
                {
                }
                Mock Set-PSScriptInfo { throw }
            }
            It -Name 'Should throw' {
                { Update-PSScriptInfo -FilePath $file.fullname -Properties @{Version = '2.0.0.0'; Author = 'Jane Doe' } } | Should -Throw
            }
        }
    }
}
