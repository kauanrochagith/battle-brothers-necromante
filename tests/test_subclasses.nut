// ======================================================================
// Etapa F - testes das 8 subclasses (fora do jogo, com bb_mock.nut)
// Cobre o checklist do cap. 13 que não depende do mapa tático:
//   - exclusividade de perks e ativas entre TODAS as subclasses;
//   - todo perk/ativa/efeito da tabela carrega e tem o ID esperado;
//   - fileiras abrem nos níveis 4/6/8/10;
//   - tipos de cada subclasse existem e têm script;
//   - limites com peso (Legião Incontável, Escola de Magos, Escudeiro máx. 4);
//   - Ordens do Maestro (duração, Batuta, Ordem Dupla 50%, Crescendo, Opus);
//   - teto de acúmulos (Virulência) e efeito em mortos-vivos.
// Spawn, IA e combate real só são testáveis no jogo (ver LEIA-ME.md).
// ======================================================================
::dofile("C:/Users/User/mod_necromante/tests/bb_mock.nut");
local U = ::Const.Necro.Util;
local N = ::Const.Necro;

// Simula event.setScreen do vanilla: clona a tela e roda start().
function abrir( _ev, _id )
{
	local def = _ev.getScreen(_id);
	local s = clone def;
	s.Options = [];
	foreach (o in def.Options) s.Options.push(clone o);
	s.List = [];
	s.Characters = [];
	s.start(_ev);
	// Limite real da janela do vanilla (ui/controls/dialog.js): mais de 6 botões
	// e só o primeiro aparece. Toda tela aberta nos testes é conferida.
	if (s.Options.len() > ::Const.Necro.BOTOES_MAX_EVENTO)
	{
		::__falhas++;
		print("  FALHA tela '" + _id + "' com " + s.Options.len() + " botões (máx. " + ::Const.Necro.BOTOES_MAX_EVENTO + ")" + "\n");
	}
	return s;
}
function opcoes( _tela ) { local r = []; foreach (o in _tela.Options) r.push(o.Text); return r; }
function temOpcao( _tela, _txt ) { foreach (o in _tela.Options) if (o.Text.find(_txt) != null) return true; return false; }
// Clica no botão cujo texto contém _txt; retorna a próxima tela (ou null se fechou).
function clicar( _ev, _tela, _txt )
{
	foreach (o in _tela.Options)
		if (o.Text.find(_txt) != null)
		{
			local r = o.getResult(_ev);
			if (typeof r == "string") return abrir(_ev, r);
			return null;
		}
	throw "botão não encontrado: " + _txt;
}
function iniciarEvento( _ev, _ign = null ) { _ev.onClear(); _ev.onPrepare(); return abrir(_ev, _ev.onDetermineStartScreen()); }
function existeScript( _s ) { return fileExists(::MOD + _s + ".nut"); }

// ==================================================================
secao("1. Tabela das subclasses");
// ==================================================================
local totalPerks = 0;
local dono = {};
foreach (subID, s in N.Subclasses)
{
	local n = 0;
	foreach (f, fileira in s.Fileiras)
	{
		foreach (id in fileira)
		{
			n++;
			check(subID + ": perk " + id + " está no PerkInfo", id in N.PerkInfo);
			check(subID + ": perk " + id + " pertence só a ela", !(id in dono));
			dono[id] <- subID;
		}
	}
	totalPerks += n;
	check(subID + ": 10 perks (3/3/2/2)", n == 10 && s.Fileiras[0].len() == 3 && s.Fileiras[1].len() == 3 && s.Fileiras[2].len() == 2 && s.Fileiras[3].len() == 2);
	foreach (e in s.Tipos)
	{
		check(subID + ": tipo " + e.Tipo + " existe", e.Tipo in N.Tipos);
		if (e.Tipo in N.Tipos) check(subID + ": script de " + e.Tipo + " existe", existeScript(N.Tipos[e.Tipo].Script));
	}
	foreach (script in s.Ativas) check(subID + ": ativa " + script + " existe", existeScript(script));
}
check("80 perks de subclasse no total", totalPerks == 80);
foreach (k in ["abominacao", "torre", "cavaleiro", "reanimado", "putrefato"]) check("script do tipo especial " + k, existeScript(N.Tipos[k].Script));

// ==================================================================
secao("2. Todo perk carrega, tem o ID certo e marca a subclasse");
// ==================================================================
foreach (id, info in N.PerkInfo)
{
	local ok = true;
	try
	{
		local p = ::new(info.Script);
		ok = p.getID() == id && p.getName() == info.Nome;
	}
	catch (e) { ok = false; print("  erro ao carregar " + info.Script + ": " + e + "\n"); }
	check("perk carrega: " + id, ok);
}

