# Mod Necromante — Battle Brothers (vanilla + DLCs, sem MSU)

## Instalar / atualizar
```
powershell -ExecutionPolicy Bypass -File C:\Users\User\mod_necromante\build.ps1
```
Verifica a sintaxe de todos os `.nut` e copia `mod_necromante.zip` para `...\Battle Brothers\data\`.
Balanço: edite só `scripts/config/necro_constants.nut`.

## Como jogar
- Nova campanha → origem **"O Necromante"** (1 Necromante + 2 saqueadores de túmulos).
  Nessa origem, Necromantes também aparecem para recrutar nas cidades.
- Em combate o Necromante tem **Erguer o Morto** e **Alternar Tipo de Morto**.
- **Perks do Necromante = evento "O Grimório"**: o Grimório tem pontos PRÓPRIOS (1 por nível,
  até o nível 11). O evento abre sozinho no mapa quando há ponto do Grimório. Os pontos de
  perk normais NÃO são usados: a árvore de perks do jogo continua livre na aba de perks.
  Camada N libera com N-1 perks do Grimório. "Decidir depois" esconde até o próximo nível.

## Roteiro de testes (cap. 15)
1. [ ] Jogo abre; origem aparece; Necromante tem as 2 ativas e "Vontade Inquebrável".
2. [ ] Erguer o Morto: 2 Guerreiros nascem à frente; Arqueiros atrás; cooldown só do tipo usado.
3. [ ] Alternar Tipo: só Guerreiro/Arqueiro no início; após Linhagem Nobre / Arsenal da Cripta aparecem os outros.
4. [ ] Mortos agem sozinhos a partir da próxima rodada, nunca fogem.
5. [ ] Limite: 2 mortos no nível 1, +1 por nível (12 no nível 11) + bônus da subclasse; invocação parcial quando faltam vagas.
6. [ ] Veneno (golpes corpo a corpo) e Necrose (tiros): ícone, acúmulos até 10, duração reinicia, coexistem.
7. [ ] Inimigos mortos-vivos não recebem efeitos (até pegar Mestre da Necromancia).
8. [ ] Despertar do Mago: máx. 2; Mago ergue mortos sozinho (máx. 3x por combate), cooldown do Necromante não muda.
9. [ ] Marca do Comando: mortos focam o alvo; tooltip do alvo mostra os bônus.
10. [ ] Colheita da Morte: dano = restante x 1.25, remove os efeitos; indisponível sem alvos com efeitos.
11. [ ] Alcance dos Mortos (+2 tiro) / Alcance Independente (+1 tudo; corpo a corpo alcança 2).
12. [ ] Putrefação Redobrada: tooltip do efeito mostra dano e turnos dobrados.
13. [ ] Pacto: no máx. 4 Fraturados por combate.
14. [ ] Necromante morre → mortos dele (e Magos) desabam; mortos dos Magos continuam.
15. [ ] Fim do combate sem erro; nenhum item dos mortos no loot; janela de espólios com no máx. 2 itens gastos (+1 a cada 5 níveis).
16. [ ] Equipamento dos mortos muda com o nível do Necromante (pano → couro → malha → escamas/placas).

Erros: mande o `log.html` de `Documentos\Battle Brothers\`.

## Decisões e limitações conhecidas
- **Árvore de perks**: o vanilla tem uma árvore global única; por isso o Grimório (evento).
- **Soldado Nobre** usa espada de armas + escudo heráldico (a espada longa vanilla é de 2 mãos).
- **Lanceiro** usa espeto (spetum): ataque de alcance 2 + Parede de Lanças.
- **Besteiro** usa besta normal: atira e recarrega, então dispara a cada 2 turnos.
- **IA**: comportamentos vanilla (sem pathfinding próprio). A prioridade da Marca usa
  `TargetAttractionMult` (mesmo mecanismo do Taunt). "Desempate por mais acúmulos" não foi
  implementado para os mortos (só para a Marca do Mago).
- **Alcance corpo a corpo +1**: funciona para o jogador; a IA dos mortos ainda tende a encostar no alvo.
- **Eco do Mago**: o Mago recebe 50% de Ossos Reforçados e Voz do Necromante.
- **Vontade Inquebrável**: +20 de Resolução contra medo/pânico/controle mental (a spec não definia números).
- **Salvar/carregar no meio do combate**: fora do escopo (o vanilla não permite).

## Subclasses (etapas B a F)

Todas as 8 subclasses estão implementadas: cada uma com 10 perks (fileiras nos níveis 4/6/8/10), ativas próprias concedidas no Juramento e tipos de morto exclusivos. Testes fora do jogo: `testes.ps1` (567 checagens, incluindo `tests/test_subclasses.nut`).

Roteiro de teste no jogo (um Necromante por subclasse, nível 11 pelo console ou subindo de nível):

| Subclasse | O que conferir |
|---|---|
| Senhor da Legião | Formar Linha dá +15 de Defesa e imunidade a empurrão; Carga Fúnebre leva até 8 mortos ao alvo e eles ficam com -2 PA no turno seguinte; Capitão e Estandarte aparecem no nome/tooltip. |
| Lich | Sentinelas e Acólitos; até 3 Magos (5 com Escola); Conjuração Coletiva faz os Magos invocarem; Raio Necrótico 85% fixo; se o Lich morre sem Filactério, todos os mortos desabam; Filactério salva 1 vez. |
| Mestre da Peste | Putrefatos, Ratos e Arqueiros; Nuvem de Peste envenena quem começa o turno dentro; Epidemia copia 50% dos acúmulos (100% e raio 2 com Pandemia). |
| Cavaleiro da Morte | +20 de Fadiga máxima; Chamar o Cavaleiro (2, ou 3 com Elite Funesta); Execução Sombria: golpe do Necromante e depois os mortos a até 6 tiles atacam. |
| Atirador Espectral | Saraivada Fantasma (máx. 15 atiradores); Marca do Caçador; Caçador Espectral atira a cada 2 turnos; Escudeiros no máximo 4. |
| Coveiro | Reanimar Cadáver em corpos do combate (não chefes); reanimado veste o equipamento do morto e vira pó em 6 turnos (Sem Descanso tira isso); Colheita de Almas cura 20%. |
| Ossário | Fusão de Ossos com 3 a 5 esqueletos vira Abominação (peso 5, máx. 3); Dividir devolve os esqueletos com a mesma % de vida; fundidos não disparam Exército Sem Fim. |
| Maestro dos Ossos | Alternar Ordem e Dar Ordem; Muralha segura os mortos a até 3 tiles; Reagrupar puxa e cura; Opus Final ativa as 4 Ordens uma vez por combate. |

Decisões tomadas onde a spec deixava margem:
- **Ossário**: a fusão é viável com o mesmo mecanismo do colapso dos mortos (consumo silencioso + spawn), então foi implementada como na spec, sem fallback.
- **Coveiro**: o reanimado é um esqueleto que veste cópias do equipamento do morto e copia os atributos (60%/80%), em vez de reusar o script do inimigo (o onInit dos inimigos depende da facção/IA deles). As cópias não viram espólio, exceto pelo Cemitério Itinerante.
- **Escudeiro**: se no início do turno não estiver ao lado do Necromante, dá um passo curto (até 4 tiles) para escoltá-lo.
- **Disparo Triplo**: o primeiro tiro do turno com PA cheio vira 3 tiros (-10% cada) e gasta todo o PA, sem precisar de uma habilidade extra para a IA.
- **Postura Fantasma**: +2 PA para atiradores; tiro depois de andar no mesmo turno tem -10%.
- **Flanco Sombrio**: "flanco ou costas" = alvo que já tem outro morto aliado ao lado.
