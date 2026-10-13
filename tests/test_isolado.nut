::dofile("C:/Users/User/mod_necromante/tests/bb_mock.nut");
local U = ::Const.Necro.Util;

// ------------------------------------------------------------------
secao("1. Instanciar TODAS as classes de habilidade/efeito/perk/evento");
// ------------------------------------------------------------------
local scripts = [
	"scripts/skills/effects/necro_poison_effect", "scripts/skills/effects/necro_necrosis_effect",
	"scripts/skills/effects/necro_mark_effect", "scripts/skills/effects/necro_pact_watcher_effect",
	"scripts/skills/actives/necro_raise_dead", "scripts/skills/actives/necro_cycle_type",
	"scripts/skills/actives/necro_awaken_mage", "scripts/skills/actives/necro_mark",
	"scripts/skills/actives/necro_harvest", "scripts/skills/actives/necro_mage_raise",
	"scripts/skills/actives/necro_mage_mark", "scripts/skills/actives/necro_mage_harvest",
	"scripts/skills/special/necro_unbreakable_will", "scripts/skills/racial/necro_undead_racial",
	"scripts/skills/backgrounds/necromancer_background",
	"scripts/events/events/necro_grimoire_event", "scripts/events/events/necro_spoils_event"
];
foreach (id, p in ::Const.Necro.PerkInfo) scripts.push(p.Script);
local falhouCriar = 0;
foreach (s in scripts)
{
	try { local o = ::new(s); if (o.m.ID == "" ) { print("  sem ID: " + s + "\n"); falhouCriar++; } }
	catch (e) { print("  ERRO criando " + s + ": " + e + "\n"); falhouCriar++; }
}
check(scripts.len() + " classes criadas sem erro", falhouCriar == 0);

// ------------------------------------------------------------------
secao("2. Veneno / Necrose isolados");
// ------------------------------------------------------------------
resetMundo();
::Tactical.State = novoCombate();
local necro = makeNecro("Necro", 3);
local alvo = makeActor("Bandido", 3);
::TacticalEntities.push(alvo);
U.cachePerks(necro);
for (local i = 0; i < 15; i++) U.addStacks(alvo, U.VenenoID, 1, necro.getID());
local v = alvo.getSkills().getSkillByID(U.VenenoID);
check("veneno aplicado", v != null);
check("teto de 10 acúmulos", v.getStacks() == 10);
check("duração = EFEITO_DURACAO (4)", v.getTurnsLeft() == 4);
check("dano por turno 10x3 = 30", v.getDamagePerTurn() == 30);
check("getDamage() existe (exigido pela IA vanilla)", v.getDamage() == 30);
check("dano restante = 30x4 = 120", v.getRemainingDamage() == 120);
U.addStacks(alvo, U.NecroseID, 3, necro.getID());
local n = alvo.getSkills().getSkillByID(U.NecroseID);
check("necrose coexiste com veneno", n != null && alvo.getSkills().hasSkill(U.VenenoID));
local props = { DamageTotalMult = 1.0 };
n.onUpdate(props);
check("necrose x3 reduz 3% do dano causado", props.DamageTotalMult > 0.969 && props.DamageTotalMult < 0.971);
::Time.round = 2;
v.onTurnStart();
check("início do turno NÃO causa dano (evita travar o combate)", alvo.Damage == 0 && v.getTurnsLeft() == 4);
v.onTurnEnd();
check("tick no fim do turno: alvo perdeu 30 HP", alvo.Damage == 30);
check("tick: turnos 4 -> 3", v.getTurnsLeft() == 3);
v.onWaitTurn();
v.onTurnEnd();
check("esperar + fim do turno na mesma rodada não repete dano", alvo.Damage == 30 && v.getTurnsLeft() == 3);
U.addStacks(alvo, U.VenenoID, 1, necro.getID());
check("novo acerto reinicia duração", v.getTurnsLeft() == 4);
local morto = makeActor("Esqueleto", 3);
morto.getFlags().add("undead");
U.addStacks(morto, U.VenenoID, 1, necro.getID());
check("morto-vivo imune sem Mestre da Necromancia", !morto.getSkills().hasSkill(U.VenenoID));

// ------------------------------------------------------------------
secao("3. Marca do Comando isolada");
// ------------------------------------------------------------------
local marca = ::new("scripts/skills/effects/necro_mark_effect");
alvo.getSkills().add(marca);
marca.setup(1.0, necro.getID(), necro.getID());
check("marca: +50% no dano dos efeitos", U.getEffectDamageMult(alvo, necro.getID()) == 1.5);
check("veneno marcado: 10x3x1.5 = 45", v.getDamagePerTurn() == 45);
local p2 = { TargetAttractionMult = 1.0 };
marca.onUpdate(p2);
check("marca: peso de IA x3", p2.TargetAttractionMult == 3.0);
marca.setup(0.5, necro.getID(), necro.getID());
check("marca mais fraca não substitui a mais forte", marca.getPotency() == 1.0);

// ------------------------------------------------------------------
secao("4. Colheita da Morte isolada");
// ------------------------------------------------------------------
local col = ::new("scripts/skills/actives/necro_harvest");
necro.getSkills().add(col);
local alvos = col.getHarvestTargets();
check("colheita encontra 1 alvo com efeitos", alvos.len() == 1);
local esperado = ((v.getRemainingDamage() + n.getRemainingDamage()) * 1.25 + 0.5).tointeger();
check("colheita: (restante veneno+necrose) x 1.25 = " + esperado, alvos[0].Dano == esperado);
local hpAntes = alvo.Damage;
col.onUse(necro, null);
check("colheita causou o dano", alvo.Damage - hpAntes == esperado);
check("colheita removeu veneno e necrose", !alvo.getSkills().hasSkill(U.VenenoID) && !alvo.getSkills().hasSkill(U.NecroseID));
check("colheita entrou em recarga (5)", col.getCooldownLeft() == 5);
col.onTurnStart();
check("recarga cai 1 por turno", col.getCooldownLeft() == 4);

