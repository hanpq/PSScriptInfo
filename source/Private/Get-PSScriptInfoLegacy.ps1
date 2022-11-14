function Get-PSScriptInfoLegacy
{
    <#
        .DESCRIPTION
            Collect and parse psscriptinfo from file
        .PARAMETER FilePath
            Defines the path to the file from which to get psscriptinfo from.
        .EXAMPLE
            Get-PSScriptInfoLegacy -FilePath C:\temp\file.ps1
            Description of example
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })][Parameter(Mandatory)][string]$FilePath
    )

    PROCESS
    {
        try
        {
            $PSScriptInfo = [ordered]@{ }
            New-Variable astTokens -Force
            New-Variable astErr -Force
            $null = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$astTokens, [ref]$astErr)
            $FileContent = $astTokens.where{ $_.kind -eq 'comment' -and $_.text.Replace("`r", '').Split("`n")[0] -like '<#PSScriptInfo*' } | Select-Object -ExpandProperty text
            $FileContent = $FileContent.Replace("`r", '').Split("`n")
            $FileContent | Select-Object -Skip 1 | ForEach-Object {
                $CurrentRow = $PSItem
                if ($CurrentRow.Trim() -like '.*')
                {
                    # New attribute found, extract attribute name
                    $Attribute = $CurrentRow.Split('.')[1].Split(' ')[0]

                    # Check if row has value
                    if ($CurrentRow.Trim().Replace($Attribute, '').TrimStart('.').Trim().Length -gt 0)
                    {

                        # Value on same row
                        $Value = $CurrentRow.Trim().Split(' ', 2)[1].Trim()

                        # Datetime
                        if (@('CREATEDDATE' -contains $Attribute))
                        {
                            $Value = $Value -as [string]
                        }
                        # System version
                        if (@('VERSION' -contains $Attribute))
                        {
                            $Value = $Value -as [string]
                        }
                        # guid
                        if (@('GUID' -contains $Attribute))
                        {
                            $Value = $Value -as [guid]
                        }

                        if (@('UNITTEST' -contains $Attribute))
                        {
                            if ($Value -eq 'false')
                            {
                                $Value = $false
                            }
                            elseif ($Value -eq 'true')
                            {
                                $Value = $true
                            }
                            else
                            {
                                $Value = $null
                            }
                        }

                        # Add attribute and value to PSScriptInfo
                        $null = $PSScriptInfo.Add($Attribute, $Value)
                    }
                    else
                    {
                        # If no value is provided populate PSScriptInfo with attribute and an empty collection as value
                        $null = $PSScriptInfo.Add($Attribute, [collections.arraylist]::New())
                    }
                }
            }
            Write-Output ([pscustomobject]$PSScriptInfo)
        }
        catch
        {
            Write-Error -Message 'No valid PSScriptInfo was found in file' -ErrorRecord $_
        }
    }
}
