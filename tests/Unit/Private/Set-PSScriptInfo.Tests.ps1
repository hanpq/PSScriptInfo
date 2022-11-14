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
    Describe -Name 'Set-PSScriptInfo.ps1' -Fixture {
        BeforeAll {
        }
        Context -Name 'When passing valid JSON and file exists' {
            BeforeEach {
                $File = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $File.FullName -Value 'Get-Test'

            }
            AfterEach {
                Remove-Item $File.FullName
            }
            It -Name 'Should not throw' {
                { Set-PSScriptInfo -FilePath $File.FullName -JSON "{$([system.environment]::NewLine)`"Version`":`"1.0.0.0`"$([system.environment]::NewLine)}" } | Should -Not -Throw
            }
            It -Name 'Should contain correct content' {
                Set-PSScriptInfo -FilePath $File.FullName -JSON "{$([system.environment]::NewLine)`"Version`":`"1.0.0.0`"$([system.environment]::NewLine)}"
                Get-Content $File.FullName -Raw | Should -Be "<#PSScriptInfo$([system.environment]::NewLine){$([system.environment]::NewLine)`"Version`":`"1.0.0.0`"$([system.environment]::NewLine)}$([system.environment]::NewLine)PSScriptInfo#>$([system.environment]::NewLine)Get-Test$([system.environment]::NewLine)"
            }
        }
        Context -Name 'When passing invalid json' {
            BeforeEach {
                $File = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $File.FullName -Value 'Get-Test'

            }
            AfterEach {
                Remove-Item $File.FullName
            }
            It -Name 'Should throw' {
                { Set-PSScriptInfo -FilePath $File.FullName -JSON "$([system.environment]::NewLine)`"Version`":`"1.0.0.0`"$([system.environment]::NewLine)}" } | Should -Throw
            }
        }
        Context -Name 'When file does not exist' {
            It -Name 'Should throw' {
                { Set-PSScriptInfo -FilePath $File.FullName -JSON "{$([system.environment]::NewLine)`"Version`":`"1.0.0.0`"$([system.environment]::NewLine)}" } | Should -Throw
            }
        }
        Context -Name 'When file exists but content cannot be read' {
            BeforeEach {
                $File = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $File.FullName -Value 'Get-Test'
                Mock -CommandName Get-Content -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Set-PSScriptInfo -FilePath $File.FullName -JSON "{$([system.environment]::NewLine)`"Version`":`"1.0.0.0`"$([system.environment]::NewLine)}" } | Should -Throw
            }
        }
        Context -Name 'When writing to file fails' {
            BeforeEach {
                $File = New-Item -Path TestDrive:\file.ps1
                Set-Content -Path $File.FullName -Value 'Get-Test'
                Mock Set-Content -MockWith { throw }
            }
            AfterEach {
                Remove-Item $File.FullName
            }
            It -Name 'Should throw' {
                { Set-PSScriptInfo -FilePath $File.FullName -JSON "{$([system.environment]::NewLine)`"Version`":`"1.0.0.0`"$([system.environment]::NewLine)}" } | Should -Throw
            }
        }
    }
}
