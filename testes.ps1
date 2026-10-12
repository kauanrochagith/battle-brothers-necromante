# =====================================================================
# MOD NECROMANTE - testes fora do jogo
# ---------------------------------------------------------------------
# Roda os scripts REAIS do mod num mini-ambiente que imita o Battle Brothers
# (tests/bb_mock.nut), usando as classes-base REAIS do vanilla decompiladas
# em tools/vanilla/. Personagens, mapa e mundo são simulados.
#   tests/test_isolado.nut  -> cada peça separada
#   tests/test_conjunto.nut -> fluxos completos (Grimório, Juramento,
#                              migração, salvar/carregar, espólios)
# O que NÃO é coberto: entidades no mapa, IA e spawn (só no jogo).
#
# Uso: powershell -ExecutionPolicy Bypass -File testes.ps1
# =====================================================================
$ErrorActionPreference = "Continue"
$raiz = $PSScriptRoot
$sq = Join-Path $raiz "tools\modkit\sq.exe"
$falhou = $false

foreach ($t in @("test_isolado.nut", "test_conjunto.nut", "test_subclasses.nut")) {
	Write-Host "== $t =="
	$saida = (& $sq (Join-Path $raiz "tests\$t") 2>&1 | Out-String)
	$saida.Split("`n") | Where-Object { $_ -cmatch "  FALHA |RESULTADO|AN ERROR HAS OCCURED|ERRO:" } | ForEach-Object { Write-Host $_ }
	if ($saida -cmatch "  FALHA |AN ERROR HAS OCCURED" -or $saida -cnotmatch "RESULTADO") { $falhou = $true }
}

if ($falhou) {
	Write-Host "Há falhas. Rode o arquivo de teste direto para ver os detalhes." -ForegroundColor Red
	exit 1
}
Write-Host "Todos os testes passaram." -ForegroundColor Green
