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
    Describe -Name 'Get-PSScriptInfo.ps1' -Fixture {
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
}
