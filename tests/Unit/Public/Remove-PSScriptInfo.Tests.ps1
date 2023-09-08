BeforeDiscovery {
        $RootItem = Get-Item $PSScriptRoot
    while ($RootItem.GetDirectories().Name -notcontains "source") {$RootItem = $RootItem.Parent}
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

InModuleScope $ProjectName { Describe -Name 'Remove-PSScriptInfo.ps1' -Fixture {
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
}
