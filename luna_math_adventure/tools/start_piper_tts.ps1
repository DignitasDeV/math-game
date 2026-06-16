$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$serverPath = Join-Path $scriptDir "piper_tts_server.py"
$voiceRoot = Join-Path $scriptDir "piper_voices"

$voiceFiles = @()
if (Test-Path $voiceRoot) {
    $voiceFiles = @(
        Get-ChildItem -Path $voiceRoot -Directory |
            ForEach-Object {
                Get-ChildItem -Path $_.FullName -Filter "*.onnx" -File
            } |
            Sort-Object FullName
    )
}

if ($voiceFiles.Count -eq 0) {
    $legacyModelPath = Join-Path $voiceRoot "es_ES-sharvard-medium\es_ES-sharvard-medium.onnx"
    if (-not (Test-Path $legacyModelPath)) {
        throw "No encuentro voces Piper en: $voiceRoot. Ejecuta tools\download_piper_voices.ps1 primero."
    }

    $voiceFiles = @(Get-Item $legacyModelPath)
}

$arguments = @($serverPath)
foreach ($voiceFile in $voiceFiles) {
    $voiceId = [System.IO.Path]::GetFileNameWithoutExtension($voiceFile.Name)
    $arguments += @("--voice", "$voiceId=$($voiceFile.FullName)")
}

python @arguments
