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
                }) }
    ).BaseName

    Import-Module $ProjectName -Force
}

InModuleScope $ProjectName {
    Describe 'Assert-FolderExist' {
        Context 'Default' {
            It 'Folder is created' {
                'TestDrive:\FolderDoesNotExists' | Assert-FolderExist
                'TestDrive:\FolderDoesNotExists' | Should -Exist
            }

            It 'Folder is still present' {
                New-Item -Path 'TestDrive:\FolderExists' -ItemType Directory
                'TestDrive:\FolderExists' | Assert-FolderExist
                'TestDrive:\FolderExists' | Should -Exist
            }
        }
    }

    Describe 'Get-PSScriptInfoLegacy' -Fixture {
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

    Describe 'Invoke-GarbageCollect' {
        Context 'Default' {
            It 'Should not throw' {
                { Invoke-GarbageCollect } | Should -Not -Throw
            }
        }
    }

    Describe 'pslog' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { [datetime]'2000-01-01 01:00:00+00:00' }
            $CompareString = ([datetime]'2000-01-01 01:00:00+00:00').ToString('yyyy-MM-ddThh:mm:ss.ffffzzz')
        }
        Context 'Success' {
            It 'Log file should have content' {
                pslog -Severity Success -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tSuccess`tdefault`tMessage"
            }
        }
        Context 'Info' {
            It 'Log file should have content' {
                pslog -Severity Info -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tInfo`tdefault`tMessage"
            }
        }
        Context 'Warning' {
            It 'Log file should have content' {
                pslog -Severity Warning -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tWarning`tdefault`tMessage"
            }
        }
        Context 'Error' {
            It 'Log file should have content' {
                pslog -Severity Error -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tError`tdefault`tMessage"
            }
        }
        Context 'Verbose' {
            It 'Log file should have content' {
                pslog -Severity Verbose -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole -Verbose:$true
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tVerbose`tdefault`tMessage"
            }
        }
        Context 'Debug' {
            It 'Log file should have content' {
                pslog -Severity Debug -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole -Debug:$true
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tDebug`tdefault`tMessage"
            }
        }
    }

    Describe 'Set-PSScriptInfo' -Fixture {
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

    Describe 'Write-PSProgress' {
        Context 'Default' {
            It 'Should not throw' {
                $ProgressPreference = 'SilentlyContinue'
                {
                    1..5 | ForEach-Object -Begin { $StartTime = Get-Date } -Process {
                        Write-PSProgress -Activity 'Looping' -Target $PSItem -Counter $PSItem -Total 5 -StartTime $StartTime
                    }
                } | Should -Not -Throw
            }
        }
    }
}
