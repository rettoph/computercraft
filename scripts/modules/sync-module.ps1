Import-Module -Name ($PSScriptRoot + "\utilities-module.ps1") -Force

function Sync-File([string]$file)
{
    
}

function Sync-Projects([string[]]$files = $null)
{
    [System.Object[]]$projects = Get-Content (Get-File "$PSScriptRoot\..\..\projects.config.json") | ConvertFrom-Json

    foreach($project in $projects.GetEnumerator())
    {
        Sync-Project $project
    }

    Close-SFTP
}

function Sync-Project([System.Object]$project, [string[]]$files = $null)
{
    [string[]]$targets = @{}
    $cache = Get-Cache "project.$($project.name)"

    if($null -eq $files)
    {
        $targets = $project.files
    }
    else {
        foreach($file in $files)
        {
            if($project.files.Contains($file))
            {
                $targets.Add($file)
            }
        }
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

function Sync-ProjectFile($project, $file, $cache = $null)
{
    if($null -eq $cache)
    {
        $cache = Get-Cache "project.$($project.name)"
    }

    $source = Get-ProjectSource $file
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

    Write-Host "Syncing project file. Project = '$($project.name)', File = '$file', Source = '$source'"
    foreach($computer in $project.computers.GetEnumerator())
    {
        $sftp = Get-SFTP
        $uploadFile = "$($sftp.Config.folder)/$computer/$file" -replace "\\", "/"
        $uploadFileDir = [System.IO.Path]::GetDirectoryName($uploadFile) -replace "\\", "/"

        Write-Debug "Computer = $computer, File = '$($file)', Path = '$($uploadFile)'"
        if ((Test-SFTPPath -SessionId $sftp.Session.SessionId -Path $uploadFileDir) -eq $false)
        {
            $null = New-SFTPItem -SessionId $sftp.Session.SessionId -Path $uploadFileDir -ItemType Directory
        }
    
        $null = Set-SFTPItem -SessionId $sftp.Session.SessionId -Destination $uploadFileDir -Path $source -Force
    }


    $cache[$file] = $hash

    return @{Modified = $true; Cache = $cache}
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
            Session = (New-SFTPSession -ComputerName $config.host -Port $config.port -Credential $credentials -KeyFile $config.privateKeyPath -AcceptKey);
        }
    }

    return $global:sftp
}

function Close-SFTP
{
    Remove-SFTPSession -SFTPSession $global:sftp.Session | Out-Null
    $global:sftp = $null
}

function Get-ProjectSource([string]$file = $null)
{
    if($null -eq $file)
    {
        return Get-Directory "$PSScriptRoot\..\..\src\"
    }

    return Get-File "$PSScriptRoot\..\..\src\$file"
}