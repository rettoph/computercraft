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
            openSsh = $true;
            privateKeyPath = "";
        };
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
    [string]$in
)
{
    $key = "$($entryFile).$($in)"
    $file = Get-LuaPath $in
    if($null -eq $file)
    {
        return 0
    }

    $hash = (Get-FileHash $file).Hash

    # Check if contents has changed since last minification
    if($minified.ContainsKey($key) -eq $true -and $hash -eq $minified[$key])
    {
        # return 0
    }

    $minified[$key] = $hash
    $content = Get-Content $file 
    $result = 1
    
    # find all 'require' directives
    $pattern = "require.*?['|`"](.*?)['|`"]"
    $matches = [regex]::Matches($content, $pattern)
    foreach ($match in $matches) {
        $result = $result + (Save-MinifiedLua $match.Groups[1].Value $sourceDir $outDir)
    }

    $outputFile = "$($outDir)/$($in).lua"
    $outputFileDir = [System.IO.Path]::GetDirectoryName($outputFile)
    if(-not (Test-Path $outputFileDir))
    {
        New-Item -Path $outputFileDir -ItemType Directory
    }

    Write-Host "Minifying '$($file)'..."
    $output = npx luamin -f $file
    Set-Content -Path $outputFile -Value $output

    $uploadFile = "$($config.remote.folder)/$($in).lua"
    $uploadFileDir = [System.IO.Path]::GetDirectoryName($uploadFile) -replace "\\", "/"

    Write-Host "Uploading file: '$($outputFile)' => '$($uploadFileDir)'"
    if ((Test-SFTPPath -SessionId $sftp.SessionId -Path $uploadFileDir) -eq $false)
    {
        $null = New-SFTPItem -SessionId $sftp.SessionId -Path $uploadFileDir -ItemType Directory
    }

    $null = Set-SFTPItem -SessionId $sftp.SessionId -Destination $uploadFileDir -Path $outputFile -Force

    return $result
}

function Get-LuaPath($name, $dir)
{
    $file = "$($sourceDir)/$($in).lua"
    if((Test-Path $file) -eq $true)
    {
        return $file
    }

    $file = "$($sourceDir)/$($in)"
    if((Test-Path $file) -eq $true)
    {
        return $file
    }

    $file = $in
    if((Test-Path $file) -eq $true)
    {
        return $file
    }

    Write-Warning "$($name) not found"
    return $null
}


if (-not (Test-Path $outDir))
{
    New-Item -Path $outDir -ItemType Directory
}

$modified = Save-MinifiedLua $entryFile $sourceDir $outDir
if($modified -gt 0)
{
    
    Set-Content "$PSScriptRoot\.cache\.minified.json" (ConvertTo-Json $minified)
}

Remove-SFTPSession -SFTPSession $sftp | Out-Null

Write-Host "Done. $($modified) file(s) minified & uploaded."