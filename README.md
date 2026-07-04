# PS1_Util
便利な自作ps1ファイルをまとめました

## Add-Path.ps1
ディレクトリをPATHに追加します
### パターン1:現代のフォルダをPATHに追加する
```PowerShell
.\Add-Path.ps1
```
### パターン2：特定のフォルダを指定してPATHに追加する
```PowerShell
.\Add-Path.ps1 -TargetDir "C:\追加したいフォルダのパス"
```
⚠️ **注意**: 実行後は環境変数を反映させるため、**PowerShellを一度閉じて開き直してください**。
## Get-LanClient.ps1
LAN内の機器をスキャンし、IPアドレスがオンラインか確認します
### 1. 基本（すべてデフォルト設定で実行）
```PowerShell
.\Get-LanClient.ps1
```
※ `192.168.1.1` ～ `192.168.1.255` の範囲をスキャンし、オンライン・オフライン両方を表示します。
### 2. 応答があった機器（Online）のみを表示
```PowerShell
.\Get-LanClient.ps1 -OnlineOnly
```
### 3. ネットワークやIPの範囲を指定して実行
* **ネットワーク（第3オクテットまで）を変更する**
```PowerShell
.\Get-LanClient.ps1 -Network "192.168.10."
```
* **スキャンするIPの範囲（開始・終了）を指定する**
```PowerShell
.\Get-LanClient.ps1 -Start 10 -End 50
```
* **ネットワークと範囲を組み合わせて指定する**
```PowerShell
.\Get-LanClient.ps1 -Network "10.0.0." -Start 1 -End 100 -OnlineOnly
```