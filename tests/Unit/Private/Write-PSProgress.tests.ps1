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
                }) }
    ).BaseName

    Import-Module $ProjectName -Force
}

InModuleScope $ProjectName {
    Describe Write-PSProgress {
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