// ==================================================================
secao("3. Toda ativa de subclasse carrega com o ID esperado");
// ==================================================================
foreach (subID, s in N.Subclasses)
{
	foreach (script in s.Ativas)
	{
		local ok = true;
		try { local a = ::new(script); ok = a.getID() == U.getActiveIDFromScript(script); }
		catch (e) { ok = false; print("  erro ao carregar " + script + ": " + e + "\n"); }
		check(subID + ": ativa carrega com ID certo: " + script, ok);
	}
}
foreach (script in ["scripts/skills/actives/necro_grave_devour", "scripts/skills/actives/necro_maestro_opus", "scripts/skills/actives/necro_mage_ray",
	"scripts/skills/effects/necro_baixas_effect", "scripts/skills/effects/necro_formation_effect", "scripts/skills/effects/necro_charge_tired_effect",
	"scripts/skills/effects/necro_hunter_mark_effect", "scripts/skills/effects/necro_phylactery_buff_effect", "scripts/skills/effects/necro_enemy_aura_effect",
	"scripts/skills/effects/necro_corpse_watcher_effect"])
{
	local ok = true;
	try { ::new(script); } catch (e) { ok = false; print("  erro: " + script + ": " + e + "\n"); }
	check("carrega: " + script, ok);
}

// ==================================================================
secao("4. Exclusividade: cada subclasse só vê e só pega o que é dela");
// ==================================================================
local gri = ::new("scripts/events/events/necro_grimoire_event");
foreach (subID, s in N.Subclasses)
{
	resetMundo();
	local n = makeNecro("N_" + subID, 11);
	n.getFlags().set(U.FlagSubclasse, subID);
	n.getSkills().getSkillByID(U.BackgroundID).syncSubclassActives();

	// Grimório no nível 11 oferece exatamente os 10 perks da subclasse (+ tronco).
	local ofertados = {};
	for (local g = 1; g <= 4; g++) foreach (p in gri.getAvailableInGroup(n, g)) ofertados[p.ID] <- true;
	local soDela = true;
	foreach (id, _ in ofertados) if (dono[id] != subID) soDela = false;
	check(subID + ": Grimório oferece os 10 perks dela", ofertados.len() == 10);
	check(subID + ": Grimório não oferece perk de outra", soDela);

	// Perk de outra subclasse adicionado à força se remove e devolve o ponto.
	foreach (id, d in dono)
	{
		if (d == subID) continue;
		local pts = n.m.PerkPoints;
		n.getSkills().add(::new(N.PerkInfo[id].Script));
		if (n.getSkills().hasSkill(id) || n.m.PerkPoints != pts + 1)
		{
			check(subID + ": perk alheio " + id + " bloqueado", false);
		}
		n.m.PerkPoints = pts;
	}
	check(subID + ": nenhum dos 70 perks alheios ficou", true);

	// Ativas: tem as dela, não tem as das outras.
	local todas = U.getAllSubclassActiveIDs();
	local ativasOk = true;
	foreach (id, d in todas)
	{
		local tem = n.getSkills().hasSkill(id);
		local deveria = false;
		foreach (script in s.Ativas) if (U.getActiveIDFromScript(script) == id) deveria = true;
		if (tem != deveria) { ativasOk = false; print("  " + subID + ": ativa " + id + " tem=" + tem + "\n"); }
	}
	check(subID + ": ativas exclusivas corretas", ativasOk);
}

// ==================================================================
secao("5. Fileiras por nível (4/6/8/10)");
// ==================================================================
resetMundo();
local m = makeNecro("Maestro", 3);
m.getFlags().set(U.FlagSubclasse, "maestro");
local porNivel = [[3, 0], [4, 3], [5, 3], [6, 6], [7, 6], [8, 8], [9, 8], [10, 10], [11, 10]];
foreach (pn in porNivel)
{
	m.m.Level = pn[0];
	local n = 0;
	for (local g = 1; g <= 4; g++) n += gri.getAvailableInGroup(m, g).len();
	check("nível " + pn[0] + ": " + pn[1] + " perks liberados", n == pn[1]);
}

// ==================================================================
secao("6. Limites com peso");
// ==================================================================
resetMundo();
::Tactical.State = novoCombate();
local leg = makeNecro("Legiao", 11);
leg.getFlags().set(U.FlagSubclasse, "legion");
U.clearRuntime();
check("Legião nível 11: limite 12 + 4 = 16", U.getMaxSummons(leg.getID()) == 16);
leg.getSkills().add(::new("scripts/skills/perks/perk_necro_legiao_incontavel"));
U.clearRuntime();
check("Legião Incontável: limite 18", U.getMaxSummons(leg.getID()) == 18);
local rl = leg.getSkills().getSkillByID("actives.necro_raise_dead");
check("Legião Incontável: cooldown do guerreiro 4 -> 3", rl.getTypeCooldown("guerreiro") == 3);

