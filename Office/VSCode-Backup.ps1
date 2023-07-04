
# global variables
$OutputPath = "$([Environment]::GetFolderPath("Desktop"))\VsCodeSettings.zip"
$FilesToBackup = @()

# user settings
$FilesToBackup += "C:\Users\$($env:UserName)\AppData\Roaming\Code\User\settings.json"

# snippests
$FilesToBackup += (Get-ChildItem -Path "C:\Users\$($env:UserName)\AppData\Roaming\Code\User\snippets" -filter "*.json").FullName

# add to archive
Compress-Archive -Path $FilesToBackup -Update -DestinationPath $OutputPath

Write-Host "Done, $($FilesToBackup.Length) files backed up to $OutputPath"