// ------------------------------------------------------------------
secao("5. Background isolado");
// ------------------------------------------------------------------
resetMundo();
local nb = makeNecro("Novo", 1);
check("nível 1: 1 ponto do Grimório e os pontos normais intactos", U.getGrimoirePoints(nb) == 1 && nb.getPerkPoints() == 0);
check("ganha Erguer o Morto", nb.getSkills().hasSkill("actives.necro_raise_dead"));
check("ganha Alternar Tipo", nb.getSkills().hasSkill("actives.necro_cycle_type"));
check("ganha Vontade Inquebrável", nb.getSkills().hasSkill("special.necro_unbreakable_will"));
check("registra Grimório e Espólios", ::SpecialEvents.find("event.necro_grimorio") != null && ::SpecialEvents.find("event.necro_espolios") != null);
local bg2 = nb.getSkills().getSkillByID(U.BackgroundID);
bg2.onAdded();
check("recarregar save não dá pontos a mais", U.getGrimoirePoints(nb) == 1 && nb.getPerkPoints() == 0);

// ------------------------------------------------------------------
secao("6. Filtro de exclusividade no próprio perk");
// ------------------------------------------------------------------
nb.getFlags().set(U.FlagSubclasse, "legion");
nb.getFlags().set(U.FlagGrimorioGastos, 1);
nb.getSkills().add(::new("scripts/skills/perks/perk_necro_alcance_dos_mortos"));
check("perk do Atirador recusado na Legião", !nb.getSkills().hasSkill("perk.necro_alcance_dos_mortos"));
check("ponto do Grimório devolvido ao recusar (normais intactos)", U.getGrimoirePoints(nb) == 1 && nb.getPerkPoints() == 0);
nb.getSkills().add(::new("scripts/skills/perks/perk_necro_exercito_sem_fim"));
check("perk da Legião aceito na Legião", nb.getSkills().hasSkill("perk.necro_exercito_sem_fim"));
nb.getSkills().add(::new("scripts/skills/perks/perk_necro_ossos_reforcados"));
check("perk do tronco aceito", nb.getSkills().hasSkill("perk.necro_ossos_reforcados"));
nb.getSkills().add(::new("scripts/skills/perks/perk_necro_marca_do_comando"));
check("perk removido (Marca antiga) recusado após Juramento", !nb.getSkills().hasSkill("perk.necro_marca_do_comando"));
check("e não deixa a ativa da Marca para trás", !nb.getSkills().hasSkill("actives.necro_mark"));

// ------------------------------------------------------------------
secao("7. Erguer o Morto / Alternar Tipo isolados");
// ------------------------------------------------------------------
local raise = nb.getSkills().getSkillByID("actives.necro_raise_dead");
local cyc = nb.getSkills().getSkillByID("actives.necro_cycle_type");
check("Legião: tipo inicial = guerreiro", raise.getSelectedType() == "guerreiro");
local vistos = [];
for (local i = 0; i < 6; i++) { local nx = cyc.getNextType(); vistos.push(nx); nb.getFlags().set(U.FlagTipoSelecionado, nx); }
check("Alternar percorre só os 5 tipos da Legião e volta ao início", vistos.find("arqueiro") == null && vistos[4] == "guerreiro" && vistos[5] == "soldado");
nb.getFlags().set(U.FlagTipoSelecionado, "arqueiro");
check("tipo inválido salvo cai para o primeiro da subclasse", raise.getSelectedType() == "guerreiro");
check("cooldown do soldado na Legião = 5", raise.getTypeCooldown("soldado") == 5);
check("Tempo de Guerra não pego: guerreiro = 4", raise.getTypeCooldown("guerreiro") == 4);
nb.getSkills().add(::new("scripts/skills/perks/perk_necro_tempo_de_guerra"));
U.cachePerks(nb);
check("Tempo de Guerra: guerreiro 4 -> 3 (mínimo 3)", raise.getTypeCooldown("guerreiro") == 3);
local lich = makeNecro("Lich", 4);
lich.getFlags().set(U.FlagSubclasse, "lich");
local rl = lich.getSkills().getSkillByID("actives.necro_raise_dead");
check("Lich: primeiro tipo = Sentinela de Osso", rl.getSelectedType() == "sentinela");
check("Lich: cooldown da Sentinela = 4 (tabela da subclasse)", rl.getCooldownMax() == 4 && rl.getCooldownLeft() == 0);
local tt = rl.getTooltip();
check("Lich: tooltip funciona sem tipos", tt.len() >= 3);
check("Lich: Alternar Tipo vai para o Acólito", lich.getSkills().getSkillByID("actives.necro_cycle_type").getNextType() == "acolito");

// ------------------------------------------------------------------
secao("8. Tooltips de todos os perks");
// ------------------------------------------------------------------
local tf = 0;
foreach (id, p in ::Const.Necro.PerkInfo)
{
	try { local pk = ::new(p.Script); pk.getTooltip(); } catch (e) { print("  ERRO tooltip " + id + ": " + e + "\n"); tf++; }
}
check("tooltip de todos os perks", tf == 0);

print("\nRESULTADO ISOLADO: " + ::__ok + " ok, " + ::__falhas + " falha(s)\n");
foreach (l in ::__log) print(l + "\n");
