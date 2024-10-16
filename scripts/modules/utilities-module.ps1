function Get-Directory(
    [string] $path,
    [bool] $create = $false
)
{
    $result = [IO.Path]::GetFullPath($path);

    if([IO.Directory]::Exists($result) -eq $false -and $create -eq $true)
    {
        [IO.Directory]::CreateDirectory($result);
    }

    return $result
}

function Get-File(
    [string] $path,
    [bool] $create = $false
)
{
    $result = [IO.Path]::GetFullPath($path);

    if([IO.File]::Exists($result) -eq $false -and $create -eq $true)
    {
        # Ensure file directory exists
        $directory = [IO.Path]::GetDirectoryName($result)
        $directory = Get-Directory $directory $true

        [IO.File]::Create($result).Close()
    }

    return $result
}

function Get-Cache([string]$name)
{
    $path = Get-File "$PSScriptRoot\..\.cache\$name.cache" $true
    $result = Get-Content $path | ConvertFrom-Json -AsHashtable
    if (-not $result) {
        # Set a default value if $minified is null
        $result = @{}
    }

    return $result
}

function Set-Cache(
    [string]$name,
    [System.Object]$value
)
{
    $path = Get-File "$PSScriptRoot\..\.cache\$name.cache" $true
    Set-Content $path (ConvertTo-Json $value)
}