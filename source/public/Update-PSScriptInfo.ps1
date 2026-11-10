function Update-PSScriptInfo
{
    <#
        .DESCRIPTION
            Replaces PSScriptInfo settings. Properties defined the properties
            parameter that do not exist in the existing PSScriptInfo are added,
            already existing settings set to $null are removed and existing
            properties with a non-null value are updated.
        .PARAMETER FilePath
            File path to file to update PSScriptInfo in.
        .PARAMETER Properties
            Hashtable with properties to add,remove and change.
        .EXAMPLE
            Update-PSScriptInfo -Filepath C:\Script\Get-Test.ps1 -Properties @{Version="1.0.0.1";IsPreRelease=$null;IsReleased=$true}

            Assuming that the specified file contains a PSScriptInfo block with the properties Version:"0.0.1.4" and IsPreRelease="true" this example would
            - Update version
            - Remove IsPreRelease
            - Add IsReleased

            <#PSScriptInfo
            {
                "Version":"1.0.0.1",
                "IsReleased":"true"
            }
            PSScriptInfo#>
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'No system state changed')]
    [CmdletBinding()] # Enabled advanced function support
    param(
        [ValidateScript( { Test-Path -Path $_.FullName -PathType Leaf })]
        [Parameter(Mandatory)]
        [system.io.fileinfo]
        $FilePath,

        [hashtable]
        $Properties
    )

    PROCESS
    {
        try
        {
            $PSScriptInfo = Get-PSScriptInfo -FilePath $FilePath -ErrorAction Stop
            Write-Verbose 'Found existing PSScriptInfo'
        }
        catch
        {
            throw "Could not collect existing PSScriptInfo to update. Error: $PSItem"
        }

        foreach ($key in $Properties.keys)
        {
            # Missing attribute, add
            if ($PSScriptInfo.PSObject.Properties.Name -notcontains $key)
            {
                $PSScriptInfo | Add-Member -Name $Key -MemberType NoteProperty -Value $Properties[$key]
            }
            # Existing attribute
            else
            {
                # Remove if property is set to null
                if ($null -eq $Properties[$key])
                {
                    $PSScriptInfo = $PSScriptInfo | Select-Object -Property * -ExcludeProperty $key
                }
                # Not null, update value
                else
                {
                    $PSScriptInfo.$Key = $Properties[$key]
                }
            }
        }

        try
        {
            $JSON = $PSScriptInfo | ConvertTo-Json -ErrorAction Stop
            Write-Verbose -Message 'Converted updated PSScriptInfo to JSON'
        }
        catch
        {
            throw 'Failed to convert new PSScriptInfo to JSON'
        }

        try
        {
            $RemovedPosition = Remove-PSScriptInfo -FilePath $FilePath -ErrorAction Stop
            Write-Verbose -Message 'Removed old PSScriptInfo from file'
        }
        catch
        {
            throw "Failed to remove old PSScriptInfo from file with error: $PSItem"
        }

        try
        {
            Set-PSScriptInfo -FilePath $FilePath -JSON $JSON -InsertAt $RemovedPosition.StartOffSet -ErrorAction Stop
            Write-Verbose -Message 'Added updated PSScriptInfo to file'
        }
        catch
        {
            throw "Failed to add updated PSScriptInfo to file with error: $PSItem"
        }
    }
}
#endregion
