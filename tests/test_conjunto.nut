::dofile("C:/Users/User/mod_necromante/tests/bb_mock.nut");
local U = ::Const.Necro.Util;

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
function subirNivel( _n, _nivel ) { while (_n.m.Level < _nivel) { _n.m.Level++; _n.m.PerkPoints++; } }
function perksOferecidos( _ev, _n )
{
	local r = [];
	for (local g = 0; g <= 4; g++) foreach (p in _ev.getAvailableInGroup(_n, g)) r.push(p.ID);
	return r;
}

local gri = ::new("scripts/events/events/necro_grimoire_event");

// ==================================================================
secao("A. Fluxo completo: nível 1 -> tronco -> Juramento -> fileiras");
// ==================================================================
resetMundo();
local n = makeNecro("Morbus", 1);
check("nível 1: Grimório válido (ponto do Grimório)", gri.isValid());
local t = iniciarEvento(gri, n);
check("nível 1: abre na tela de perks (A)", gri.m.Modo == "perks");
check("nível 1: oferece os 3 perks do tronco", temOpcao(t, "Ossos") && temOpcao(t, "Disciplina") && temOpcao(t, "Tempo de Guerra"));
check("nível 1: nada de subclasse oferecido", perksOferecidos(gri, n).len() == 3);
local r = clicar(gri, t, "Ossos");
check("aprendeu Ossos Reforçados", n.getSkills().hasSkill("perk.necro_ossos_reforcados") && r.ID == "B");
check("gastou o ponto do Grimório", U.getGrimoirePoints(n) == 0);
check("pontos de perk normais NÃO foram gastos", n.getPerkPoints() == 0 && n.m.PerkPointsSpent == 0);
check("sem pontos: Grimório fecha", !gri.isValid());
subirNivel(n, 2);
t = iniciarEvento(gri, n);
clicar(gri, t, "Disciplina");
check("2 perks do tronco", gri.countTrunkPerks(n) == 2);
n.getFlags().set(U.FlagGrimorioGastos, 1);
check("limite do tronco: 3º perk do tronco NÃO é oferecido", perksOferecidos(gri, n).len() == 0);
n.getFlags().set(U.FlagGrimorioGastos, 2);
check("árvore normal livre: nível 2 tem 1 ponto de perk normal", n.getPerkPoints() == 1);
subirNivel(n, 3);
check("nível 3: Grimório válido", gri.isValid());
t = iniciarEvento(gri, n);
check("nível 3: abre o Juramento (J)", t.ID == "J");
check("Juramento pág. 1: 4 subclasses + 'Ver outras' + 'Decidir depois' = 6 botões", t.Options.len() == 6);
check("pág. 1: Legião, Lich, Peste e Cavaleiro", temOpcao(t, "Legião") && temOpcao(t, "Lich") && temOpcao(t, "Peste") && temOpcao(t, "Cavaleiro"));
check("texto lista as 8 subclasses em qualquer página", t.List.len() == 8);
local p2 = clicar(gri, t, "Ver outras subclasses");
check("pág. 2: Atirador, Coveiro, Ossário e Maestro", p2.Options.len() == 6 && temOpcao(p2, "Atirador") && temOpcao(p2, "Coveiro") && temOpcao(p2, "Ossário") && temOpcao(p2, "Maestro"));
local p3 = clicar(gri, p2, "Ver outras subclasses");
check("'Ver outras' volta para a pág. 1", temOpcao(p3, "Legião"));
local alcancaveis = {};
foreach (pg in [ t, p2 ]) foreach (o in pg.Options) if ("SubID" in o) alcancaveis[o.SubID] <- true;
check("todas as 8 subclasses podem ser escolhidas", alcancaveis.len() == 8);
t = p3;
local c = clicar(gri, t, "Lich");
check("tela de confirmação do Lich", c.ID == "C" && c.Text.find("Lich") != null);
check("confirmação lista os tipos do Lich", c.List[1].text.find("Sentinela de Osso") != null && c.List[1].text.find("Acólito Espectral") != null);
check("confirmação: árvore completa (10 de 10)", c.List[3].text.find("10 de 10") != null);
local j = clicar(gri, c, "Voltar");
check("'Voltar' retorna ao Juramento sem jurar", j.ID == "J" && U.getSubclass(n) == null);
j = clicar(gri, j, "Ver outras subclasses");
c = clicar(gri, j, "Maestro");
local s = clicar(gri, c, "Jurar");
check("jurou Maestro dos Ossos", U.getSubclass(n) == "maestro" && s.ID == "S");
check("Juramento gastou o ponto do Grimório do nível 3", U.getGrimoirePoints(n) == 0 && n.getFlags().getAsInt(U.FlagGrimorioGastos) == 3);
check("nível 3: os 2 pontos de perk normais continuam livres", n.getPerkPoints() == 2);
check("Maestro recebeu Marca do Comando (inata)", n.getSkills().hasSkill("actives.necro_mark"));
check("Maestro NÃO recebeu Despertar do Mago", !n.getSkills().hasSkill("actives.necro_awaken_mage"));
check("Juramento não reabre", !gri.needsOath(n));
s = clicar(gri, c, "Jurar");
check("jurar de novo não muda a subclasse", U.getSubclass(n) == "maestro" && n.getFlags().getAsInt(U.FlagGrimorioGastos) == 3);
subirNivel(n, 4);
local of = perksOferecidos(gri, n);
check("nível 4: só a fileira 1 do Maestro (3 perks)", of.len() == 3 && of.find("perk.necro_voz_do_necromante") != null && of.find("perk.necro_batuta_ossea") != null && of.find("perk.necro_sincronia") != null);
subirNivel(n, 10);
of = perksOferecidos(gri, n);
check("nível 10: fileira 4 abre (Essência Morta)", of.find("perk.necro_essencia_morta") != null);
local vazou = 0;
foreach (id in of) { local d = ::Const.Necro.PerkInfo[id].Subclasse; if (d != "maestro" && d != "tronco") vazou++; }
check("EXCLUSIVIDADE: nenhum perk de outra subclasse oferecido", vazou == 0);
check("tronco não volta depois de 2 perks", of.find("perk.necro_tempo_de_guerra") == null);
t = iniciarEvento(gri, n);
check("Grimório abre na fileira mais alta liberada (4)", gri.m.Grupo == 4);
check("botão 'Ver outra fileira' aparece", temOpcao(t, "Ver outra fileira"));
local t2 = clicar(gri, t, "Ver outra fileira");
check("'Ver outra fileira' troca de fileira", gri.m.Grupo != 4 && t2.ID == "A");
local d = clicar(gri, t2, "Decidir depois");
check("'Decidir depois' esconde até o próximo nível", d == null && !gri.isValid());
subirNivel(n, 11);
check("próximo nível: Grimório volta", gri.isValid());
check("perk de outra subclasse recusado por learn()", !gri.learn("perk.necro_alcance_dos_mortos"));

