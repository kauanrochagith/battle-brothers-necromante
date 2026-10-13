# =====================================================================
# MOD NECROMANTE - build da versão em INGLÊS
# ---------------------------------------------------------------------
# O código-fonte é um só (em português). Este script:
# 1. Gera uma cópia de "scripts" com os textos trocados pelo inglês
#    (tools/en/textos_en.json, via tools/en/gerar_en.py) em build_en/.
# 2. Confere a sintaxe de cada .nut com o sq.exe do Mod Kit.
# 3. Empacota em mod_necromante_en.zip.
#
# Uso:  powershell -ExecutionPolicy Bypass -File build_en.ps1
#       (adicione -Instalar para copiar para a pasta data; NÃO deixe a
#        versão em português e a em inglês juntas na pasta data)
# =====================================================================
param(
	[switch]$Instalar,
	[string]$PastaData = "C:\Program Files (x86)\Steam\steamapps\common\Battle Brothers\data"
)

$ErrorActionPreference = "Stop"
$raiz = $PSScriptRoot
$build = Join-Path $raiz "build_en"
$sq = Join-Path $raiz "tools\modkit\sq.exe"
$tmp = Join-Path $env:TEMP "necro_check_en.cnut"
$erros = 0

Write-Host "== Gerando a versão em inglês =="
& python (Join-Path $raiz "tools\en\extrair_en.py")
& python (Join-Path $raiz "tools\en\gerar_en.py") $build
if ($LASTEXITCODE -ne 0) {
	Write-Host "Há textos sem tradução. Traduza em tools/en/ e rode de novo." -ForegroundColor Red
	exit 1
}

Write-Host "== Verificando sintaxe =="
Get-ChildItem (Join-Path $build "scripts") -Recurse -Filter *.nut | ForEach-Object {
	$ErrorActionPreference = "Continue"
	$saida = (& $sq -o $tmp -c $_.FullName 2>&1 | Out-String).Trim()
	$ErrorActionPreference = "Stop"
	if ($LASTEXITCODE -ne 0 -or $saida) {
		Write-Host "ERRO em $($_.FullName):" -ForegroundColor Red
		Write-Host $saida
		$erros++
	}
}
Remove-Item $tmp -ErrorAction SilentlyContinue

if ($erros -gt 0) {
	Write-Host "$erros arquivo(s) com erro. Nada foi empacotado." -ForegroundColor Red
	exit 1
}
Write-Host "sintaxe ok"

Write-Host "== Empacotando =="
$zip = Join-Path $raiz "mod_necromante_en.zip"
Remove-Item $zip -ErrorAction SilentlyContinue
Add-Type -AssemblyName System.IO.Compression.FileSystem
$arquivo = [System.IO.Compression.ZipFile]::Open($zip, "Create")
try {
	Get-ChildItem (Join-Path $build "scripts") -Recurse -File | ForEach-Object {
		$nome = $_.FullName.Substring($build.Length + 1).Replace("\", "/")
		[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($arquivo, $_.FullName, $nome) | Out-Null
	}
} finally {
	$arquivo.Dispose()
}
Write-Host "Gerado: $zip"

if ($Instalar) {
	Remove-Item (Join-Path $PastaData "mod_necromante.zip") -ErrorAction SilentlyContinue
	Copy-Item $zip (Join-Path $PastaData "mod_necromante_en.zip") -Force
	Write-Host "Instalado em: $PastaData\mod_necromante_en.zip (a versão em português foi removida da pasta data)" -ForegroundColor Green
}
