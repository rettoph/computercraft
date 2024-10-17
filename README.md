## Rettoph's ComputerCraft Scripts!
A simple collection of scripts I think are useful for setting up new computercraft worlds.

### Setup
This repo allows you to edit and automatically publish scripts to your CC computers in bulk, to setup simply:
- Install recommended plugins
- Install Posh-SSH:
  - `PS > Install-Module -Name Posh-SSH`
- Configure `remote.config.json`. 
  - See [`remote.config.json.example`](remote.config.json.example)
- Configure `projects.config.json`
  - Note the computer ids - set these to the computer ids in your world you wish to publish projects to.
- Run Launch profile: `Force Sync: All`

Once complete, your files should be uploaded to the sftp location on save.
