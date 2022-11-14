function Set-PSScriptInfo
{
    <#
        .DESCRIPTION
            Adds a PSScriptInfo block to a file
        .PARAMETER FilePath
            FilePath for file to set PSScriptInfo for
        .PARAMETER JSON
            String value containing json formatted PSScriptInfo
        .PARAMETER InsertAt
            Defines the row number to insert the PSScriptInfo block.
        .EXAMPLE
            Set-PSScriptInfo -Filepath C:\Script\Get-Test.ps1 -JSON $JSON
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'No system state changed')]
    [CmdletBinding()]
    param(
        [ValidateScript( { Test-Path $_.FullName -PathType Leaf })]
        [Parameter(Mandatory)]
        [System.IO.FileInfo]
        $FilePath,

        [Parameter(Mandatory)]
        [string]
        $JSON,

        [int]
        $InsertAt = 0
    )

    try
    {
        $null = $JSON | ConvertFrom-Json -ErrorAction Stop
        Write-Verbose 'Tested JSON input for valid JSON'
    }
    catch
    {
        throw 'Failed to parse input JSON, input is not valid JSON'
    }

    # Increase indent from two to four
    $JSON.Replace('  ', '    ')

    $JSON = ("<#PSScriptInfo$([system.environment]::NewLine){0}$([system.environment]::NewLine)PSScriptInfo#>$([system.environment]::NewLine)" -f $JSON)
    Write-Verbose 'Added prefix and suffix to JSON block'

    try
    {
        $FileContent = Get-Content -Path $FilePath -ErrorAction Stop
        Write-Verbose -Message ('Read content from filepath')
    }
    catch
    {
        throw ('Failed to read content from filepath with error: {0}' -f $_.exception.message)
    }

    $StringBuilder = [System.Text.StringBuilder]::new(($FileContent) -join ([system.environment]::NewLine))
    Write-Verbose -Message ('Created stringbuilder')

    $null = $StringBuilder.Insert($InsertAt, ($JSON))
    Write-Verbose -Message ('Inserted PSScriptInfo at beginning of content block')

    try
    {
        $StringBuilder.ToString() | Set-Content -Path $FilePath -Encoding utf8 -ErrorAction Stop
        Write-Verbose -Message ('Successfully wrote content block back to file')
    }
    catch
    {
        throw ('Failed to write content block back to file with error: {0}' -f $_.exception.message)
    }
}
