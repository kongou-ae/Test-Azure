param (
    [switch]$network,
    [switch]$backup,
    [switch]$disk,
    [switch]$compute,
    [switch]$PassThru,
    [switch]$export
)

$ErrorActionPreference = "stop"

Function Out-Log
{
    param(
    [string]$message,
    [string]$Color = 'White'
    )

    Write-Host "$message" -ForegroundColor $Color
}

# Pester の結果を取得
$result = Invoke-Pester -PassThru -Show None

# Pester の結果から必要な部分だけを抽出
$TestResult = $result.TestResult | Select-Object Describe, Context, Name, Result

# ToDo: ファイルに書き出す処理を足す
#$result | ConvertTo-Json 

# カテゴリを抽出する
$describes = ($TestResult | Select-Object Describe | Sort-Object -Property Describe -Unique).Describe

# カテゴリごとに処理をループ
$describes | ForEach-Object {
    $describe = $_
    Write-Output "-----------------------------------------------------"
    Write-Output "$describe"
    Write-Output "-----------------------------------------------------"

    # カテゴリ内のテスト項目を抽出
    $contexts = ($TestResult | Where-Object { $_.Describe -eq $describe } | Select-Object Context | Sort-Object -Property Context -Unique).Context

    # テスト項目ごとに処理をループ
    $contexts | ForEach-Object {
        $context = $_ 
        Write-Output "$context"

        # 全件からカテゴリとテスト項目に該当するものを抽出してループ
        $TestResult | Where-Object { $_.Describe -eq $describe -and $_.Context -eq $context } | ForEach-Object {
            $a = $_.Result
            $b = $_.Name
            switch ($a) {
                "Passed" {
                    Out-Log "  $($a) $($b)" "Green"
                }
                "Failed" {
                    Out-Log "  $($a) $($b)" "Red"
                }
            }
        }
    }
}