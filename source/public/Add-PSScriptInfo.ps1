function Add-PSScriptInfo
{
    <#
        .DESCRIPTION
            Add new PSScriptInfo to file
        .PARAMETER FilePath
            File to add PSScriptInfo to
        .PARAMETER Properties
            HashTable (ordered dictionary) containing key value pairs for properties that should be included in PSScriptInfo
        .PARAMETER Force
            Use force to replace any existing PSScriptInfo block
        .EXAMPLE
            Add-PSScriptInfo -FilePath C:\Scripts\Do-Something.ps1 -Properties @{Version='1.0.0';Author='Jane Doe';DateCreated='2021-01-01'}
            Adds a PSScriptInfo block containing the properties version and author. Resulting PSScriptInfo block
            that would be added to the beginning of the file would look like:

            <#PSScriptInfo
            {
                "Version" : "1.0.0",
                "Author" : "Jane Doe",
                "DateCreated" : "2021-01-01"
            }
            PSScriptInfo#>
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [ValidateScript( { Test-Path $_.FullName -PathType Leaf })]
        [Parameter(Mandatory)]
        [System.IO.FileInfo]
        $FilePath,

        [hashtable]
        $Properties,

        [switch]
        $Force
    )

    BEGIN
    {
        # If PSScriptInfo exists and force is not specified; throw
        if ((Get-PSScriptInfo -FilePath $FilePath.FullName -ErrorAction SilentlyContinue) -and -not $Force)
        {
            throw 'PSScriptInfo already exists, use Update-PSScriptInfo to modify. Use force to overwrite existing PSScriptInfo'
        }
        elseif ((Get-PSScriptInfo -FilePath $FilePath.FullName -ErrorAction SilentlyContinue) -and $Force)
        {
            # If PSScriptInfo exists and force is specified remove PSScriptInfo before adding new
            try
            {
                Remove-PSScriptInfo -FilePath $FilePath.FullName -ErrorAction Stop
                Write-Verbose -Message 'Successfully removed PSScriptInfo'
            }
            catch
            {
                throw ('Failed to remove PSScriptInfo from file with error: {0}' -f $_.exception.message)
            }
        }
    }

    PROCESS
    {
        # Try build json text
        try
        {
            $JSON = $Properties | ConvertTo-Json -ErrorAction Stop
        }
        catch
        {
            throw ('Failed to generate JSON object with error: {0}' -f $_.exception.message)
        }

        # Set PSScriptInfo
        try
        {
            Set-PSScriptInfo -FilePath $FilePath.FullName -JSON $JSON -ErrorAction Stop
        }
        catch
        {
            throw ('Failed to set PSScriptInfo with error: {0}' -f $_.exception.message)
        }
    }
}