// ==================================================================
secao("B. Migração de save antigo (perks da base, sem subclasse)");
// ==================================================================
resetMundo();
local old = makeNecro("Velho", 6);
old.m.PerkPoints = 0;
old.m.PerkPointsSpent = 6;
foreach (p in ["perk_necro_ossos_reforcados", "perk_necro_eco_do_mago", "perk_necro_arsenal_da_cripta", "perk_necro_alcance_dos_mortos", "perk_necro_despertar_do_mago", "perk_necro_mestre_da_necromancia"])
	old.getSkills().add(::new("scripts/skills/perks/" + p));
check("save antigo: perks antigos tolerados antes do Juramento", old.getSkills().hasSkill("perk.necro_eco_do_mago"));
check("save antigo: Despertar antigo dá a ativa", old.getSkills().hasSkill("actives.necro_awaken_mage"));
check("Juramento abre mesmo sem pontos", gri.isValid());
t = iniciarEvento(gri, old);
c = clicar(gri, t, "Lich");
s = clicar(gri, c, "Jurar");
check("migração removeu Eco, Arsenal, Alcance e Despertar", !old.getSkills().hasSkill("perk.necro_eco_do_mago") && !old.getSkills().hasSkill("perk.necro_arsenal_da_cripta") && !old.getSkills().hasSkill("perk.necro_alcance_dos_mortos") && !old.getSkills().hasSkill("perk.necro_despertar_do_mago"));
check("migração manteve tronco e o perk do Lich (Mestre)", old.getSkills().hasSkill("perk.necro_ossos_reforcados") && old.getSkills().hasSkill("perk.necro_mestre_da_necromancia"));
check("migração: 6 pontos normais devolvidos à árvore do jogo", old.getPerkPoints() == 6 && old.m.PerkPointsSpent == 0);
check("4 pontos do Grimório devolvidos (Juramento sem ponto = grátis)", U.getGrimoirePoints(old) == 4);
check("tela final lista os 4 devolvidos", s.List.len() == 4);
check("Lich mantém Despertar do Mago (inata) mesmo removendo o perk antigo", old.getSkills().hasSkill("actives.necro_awaken_mage"));

