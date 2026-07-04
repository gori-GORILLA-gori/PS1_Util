param (
    [string]$TargetDir = (Get-Location).Path
)

# OSごとのパス区切り文字とスラッシュの定義
# Windows: ';' と '\' / Linux・Mac: ':' と '/'
$pathSeparator = [IO.Path]::PathSeparator
$dirSeparator  = [IO.Path]::DirectorySeparatorChar

# パスの末尾のスラッシュを削除して統一（重複チェックの精度向上）
$TargetDir = $TargetDir.TrimEnd($dirSeparator)

# 指定されたパスが存在するか確認
if (-not (Test-Path -Path $TargetDir -PathType Container)) {
    Write-Error "指定されたディレクトリが存在しません: $TargetDir"
    exit
}

# --- Windows の場合の処理 ---
if ($IsWindows) {
    $registryPath = "HKCU:\Environment"
    $oldPath = (Get-ItemProperty -Path $registryPath).Path
    $pathArray = ($oldPath -split $pathSeparator).TrimEnd('\')

    if ($pathArray -contains $TargetDir) {
        Write-Host "既に追加されています (Windowsレジストリ): $TargetDir" -ForegroundColor Yellow
    } else {
        $newPath = [string]::IsNullOrEmpty($oldPath) ? $TargetDir : "$oldPath$pathSeparator$TargetDir"
        Set-ItemProperty -Path $registryPath -Name "Path" -Value $newPath
        Write-Host "WindowsレジストリのPATHに追加しました: $TargetDir" -ForegroundColor Green
    }
}
# --- Linux / macOS の場合の処理 ---
elseif ($IsLinux -or $IsMacOS) {
    # 現在のセッションのPATH配列を取得（空要素を除外）
    $currentPaths = ($env:PATH -split $pathSeparator).TrimEnd('/')
    
    if ($currentPaths -contains $TargetDir) {
        Write-Host "既に追加されています (現在のPATH): $TargetDir" -ForegroundColor Yellow
    } else {
        # PowerShellのプロファイルファイルが存在しない場合は作成
        if (-not (Test-Path $PROFILE)) {
            New-Item -Type File -Path $PROFILE -Force | Out-Null
            Write-Host "プロファイルファイルを作成しました: $PROFILE" -ForegroundColor Cyan
        }

        # プロファイルに書き込む文字列（例: $env:PATH += ":/home/gori/dev/PS1_Util"）
        # ※シングルクォートで括ることで、起動時に評価されるようにする
        $profileLine = "`$env:PATH += `"$pathSeparator$TargetDir`""

        # 既にプロファイルに同じ記述がないかチェックして追記
        $profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue
        if ($profileContent -contains $profileLine) {
            Write-Host "プロファイルには既に記述が存在します。" -ForegroundColor Yellow
        } else {
            Add-Content -Path $PROFILE -Value $profileLine
            # 現在のセッションにも即時反映
            $env:PATH += "$pathSeparator$TargetDir"
            Write-Host "PowerShellプロファイルにPATHを追加しました: $TargetDir" -ForegroundColor Green
            Write-Host "（次回のPowerShell起動時にも自動で有効になります）" -ForegroundColor Gray
        }
    }
}