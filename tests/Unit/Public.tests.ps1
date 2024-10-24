BeforeDiscovery {
    $RootItem = Get-Item $PSScriptRoot
    while ($RootItem.GetDirectories().Name -notcontains 'source')
    {
        $RootItem = $RootItem.Parent
    }
    $ProjectPath = $RootItem.FullName
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
    Describe 'Add-PSScriptInfo' -Fixture {
        BeforeAll {
        }
        Context -Name 'When file exists but PSScriptInfo throws' {
            BeforeAll {
                $File = New-Item TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo -MockWith { $true }
            }
            It -Name 'Should throw' {
                { Add-PSScriptInfo -FilePath $File.FullName -Properties @{Version = '1.0.0.0' } } | Should -Throw
            }
        }
        Context -Name 'When file exists and valid PSScriptInfo is found' {
            BeforeAll {
                $File = New-Item TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo -MockWith {}
                function Remove-PSScriptInfo
                {
                }
                Mock Remove-PSScriptInfo -MockWith {}
                function Set-PSScriptInfo
                {
                }
                Mock Set-PSScriptInfo -MockWith {}
            }
            It -Name 'Should not throw' {
                { Add-PSScriptInfo -FilePath $File.FullName -Properties @{Version = '1.0.0.0' } } | Should -Not -Throw
            }
        }
        Context -Name 'When PSScriptInfo is found but force is specified' {
            BeforeAll {
                $File = New-Item TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo -MockWith { $true }
                function Remove-PSScriptInfo
                {
                }
                Mock Remove-PSScriptInfo -MockWith {} -Verifiable
                function Set-PSScriptInfo
                {
                }
                Mock Set-PSScriptInfo -MockWith {}
            }
            It -Name 'Should not throw' {
                { Add-PSScriptInfo -FilePath $File.FullName -Properties @{Version = '1.0.0.0' } -Force } | Should -Not -Throw
                Should -Invoke -CommandName Remove-PSScriptInfo -Times 1
            }
        }
        Context -Name 'When PSScriptInfo is found but force is specified and removal fails' {
            BeforeAll {
                $File = New-Item TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo -MockWith { $true }
                function Remove-PSScriptInfo
                {
                }
                Mock Remove-PSScriptInfo -MockWith { throw }
                function Set-PSScriptInfo
                {
                }
                Mock Set-PSScriptInfo -MockWith {}
            }
            It -Name 'Should throw' {
                { Add-PSScriptInfo -FilePath $File.FullName -Properties @{Version = '1.0.0.0' } -Force } | Should -Throw
            }
        }
        Context -Name 'When Get-PSScriptInfo fails and force is not specified' {
            BeforeAll {
                $File = New-Item TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Add-PSScriptInfo -FilePath $File.FullName -Properties @{Version = '1.0.0.0' } } | Should -Throw
            }
        }
        Context -Name 'When file exists but convert to json fails' {
            BeforeAll {
                $File = New-Item TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo -MockWith {}
                function Set-PSScriptInfo
                {
                }
                Mock Set-PSScriptInfo -MockWith {}
                Mock ConvertTo-JSON -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Add-PSScriptInfo -FilePath $File.FullName -Properties @{Version = '1.0.0.0' } } | Should -Throw
            }
        }
        Context -Name 'When Set-PSScriptInfo fails' {
            BeforeAll {
                $File = New-Item TestDrive:\file.ps1
                function Get-PSScriptInfo
                {
                }
                Mock Get-PSScriptInfo -MockWith {}
                function Set-PSScriptInfo
                {
                }
                Mock Set-PSScriptInfo -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Add-PSScriptInfo -FilePath $File.FullName -Properties @{Version = '1.0.0.0' } } | Should -Throw
            }
        }
    }

    Describe 'Get-PSScriptInfo' -Fixture {
        BeforeAll {
        }
        Context 'When parsing files failed' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value 'function {}}'
                function New-Variable
                {
                }
                Mock -CommandName New-Variable -MockWith { throw }
            }
            It -Name 'Should throw' {
                Mock -CommandName New-Variable -MockWith { throw }
                { Get-PSScriptInfo -FilePath $file.fullname } | Should -Throw
            }
        }
        Context -Name 'When file do not exist' {
            It 'Should throw' {
                { Get-PSScriptInfo -FilePath 'C:\Script\file.ps1' } | Should -Throw
            }
        }
        Context -Name 'When file exist but is not valid powershell' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value 'function {}}'
            }
            It 'Should throw' {
                { Get-PSScriptInfo -FilePath $file.fullname } | Should -Throw
            }
        }
        Context -Name 'When file exist but no valid psscriptinfo is found' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value 'function {}'
            }
            It 'Should throw' {
                { Get-PSScriptInfo -FilePath $file.fullname } | Should -Throw
            }
        }
        Context -Name 'When file exist and psscriptinfo is found but JSON is invalid' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n{{`n`r`"Version`":`"1.0.0.0`"`n`r}`nPSScriptInfo#>`nGet-Test`r`n"
            }
            It 'Should throw' {
                { Get-PSScriptInfo -FilePath $file.fullname } | Should -Throw
            }
        }
        Context -Name 'When file exist and legacy psscriptinfo is found' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n`r.VERSION 1.0.0.0`n`r#>`r`nGet-Test`r`n"
                function Get-PSScriptInfoLegacy
                {
                }
                Mock Get-PSScriptInfoLegacy -MockWith {}
            }
            It 'Should not throw' {
                { Get-PSScriptInfo -FilePath $file.fullname } | Should -Not -Throw
            }
        }
        Context -Name 'When file exist and valid psscriptinfo is found' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n{`n`r`"Version`":`"1.0.0.0`"`n`r}`nPSScriptInfo#>`nGet-Test`r`n"
            }
            It 'Should not throw' {
                { Get-PSScriptInfo -FilePath $file.fullname } | Should -Not -Throw
            }
            It 'Should return PSCustomobject' {
                $PSScriptInfo = Get-PSScriptInfo -FilePath $file.fullname
                $PSScriptInfo | Should -BeOfType [psobject]
                $PSScriptInfo.Version = '1.0.0.0'
            }
        }
    }

    Describe 'Remove-PSScriptInfo' -Fixture {
        BeforeAll {
        }
        Context 'When parsing files failed' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value 'function {}}'
                function New-Variable
                {
                }
                Mock -CommandName New-Variable -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Remove-PSScriptInfo -FilePath $file.fullname } | Should -Throw
            }
        }
        Context -Name 'When file do not exist' {
            It 'Should throw' {
                { Remove-PSScriptInfo -FilePath 'C:\Script\file.ps1' } | Should -Throw
            }
        }
        Context -Name 'When file exist but is not valid powershell' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value 'function {}}'
            }
            It 'Should throw' {
                { Remove-PSScriptInfo -FilePath $file.fullname } | Should -Throw
            }
        }
        Context -Name 'When getting content fails' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n{`n`r`"Version`":`"1.0.0.0`"`n`r}`nPSScriptInfo#>`nGet-Test`r`n"
                Mock Get-Content -MockWith { throw }
            }
            It 'Should throw' {
                { Remove-PSScriptInfo -FilePath $file.fullname } | Should -Throw
            }
        }
        Context -Name 'When setting content fails' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n{`n`r`"Version`":`"1.0.0.0`"`n`r}`nPSScriptInfo#>`nGet-Test`r`n"
                Mock Set-Content -MockWith { throw }
            }
            It 'Should throw' {
                { Remove-PSScriptInfo -FilePath $file.fullname } | Should -Throw
            }
        }
        Context -Name 'When file is valid and contains valid psscriptinfo' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n{`n`r`"Version`":`"1.0.0.0`"`n`r}`nPSScriptInfo#>`nGet-Test`r`n"
            }
            It 'Should not throw' {
                { Remove-PSScriptInfo -FilePath $file.fullname } | Should -Not -Throw
            }
        }
    }

    Describe 'Update-PSScriptInfo' -Fixture {
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