// ==================================================================
secao("C. Salvar/carregar (simulado: recria o personagem a partir das flags)");
// ==================================================================
local load = makeActor("Velho (carregado)");
foreach (k, v in old.getFlags().m) load.getFlags().set(k, v.Value);
load.m.PerkPoints = old.m.PerkPoints;
load.getSkills().add(::new("scripts/skills/backgrounds/necromancer_background"));
foreach (id in ["perk_necro_ossos_reforcados", "perk_necro_mestre_da_necromancia"]) load.getSkills().add(::new("scripts/skills/perks/" + id));
check("carregado: subclasse mantida", U.getSubclass(load) == "lich");
check("carregado: ponto extra NÃO dado de novo", load.m.PerkPoints == old.m.PerkPoints);
check("carregado: ativa da subclasse recriada (Despertar)", load.getSkills().hasSkill("actives.necro_awaken_mage"));
check("carregado: perks legítimos mantidos", load.getSkills().hasSkill("perk.necro_mestre_da_necromancia"));
check("carregado: ativas inatas recriadas", load.getSkills().hasSkill("actives.necro_raise_dead") && load.getSkills().hasSkill("actives.necro_cycle_type"));

// ==================================================================
secao("D. Estado por combate");
// ==================================================================
::Tactical.State = novoCombate();
U.getRuntime().Essencia[1] <- 7;
check("runtime guarda dados no combate", U.getRuntime().Essencia[1] == 7);
::Tactical.State = novoCombate();
check("combate novo começa com runtime limpo", !(1 in U.getRuntime().Essencia));

// ==================================================================
secao("E. Espólios dos mortos (3 botões)");
// ==================================================================
local esp = ::new("scripts/events/events/necro_spoils_event");
local ESP = ::Const.Necro.Espolios;
local ESPADA = "scripts/items/fake/espada";
local ELMO = "scripts/items/fake/elmo";
function prepararEspolios( _master, _qtd, _scripts = null )
{
	if (_scripts == null) _scripts = [ "scripts/items/fake/espada", "scripts/items/fake/elmo" ];
	U.clearPendingSpoils();
	for (local i = 0; i < _qtd; i++) U.registerSpoils(_master, _scripts);
}
resetMundo();
local m1 = makeNecro("Mestre", 3);
check("sem espólios: janela não abre", !esp.isValid());
prepararEspolios(m1, 3, [ ESPADA, ELMO, "scripts/items/ammo/quiver_of_arrows" ]);
check("6 itens registrados (3 mortos x 2 itens; munição não conta)", U.getPendingSpoils().len() == 6);
check("registro guarda o nível do Necromante", U.getPendingSpoils()[0].Nivel == 3);
check("com espólios: janela válida no mapa", esp.isValid());
::Tactical.State = novoCombate();
check("NÃO abre durante o combate", !esp.isValid());
::Tactical.State = null;
t = iniciarEvento(esp, m1);
check("nível 3: só MAX_ITENS itens sorteados entre os 6", esp.m.Itens.len() == ESP.MAX_ITENS);
check("3 botões: pegar / XP / ouro", t.Options.len() == 3 && temOpcao(t, "Pegar") && temOpcao(t, "XP") && temOpcao(t, "ouro"));
clicar(esp, t, "ouro");
check("ouro: espólios limpos (janela não reabre)", !esp.isValid() && U.getPendingSpoils().len() == 0);

