#Requires -Version 6.0

Import-Module -Name ($PSScriptRoot + "\modules\sync-module.ps1") -Force

Sync-Projects $args

exit