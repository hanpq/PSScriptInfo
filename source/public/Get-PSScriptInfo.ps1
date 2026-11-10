function Get-PSScriptInfo
{
    <#
        .DESCRIPTION
            Collect and parse psscriptinfo from file
        .PARAMETER FilePath
            Defines the path to the file from which to get psscriptinfo from.
        .EXAMPLE
            Get-PSScriptInfo -FilePath C:\temp\file.ps1
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [ValidateScript( { Test-Path -Path $_.FullName -PathType Leaf })]
        [Parameter(Mandatory)]
        [system.io.fileinfo]
        $FilePath
    )

    PROCESS
    {
        # Read ast tokens from file
        try
        {
            New-Variable astTokens -Force -ErrorAction Stop
            New-Variable astErr -Force -ErrorAction Stop
            $null = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$astTokens, [ref]$astErr)
            Write-Verbose -Message 'Read file content'
        }
        catch
        {
            throw "Failed to read file content with error: $PSItem"
        }

        # Find PSScriptInfo comment token
        $PSScriptInfoText = $astTokens.where{ $_.kind -eq 'comment' -and $_.text.Replace("`r", '').Split("`n")[0] -like '<#PSScriptInfo*' } | Select-Object -ExpandProperty text -ErrorAction stop
        Write-Verbose -Message 'Parsed powershell script file and extracted raw PSScriptInfoText'

        if (-not $PSScriptInfoText)
        {
            throw 'No PSScriptInfo found in file'
        }

        # Extract PSScriptInfo from JSON
        try
        {
            $PSScriptInfoRaw = @($PSScriptInfoText.Split("`n") | Select-Object -Skip 1 -ErrorAction Stop | Select-Object -SkipLast 1 -ErrorAction Stop)
            $PSScriptInfo = $PSScriptInfoRaw | ConvertFrom-Json -ErrorAction Stop
            Write-Verbose -Message 'Parsed PSScriptInfo to JSON'
        }
        catch
        {
            if (($PSScriptInfoRaw[0].Trim() -like '.*') -and ($_.exception.message -like '*Invalid JSON primitive*' -or $_.exception.message -like '*Unexpected character encountered while parsing number*'))
            {
                # Legacy PSScriptInfo
                Write-Verbose -Message 'Standard JSON parsing failed, trying legacy...'
                $PSScriptInfo = Get-PSScriptInfoLegacy -FilePath $FilePath
            }
            else
            {
                throw "Failed to parse PSScriptInfo to JSON with error: $PSItem"
            }
        }

        return $PSScriptInfo
    }
}
