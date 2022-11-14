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
    Describe -Name 'Get-PSScriptInfoLegacy.ps1' -Fixture {
        BeforeAll {
        }
        Context 'When valid legacy PSScriptInfo is provided in file' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n`r.VERSION 1.0.0.0`n`r.AUTHOR John Doe`n`r#>`r`nGet-Test`r`n"
            }
            It -Name 'Should not throw' {
                { Get-PSScriptInfoLegacy -FilePath $file.fullname } | Should -Not -Throw
            }
        }
        Context 'When PSScriptInfo contains key CREATEDDATE' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n`r.CREATEDDATE 2020-01-01`n`r#>`r`nGet-Test`r`n"
            }
            It -Name 'Should not throw' {
                { Get-PSScriptInfoLegacy -FilePath $file.fullname } | Should -Not -Throw
            }
        }
        Context 'When PSScriptInfo contains key GUID' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n`r.GUID e8b0cd33-7895-451a-b08c-92529596d26e`n`r#>`r`nGet-Test`r`n"
            }
            It -Name 'Should not throw' {
                { Get-PSScriptInfoLegacy -FilePath $file.fullname } | Should -Not -Throw
            }
        }
        Context 'When PSScriptInfo contains key UNITTEST false' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n`r.UNITTEST false`n`r#>`r`nGet-Test`r`n"
            }
            It -Name 'Should not throw' {
                { Get-PSScriptInfoLegacy -FilePath $file.fullname } | Should -Not -Throw
            }
        }
        Context 'When PSScriptInfo contains key UNITTEST true' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n`r.UNITTEST true`n`r#>`r`nGet-Test`r`n"
            }
            It -Name 'Should not throw' {
                { Get-PSScriptInfoLegacy -FilePath $file.fullname } | Should -Not -Throw
            }
        }
        Context 'When PSScriptInfo contains key UNITTEST foo' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n`r.UNITTEST foo`n`r#>`r`nGet-Test`r`n"
            }
            It -Name 'Should not throw' {
                { Get-PSScriptInfoLegacy -FilePath $file.fullname } | Should -Not -Throw
            }
        }
        Context 'When PSScriptInfo contains key with string array' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n`r.ARRAY @(foo,bar)`n`r#>`r`nGet-Test`r`n"
            }
            It -Name 'Should not throw' {
                { Get-PSScriptInfoLegacy -FilePath $file.fullname } | Should -Not -Throw
            }
        }
        Context 'When PSScriptInfo contains key without value' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n`r.NONE `n`r#>`r`nGet-Test`r`n"
            }
            It -Name 'Should not throw' {
                { Get-PSScriptInfoLegacy -FilePath $file.fullname } | Should -Not -Throw
            }
        }
        Context 'When something fails' {
            BeforeAll {
                $file = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $file.fullname -Value "<#PSScriptInfo`n`r.NONE `n`r#>`r`nGet-Test`r`n"
                Mock Select-Object -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Get-PSScriptInfoLegacy -FilePath $file.fullname } | Should -Throw
            }
        }
    }
}