local li = makeNecro("Lich", 11);
li.getFlags().set(U.FlagSubclasse, "lich");
U.clearRuntime();
check("Lich: 3 magos", U.getMaxMages(li.getID()) == 3);
li.getSkills().add(::new("scripts/skills/perks/perk_necro_escola_de_magos"));
U.clearRuntime();
check("Escola de Magos: 5 magos (teto)", U.getMaxMages(li.getID()) == 5);

local at = makeNecro("Atirador", 11);
at.getFlags().set(U.FlagSubclasse, "shooter");
U.clearRuntime();
check("Atirador: Escudeiro com máximo 4", U.getTypeMaxUnits(at.getID(), "escudeiro") == 4);
check("Atirador: Arqueiro sem máximo próprio", U.getTypeMaxUnits(at.getID(), "arqueiro") == -1);
check("peso da Abominação = 4", U.getTypeWeight("abominacao") == N.OSSARIO_PESO_ABOMINACAO && U.getTypeWeight("guerreiro") == 1);

// Mortos simulados com peso: 2 Abominações + 2 esqueletos = 10 vagas de 15 (12 + 3) no Ossário nível 11.
local os = makeNecro("Ossario", 11);
os.getFlags().set(U.FlagSubclasse, "ossuary");
U.clearRuntime();
foreach (i, peso in [4, 4, 1, 1])
{
	local e = makeActor("morto" + i, ::Const.Faction.PlayerAnimals);
	e.getFlags().add(U.FlagMorto);
	e.getFlags().set(U.FlagMestre, os.getID());
	if (peso > 1) e.getFlags().set(U.FlagPeso, peso);
	::TacticalEntities.push(e);
}
check("Ossário: peso somado 10", U.countSummonWeight(os.getID()) == 10);
check("Ossário: cabem 5 esqueletos", U.getFreeSlots(os.getID()) == 5);
check("Ossário: cabe 1 Abominação", U.getFreeSlots(os.getID(), 4) == 1);
::TacticalEntities.clear();

// ==================================================================
secao("7. Ordens do Maestro");
// ==================================================================
resetMundo();
::Tactical.State = novoCombate();
local ma = makeNecro("Maestro", 11);
ma.getFlags().set(U.FlagSubclasse, "maestro");
U.clearRuntime();
local id = ma.getID();
U.giveOrder(id, "ataque");
check("Ordem dura ORDEM_DURACAO", U.getActiveOrders(id)[0].Turnos == N.ORDEM_DURACAO);
check("Ataque Total a 100%", U.getOrderMult(id, "ataque") == 1.0);
U.giveOrder(id, "muralha");
check("sem Ordem Dupla: a nova substitui", U.getOrderMult(id, "ataque") == 0.0 && U.getOrderMult(id, "muralha") == 1.0);
ma.getSkills().add(::new("scripts/skills/perks/perk_necro_ordem_dupla"));
ma.getSkills().add(::new("scripts/skills/perks/perk_necro_batuta_ossea"));
U.clearRuntime();
U.giveOrder(id, "ataque");
U.giveOrder(id, "disparo");
check("Ordem Dupla: anterior fica com 50%", U.getOrderMult(id, "disparo") == 1.0 && U.getOrderMult(id, "ataque") == 0.5);
check("Batuta Óssea: +1 turno", U.getActiveOrders(id)[0].Turnos == N.ORDEM_DURACAO + 1);
U.tickOrders(id); U.tickOrders(id);
check("Ordem dura até o fim", U.getOrderMult(id, "disparo") == 1.0);
U.tickOrders(id);
check("Ordem expira", U.getActiveOrders(id).len() == 0);
ma.getSkills().add(::new("scripts/skills/perks/perk_necro_crescendo"));
U.clearRuntime();
U.giveOrder(id, "muralha");
check("Crescendo: 1º turno sem bônus", U.getCrescendoMult(id) == 1.0);
U.getActiveOrders(id)[0].Turnos = 99;
U.tickOrders(id); U.tickOrders(id);
check("Crescendo: 2º turno seguido = +5%", ::Math.abs(U.getCrescendoMult(id) - 1.05) < 0.001);
for (local i = 0; i < 10; i++) U.tickOrders(id);
check("Crescendo: teto de +25%", ::Math.abs(U.getCrescendoMult(id) - 1.25) < 0.001);
U.giveAllOrders(id, N.Sub.Maestro.OpusTurnos);
local todas = true;
foreach (o in N.Ordens) if (U.getOrderMult(id, o.ID) != 1.0) todas = false;
check("Opus Final: 4 Ordens a 100%", todas);
local cyc = ::new("scripts/skills/actives/necro_maestro_cycle");
ma.getSkills().add(cyc);
check("Alternar Ordem começa em Ataque Total", cyc.getIndex() == 0);
cyc.onUse(ma, null);
check("Alternar Ordem avança para Muralha", ma.getFlags().get("necro_ordem_sel") == "muralha");

