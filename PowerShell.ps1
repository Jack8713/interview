function formatLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string]$Path
    )
    $log = Get-Content $Path
    #logCategory
    $apple = $unapple = $inComplete = @()
    for ($i = 0; $i -lt $log.Count; $i++) {
        if ($log[$i] -match "com.apple.xpc.launchd") {
            $apple += $log[$i]
        }
        elseif ($log[$i].StartsWith("M") -and !($log[$i] -match "com.apple.xpc.launchd")) {
            #[System.DateTime]::Now.ToString("MMM") -and !($log[$i] -match "com.apple.xpc.launchd")
            $unapple += $log[$i]
        }
        else {
            $inComplete += ($log[$i - 1].Trim(), $log[$i].Trim() -join " ")  
        }
    }
    for ($i = 0; $i -lt $inComplete.Count; $i++) {
        if (!$inComplete[$i].StartsWith("M")) {
            $inComplete[$i - 1] = $inComplete[$i - 1], $inComplete[$i] -join " "
            $inComplete[$i] = ""
        }
    }
    #appleLog
    for ($i = 0; $i -lt $apple.Count; $i++) {
        $appleJson += @{
            index       = $i
            deviceName  = $apple[$i].Split(" ", 7 )[3];
            timeWindow  = formatDate($i, "appleLog");
            processName = $apple[$i].Split(" ", 7)[-2] -replace ("[^a-z,A-Z.]", ""); 
            description = $apple[$i].Split(" ", 7)[-1]; 
            processId   = $apple[$i].Split(" ", 7)[-2] -replace ("[a-zA-z.():]", "") 
        } | ConvertTo-Json 
  
    }
    #unAppleLog
    for ($i += 0; $i -lt $unapple.Count; $i++) {
        $unAppleJson += @{
            index       = $i;
            deviceName  = $unapple[$i].Split(" ", 6 )[3];
            timeWindow  = formatDate($i, "unAppleLog");
            processName = $unapple[$i].Split(" ", 6)[-2] -replace ("[^a-z,A-Z.]", ""); 
            description = $unapple[$i].Split(" ", 6)[-1]; 
            processId   = $unapple[$i].Split(" ", 6)[-2] -replace ("[a-zA-z.():]", "") 
        } | ConvertTo-Json 
    }
    #inComplete
    for ($i = 0; $i -lt $inComplete.Count; $i++) {
        if ($inComplete[$i].Length -ne 0) {
            $inCompleteJson += @{
                index       = $i;
                deviceName  = $inComplete[$i].Split(" ", 6 )[3];
                timeWindow  = formatDate($i, "unAppleLog");
                processName = $inComplete[$i].Split(" ", 6)[-2] -replace ("[^a-z,A-Z.]", ""); 
                description = $inComplete[$i].Split(" ", 6)[-1]; 
                processId   = $inComplete[$i].Split(" ", 6)[-2] -replace ("[a-zA-z.():]", "") 
            } | ConvertTo-Json
        }
    }
    Invoke-WebRequest -Uri https://foo.com/bar -Body $appleJson + $unAppleJson + $inCompleteJson -Method Post
}
function formatDate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        $index,
        [string]$isApple
    )
    if ($isApple -eq "appleLog") {
        if (([datetime]$apple[$index].Split(" ", 7)[2]).hour -le 10) {
            return  "0" + ([datetime]$apple[$index].Split(" ", 7)[2]).hour + "00" + "-" + "0" + (([datetime]$apple[$index].Split(" ", 7)[2]).hour + 1) + "00"
        }
        else {
            return [string]([datetime]$apple[$index].Split(" ", 7)[2]).hour + "00" + "-" + [string](([datetime]$apple[$index].Split(" ", 7)[2]).hour + 1) + '00'
        }
    }
    else {
        if (([datetime]$unapple[$index].Split(" ", 6)[2]).hour -le 10) {
            return  "0" + ([datetime]$unapple[$index].Split(" ", 6)[2]).hour + "00" + "-" + "0" + (([datetime]$unapple[$index].Split(" ", 6)[2]).hour + 1) + "00"
        }
        else {
            return [string]([datetime]$unapple[$index].Split(" ", 6)[2]).hour + "00" + "-" + [string](([datetime]$unapple[$index].Split(" ", 6)[2]).hour + 1) + '00'
        }
    }
    
}