// Só espadas (valor 100): resultado previsível.
::Money = 0;
prepararEspolios(m1, 5, [ ESPADA ]);
t = iniciarEvento(esp, m1);
check("valor total = 2 x 100 = 200", esp.m.ValorTotal == 200);
check("botão de ouro: 200 x 0.25 = 50", temOpcao(t, "+50 coroas"));
check("botão de XP: 200 x 0.05 = 10", temOpcao(t, "+10 XP"));
r = clicar(esp, t, "ouro");
check("ouro: +50 coroas", ::Money == 50 && r.ID == "B");

prepararEspolios(m1, 5, [ ESPADA ]);
local xpAntes = m1.m.XP;
t = iniciarEvento(esp, m1);
clicar(esp, t, "XP");
check("XP: Necromante recebe 10", m1.m.XP - xpAntes == 10);

// Mais itens em níveis altos: +1 a cada ITENS_EXTRA_A_CADA_NIVEIS níveis.
local mAlto = makeNecro("Veterano", 10);
prepararEspolios(mAlto, 10, [ ESPADA ]);
t = iniciarEvento(esp, mAlto);
check("nível 10: MAX_ITENS + 2 itens", esp.m.Itens.len() == ESP.MAX_ITENS + 2);
clicar(esp, t, "ouro");
::Roster.remove(::Roster.find(mAlto));

// Tetos de ouro e de XP.
local ouroMult = ESP.OURO_MULT;
local xpMult = ESP.XP_MULT;
ESP.OURO_MULT = 100.0;
ESP.XP_MULT = 100.0;
prepararEspolios(m1, 5, [ ESPADA ]);
t = iniciarEvento(esp, m1);
check("ouro limitado a OURO_MAX", temOpcao(t, "+" + ESP.OURO_MAX + " coroas"));
check("XP limitada a XP_MAX", temOpcao(t, "+" + ESP.XP_MAX + " XP"));
clicar(esp, t, "ouro");
ESP.OURO_MULT = ouroMult;
ESP.XP_MULT = xpMult;

prepararEspolios(m1, 5, [ ESPADA ]);
::Stash.slots = 1;
::Stash.items.clear();
::Money = 0;
t = iniciarEvento(esp, m1);
r = clicar(esp, t, "Pegar");
check("pegar: 1 item no baú (baú com 1 vaga)", ::Stash.items.len() == 1);
check("pegar: 1 excedente vendido (100 x 0.25 = 25)", ::Money == 25);
check("pegar: resultado avisa da venda", r.List.len() == 2);
::Stash.slots = 100;

prepararEspolios(m1, 2, [ ESPADA ]);
local m2 = makeNecro("Outro", 3);
::Roster.remove(::Roster.find(m1));
xpAntes = m2.m.XP;
t = iniciarEvento(esp, m2);
clicar(esp, t, "XP");
check("XP: invocador morreu -> XP vai para outro Necromante", m2.m.XP - xpAntes == 10);

prepararEspolios(m2, 1);
::Roster.clear();
t = iniciarEvento(esp, m2);
check("sem Necromante vivo: botão de XP some", !temOpcao(t, "XP") && t.Options.len() == 2);
clicar(esp, t, "ouro");

::Roster.push(m2);
m2.m.XP = 495;
m2.m.Level = 2;
local pp = m2.m.PerkPoints;
prepararEspolios(m2, 5, [ ESPADA ]);
t = iniciarEvento(esp, m2);
clicar(esp, t, "XP");
check("XP pode subir de nível (updateLevel)", m2.m.Level == 3 && m2.m.PerkPoints == pp + 1);

