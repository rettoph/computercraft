Import-Module -Name ($PSScriptRoot + "\utilities-module.ps1") -Force

function Sync-File([string]$file)
{
    
}

function Sync-Projects([string[]]$files = $null)
{
    [System.Object[]]$projects = Get-Content (Get-File "$PSScriptRoot\..\..\projects.config.json") | ConvertFrom-Json

    foreach($project in $projects.GetEnumerator())
    {
        Sync-Project $project $files
    }

    Close-SFTP
}

function Sync-Project([System.Object]$project, [string[]]$files = $null, [bool]$force = $false)
{
    [string[]]$targets = @()
    $cache = Get-Cache "project.$($project.name)"

    if($null -eq $files -or $files.Length -eq 0)
    {
        $targets = $project.files
        $force = $true

        foreach($computer in $project.computers)
        {
            Remove-ComputerFiles $computer
        }
    }
    else {
        foreach($file in $files)
        {
            $name = Get-ProjectFileName $file
            if($project.files.Contains($name) -or $cache.ContainsKey($name))
            {
                $targets += $name
            }
            else {
                foreach($projectFile in $project.files)
                {
                    if($file.StartsWith($projectFile) -eq $true)
                    {
                        $targets += $projectFile
                    }
                }
            }
        }
    }

    $targets = Expand-ProjectTargets $targets

    if($force -eq $true)
    {
        $cache = @{}
    }

    $result = $false
    foreach($target in $targets.GetEnumerator())
    {
        $result = (Sync-ProjectFile $project $target $cache).Modified -or $result
    }

    if($result -eq $true)
    {
        Update-SyncCache $project $cache
    }
}

function Sync-ProjectFile($project, [string]$file, [hashtable]$cache)
{
    $source = Get-ProjectFileSource $file
    if((Test-Path $source) -eq $false)
    {
        Write-Warning "Unknown project file. Project = '$($project.name)', File = '$file'"
        return @{Modified = $false; Cache = $null}
    }

    $hash = (Get-FileHash $source).Hash
    if($cache.ContainsKey($file) -and $cache[$file] -eq $hash)
    {
        return @{Modified = $false; Cache = $null}
    }

    # find all 'require' directives
    [string]$content = Get-Content $source
    if ($content.Length -gt 0)
    {
        $pattern = "require.*?['|`"](.*?)['|`"]"
        $requires = [regex]::Matches($content, $pattern)
        foreach ($require in $requires) {
            Sync-ProjectFile $project (Get-ProjectRequireFileName $require.Groups[1].Value $source) $cache
        }
    }

    Write-Host "Syncing project file. Project = '$($project.name)', File = '$file', Source = '$source'"
    foreach($computer in $project.computers.GetEnumerator())
    {
        $sftp = Get-SFTP
        $uploadFile = "$($sftp.Config.folder)/$computer/$file" -replace "\\", "/"
        $uploadFileDir = [System.IO.Path]::GetDirectoryName($uploadFile) -replace "\\", "/"

        if ((Test-SFTPPath -SessionId $sftp.Session.SessionId -Path $uploadFileDir) -eq $false)
        {
            Write-Debug "Computer = $computer, Path = '$($uploadFileDir)'"
            $null = New-SFTPItem -SessionId $sftp.Session.SessionId -Path $uploadFileDir -ItemType Directory
        }
    
        Write-Debug "Computer = $computer, File = '$($file)', Path = '$($uploadFile)'"
        $null = Set-SFTPItem -SessionId $sftp.Session.SessionId -Destination $uploadFileDir -Path $source -Force
    }


    $cache[$file] = $hash

    return @{Modified = $true; Cache = $cache}
}

function Remove-ComputerFiles($computer)
{
    $sftp = Get-SFTP
    $uploadDir = "$($sftp.Config.folder)/$computer" -replace "\\", "/"

    foreach($file in (Get-SFTPChildItem -SessionId $sftp.Session.SessionId -Path $uploadDir -Recurse -File))
    {
        if ($file.FullName.Contains("/.persistence"))
        {
            continue
        }

        Write-Host "Deleting: '$($file.FullName)'"
        Remove-SFTPItem -SessionId $sftp.Session.SessionId -Path $file.FullName
    }

    
    foreach($directory in ((Get-SFTPChildItem -SessionId $sftp.Session.SessionId -Path $uploadDir -Recurse -Directory).FullName | Sort-Object -Property Length -Descending))
    {
        if ($directory.Contains("/.persistence"))
        {
            continue
        }

        Write-Host "Deleting: '$($directory)'"
        Remove-SFTPItem -SessionId $sftp.Session.SessionId -Path $directory
    }
}

function Update-SyncCache($project, $cache)
{
    Set-Cache "project.$($project.name)" $cache
}

$global:sftp = $null
function Get-SFTP()
{
    if($null -eq $global:sftp)
    {    
        [hashtable]$config = Get-Content (Get-File "$PSScriptRoot\..\..\remote.config.json") | ConvertFrom-Json -AsHashtable

        $credentials = New-Object System.Management.Automation.PSCredential($config.username, (new-object System.Security.SecureString))
        $global:sftp = @{
            Config = $config;
            Session = (New-SFTPSession -ComputerName $config.host -Port $config.port -Credential $credentials -KeyFile $config.key -AcceptKey);
        }
    }

    return $global:sftp
}

function Close-SFTP
{
    Remove-SFTPSession -SFTPSession $global:sftp.Session | Out-Null
    $global:sftp = $null
}

function Get-ProjectFileSource([string]$file = $null)
{
    return Get-File "$PSScriptRoot\..\..\src\$file"
}

function Get-ProjectFileName([string]$source)
{
    $directory = Get-Directory "$PSScriptRoot\..\..\src\"
    $result = $source.Substring($directory.Length)
    return $result
}

function Get-ProjectRequireFileName([string]$require, [string]$source)
{
    $sourceDirectory = [System.IO.Path]::GetDirectoryName($source)
    if($require.StartsWith("/"))
    {
        $sourceDirectory = Get-Directory "$PSScriptRoot\..\..\src"
    }

    $result = Get-ProjectFileName (Get-File "$sourceDirectory/$require.lua")
    return $result
}

function Expand-ProjectTargets([string[]] $targets)
{
    $directory = Get-Directory "$PSScriptRoot\..\..\src\"

    $expanded = @()

    foreach($target in $targets)
    {
        $path = [IO.Path]::GetFullPath("$directory\$target")

        if((Test-Path -Path $path -PathType Leaf) -eq $true)
        {
            $expanded += $target
        }

        if((Test-Path -Path $path -PathType Container) -eq $true)
        {
            foreach($child in (Get-ChildItem $path -Recurse))
            {
                $expanded += $child.FullName.Substring($directory.Length)
            }
        }
    }

    return $expanded
}