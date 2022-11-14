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
    Describe -Name 'Add-PSScriptInfo.ps1' -Fixture {
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
}
