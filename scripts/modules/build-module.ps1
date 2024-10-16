Import-Module -Name ($PSScriptRoot + "\utilities-module.ps1") -Force

function Get-BuildFiles()
{
    return Get-Cache "build"
}

function Build-Files()
{
        [hashtable]$cache = Get-Cache "build"

        $files = @{}
        foreach($name in Get-ChildItem (Get-LuaRoot) -Recurse -Name -Include *.*)
        {
            $file = Get-File "$(Get-LuaRoot)\$name"
            $hash = (Get-FileHash $file).Hash
            $result = $null

            if($cache.ContainsKey($name) -eq $false -or $cache[$name].hash -ne $hash)
            {
                $result = Build-File $name $file
            }
            else 
            {
                $result = $cache[$name].path
            }

            $files[$name] = @{
                path = $result;
                hash = $hash;
            }
        }

        Set-Cache "build" $files
}

function Build-SingleFile($source)
{

}

function Build-File([string]$name, [string]$source)
{
    Write-Host "Building: '$name'..."
    $extension = [System.IO.Path]::GetExtension($source)
    switch ($extension) {
        ".lua" {
            $location = Get-Location
            Set-Location (Get-LuaRoot)

            $minifiedFile = Get-File "$(Get-BuildRoot)\$name" $true
            $minifiedContent = npx luamin -f $file
            Set-Content -Path $minifiedFile -Value $minifiedContent

            Set-Location $location

            return $minifiedFile
        }
        Default {
            Write-Error "Unknown file type: '$extension'"
        }
    }
}

function Get-LuaRoot()
{
    return Get-File "$PSScriptRoot\..\..\src\"
}

function Get-BuildRoot()
{
    return Get-File "$PSScriptRoot\..\..\build\"
}