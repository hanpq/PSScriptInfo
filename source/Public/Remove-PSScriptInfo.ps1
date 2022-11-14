function Remove-PSScriptInfo
{
    <#
        .DESCRIPTION
            Removes a PSScriptInfo block from a script file
        .PARAMETER FilePath
            Path to file where PSScriptInfo block should be removed
        .EXAMPLE
            Remove-PSScriptInfo -FilePath C:\Script\file.ps1
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'No system state changed')]
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
        $PSScriptInfo = $astTokens.where{ $_.kind -eq 'comment' -and $_.text.Replace("`r", '').Split("`n")[0] -like '<#PSScriptInfo*' }
        Write-Verbose -Message 'Parsed powershell script file and extracted raw PSScriptInfoText'


        if (-not $PSScriptInfo)
        {
            throw 'No PSScriptInfo found in file'
        }

        $StartLine = $PSScriptInfo.extent.StartLineNumber
        $EndLine = $PSScriptInfo.extent.EndLineNumber

        # Read file
        try
        {
            $FileContent = Get-Content -Path $FilePath -ErrorAction Stop
            Write-Verbose -Message 'Collected file content'
        }
        catch
        {
            throw "Failed to read file content with error: $PSItem"
        }

        # Exclude PSScriptInfo
        $NewContent = @($FileContent | Select-Object -First ($StartLine - 1) -ErrorAction stop) + @($FileContent | Select-Object -Skip ($EndLine) -ErrorAction Stop)
        Write-Verbose -Message 'Concatinated content around removed PSScriptInfo'

        # Write content back to file
        try
        {
            $NewContent | Set-Content -Path $FilePath -ErrorAction Stop
            Write-Verbose -Message 'Wrote content to back to file'
        }
        catch
        {
            throw "Failed to write content back to file with error: $PSItem"
        }

        return ([pscustomobject]@{
                StartLine   = $StartLine
                EndLine     = $EndLine
                StartOffset = $PSScriptInfo.extent.StartOffset
                EndOffset   = $PSScriptInfo.extent.EndOffset
            })

    }
}
