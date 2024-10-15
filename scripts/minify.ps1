#Requires -Version 6.0

# Check config...
$configFile = $PSScriptRoot + "\config.json"
if((Test-Path -Path $configFile -PathType Leaf))
{   
    $config = Get-Content $configFile | ConvertFrom-Json
    Write-Information "Loaded config from: $($configFile)"
}
else 
{
    $config = @{
        remote = @{
            host = "";
            port = "";
            folder = "";
            username = "";
            privateKeyPath = "";
        };
        projects = @{

        }
    }

    New-Item $configFile
    Set-Content $configFile ($config | ConvertTo-Json)

    Write-Information "No valid configuration file found. Please update the one at $($configPath)"

    Exit
}

if (-not (Test-Path "$PSScriptRoot\.cache"))
{
    New-Item -Path "$PSScriptRoot\.cache" -ItemType Directory
}

if (-not (Test-Path "$PSScriptRoot\.cache\.minified.json"))
{
    New-Item -Path "$PSScriptRoot\.cache\.minified.json" -ItemType File
}

[hashtable]$minified = Get-Content "$PSScriptRoot\.cache\.minified.json" | ConvertFrom-Json -AsHashtable
if (-not $minified) {
    # Set a default value if $minified is null
    $minified = @{}
}

$credentials = New-Object System.Management.Automation.PSCredential($config.remote.username, (new-object System.Security.SecureString))
$sftp = New-SFTPSession -ComputerName $config.remote.host -Port $config.remote.port -Credential $credentials -KeyFile $config.remote.privateKeyPath -AcceptKey

Write-Information "test"

function Save-MinifiedLua(
    [string]$in,
    [string]$inDir,
    [string]$minDir,
    [string]$computer
)
{
    $key = "$($entryFile).$($in)"
    $file = Get-LuaPath $in $inDir
    if($null -eq $file)
    {
        return 0
    }

    $hash = (Get-FileHash $file).Hash

    # Check if contents has changed since last minification
    if($minified.ContainsKey($key) -eq $true -and $hash -eq $minified[$key])
    {
        return 0
    }

    $minified[$key] = $hash
    $content = Get-Content $file 
    $result = 1
    
    # find all 'require' directives
    $pattern = "require.*?['|`"](.*?)['|`"]"
    $matches = [regex]::Matches($content, $pattern)
    foreach ($match in $matches) {
        $result = $result + (Save-MinifiedLua $match.Groups[1].Value $inDir $minDir $computer)
    }

    $minFile = "$($minDir)/$($in).lua"
    $minFileDir = [System.IO.Path]::GetDirectoryName($minFile)
    if(-not (Test-Path $minFileDir))
    {
        New-Item -Path $minFileDir -ItemType Directory
    }

    Write-Host "Minifying '$($file)'..."
    $output = npx luamin -f $file
    Set-Content -Path $minFile -Value $output

    $uploadFile = "$($config.remote.folder)/$($computer)/$($in).lua"
    $uploadFileDir = [System.IO.Path]::GetDirectoryName($uploadFile) -replace "\\", "/"

    Write-Host "Uploading file: '$($minFile)' => '$($uploadFileDir)'"
    if ((Test-SFTPPath -SessionId $sftp.SessionId -Path $uploadFileDir) -eq $false)
    {
        $null = New-SFTPItem -SessionId $sftp.SessionId -Path $uploadFileDir -ItemType Directory
    }

    $null = Set-SFTPItem -SessionId $sftp.SessionId -Destination $uploadFileDir -Path $minFile -Force

    return $result
}

function Get-LuaPath($name, $dir)
{
    $file = "$($dir)/$($in).lua"
    if((Test-Path $file) -eq $true)
    {
        return $file
    }

    $file = "$($dir)/$($in)"
    if((Test-Path $file) -eq $true)
    {
        return $file
    }

    $file = $in
    if((Test-Path $file) -eq $true)
    {
        return $file
    }

    Write-Warning "$($dir) not found"
    Write-Warning "$($name) not found"
    return $null
}


if (-not (Test-Path $outDir))
{
    New-Item -Path $outDir -ItemType Directory
}

foreach($project in $config.projects)
{
    Write-Host "Cleaning project: $($project.name)"
    $modified = Save-MinifiedLua $project.entry "$($PSScriptRoot)/../src" "$($PSScriptRoot)/../min" $project.computer
    if($modified -gt 0)
    {
        Set-Content "$PSScriptRoot\.cache\.minified.json" (ConvertTo-Json $minified)
    }
    Write-Host "Done. $($modified) file(s) minified & uploaded."
}

Remove-SFTPSession -SFTPSession $sftp | Out-Null