::Const.Necro.Espolios.ATIVO = false;
U.clearPendingSpoils();
U.registerSpoils(m2, [ ESPADA ]);
check("ATIVO = false desliga a mecânica", U.getPendingSpoils().len() == 0 && !esp.isValid());
::Const.Necro.Espolios.ATIVO = true;

// ==================================================================
secao("F. Limite de mortos por nível e equipamento por nível");
// ==================================================================
resetMundo();
::Tactical.State = novoCombate();
local n1 = makeNecro("Novato", 1);
U.clearRuntime();
check("nível 1: limite 2", U.getMaxSummons(n1.getID()) == 2);
n1.m.Level = 5;
check("nível 5: limite 6", U.getMaxSummons(n1.getID()) == 6);
n1.m.Level = 11;
check("nível 11: limite 12", U.getMaxSummons(n1.getID()) == 12);
n1.m.Level = 15;
check("nível 15 (veterano): continua 12", U.getMaxSummons(n1.getID()) == 12);
check("faixa de equipamento: 1 -> 0, 4 -> 1, 9 -> 4, 11 -> 5, 14 -> 5",
	U.getGearTier(1) == 0 && U.getGearTier(4) == 1 && U.getGearTier(9) == 4 && U.getGearTier(11) == 5 && U.getGearTier(14) == 5);
local okInf = true;
local okArco = true;
local okHaste = true;
for (local i = 0; i < 40; i++)
{
	foreach (sc in U.pickEquipment("infantaria", 1))
		if (sc.find("plate") != null || sc.find("scale") != null || sc.find("mail") != null) okInf = false;
	local arco = U.pickEquipment("arco", 11);
	if (arco[0] != "scripts/items/weapons/war_bow" || arco[1] != "scripts/items/ammo/quiver_of_arrows") okArco = false;
	local h = U.pickEquipment("haste", 1);
	if (h[0] != "scripts/items/weapons/pitchfork") okHaste = false;
}
check("nível 1: infantaria sem cota, escamas nem placas", okInf);
check("nível 11: arqueiro com arco de guerra + aljava", okArco);
check("nível 1: lanceiro com forcado (haste de duas mãos)", okHaste);
local okPesado = true;
for (local i = 0; i < 40; i++)
{
	local eqp = U.pickEquipment("pesado", 1);
	local achou = false;
	foreach (sc in eqp) if (::Const.Necro.Equipamento.Corpo[1].find(sc) != null) achou = true;
	if (!achou) okPesado = false;
}
check("pesado no nível 1 usa a armadura da faixa seguinte", okPesado);

// ==================================================================
secao("G. Respec do Legends (resetPerks): pontos voltam ao Grimório");
// ==================================================================
resetMundo();
local rp = makeNecro("Respec", 6);
rp.getFlags().set(U.FlagSubclasse, "lich");
foreach (p in ["perk_necro_ossos_reforcados", "perk_necro_mestre_da_necromancia"])
	rp.getSkills().add(::new("scripts/skills/perks/" + p));
rp.getFlags().set(U.FlagGrimorioV2, true);
rp.getFlags().set(U.FlagGrimorioGastos, 3);
rp.getFlags().set("necro_grimorio_adiado", 6);
local normaisAntes = rp.getPerkPoints();
local nrem = U.respecGrimoire(rp);
check("respec: 2 perks do Grimório removidos", nrem == 2 && !rp.getSkills().hasSkill("perk.necro_ossos_reforcados") && !rp.getSkills().hasSkill("perk.necro_mestre_da_necromancia"));
check("respec: Juramento mantido (subclasse e o ponto dele)", U.getSubclass(rp) == "lich" && rp.getFlags().getAsInt(U.FlagGrimorioGastos) == 1);
check("respec: pontos voltam ao Grimório (nível 6 - Juramento = 5)", U.getGrimoirePoints(rp) == 5);
check("respec: pontos de perk normais não mudam", rp.getPerkPoints() == normaisAntes);
check("respec: Grimório reabre mesmo se adiado", gri.isValid());

print("\nRESULTADO CONJUNTO: " + ::__ok + " ok, " + ::__falhas + " falha(s)\n");
foreach (l in ::__log) print(l + "\n");
