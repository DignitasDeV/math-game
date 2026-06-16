[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$voiceRoot = Join-Path $scriptDir "piper_voices"
$baseUrl = "https://huggingface.co/rhasspy/piper-voices/resolve/main"

$voices = @(
    @{
        Id = "es_ES-sharvard-medium"
        Remote = "es/es_ES/sharvard/medium/es_ES-sharvard-medium"
    },
    @{
        Id = "es_ES-davefx-medium"
        Remote = "es/es_ES/davefx/medium/es_ES-davefx-medium"
    },
    @{
        Id = "ca_ES-upc_ona-medium"
        Remote = "ca/ca_ES/upc_ona/medium/ca_ES-upc_ona-medium"
    },
    @{
        Id = "ca_ES-upc_pau-x_low"
        Remote = "ca/ca_ES/upc_pau/x_low/ca_ES-upc_pau-x_low"
    }
)

foreach ($voice in $voices) {
    $targetDir = Join-Path $voiceRoot $voice.Id
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

    foreach ($extension in @(".onnx", ".onnx.json")) {
        $fileName = "$($voice.Id)$extension"
        $targetPath = Join-Path $targetDir $fileName
        if ((Test-Path $targetPath) -and -not $Force) {
            Write-Host "Ya existe $fileName"
            continue
        }

        $url = "$baseUrl/$($voice.Remote)$extension"
        Write-Host "Descargando $fileName"
        Invoke-WebRequest -Uri $url -OutFile $targetPath
    }
}

Write-Host "Voces Piper listas en $voiceRoot"
