param (
    [Parameter(Mandatory = $false)]
    [string]$Network = "192.168.1.",

    [Parameter(Mandatory = $false)]
    [int]$Start = 1,

    [Parameter(Mandatory = $false)]
    [int]$End = 255,

    [Parameter(Mandatory = $false)]
    [switch]$OnlineOnly
)

# 読み込むXMLファイル名を Get-LanClient.ps1xml に変更
$xmlPath = Join-Path (Split-Path $script:MyInvocation.MyCommand.Path) "Get-LanClient.ps1xml"
Update-FormatData -AppendPath $xmlPath

if (-not $Network.EndsWith(".")) { $Network += "." }

Write-Host "[Scan Start] ${Network}${Start} - ${Network}${End}" -ForegroundColor Green

# ----------------------------------------------------
# PS7以降の処理
# ----------------------------------------------------
if ($PSVersionTable.PSVersion.Major -ge 7) {
    $results = $Start..$End | ForEach-Object -Parallel {
        $ip = $using:Network + $_
        if (Test-Connection -ComputerName $ip -Count 1 -TimeoutSeconds 1 -Quiet) {
            [PSCustomObject]@{ PSTypeName = 'LanClientResult'; IPAddress = $ip; Status = "Online" }
        } else {
            if (-not $using:OnlineOnly) {
                [PSCustomObject]@{ PSTypeName = 'LanClientResult'; IPAddress = $ip; Status = "Offline" }
            }
        }
    } -ThrottleLimit 50
} 
# ----------------------------------------------------
# PS5.1の処理
# ----------------------------------------------------
else {
    $results = $Start..$End | ForEach-Object {
        $ip = $Network + $_
        $ping = [System.Net.NetworkInformation.Ping]::new()
        try {
            $reply = $ping.Send($ip, 1000)
            if ($reply.Status -eq 'Success') {
                [PSCustomObject]@{ PSTypeName = 'LanClientResult'; IPAddress = $ip; Status = "Online" }
            } else {
                if (-not $OnlineOnly) {
                    [PSCustomObject]@{ PSTypeName = 'LanClientResult'; IPAddress = $ip; Status = "Offline" }
                }
            }
        } catch {
            if (-not $OnlineOnly) {
                [PSCustomObject]@{ PSTypeName = 'LanClientResult'; IPAddress = $ip; Status = "Offline" }
            }
        } finally {
            if ($ping) { $ping.Dispose() }
        }
    }
}

$results | Sort-Object { [version]$_.IPAddress }