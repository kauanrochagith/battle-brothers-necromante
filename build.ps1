# =====================================================================
# MOD NECROMANTE - build e instalação
# ---------------------------------------------------------------------
# 1. Compila cada .nut com o sq.exe do Battle Brothers Mod Kit, só para
#    checar erros de sintaxe (o resultado da compilação é descartado).
# 2. Empacota a pasta "scripts" em mod_necromante.zip.
# 3. Copia o .zip para a pasta "data" do jogo.
#
# Uso:  powershell -ExecutionPolicy Bypass -File build.ps1
#       (adicione -SemInstalar para só gerar o .zip aqui)
# =====================================================================
param(
	[switch]$SemInstalar,
	[string]$PastaData = "C:\Program Files (x86)\Steam\steamapps\common\Battle Brothers\data"
)

$ErrorActionPreference = "Stop"
$raiz = $PSScriptRoot
$sq = Join-Path $raiz "tools\modkit\sq.exe"
$tmp = Join-Path $env:TEMP "necro_check.cnut"
$erros = 0

Write-Host "== Verificando sintaxe =="
Get-ChildItem (Join-Path $raiz "scripts") -Recurse -Filter *.nut | ForEach-Object {
	# O sq.exe escreve erros no stderr; não deixamos isso abortar o script.
	$ErrorActionPreference = "Continue"
	$saida = (& $sq -o $tmp -c $_.FullName 2>&1 | Out-String).Trim()
	$ErrorActionPreference = "Stop"
	if ($LASTEXITCODE -ne 0 -or $saida) {
		Write-Host "ERRO em $($_.FullName):" -ForegroundColor Red
		Write-Host $saida
		$erros++
	} else {
		Write-Host "ok  $($_.FullName.Substring($raiz.Length + 1))"
	}
}
Remove-Item $tmp -ErrorAction SilentlyContinue

if ($erros -gt 0) {
	Write-Host "$erros arquivo(s) com erro. Nada foi empacotado." -ForegroundColor Red
	exit 1
}

Write-Host "== Empacotando =="
$zip = Join-Path $raiz "mod_necromante.zip"
Remove-Item $zip -ErrorAction SilentlyContinue
Add-Type -AssemblyName System.IO.Compression.FileSystem
$arquivo = [System.IO.Compression.ZipFile]::Open($zip, "Create")
try {
	Get-ChildItem (Join-Path $raiz "scripts") -Recurse -File | ForEach-Object {
		# O jogo exige barras normais e o caminho começando em "scripts/".
		$nome = $_.FullName.Substring($raiz.Length + 1).Replace("\", "/")
		[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($arquivo, $_.FullName, $nome) | Out-Null
	}
} finally {
	$arquivo.Dispose()
}
Write-Host "Gerado: $zip"

if (-not $SemInstalar) {
	Copy-Item $zip (Join-Path $PastaData "mod_necromante.zip") -Force
	Write-Host "Instalado em: $PastaData\mod_necromante.zip" -ForegroundColor Green
}
