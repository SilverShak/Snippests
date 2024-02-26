# get optional argument
param ([string]$Title)

# hide cursor
[console]::CursorVisible = $false

# start measure time
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

While ($True) {
    
    # format time elapsed
    $Seconds = '{0:d2}' -f [int]$Stopwatch.Elapsed.Seconds
    $Minutes = '{0:d2}' -f [int]$Stopwatch.Elapsed.Minutes
    $Hours = '{0:d2}' -f [int]$Stopwatch.Elapsed.Hours

    # print
    Clear-Host
    if ($Title) {Write-Host -NoNewLine "$Title - "}
    Write-Host -NoNewLine "$('{0:d2}' -f $Seconds):$('{0:d2}' -f $Minutes):$('{0:d2}' -f $Hours)"

    # wait
    Start-Sleep -Seconds 1
}