// ==================================================================
secao("8. Peste: teto de acúmulos e mortos-vivos");
// ==================================================================
resetMundo();
::Tactical.State = novoCombate();
local pe = makeNecro("Peste", 11);
pe.getFlags().set(U.FlagSubclasse, "plague");
U.clearRuntime();
check("teto padrão = ACUMULO_MAX", U.getStackCap(pe.getID()) == N.ACUMULO_MAX);
check("sem perks: morto-vivo imune", U.getUndeadEffectMult(pe.getID()) == 0.0);
pe.getSkills().add(::new("scripts/skills/perks/perk_necro_virulencia"));
U.clearRuntime();
check("Virulência: teto +5", U.getStackCap(pe.getID()) == N.ACUMULO_MAX + 5);
check("Virulência: mortos-vivos a 25%", U.getUndeadEffectMult(pe.getID()) == 0.25);
local alvo = makeActor("Bandido", ::Const.Faction.Enemy);
::TacticalEntities.push(alvo);
U.addStacks(alvo, U.VenenoID, 20, pe.getID());
check("acúmulos param no teto de 15", alvo.getSkills().getSkillByID(U.VenenoID).getStacks() == 15);
check("total de acúmulos = 15", U.getTotalStacks(alvo) == 15);

// Lich: Mestre da Necromancia continua dando 50% (vale o maior).
local lc = makeNecro("Lich2", 11);
lc.getFlags().set(U.FlagSubclasse, "lich");
lc.getSkills().add(::new("scripts/skills/perks/perk_necro_mestre_da_necromancia"));
U.clearRuntime();
check("Mestre da Necromancia: mortos-vivos a 50%", U.getUndeadEffectMult(lc.getID()) == N.Perks.MESTRE_MORTOVIVO_MULT);

// ==================================================================
secao("9. Juramento concede as ativas e não aparecem as ocultas na lista");
// ==================================================================
resetMundo();
local nj = makeNecro("Jurado", 3);
local t = iniciarEvento(gri, nj);
t = clicar(gri, t, "Ver outras subclasses");
local c = clicar(gri, t, "Coveiro");
check("Coveiro: confirmação lista Reanimar Cadáver", c.List[2].text.find("Reanimar Cadáver") != null);
check("Coveiro: regra oculta não aparece na lista", c.List[2].text.find("necro_sub") == null && c.List[2].text.find(", ,") == null);
clicar(gri, c, "Jurar");
check("Coveiro: recebeu Reanimar e Colheita de Almas", nj.getSkills().hasSkill("actives.necro_grave_raise") && nj.getSkills().hasSkill("actives.necro_grave_harvest"));
check("Coveiro: recebeu a regra oculta", nj.getSkills().hasSkill("actives.necro_sub_gravedigger"));
check("Coveiro: NÃO recebeu ativas do Lich", !nj.getSkills().hasSkill("actives.necro_lich_ray") && !nj.getSkills().hasSkill("actives.necro_awaken_mage"));

// Perks que concedem ativa.
resetMundo();
local nf = makeNecro("Necrofago", 11);
nf.getFlags().set(U.FlagSubclasse, "gravedigger");
nf.getSkills().add(::new("scripts/skills/perks/perk_necro_necrofago"));
check("Necrófago concede a ativa", nf.getSkills().hasSkill("actives.necro_grave_devour"));
local mo = makeNecro("Opus", 11);
mo.getFlags().set(U.FlagSubclasse, "maestro");
mo.getSkills().add(::new("scripts/skills/perks/perk_necro_opus_final"));
check("Opus Final concede a ativa", mo.getSkills().hasSkill("actives.necro_maestro_opus"));
local ml = makeNecro("Errado", 11);
ml.getFlags().set(U.FlagSubclasse, "legion");
ml.getSkills().add(::new("scripts/skills/perks/perk_necro_opus_final"));
check("Opus Final num Senhor da Legião: bloqueado e sem ativa", !ml.getSkills().hasSkill("perk.necro_opus_final") && !ml.getSkills().hasSkill("actives.necro_maestro_opus"));

print("\nRESULTADO SUBCLASSES: " + ::__ok + " ok, " + ::__falhas + " falha(s)\n");
