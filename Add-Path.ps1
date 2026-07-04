param (
    [string]$TargetDir = (Get-Location).Path
)

# パスの末尾のバックスラッシュを削除して統一（重複チェックの精度向上）
$TargetDir = $TargetDir.TrimEnd('\')

# 指定されたパスが存在するか確認
if (-not (Test-Path -Path $TargetDir -PathType Container)) {
    Write-Error "指定されたディレクトリが存在しません: $TargetDir"
    exit
}

# レジストリから現在のユーザーPATHを取得
$registryPath = "HKCU:\Environment"
$oldPath = (Get-ItemProperty -Path $registryPath).Path

# セミコロンで分割して配列化し、各パスの末尾のバックスラッシュを除去して比較
$pathArray = ($oldPath -split ';').TrimEnd('\')

# 重複チェックして追加
if ($pathArray -contains $TargetDir) {
    Write-Host "既に追加されています: $TargetDir" -ForegroundColor Yellow
} else {
    # 元の環境変数PATHが空でない場合はセミコロンで連結
    if ([string]::IsNullOrEmpty($oldPath)) {
        $newPath = $TargetDir
    } else {
        $newPath = "$oldPath;$TargetDir"
    }
    
    Set-ItemProperty -Path $registryPath -Name "Path" -Value $newPath
    Write-Host "PATHに追加しました: $TargetDir" -ForegroundColor Green
}