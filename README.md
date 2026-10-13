# Mod Necromante — Battle Brothers

Mod para o jogo **Battle Brothers** (versão 1.5 + DLCs) que adiciona a classe **Necromante**: um personagem que ergue mortos-vivos para lutar ao lado da companhia.

Funciona no jogo sem modificações (vanilla), **sem precisar de MSU ou de outros frameworks de mods**.

## O que o mod adiciona

- **Origem "O Necromante"**: nova campanha que começa com um Necromante e dois saqueadores de túmulos.
- **Erguer o Morto**: invoca esqueletos (guerreiros, arqueiros, soldados, lanceiros, besteiros, etc.) que agem sozinhos na batalha.
- **Limite de mortos por nível**: 2 mortos no nível 1, +1 por nível, até 12 no nível 11. A subclasse soma vagas extras.
- **Equipamento por nível**: os mortos usam armas e armaduras sorteadas conforme o nível do Necromante (de trapos e facas a cotas de escamas, placas, piques e bestas pesadas).
- **Veneno do Cadáver e Necrose**: efeitos que acumulam nos inimigos atingidos pelos mortos.
- **Grimório**: árvore de perks própria, com pontos próprios (1 por nível), escolhida por um evento quando o Necromante sobe de nível. A árvore de perks normal do jogo continua disponível.
- **8 subclasses** (escolhidas no nível 3): Senhor da Legião, Lich, Mestre da Peste, Cavaleiro da Morte, Atirador Espectral, Coveiro, Ossário e Maestro dos Ossos, cada uma com habilidades e perks próprios.
- **Espólios dos mortos**: depois da batalha, alguns itens gastos dos mortos podem ser guardados ou oferecidos em troca de XP ou de ouro.

## Versão em inglês (English version)

There is an **English version** of the mod: download `mod_necromante_en.zip` from the [Releases](https://github.com/kauanrochagith/battle-brothers-necromante/releases) page and copy it (without unzipping) to the game's `data` folder. Install **only one** of the two files (Portuguese or English).

O código-fonte é um só, em português. A versão em inglês é gerada pelo `build_en.ps1`, que troca os textos pelas traduções de `tools/en/textos_en.json` (textos novos aparecem ali vazios para traduzir; `tools/en/gerar_en.py juntar` confere variáveis, cores e quebras de linha).

## Instalação

1. Baixe ou gere o arquivo `mod_necromante.zip` (veja "Compilar" abaixo).
2. Copie o `.zip` para a pasta `data` do jogo, por exemplo:
   `C:\Program Files (x86)\Steam\steamapps\common\Battle Brothers\data\`
3. Comece uma nova campanha e escolha a origem **"O Necromante"**.

## Compilar

O script `build.ps1` verifica a sintaxe de todos os `.nut`, empacota a pasta `scripts` e copia o `.zip` para o jogo:

```
powershell -ExecutionPolicy Bypass -File build.ps1
```

Ele precisa do `sq.exe` do **Battle Brothers Mod Kit** em `tools\modkit\` (não incluído neste repositório). Use `-SemInstalar` para só gerar o `.zip`.

## Testes

Os testes rodam fora do jogo, com um ambiente simulado (`tests/bb_mock.nut`):

```
powershell -ExecutionPolicy Bypass -File testes.ps1
```

## Balanceamento

Todos os números do mod (limite de mortos, atributos, recargas, equipamento por nível, espólios) ficam em um só arquivo: `scripts/config/necro_constants.nut`.

## Estrutura

```
scripts/
  config/        constantes de balanço e funções auxiliares
  entity/        os tipos de mortos-vivos
  skills/        habilidades ativas, perks, efeitos e passivas
  events/        Grimório (perks) e Espólios dos mortos
  ai/            comportamento dos mortos na batalha
  scenarios/     origem "O Necromante"
tests/           testes fora do jogo
```

Mais detalhes de uso e um roteiro de testes no jogo em [LEIA-ME.md](LEIA-ME.md).

## Compatibilidade com o Legends

O mod funciona no jogo original sem hooks. Com o **Legends** (que exige MSU e Modern Hooks), o arquivo `scripts/!mods_preload/mod_necromante.nut` integra o respec do Legends: os perks do Grimório voltam como pontos do Grimório. Os mortos erguidos usam a armadura em camadas do Legends.

## Versões

- **1.0.1**: versão em inglês (arquivo separado); compatibilidade com o Legends; o Grimório tem pontos próprios (1 por nível) e a árvore de perks normal fica livre; corrigido o travamento em combate quando um inimigo morria pelo Veneno do Cadáver/Necrose (o dano agora sai no fim do turno do alvo).
- **1.0.0**: primeira versão.
