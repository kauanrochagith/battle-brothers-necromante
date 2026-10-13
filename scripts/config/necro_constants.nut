// =====================================================================
// MOD NECROMANTE - CONSTANTES GLOBAIS
// ---------------------------------------------------------------------
// Este é o ÚNICO arquivo de balanço do mod. Ajuste os números aqui sem
// mexer na lógica dos outros scripts.
//
// Como é carregado: o jogo inclui automaticamente todo arquivo dentro de
// "scripts/config/" durante a inicialização (ver scripts/preload.nut do
// vanilla). Por isso este arquivo NÃO precisa de nenhum framework de mods.
//
// Os valores são mesclados em Const.Necro (o arquivo necro_helpers.nut
// também escreve nessa tabela, então a ordem de carga não importa).
// =====================================================================

local gt = this.getroottable();

if (!("Necro" in gt.Const))
{
	gt.Const.Necro <- {};
}

local c = {
	// -----------------------------------------------------------------
	// Cap. 3 - Constantes globais
	// -----------------------------------------------------------------

	// Limite de mortos em campo por Necromante (os mortos dos Magos contam junto).
	// Limite = LIMITE_BASE + LIMITE_POR_NIVEL x (nível - 1), até o nível LIMITE_NIVEL_MAX,
	// mais o BonusMortos da subclasse. Nível 1 = 2 mortos; nível 11 = 12 mortos.
	// Uma invocação que ultrapassar o limite spawna só o que couber.
	LIMITE_BASE = 2,
	LIMITE_POR_NIVEL = 1,
	LIMITE_NIVEL_MAX = 11,

	// Teto absoluto (segurança), qualquer que seja o nível ou a subclasse.
	MAX_MORTOS_TOTAL = 30,

	// Máximo de Magos Sepulcrais ativos ao mesmo tempo.
	MAX_MAGOS = 2,

	// Quantas vezes cada Mago pode usar Erguer o Morto por combate.
	MAGO_MAX_INVOCACOES_POR_COMBATE = 3,

	// O cooldown do Mago é este multiplicador vezes o cooldown do tipo de morto.
	COOLDOWN_MAGO_MULT = 1.5,

	// Dano por turno de cada acúmulo de Veneno do Cadáver.
	VENENO_DANO_POR_ACUMULO = 3,

	// Dano por turno de cada acúmulo de Necrose.
	NECROSE_DANO_POR_ACUMULO = 3,

	// Teto de acúmulos de cada efeito (Veneno e Necrose contam separados).
	ACUMULO_MAX = 10,

	// Duração dos efeitos em turnos. Novo acerto reinicia a duração.
	EFEITO_DURACAO = 4,

	// Multiplicador do dano restante ao detonar com Colheita da Morte.
	COLHEITA_MULT = 1.25,

	// Fração do XP das kills dos mortos que é creditada ao Necromante.
	// (Era 0.5: com muitos mortos o Necromante subia 2 níveis numa batalha.)
	XP_MORTOS_PARA_NECRO = 0.15,

	// Perk Putrefação Redobrada: multiplica o dano por acúmulo e a duração.
	PUTREFACAO_MULT = 2,

	// -----------------------------------------------------------------
	// Efeitos (cap. 6)
	// -----------------------------------------------------------------

	// Necrose: redução do dano causado pelo alvo, por acúmulo (0.01 = 1%).
	NECROSE_REDUCAO_DANO_POR_ACUMULO = 0.01,

	// Dano mínimo (HP + armadura) que um golpe precisa causar para aplicar efeito.
	EFEITO_DANO_MINIMO = 1,

	// -----------------------------------------------------------------
	// Invocação (cap. 5 e 7)
	// -----------------------------------------------------------------

	// Raio (em tiles) ao redor do invocador onde os mortos podem nascer.
	SPAWN_RAIO = 3,

	// Habilidades ativas: custo de PA, fadiga, cooldown (em turnos do usuário).
	Ativas = {
		ErguerPA = 6,
		ErguerFadiga = 25,
		MagoPA = 8,
		MagoFadiga = 30,
		MagoCooldown = 10,
		MarcaPA = 4,
		MarcaFadiga = 10,
		MarcaCooldown = 3,
		MarcaAlcance = 7,
		MarcaDuracao = 2,
		MarcaPesoIA = 3.0,
		MarcaBonusDano = 0.15,
		MarcaBonusEfeitos = 0.5,
		MarcaChanceZerarCooldown = 50,
		ColheitaPA = 8,
		ColheitaFadiga = 30,
		ColheitaCooldown = 5,

		// Mago (Eco do Mago): só usa a Colheita se o dano total somado for pelo menos isto.
		MagoColheitaDanoMinimo = 30
	},

	// -----------------------------------------------------------------
	// Cap. 8 - Classes de morto
	// ---------------------------------------------------------------------
	// Grupo = quantos nascem por invocação | Cooldown em turnos
	// Armadura = [cabeça, corpo]
	// Distancia = true para arqueiros/besteiros (nascem atrás da linha)
	// Desbloqueio = ID do perk que libera o tipo (null = disponível desde o início)
	// -----------------------------------------------------------------
	Tipos = {
		guerreiro = {
			Nome = "Guerreiro Ossudo",
			Script = "scripts/entity/tactical/necro/necro_guerreiro",
			Grupo = 2,
			Cooldown = 4,
			Hitpoints = 60,
			Initiative = 90,
			MeleeSkill = 60,
			RangedSkill = 40,
			MeleeDefense = 10,
			RangedDefense = 5,
			Armadura = [80, 110],
			Distancia = false,
			Desbloqueio = null
		},
		soldado = {
			Nome = "Soldado Nobre",
			Script = "scripts/entity/tactical/necro/necro_soldado",
			Grupo = 2,
			Cooldown = 5,
			Hitpoints = 70,
			Initiative = 85,
			MeleeSkill = 68,
			RangedSkill = 40,
			MeleeDefense = 15,
			RangedDefense = 10,
			Armadura = [110, 150],
			Distancia = false,
			Desbloqueio = "perk.necro_linhagem_nobre"
		},
		paladino = {
			Nome = "Paladino Sepulcral",
			Script = "scripts/entity/tactical/necro/necro_paladino",
			Grupo = 1,
			Cooldown = 5,
			Hitpoints = 90,
			Initiative = 70,
			MeleeSkill = 65,
			RangedSkill = 35,
			MeleeDefense = 18,
			RangedDefense = 15,
			Armadura = [140, 190],
			Distancia = false,
			Desbloqueio = "perk.necro_linhagem_nobre"
		},
		lanceiro = {
			Nome = "Lanceiro",
			Script = "scripts/entity/tactical/necro/necro_lanceiro",
			Grupo = 2,
			Cooldown = 4,
			Hitpoints = 55,
			Initiative = 95,
			MeleeSkill = 62,
			RangedSkill = 40,
			MeleeDefense = 8,
			RangedDefense = 5,
			Armadura = [70, 100],
			Distancia = false,
			Desbloqueio = "perk.necro_arsenal_da_cripta"
		},
		carniceiro = {
			Nome = "Carniceiro",
			Script = "scripts/entity/tactical/necro/necro_carniceiro",
			Grupo = 1,
			Cooldown = 4,
			Hitpoints = 55,
			Initiative = 100,
			MeleeSkill = 65,
			RangedSkill = 35,
			MeleeDefense = 5,
			RangedDefense = 5,
			Armadura = [40, 60],
			Distancia = false,
			Desbloqueio = "perk.necro_arsenal_da_cripta"
		},
		arqueiro = {
			Nome = "Arqueiro",
			Script = "scripts/entity/tactical/necro/necro_arqueiro",
			Grupo = 2,
			Cooldown = 4,
			Hitpoints = 45,
			Initiative = 110,
			MeleeSkill = 35,
			RangedSkill = 65,
			MeleeDefense = 5,
			RangedDefense = 5,
			Armadura = [50, 70],
			Distancia = true,
			Desbloqueio = null
		},
		besteiro = {
			Nome = "Besteiro",
			Script = "scripts/entity/tactical/necro/necro_besteiro",
			Grupo = 2,
			Cooldown = 5,
			Hitpoints = 50,
			Initiative = 90,
			MeleeSkill = 35,
			RangedSkill = 68,
			MeleeDefense = 5,
			RangedDefense = 5,
			Armadura = [60, 85],
			Distancia = true,
			Desbloqueio = "perk.necro_arsenal_da_cripta"
		}
	},

	// Ordem em que "Alternar Tipo de Morto" percorre os tipos.
	OrdemTipos = [
		"guerreiro",
		"arqueiro",
		"soldado",
		"paladino",
		"lanceiro",
		"carniceiro",
		"besteiro"
	],

	// Efeitos especiais de algumas classes.
	PALADINO_AURA_REDUCAO = 0.10,
	CARNICEIRO_IGNORA_ARMADURA = 0.20,
	BESTEIRO_DANO = 0.15,
	BESTEIRO_IGNORA_ARMADURA = 0.10,

	// Munição infinita na prática para arqueiros e besteiros.
	MORTOS_MUNICAO = 99,

	// -----------------------------------------------------------------
	// Cap. 9 - Mago Sepulcral
	// -----------------------------------------------------------------
	Mago = {
		Nome = "Mago Sepulcral",
		Script = "scripts/entity/tactical/necro/necro_mago",
		Hitpoints = 40,
		Stamina = 100,
		Initiative = 105,
		MeleeSkill = 30,
		RangedSkill = 30,
		MeleeDefense = 5,
		RangedDefense = 10,
		Armadura = [30, 40],

		// Quanto a IA inimiga "gosta" de atacar o Mago (>1 também faz os
		// Paladinos protegerem o Mago, via comportamento vanilla ai_protect).
		AtracaoIA = 1.1,

		// Se o inimigo mais próximo estiver a esta distância ou mais,
		// o Mago prefere invocar arqueiros/besteiros.
		DistanciaPreferirRanged = 5
	},

	// -----------------------------------------------------------------
	// Cap. 11 - Valores dos perks
	// -----------------------------------------------------------------
	Perks = {
		OSSOS_DEFESA = 10,
		OSSOS_REDUCAO_DANO = 0.15,
		DISCIPLINA_DANO = 0.05,
		DISCIPLINA_HAB = 5,
		DISCIPLINA_MAX_ALIADOS = 4,
		TEMPO_GUERRA_REDUCAO = 1,
		TEMPO_GUERRA_MINIMO = 3,
		ALCANCE_DOS_MORTOS = 2,
		ALCANCE_DOS_MORTOS_VISAO = 2,
		SANGUE_TOXICO_CHANCE = 20,
		EXERCITO_CHANCE = 30,
		FRATURADO_MULT = 0.5,
		ALCANCE_INDEPENDENTE = 1,
		ESSENCIA_MAX = 20,
		ESSENCIA_DANO = 0.02,
		ESSENCIA_HAB = 0.01,
		VOZ_RAIO = 4,
		VOZ_INICIATIVA = 10,
		VOZ_RESOLUCAO = 5,
		MESTRE_DURACAO = 1,
		MESTRE_DANO = 1,
		MESTRE_MORTOVIVO_MULT = 0.5,
		ELO_FRACAO = 0.25,
		ECO_POTENCIA = 0.5,
		NUVEM_DEFESA = 15,
		NUVEM_MIN_MORTOS = 3,
		// Custo opcional da Putrefação Redobrada. Coloque 0.0 para desligar.
		PUTREFACAO_PENALIDADE_HP = 0.10,
		PACTO_CHANCE = 25,
		PACTO_MAX_POR_COMBATE = 4
	},

	// Vontade Inquebrável (passiva inata): Resolução extra contra medo/pânico/controle mental.
	VONTADE_RESOLUCAO_MEDO = 20,

	// -----------------------------------------------------------------
	// Cap. 4 - Background "Necromante"
	// -----------------------------------------------------------------
	// Modificadores somados aos atributos base de todo recruta do vanilla:
	//   HP 50-60 | Resolução 30-40 | Fadiga 90-100 | CaC 47-57 | Dist 32-42
	//   Def CaC 0-5 | Def Dist 0-5 | Iniciativa 100-110
	// Formato de cada linha: [mínimo, máximo].
	// Resultado com os valores abaixo:
	//   HP 40-52 (frágil) | Resolução 50-62 (alta) | Fadiga 90-100 (média)
	Background = {
		Atributos = {
			Hitpoints = [-10, -8],
			Bravery = [20, 22],
			Stamina = [0, 0],
			MeleeSkill = [-10, -8],
			RangedSkill = [-5, -5],
			MeleeDefense = [0, 0],
			RangedDefense = [0, 0],
			Initiative = [0, 0]
		},
		CustoContratacao = 150,
		SalarioDiario = 15
	}
};

foreach( k, v in c )
{
	gt.Const.Necro[k] <- v;
}

// ---------------------------------------------------------------------
// Árvore de perks (7 camadas). Construída depois da tabela acima para
// poder usar os números nas descrições.
// ---------------------------------------------------------------------
local P = gt.Const.Necro.Perks;
local cor = function ( _v )
{
	return "[color=#4f8f1e]" + _v + "[/color]";
};

gt.Const.Necro.Camadas <- [
	[
		{
			ID = "perk.necro_ossos_reforcados",
			Nome = "Ossos Reforçados",
			Icone = "ui/perks/perk_15.png",
			Descricao = "Seus mortos recebem " + cor("+" + P.OSSOS_DEFESA) + " de Defesa Corpo a Corpo e à Distância e " + cor("-" + (P.OSSOS_REDUCAO_DANO * 100).tointeger() + "%") + " de dano de ataques."
		},
		{
			ID = "perk.necro_disciplina_morta",
			Nome = "Disciplina Morta",
			Icone = "ui/perks/perk_32.png",
			Descricao = "Ao atacar, cada morto ganha " + cor("+" + (P.DISCIPLINA_DANO * 100).tointeger() + "%") + " de dano e " + cor("+" + P.DISCIPLINA_HAB) + " de habilidade por morto aliado adjacente (máx. " + P.DISCIPLINA_MAX_ALIADOS + ")."
		},
		{
			ID = "perk.necro_tempo_de_guerra",
			Nome = "Tempo de Guerra",
			Icone = "ui/perks/perk_21.png",
			Descricao = "Erguer o Morto tem " + cor("-" + P.TEMPO_GUERRA_REDUCAO) + " turno de cooldown (mínimo " + P.TEMPO_GUERRA_MINIMO + ")."
		}
	],
	[
		{
			ID = "perk.necro_alcance_dos_mortos",
			Nome = "Alcance dos Mortos",
			Icone = "ui/perks/perk_17.png",
			Descricao = "Habilidades à distância de todos os seus mortos (inclusive os dos Magos) ganham " + cor("+" + P.ALCANCE_DOS_MORTOS) + " de alcance máximo. Mortos à distância também ganham " + cor("+" + P.ALCANCE_DOS_MORTOS_VISAO) + " de Visão."
		},
		{
			ID = "perk.necro_municao_profana",
			Nome = "Munição Profana",
			Icone = "ui/perks/perk_49.png",
			Descricao = "Ataques à distância dos mortos e do Necromante também aplicam " + cor("Veneno do Cadáver") + ", além da Necrose."
		},
		{
			ID = "perk.necro_sangue_toxico",
			Nome = "Sangue Tóxico",
			Icone = "ui/perks/perk_12.png",
			Descricao = cor("" + P.SANGUE_TOXICO_CHANCE + "%") + " de chance de cada golpe de Veneno ou Necrose aplicar um acúmulo extra."
		},
		{
			ID = "perk.necro_linhagem_nobre",
			Nome = "Linhagem Nobre",
			Icone = "ui/perks/perk_09.png",
			Descricao = "Desbloqueia os tipos " + cor("Soldado Nobre") + " e " + cor("Paladino Sepulcral") + " para Erguer o Morto."
		}
	],
	[
		{
			ID = "perk.necro_despertar_do_mago",
			Nome = "Despertar do Mago",
			Icone = "ui/perks/perk_27.png",
			Descricao = "Concede a habilidade " + cor("Despertar do Mago") + ": invoca um Mago Sepulcral que ergue mortos com cooldown próprio."
		},
		{
			ID = "perk.necro_marca_do_comando",
			Nome = "Marca do Comando",
			Icone = "ui/perks/perk_37.png",
			Descricao = "Concede a habilidade " + cor("Marca do Comando") + ": seus mortos priorizam o alvo e causam mais dano a ele."
		},
		{
			ID = "perk.necro_exercito_sem_fim",
			Nome = "Exército Sem Fim",
			Icone = "ui/perks/perk_14.png",
			Descricao = "Cada morto tem " + cor("" + P.EXERCITO_CHANCE + "%") + " de chance de se reerguer como Esqueleto Fraturado ao morrer (metade de vida, armadura e dano). Não se reergue duas vezes."
		},
		{
			ID = "perk.necro_arsenal_da_cripta",
			Nome = "Arsenal da Cripta",
			Icone = "ui/perks/perk_47.png",
			Descricao = "Desbloqueia os tipos " + cor("Besteiro") + ", " + cor("Lanceiro") + " e " + cor("Carniceiro") + " para Erguer o Morto."
		}
	],
	[
		{
			ID = "perk.necro_alcance_independente",
			Nome = "Alcance Independente",
			Icone = "ui/perks/perk_58.png",
			Descricao = "Todas as habilidades de ataque do Necromante e dos mortos ganham " + cor("+" + P.ALCANCE_INDEPENDENTE) + " de alcance, qualquer que seja a arma. Ataques corpo a corpo passam a alcançar como armas de haste."
		},
		{
			ID = "perk.necro_essencia_morta",
			Nome = "Essência Morta",
			Icone = "ui/perks/perk_56.png",
			Descricao = "Cada inimigo morto por Veneno, Necrose ou por um morto dá 1 carga (máx. " + P.ESSENCIA_MAX + " por combate). Cada carga: " + cor("+" + (P.ESSENCIA_DANO * 100).tointeger() + "%") + " de dano necromântico e " + cor("+" + (P.ESSENCIA_HAB * 100).tointeger() + "%") + " de habilidade dos mortos."
		},
		{
			ID = "perk.necro_voz_do_necromante",
			Nome = "Voz do Necromante",
			Icone = "ui/perks/perk_28.png",
			Descricao = "Mortos a até " + P.VOZ_RAIO + " tiles do Necromante ganham " + cor("+" + P.VOZ_INICIATIVA) + " de Iniciativa e " + cor("+" + P.VOZ_RESOLUCAO) + " de Resolução."
		}
	],
	[
		{
			ID = "perk.necro_mestre_da_necromancia",
			Nome = "Mestre da Necromancia",
			Icone = "ui/perks/perk_36.png",
			Descricao = "Veneno e Necrose duram " + cor("+" + P.MESTRE_DURACAO) + " turno e causam " + cor("+" + P.MESTRE_DANO) + " de dano por acúmulo. Inimigos mortos-vivos deixam de ser imunes e sofrem " + cor("" + (P.MESTRE_MORTOVIVO_MULT * 100).tointeger() + "%") + " do efeito."
		},
		{
			ID = "perk.necro_elo_sombrio",
			Nome = "Elo Sombrio",
			Icone = "ui/perks/perk_34.png",
			Descricao = cor("" + (P.ELO_FRACAO * 100).tointeger() + "%") + " do dano que um morto sofreria é absorvido pelo Necromante como Fadiga. Se faltar Fadiga, nada é absorvido."
		},
		{
			ID = "perk.necro_eco_do_mago",
			Nome = "Eco do Mago",
			Icone = "ui/perks/perk_19.png",
			Descricao = "Magos Sepulcrais também usam Marca do Comando e Colheita da Morte (se você as tiver) com " + cor("" + (P.ECO_POTENCIA * 100).tointeger() + "%") + " da potência, e recebem " + cor("" + (P.ECO_POTENCIA * 100).tointeger() + "%") + " dos bônus de Ossos Reforçados e Voz do Necromante."
		}
	],
	[
		{
			ID = "perk.necro_colheita_da_morte",
			Nome = "Colheita da Morte",
			Icone = "ui/perks/perk_13.png",
			Descricao = "Concede a habilidade " + cor("Colheita da Morte") + ": detona todo o Veneno e Necrose dos inimigos de uma vez."
		},
		{
			ID = "perk.necro_cadaver_substituto",
			Nome = "Cadáver Substituto",
			Icone = "ui/perks/perk_26.png",
			Descricao = "Uma vez por combate, quando o Necromante receberia um golpe fatal, um morto adjacente absorve o golpe e morre no lugar dele."
		},
		{
			ID = "perk.necro_nuvem_de_ossos",
			Nome = "Nuvem de Ossos",
			Icone = "ui/perks/perk_05.png",
			Descricao = "O Necromante ganha " + cor("+" + P.NUVEM_DEFESA) + " de Defesa Corpo a Corpo e à Distância enquanto tiver pelo menos " + P.NUVEM_MIN_MORTOS + " mortos em campo."
		}
	],
	[
		{
			ID = "perk.necro_putrefacao_redobrada",
			Nome = "Putrefação Redobrada",
			Icone = "ui/perks/perk_54.png",
			Descricao = "O dano por acúmulo e a duração de Veneno e Necrose aplicados pelos mortos e pelo Necromante são multiplicados por " + cor("x" + gt.Const.Necro.PUTREFACAO_MULT) + ". O teto de acúmulos não muda." + (P.PUTREFACAO_PENALIDADE_HP > 0 ? " Custo: mortos perdem " + (P.PUTREFACAO_PENALIDADE_HP * 100).tointeger() + "% de vida máxima." : "")
		},
		{
			ID = "perk.necro_pacto_dos_dez_mil",
			Nome = "Pacto dos Dez Mil Mortos",
			Icone = "ui/perks/perk_62.png",
			Descricao = "Sempre que um inimigo morre, " + cor("" + P.PACTO_CHANCE + "%") + " de chance de ele se erguer como Esqueleto Fraturado ao lado do Necromante (corpo a corpo ou à distância, conforme o inimigo). Máx. " + P.PACTO_MAX_POR_COMBATE + " por combate."
		}
	]
];

// Índice rápido: ID do perk -> dados + camada (1 a 7).
gt.Const.Necro.PerkInfo <- {};

foreach( i, camada in gt.Const.Necro.Camadas )
{
	foreach( p in camada )
	{
		p.Camada <- i + 1;
		p.Script <- "scripts/skills/perks/perk_" + p.ID.slice(5);
		gt.Const.Necro.PerkInfo[p.ID] <- p;
	}
}

// =====================================================================
// SUBCLASSES (especificação de subclasses, cap. 1 e 2)
// =====================================================================

// ---------------------------------------------------------------------
// Cap. 2 - Limites e constantes das subclasses
// ---------------------------------------------------------------------
local sub = {
	LEGIAO_BONUS_MORTOS = 4,
	LICH_BONUS_MORTOS = 2,         // os magos do Lich contam no limite
	LICH_MAX_MAGOS_BASE = 3,
	LICH_MAX_MAGOS_TETO = 5,
	PESTE_BONUS_MORTOS = 2,
	CAVALEIRO_BONUS_MORTOS = 0,     // Cavaleiros Mortos pesam 2 vagas cada
	ATIRADOR_BONUS_MORTOS = 2,
	COVEIRO_BONUS_MORTOS = 3,
	COVEIRO_REANIMADO_ESCALA = 0.60,
	OSSARIO_BONUS_MORTOS = 3,
	OSSARIO_PESO_ABOMINACAO = 4,    // uma Abominação ocupa 4 vagas do limite
	OSSARIO_MAX_ABOMINACOES = 3,
	MAESTRO_BONUS_MORTOS = 2,
	ORDEM_DURACAO = 2,

	// Cap. 1 - Regras de nível
	TRONCO_MAX_PERKS = 2,           // perks do tronco comum antes do Juramento
	JURAMENTO_NIVEL = 3,            // nível em que a subclasse é escolhida
	FILEIRA_NIVEL = [4, 6, 8, 10],  // nível em que cada fileira (1 a 4) abre

	// A janela de evento do vanilla mostra no máximo 6 botões (ui/controls/dialog.js).
	// O Juramento mostra as subclasses em páginas: 4 + "Ver outras" + "Decidir depois" = 6.
	BOTOES_MAX_EVENTO = 6,
	JURAMENTO_POR_PAGINA = 4,
	// O Grimório tem pontos PRÓPRIOS (1 por nível, até GRIMORIO_NIVEL_MAX), separados
	// dos pontos de perk normais: a árvore de perks do jogo continua livre.
	GRIMORIO_NIVEL_MAX = 11,
	PONTO_EXTRA_NIVEL_1 = false,    // (antigo) +1 ponto de perk normal no nível 1; desligado

	// Sem subclasse (níveis 1-2): tipos disponíveis. Limite = só o do nível.
	TIPOS_SEM_SUBCLASSE = ["guerreiro", "arqueiro"],

	// Peso padrão de uma unidade no limite de mortos (Abominação usa OSSARIO_PESO_ABOMINACAO).
	PESO_PADRAO = 1,

	// -----------------------------------------------------------------
	// ESPÓLIOS DOS MORTOS (evento depois da batalha)
	// -----------------------------------------------------------------
	// Todo item equipado em um morto invocado durante a batalha vira espólio.
	// Depois da batalha abre uma janela com 3 escolhas:
	//   Pegar os espólios | Oferecer por XP | Oferecer por ouro
	Espolios = {
		// Liga/desliga a mecânica.
		ATIVO = true,

		// Máximo de itens por batalha. Os itens são SORTEADOS entre tudo o que os
		// mortos usaram (munição não conta); o resto se desfaz junto com os mortos.
		MAX_ITENS = 2,

		// +1 item a cada tantos níveis do Necromante de nível mais alto (0 = desliga).
		ITENS_EXTRA_A_CADA_NIVEIS = 5,

		// Os itens chegam gastos: condição sorteada entre estas frações do máximo.
		CONDICAO_MIN = 0.25,
		CONDICAO_MAX = 0.60,

		// Ouro recebido = soma do valor (já gasto) dos itens x este multiplicador, até OURO_MAX.
		OURO_MULT = 0.25,
		OURO_MAX = 400,

		// XP recebida = soma do valor (já gasto) dos itens x este multiplicador
		// (dividida entre os Necromantes que invocaram os mortos), até XP_MAX por Necromante.
		XP_MULT = 0.05,
		XP_MAX = 150,

		// Ao pegar: itens que não couberem no baú são vendidos pelo valor de ouro.
		VENDER_EXCEDENTE = true,

		// Quantas linhas da lista aparecem na janela (o resto vira "+N outros").
		LINHAS_LISTA = 12
	}
};

foreach( k, v in sub )
{
	gt.Const.Necro[k] <- v;
}

local N = gt.Const.Necro;

// Perks do tronco comum (camada 1 da base). Escolhidos antes do Juramento.
gt.Const.Necro.Tronco <- [
	"perk.necro_ossos_reforcados",
	"perk.necro_disciplina_morta",
	"perk.necro_tempo_de_guerra"
];

// Perks da base que saíram do jogo (spec, cap. 1, regra 7) ou viraram ativas
// inatas de uma subclasse. Os scripts continuam existindo só para não quebrar
// saves antigos; no Juramento eles são removidos e o ponto é devolvido.
gt.Const.Necro.PerksRemovidos <- [
	"perk.necro_eco_do_mago",
	"perk.necro_arsenal_da_cripta",
	"perk.necro_despertar_do_mago",
	"perk.necro_marca_do_comando"
];

// ---------------------------------------------------------------------
// Novos tipos de morto das subclasses (etapas B a E)
// ---------------------------------------------------------------------
// Campos opcionais além dos da tabela base:
//   Peso          = vagas que a unidade ocupa no limite (padrão PESO_PADRAO)
//   ActionPoints  = PA da unidade (padrão 9)
//   AplicaEfeito  = "veneno" ou "necrose" (padrão: corpo a corpo veneno, distância necrose)
//   DanoMult      = multiplicador do dano causado
//   AlcanceExtra  = alcance extra nos ataques à distância
//   Imovel        = true para unidades que não andam (Torre de Ossos)
// ---------------------------------------------------------------------
local novosTipos = {
	sentinela = {
		Nome = "Sentinela de Osso",
		Script = "scripts/entity/tactical/necro/necro_sentinela",
		Grupo = 1, Cooldown = 4,
		Hitpoints = 80, Initiative = 80, MeleeSkill = 62, RangedSkill = 35,
		MeleeDefense = 15, RangedDefense = 12,
		Armadura = [110, 150],
		Distancia = false, Desbloqueio = null
	},
	acolito = {
		Nome = "Acólito Espectral",
		Script = "scripts/entity/tactical/necro/necro_acolito",
		Grupo = 2, Cooldown = 4,
		Hitpoints = 35, Initiative = 105, MeleeSkill = 30, RangedSkill = 62,
		MeleeDefense = 5, RangedDefense = 10,
		Armadura = [30, 40],
		Distancia = true, Desbloqueio = null
	},
	putrefato = {
		Nome = "Putrefato",
		Script = "scripts/entity/tactical/necro/necro_putrefato",
		Grupo = 2, Cooldown = 5,
		Hitpoints = 80, Initiative = 55, MeleeSkill = 55, RangedSkill = 0,
		MeleeDefense = 0, RangedDefense = 0,
		Armadura = [30, 50],
		ActionPoints = 7,            // lento
		AplicaEfeito = "veneno",
		Distancia = false, Desbloqueio = null
	},
	rato = {
		Nome = "Rato Ossudo",
		Script = "scripts/entity/tactical/necro/necro_rato",
		Grupo = 3, Cooldown = 4,
		Hitpoints = 25, Initiative = 130, MeleeSkill = 60, RangedSkill = 0,
		MeleeDefense = 15, RangedDefense = 25,
		Armadura = [0, 0],
		ActionPoints = 11,           // rápido
		AplicaEfeito = "necrose",
		DanoMult = 0.6,              // mordida mais fraca que a de um lobo
		Distancia = false, Desbloqueio = null
	},
	cavaleiro = {
		Nome = "Cavaleiro Morto",
		Script = "scripts/entity/tactical/necro/necro_cavaleiro",
		Grupo = 1, Cooldown = 6,
		Hitpoints = 120, Initiative = 75, MeleeSkill = 72, RangedSkill = 40,
		MeleeDefense = 20, RangedDefense = 15,
		Armadura = [160, 210],
		Peso = 2,                    // ocupa 2 vagas do limite
		Distancia = false, Desbloqueio = null
	},
	escudeiro = {
		Nome = "Escudeiro Esquelético",
		Script = "scripts/entity/tactical/necro/necro_escudeiro",
		Grupo = 1, Cooldown = 5,
		Hitpoints = 70, Initiative = 85, MeleeSkill = 62, RangedSkill = 35,
		MeleeDefense = 20, RangedDefense = 20,
		Armadura = [100, 130],
		Distancia = false, Desbloqueio = null
	},
	cacador = {
		Nome = "Caçador Espectral",
		Script = "scripts/entity/tactical/necro/necro_cacador",
		Grupo = 1, Cooldown = 5,
		Hitpoints = 40, Initiative = 115, MeleeSkill = 35, RangedSkill = 78,
		MeleeDefense = 5, RangedDefense = 10,
		Armadura = [40, 50],
		AlcanceExtra = 2,            // alcance +2 sobre o arqueiro
		DanoMult = 1.5,
		Distancia = true, Desbloqueio = null
	},
	abominacao = {
		Nome = "Abominação de Ossos",
		Script = "scripts/entity/tactical/necro/necro_abominacao",
		Grupo = 1, Cooldown = 0,
		Hitpoints = 100,             // recalculado na fusão
		Initiative = 70, MeleeSkill = 75, RangedSkill = 30,
		MeleeDefense = 10, RangedDefense = 10,
		Armadura = [200, 250],
		Peso = 4,                    // = OSSARIO_PESO_ABOMINACAO
		Distancia = false, Desbloqueio = null
	},
	// Coveiro: atributos reais vêm do cadáver (setupFromCorpse); estes são só o padrão.
	reanimado = {
		Nome = "Reanimado",
		Script = "scripts/entity/tactical/necro/necro_reanimado",
		Grupo = 1, Cooldown = 0,
		Hitpoints = 50, Initiative = 80, MeleeSkill = 50, RangedSkill = 40,
		MeleeDefense = 5, RangedDefense = 5,
		Armadura = [0, 0],
		Distancia = false, Desbloqueio = null
	},
	torre = {
		Nome = "Torre de Ossos",
		Script = "scripts/entity/tactical/necro/necro_torre",
		Grupo = 1, Cooldown = 0,
		Hitpoints = 60,              // recalculado na fusão
		Initiative = 60, MeleeSkill = 30, RangedSkill = 70,
		MeleeDefense = 0, RangedDefense = 10,
		Armadura = [100, 150],
		Peso = 4,
		AlcanceFixo = 8,             // alcance de tiro da Torre
		DanoMult = 1.5,              // Lanças de Osso: dano alto
		Imovel = true,
		Distancia = true, Desbloqueio = null
	}
};

foreach( k, v in novosTipos )
{
	gt.Const.Necro.Tipos[k] <- v;
}

// ---------------------------------------------------------------------
// Valores de balanço das 8 subclasses (habilidades e perks)
// ---------------------------------------------------------------------
gt.Const.Necro.Sub <- {
	// ---------------- Senhor da Legião ----------------
	Legiao = {
		FormarPA = 5, FormarFadiga = 15, FormarCD = 4, FormarRaio = 6, FormarDuracao = 2,
		FormarDefesa = 15, FormarDefesaAdjacente = 5,
		CargaPA = 6, CargaFadiga = 20, CargaCD = 5, CargaMaxMortos = 8, CargaMovimento = 2, CargaPenalidadePA = 2,
		ParedeDefesaPorEscudo = 5, ParedeDefesaMax = 20,
		CapitaoRaio = 3, CapitaoDano = 0.10, CapitaoResolucao = 5, CapitaoPromocaoTurnos = 2,
		VeteranoHabPorKill = 1, VeteranoHabMax = 5,
		EstandarteRaio = 4, EstandarteDano = 0.10, EstandarteResolucao = 10,
		BaixasDano = 0.05, BaixasDanoMax = 0.15, BaixasDuracao = 2,
		FlancoAcerto = 15,
		LinhagemHP = 0.20, LinhagemArmadura = 0.20,
		MuralhaRaio = 2, MuralhaFracao = 0.30,
		IncontavelMortos = 2, IncontavelCD = 1, IncontavelCDMinimo = 3
	},
	// ---------------- Lich ----------------
	Lich = {
		ColetivaPA = 6, ColetivaFadiga = 25, ColetivaCD = 8,
		RaioPA = 5, RaioFadiga = 18, RaioCD = 2, RaioAlcance = 8, RaioAcerto = 85, RaioDanoMin = 25, RaioDanoMax = 35,
		EscolaMagos = 2,
		ParalelaCD = 2, ParalelaCDMinimo = 4,
		LivroUsos = 1,
		MagoRaioDanoMin = 20, MagoRaioDanoMax = 30, MagoRaioCD = 3,
		SilencioRaio = 5, SilencioHabDist = 10,
		FilacterioHP = 0.30, FilacterioDanoMagos = 0.20, FilacterioTurnos = 3,
		ArquimagoDano = 0.50, ArquimagoCD = 1, ArquimagoAlcance = 1
	},
	// ---------------- Mestre da Peste ----------------
	Peste = {
		NuvemPA = 6, NuvemFadiga = 25, NuvemCD = 6, NuvemAlcance = 6, NuvemRaio = 1, NuvemDuracao = 3, NuvemAcumulos = 1,
		EpidemiaPA = 7, EpidemiaFadiga = 25, EpidemiaCD = 5, EpidemiaFracao = 0.5, EpidemiaRaio = 1, EpidemiaAlcance = 7,
		ContagioMinimo = 5, ContagioAcumulos = 1,
		PutrefatoRegen = 2,
		GasRaio = 1, GasAcumulos = 3,
		FebrePorAcumulo = 1, FebreMax = 15,
		HospedeiroMinimo = 5, HospedeiroMax = 6,
		VirulenciaAcumulos = 5, VirulenciaMortoVivo = 0.25,
		PandemiaFracao = 1.0, PandemiaRaio = 2
	},
	// ---------------- Cavaleiro da Morte ----------------
	Cavaleiro = {
		FadigaExtra = 20,
		ChamarPA = 8, ChamarFadiga = 35, ChamarCD = 12, ChamarQuantidade = 2, ChamarQuantidadeElite = 3,
		ExecPA = 6, ExecFadiga = 30, ExecCD = 4, ExecDano = 0.25, ExecAcerto = 10, ExecRaio = 6, ExecMovimento = 2,
		ArmaduraOssosPenalidade = 0.30, ArmaduraOssosFadiga = 10,
		LaminaAcumulos = 1, LaminaAcumulosCritico = 2,
		EloSangueFracao = 0.30,
		EliteHP = 0.30, EliteDano = 0.30,
		GolpeFunebreAcumulos = 3, GolpeFunebreArmadura = 0.25,
		LealdadeHP = 0.50,
		ComandantePA = 1, ComandanteCD = 1
	},
	// ---------------- Atirador Espectral ----------------
	Atirador = {
		SaraivadaPA = 7, SaraivadaFadiga = 25, SaraivadaCD = 5, SaraivadaAcerto = 10, SaraivadaMax = 15,
		MarcaPA = 4, MarcaFadiga = 10, MarcaCD = 3, MarcaDuracao = 3, MarcaAlcance = 8, MarcaAcerto = 20, MarcaDano = 0.15,
		EscudeiroMax = 4,
		TriploTiros = 3, TriploPenalidade = 10,
		VisaoExtra = 2,
		PosturaPA = 2, PosturaPenalidade = 10,
		ChuvaIntervalo = 3, ChuvaFlechas = 10, ChuvaRaio = 2, ChuvaDanoMin = 20, ChuvaDanoMax = 35,
		PerfurantesIgnora = 0.15,
		OlhoHabDist = 10
	},
	// ---------------- Coveiro ----------------
	Coveiro = {
		ReanimarPA = 4, ReanimarFadiga = 10, ReanimarAlcance = 8,
		AlmasPA = 6, AlmasFadiga = 20, AlmasCD = 5, AlmasCadaveres = 5, AlmasCura = 0.20,
		MemoriaFracao = 0.5,
		NecrofagoPA = 2, NecrofagoFadiga = 15,
		EficientePA = 1, EficientePAMinimo = 2,
		CampoAntigoQuantidade = 5,
		ReanimadoDuracao = 6,        // turnos do reanimado antes de virar pó (Sem Descanso tira isto)
		SemDescansoHP = 0.50,
		RoubadoBonus = 0.20,
		CemiterioChance = 10,
		MestreEscala = 0.80
	},
	// ---------------- Ossário ----------------
	Ossario = {
		FusaoPA = 7, FusaoFadiga = 30, FusaoCD = 6, FusaoRaio = 4, FusaoMinimoTotal = 3, FusaoMaxExtras = 4,
		DividirPA = 4, DividirFadiga = 10, DividirCD = 2,
		AbominacaoHPBase = 100, AbominacaoHPPorFundido = 60,
		TorreHPBase = 60, TorreHPPorFundido = 30,
		OssoFrescoHP = 0.10,
		ColossoHP = 0.20,
		GiratorioPenalidade = 10,
		RapidaCD = 2, RapidaMinimoTotal = 2,
		CosturaRegen = 0.05,
		LinhagemAcumulos = 2,
		AlfaMult = 0.50,
		RessurgirQuantidade = 3
	},
	// ---------------- Maestro dos Ossos ----------------
	Maestro = {
		OrdemPA = 4, OrdemFadiga = 15, OrdemCD = 3,
		AtaqueTotalDano = 0.15, AtaqueTotalHab = 10, AtaqueTotalDefesa = 10,
		MuralhaDefesa = 20, MuralhaResistencia = 0.20, MuralhaRaio = 3,
		ReagruparMovimento = 4, ReagruparCura = 0.10,
		DisparoAcertoPorAtirador = 10, DisparoAcertoMax = 30,
		BatutaTurnos = 1,
		SincroniaMinimo = 3, SincroniaDano = 0.10, SincroniaDanoMax = 0.30,
		OrdemDuplaMult = 0.5,
		PartituraIgnora = 0.10,
		CoroRaio = 4, CoroMinimo = 3, CoroResolucao = 10,
		CadenciaPA = 1, CadenciaCD = 1,
		CrescendoDano = 0.05, CrescendoMax = 0.25,
		OpusTurnos = 2
	}
};

// Ordens do Maestro (Alternar Ordem percorre nesta ordem).
gt.Const.Necro.Ordens <- [
	{ ID = "ataque", Nome = "Ataque Total", Descricao = "Mortos ganham +15% de dano e +10 de habilidade e priorizam o alvo marcado, mas perdem 10 de defesa." },
	{ ID = "muralha", Nome = "Muralha", Descricao = "Mortos ganham +20 de Defesa e 20% de resistência a dano, e seguram a posição perto do Necromante." },
	{ ID = "reagrupar", Nome = "Reagrupar", Descricao = "Mortos andam até 4 tiles na direção do Necromante e curam 10% da vida máxima." },
	{ ID = "disparo", Nome = "Disparo Coordenado", Descricao = "Mortos à distância focam o mesmo alvo; cada atirador depois do primeiro ganha +10% de acerto (máx. +30%)." }
];

// Coveiro: tipos de entidade que NUNCA podem ser reanimados (chefes, únicos, mágicos).
gt.Const.Necro.NaoReanimaveis <- [
	"Necromancer", "ZombieBoss", "SkeletonBoss", "SkeletonPriest", "Vampire", "Ghost", "Kraken", "KrakenTentacle",
	"Alp", "AlpShadow", "Hexe", "Schrat", "SchratSmall", "TricksterGod", "SandGolem", "SpiderEggs",
	"GreenskinCatapult", "Mortar", "GoblinShaman", "SkeletonLich", "SkeletonLichMirrorImage", "FlyingSkull",
	"Lorekeeper", "FleshGolem", "GreaterFleshGolem", "FleshCradle", "ZombieBetrayer"
];

// ---------------------------------------------------------------------
// Perks novos das subclasses (o dono e a fileira são definidos pela
// tabela Subclasses mais abaixo). Os perks da base que mudaram de
// efeito (Linhagem Nobre, Elo Sombrio) têm a descrição trocada aqui.
// ---------------------------------------------------------------------
local L = gt.Const.Necro.Sub.Legiao;
local LI = gt.Const.Necro.Sub.Lich;
local PE = gt.Const.Necro.Sub.Peste;
local CA = gt.Const.Necro.Sub.Cavaleiro;
local AT = gt.Const.Necro.Sub.Atirador;
local CO = gt.Const.Necro.Sub.Coveiro;
local OS = gt.Const.Necro.Sub.Ossario;
local MA = gt.Const.Necro.Sub.Maestro;
local pct = function ( _f )
{
	return "" + (_f * 100).tointeger() + "%";
};

local perksNovos = [
	// ---- Senhor da Legião ----
	{ ID = "perk.necro_parede_escudos_mortos", Nome = "Parede de Escudos Mortos", Icone = "ui/perks/perk_08.png",
		Descricao = "Cada morto ganha " + cor("+" + L.ParedeDefesaPorEscudo) + " de Defesa Corpo a Corpo e à Distância por morto adjacente com escudo (máx. " + cor("+" + L.ParedeDefesaMax) + ")." },
	{ ID = "perk.necro_cadeia_de_comando", Nome = "Cadeia de Comando", Icone = "ui/perks/perk_28.png",
		Descricao = "Um Soldado Nobre vira " + cor("Capitão") + ": mortos a até " + L.CapitaoRaio + " tiles dele ganham " + cor("+" + pct(L.CapitaoDano)) + " de dano e " + cor("+" + L.CapitaoResolucao) + " de Resolução. Se o Capitão morre, outro Soldado Nobre é promovido depois de " + L.CapitaoPromocaoTurnos + " turnos." },
	{ ID = "perk.necro_veteranos_eternos", Nome = "Veteranos Eternos", Icone = "ui/perks/perk_16.png",
		Descricao = "Cada morto ganha " + cor("+" + L.VeteranoHabPorKill) + " de Habilidade Corpo a Corpo por inimigo que matar (máx. " + cor("+" + L.VeteranoHabMax) + ")." },
	{ ID = "perk.necro_estandarte_osseo", Nome = "Estandarte Ósseo", Icone = "ui/perks/perk_38.png",
		Descricao = "Ao erguer um grupo, um morto porta o " + cor("Estandarte") + ": mortos a até " + L.EstandarteRaio + " tiles ganham " + cor("+" + pct(L.EstandarteDano)) + " de dano e " + cor("+" + L.EstandarteResolucao) + " de Resolução. Se o portador morre, outro morto pega o estandarte no turno seguinte." },
	{ ID = "perk.necro_baixas_aceitaveis", Nome = "Baixas Aceitáveis", Icone = "ui/perks/perk_44.png",
		Descricao = "Quando um morto cai, os mortos adjacentes ganham " + cor("+" + pct(L.BaixasDano)) + " de dano por " + L.BaixasDuracao + " turnos (acumula até " + cor("+" + pct(L.BaixasDanoMax)) + ")." },
	{ ID = "perk.necro_flanco_sombrio", Nome = "Flanco Sombrio", Icone = "ui/perks/perk_33.png",
		Descricao = "Mortos que atacam um alvo cercado por outro morto aliado (flanco ou costas) ganham " + cor("+" + L.FlancoAcerto + "%") + " de chance de acerto." },
	{ ID = "perk.necro_muralha_eterna", Nome = "Muralha Eterna", Icone = "ui/perks/perk_03.png",
		Descricao = "Soldados Nobres e Paladinos a até " + L.MuralhaRaio + " tiles do Necromante absorvem " + cor(pct(L.MuralhaFracao)) + " do dano que ele receberia (dividido entre eles)." },
	{ ID = "perk.necro_legiao_incontavel", Nome = "Legião Incontável", Icone = "ui/perks/perk_57.png",
		Descricao = "Limite de mortos " + cor("+" + L.IncontavelMortos) + " e cooldown de Erguer o Morto " + cor("-" + L.IncontavelCD) + " turno (mínimo " + L.IncontavelCDMinimo + ")." },

	// ---- Lich ----
	{ ID = "perk.necro_escola_de_magos", Nome = "Escola de Magos", Icone = "ui/perks/perk_19.png",
		Descricao = cor("+" + LI.EscolaMagos) + " Magos Sepulcrais no máximo (até " + gt.Const.Necro.LICH_MAX_MAGOS_TETO + ")." },
	{ ID = "perk.necro_eco_perfeito", Nome = "Eco Perfeito", Icone = "ui/perks/perk_27.png",
		Descricao = "Os Magos herdam " + cor("100%") + " das suas passivas (normalmente herdam " + pct(gt.Const.Necro.Perks.ECO_POTENCIA) + ")." },
	{ ID = "perk.necro_conjuracao_paralela", Nome = "Conjuração Paralela", Icone = "ui/perks/perk_21.png",
		Descricao = "O cooldown de invocação dos Magos cai " + cor("-" + LI.ParalelaCD) + " turnos (mínimo " + LI.ParalelaCDMinimo + ")." },
	{ ID = "perk.necro_livro_dos_mortos", Nome = "Livro dos Mortos", Icone = "ui/perks/perk_36.png",
		Descricao = "Cada Mago ganha " + cor("+" + LI.LivroUsos) + " uso de invocação por combate." },
	{ ID = "perk.necro_arcano_profano", Nome = "Arcano Profano", Icone = "ui/perks/perk_49.png",
		Descricao = "Os Magos usam " + cor("Raio Necrótico") + " sozinhos (dano " + LI.MagoRaioDanoMin + "-" + LI.MagoRaioDanoMax + ", cooldown " + LI.MagoRaioCD + ")." },
	{ ID = "perk.necro_silencio_da_cripta", Nome = "Silêncio da Cripta", Icone = "ui/perks/perk_35.png",
		Descricao = "Inimigos com ataque à distância a até " + LI.SilencioRaio + " tiles de um Mago sofrem " + cor("-" + LI.SilencioHabDist) + " de Habilidade à Distância." },
	{ ID = "perk.necro_filacterio", Nome = "Filactério", Icone = "ui/perks/perk_61.png",
		Descricao = "Uma vez por combate, se o Lich morreria, ele volta com " + cor(pct(LI.FilacterioHP)) + " da vida e os Magos ganham " + cor("+" + pct(LI.FilacterioDanoMagos)) + " de dano por " + LI.FilacterioTurnos + " turnos." },
	{ ID = "perk.necro_arquimago", Nome = "Arquimago", Icone = "ui/perks/perk_62.png",
		Descricao = "Raio Necrótico do Lich: dano " + cor("+" + pct(LI.ArquimagoDano)) + ", cooldown " + cor("-" + LI.ArquimagoCD) + " e alcance " + cor("+" + LI.ArquimagoAlcance) + "." },

	// ---- Mestre da Peste ----
	{ ID = "perk.necro_contagio", Nome = "Contágio", Icone = "ui/perks/perk_29.png",
		Descricao = "Inimigos com " + PE.ContagioMinimo + " ou mais acúmulos espalham " + cor("" + PE.ContagioAcumulos) + " acúmulo por turno para os inimigos adjacentes." },
	{ ID = "perk.necro_imunidade_morbida", Nome = "Imunidade Mórbida", Icone = "ui/perks/perk_43.png",
		Descricao = "O Necromante fica imune a veneno e sangramento. Putrefatos regeneram " + cor("" + PE.PutrefatoRegen) + " de vida por turno." },
	{ ID = "perk.necro_corpos_inchados", Nome = "Corpos Inchados", Icone = "ui/perks/perk_30.png",
		Descricao = "Quando um Putrefato morre, libera um gás que aplica " + cor("" + PE.GasAcumulos) + " acúmulos de Veneno nos inimigos ao redor." },
	{ ID = "perk.necro_febre_cadaverica", Nome = "Febre Cadavérica", Icone = "ui/perks/perk_45.png",
		Descricao = "Inimigos afetados perdem " + cor("-" + PE.FebrePorAcumulo) + " de Iniciativa por acúmulo de Veneno e Necrose (máx. " + cor("-" + PE.FebreMax) + ")." },
	{ ID = "perk.necro_hospedeiro", Nome = "Hospedeiro", Icone = "ui/perks/perk_14.png",
		Descricao = "Inimigo morto com " + PE.HospedeiroMinimo + " ou mais acúmulos se ergue como " + cor("Putrefato") + " (máx. " + PE.HospedeiroMax + " por combate)." },
	{ ID = "perk.necro_virulencia", Nome = "Virulência", Icone = "ui/perks/perk_12.png",
		Descricao = "Teto de acúmulos de Veneno e Necrose " + cor("+" + PE.VirulenciaAcumulos) + ". Veneno e Necrose afetam inimigos mortos-vivos com " + cor(pct(PE.VirulenciaMortoVivo)) + " do efeito." },
	{ ID = "perk.necro_pandemia", Nome = "Pandemia", Icone = "ui/perks/perk_54.png",
		Descricao = "Epidemia copia " + cor("100%") + " dos acúmulos e atinge inimigos a até " + PE.PandemiaRaio + " tiles." },

	// ---- Cavaleiro da Morte ----
	{ ID = "perk.necro_armadura_de_ossos", Nome = "Armadura de Ossos", Icone = "ui/perks/perk_40.png",
		Descricao = "A penalidade de Fadiga da armadura e do elmo cai " + cor(pct(CA.ArmaduraOssosPenalidade)) + " e o Necromante ganha " + cor("+" + CA.ArmaduraOssosFadiga) + " de Fadiga máxima." },
	{ ID = "perk.necro_lamina_necrotica", Nome = "Lâmina Necrótica", Icone = "ui/perks/perk_47.png",
		Descricao = "Os golpes do Necromante aplicam " + cor("" + CA.LaminaAcumulos) + " acúmulo de Necrose (" + CA.LaminaAcumulosCritico + " em acerto na cabeça)." },
	{ ID = "perk.necro_juramento_do_vazio", Nome = "Juramento do Vazio", Icone = "ui/perks/perk_41.png",
		Descricao = "O Necromante fica imune a moral, medo e atordoamento." },
	{ ID = "perk.necro_elo_de_sangue", Nome = "Elo de Sangue", Icone = "ui/perks/perk_52.png",
		Descricao = cor(pct(CA.EloSangueFracao)) + " do dano que o Necromante causa à vida vira cura, dividida entre os mortos feridos." },
	{ ID = "perk.necro_elite_funesta", Nome = "Elite Funesta", Icone = "ui/perks/perk_39.png",
		Descricao = "Mortos ganham " + cor("+" + pct(CA.EliteHP)) + " de vida e " + cor("+" + pct(CA.EliteDano)) + " de dano. Chamar o Cavaleiro invoca " + CA.ChamarQuantidadeElite + "." },
	{ ID = "perk.necro_sentinela", Nome = "Sentinela", Icone = "ui/perks/perk_20.png",
		Descricao = "Mortos adjacentes contra-atacam quem atacar o Necromante (1 vez por turno por morto)." },
	{ ID = "perk.necro_golpe_funebre", Nome = "Golpe Fúnebre", Icone = "ui/perks/perk_56.png",
		Descricao = "Ataques do Necromante contra alvos com " + CA.GolpeFunebreAcumulos + "+ acúmulos ou marcados ignoram mais " + cor(pct(CA.GolpeFunebreArmadura)) + " da armadura." },
	{ ID = "perk.necro_lealdade_eterna", Nome = "Lealdade Eterna", Icone = "ui/perks/perk_60.png",
		Descricao = "Cavaleiros Mortos que morrem voltam uma vez com " + cor(pct(CA.LealdadeHP)) + " da vida." },
	{ ID = "perk.necro_comandante_de_guerra", Nome = "Comandante de Guerra", Icone = "ui/perks/perk_59.png",
		Descricao = cor("+" + CA.ComandantePA) + " PA máximo e Execução Sombria com cooldown " + cor("-" + CA.ComandanteCD) + "." },

	// ---- Atirador Espectral ----
	{ ID = "perk.necro_disparo_triplo", Nome = "Disparo Triplo", Icone = "ui/perks/perk_23.png",
		Descricao = "Um morto à distância que atira com o PA cheio dispara " + AT.TriploTiros + " vezes no mesmo alvo e gasta todo o PA (cada tiro com " + cor("-" + AT.TriploPenalidade + "%") + " de acerto)." },
	{ ID = "perk.necro_visao_espectral", Nome = "Visão Espectral", Icone = "ui/perks/perk_22.png",
		Descricao = "Mortos à distância ganham " + cor("+" + AT.VisaoExtra) + " de Visão." },
	{ ID = "perk.necro_postura_fantasma", Nome = "Postura Fantasma", Icone = "ui/perks/perk_25.png",
		Descricao = "Mortos à distância ganham " + cor("+" + AT.PosturaPA) + " PA para andar e atirar no mesmo turno; tiros depois de andar têm " + cor("-" + AT.PosturaPenalidade + "%") + " de acerto." },
	{ ID = "perk.necro_chuva_de_flechas", Nome = "Chuva de Flechas", Icone = "ui/perks/perk_10.png",
		Descricao = "A cada " + AT.ChuvaIntervalo + " turnos, seus arqueiros disparam " + AT.ChuvaFlechas + " flechas sozinhos numa área ao redor do ponto com mais inimigos." },
	{ ID = "perk.necro_execucao_a_distancia", Nome = "Execução à Distância", Icone = "ui/perks/perk_11.png",
		Descricao = "Matar um alvo com a Marca do Caçador zera o cooldown da Marca e dá " + cor("+1") + " PA a quem matou." },
	{ ID = "perk.necro_flechas_perfurantes", Nome = "Flechas Perfurantes", Icone = "ui/perks/perk_48.png",
		Descricao = "Tiros dos mortos à distância ignoram mais " + cor(pct(AT.PerfurantesIgnora)) + " da armadura." },
	{ ID = "perk.necro_olho_do_cacador", Nome = "Olho do Caçador", Icone = "ui/perks/perk_50.png",
		Descricao = "Caçadores Espectrais atiram todo turno e ganham " + cor("+" + AT.OlhoHabDist) + " de Habilidade à Distância." },

	// ---- Coveiro ----
	{ ID = "perk.necro_memoria_do_cadaver", Nome = "Memória do Cadáver", Icone = "ui/perks/perk_37.png",
		Descricao = "O reanimado mantém " + cor(pct(CO.MemoriaFracao)) + " das habilidades próprias que o morto tinha." },
	{ ID = "perk.necro_necrofago", Nome = "Necrófago", Icone = "ui/perks/perk_06.png",
		Descricao = "Concede " + cor("Necrófago") + ": por " + CO.NecrofagoPA + " PA, o Necromante consome um cadáver adjacente e recupera " + CO.NecrofagoFadiga + " de Fadiga." },
	{ ID = "perk.necro_coveiro_eficiente", Nome = "Coveiro Eficiente", Icone = "ui/perks/perk_04.png",
		Descricao = "Reanimar Cadáver custa " + cor("-" + CO.EficientePA) + " PA (mínimo " + CO.EficientePAMinimo + ")." },
	{ ID = "perk.necro_campo_de_batalha_antigo", Nome = "Campo de Batalha Antigo", Icone = "ui/perks/perk_05.png",
		Descricao = "No começo de cada combate, " + CO.CampoAntigoQuantidade + " Esqueletos Fraturados se erguem ao redor do Necromante." },
	{ ID = "perk.necro_sem_descanso", Nome = "Sem Descanso", Icone = "ui/perks/perk_07.png",
		Descricao = "Reanimados não se desfazem com o tempo e voltam uma vez ao morrer, com " + cor(pct(CO.SemDescansoHP)) + " da vida." },
	{ ID = "perk.necro_exercito_roubado", Nome = "Exército Roubado", Icone = "ui/perks/perk_09.png",
		Descricao = "Reanimar um inimigo de elite (campeão) dá " + cor("+" + pct(CO.RoubadoBonus)) + " de vida e dano ao reanimado." },
	{ ID = "perk.necro_cemiterio_itinerante", Nome = "Cemitério Itinerante", Icone = "ui/perks/perk_42.png",
		Descricao = "No fim do combate, cada reanimado tem " + cor("" + CO.CemiterioChance + "%") + " de chance de deixar o equipamento como espólio." },
	{ ID = "perk.necro_mestre_dos_cadaveres", Nome = "Mestre dos Cadáveres", Icone = "ui/perks/perk_51.png",
		Descricao = "Reanimados ficam com " + cor(pct(CO.MestreEscala)) + " da vida e das habilidades do original (em vez de " + pct(gt.Const.Necro.COVEIRO_REANIMADO_ESCALA) + ")." },
	{ ID = "perk.necro_ceifador", Nome = "Ceifador", Icone = "ui/perks/perk_53.png",
		Descricao = "Seus próprios mortos que caem também deixam cadáver e podem ser reanimados uma vez." },

	// ---- Ossário ----
	{ ID = "perk.necro_osso_fresco", Nome = "Osso Fresco", Icone = "ui/perks/perk_15.png",
		Descricao = "Esqueletos invocados ganham " + cor("+" + pct(OS.OssoFrescoHP)) + " de vida (a fusão mantém o bônus)." },
	{ ID = "perk.necro_colosso", Nome = "Colosso", Icone = "ui/perks/perk_46.png",
		Descricao = "Abominações ganham " + cor("+" + pct(OS.ColossoHP)) + " de vida." },
	{ ID = "perk.necro_esmagar_giratorio", Nome = "Esmagar Giratório", Icone = "ui/perks/perk_58.png",
		Descricao = "Abominações ganham um ataque giratório que atinge todos os adjacentes, com " + cor("-" + OS.GiratorioPenalidade + "%") + " de acerto." },
	{ ID = "perk.necro_fusao_rapida", Nome = "Fusão Rápida", Icone = "ui/perks/perk_01.png",
		Descricao = "Fusão de Ossos com cooldown " + cor("-" + OS.RapidaCD) + " e precisando de só " + OS.RapidaMinimoTotal + " esqueletos." },
	{ ID = "perk.necro_costura_de_ossos", Nome = "Costura de Ossos", Icone = "ui/perks/perk_34.png",
		Descricao = "Abominações regeneram " + cor(pct(OS.CosturaRegen)) + " da vida por turno enquanto houver esqueletos adjacentes." },
	{ ID = "perk.necro_artilharia_de_ossos", Nome = "Artilharia de Ossos", Icone = "ui/perks/perk_17.png",
		Descricao = "Fundir arqueiros cria uma " + cor("Torre de Ossos") + " imóvel que dispara Lanças de Osso a longa distância." },
	{ ID = "perk.necro_linhagem_de_ossos", Nome = "Linhagem de Ossos", Icone = "ui/perks/perk_26.png",
		Descricao = "Golpes da Abominação aplicam " + cor("" + OS.LinhagemAcumulos) + " acúmulos de Veneno." },
	{ ID = "perk.necro_abominacao_alfa", Nome = "Abominação Alfa", Icone = "ui/perks/perk_48.png",
		Descricao = "A primeira Abominação vira " + cor("Alfa") + ": " + cor("+" + pct(OS.AlfaMult)) + " de atributos, imune a empurrão, medo e atordoamento (máx. 1)." },
	{ ID = "perk.necro_ressurgir_dos_ossos", Nome = "Ressurgir dos Ossos", Icone = "ui/perks/perk_60.png",
		Descricao = "Quando uma Abominação morre, ela se divide em " + OS.RessurgirQuantidade + " Esqueletos Fraturados." },

	// ---- Maestro dos Ossos ----
	{ ID = "perk.necro_batuta_ossea", Nome = "Batuta Óssea", Icone = "ui/perks/perk_32.png",
		Descricao = "As Ordens duram " + cor("+" + MA.BatutaTurnos) + " turno." },
	{ ID = "perk.necro_sincronia", Nome = "Sincronia", Icone = "ui/perks/perk_33.png",
		Descricao = "Quando " + MA.SincroniaMinimo + "+ mortos atacam o mesmo alvo no mesmo turno, os seguintes ganham " + cor("+" + pct(MA.SincroniaDano)) + " de dano (máx. " + cor("+" + pct(MA.SincroniaDanoMax)) + ")." },
	{ ID = "perk.necro_ordem_dupla", Nome = "Ordem Dupla", Icone = "ui/perks/perk_57.png",
		Descricao = "Duas Ordens podem ficar ativas ao mesmo tempo; a mais antiga fica com " + cor(pct(MA.OrdemDuplaMult)) + " do efeito." },
	{ ID = "perk.necro_partitura_tatica", Nome = "Partitura Tática", Icone = "ui/perks/perk_23.png",
		Descricao = "Ataque Total e Disparo Coordenado também fazem os golpes ignorarem mais " + cor(pct(MA.PartituraIgnora)) + " da armadura." },
	{ ID = "perk.necro_coro_de_ossos", Nome = "Coro de Ossos", Icone = "ui/perks/perk_28.png",
		Descricao = "Inimigos a até " + MA.CoroRaio + " tiles de " + MA.CoroMinimo + " ou mais mortos sofrem " + cor("-" + MA.CoroResolucao) + " de Resolução." },
	{ ID = "perk.necro_cadencia_perfeita", Nome = "Cadência Perfeita", Icone = "ui/perks/perk_21.png",
		Descricao = "Dar Ordem custa " + cor("-" + MA.CadenciaPA) + " PA e tem cooldown " + cor("-" + MA.CadenciaCD) + "." },
	{ ID = "perk.necro_crescendo", Nome = "Crescendo", Icone = "ui/perks/perk_44.png",
		Descricao = "Cada turno seguido com a mesma Ordem ativa dá " + cor("+" + pct(MA.CrescendoDano)) + " de dano aos mortos (máx. " + cor("+" + pct(MA.CrescendoMax)) + ")." },
	{ ID = "perk.necro_opus_final", Nome = "Opus Final", Icone = "ui/perks/perk_62.png",
		Descricao = "Concede " + cor("Opus Final") + ": uma vez por combate, as 4 Ordens ficam ativas ao mesmo tempo por " + MA.OpusTurnos + " turnos, com 100% do efeito." }
];

foreach( p in perksNovos )
{
	p.Camada <- 0;
	p.Script <- "scripts/skills/perks/perk_" + p.ID.slice(5);
	gt.Const.Necro.PerkInfo[p.ID] <- p;
}

// Perks da base com efeito alterado pela spec de subclasses.
gt.Const.Necro.PerkInfo["perk.necro_linhagem_nobre"].Descricao = "Soldados Nobres e Paladinos Sepulcrais ganham " + cor("+" + pct(L.LinhagemHP)) + " de vida e " + cor("+" + pct(L.LinhagemArmadura)) + " de armadura.";
gt.Const.Necro.PerkInfo["perk.necro_elo_sombrio"].Descricao = cor(pct(gt.Const.Necro.Perks.ELO_FRACAO)) + " do dano que um Mago Sepulcral sofreria é absorvido pelo Lich como Fadiga. Se faltar Fadiga, nada é absorvido.";
gt.Const.Necro.PerkInfo["perk.necro_exercito_sem_fim"].Descricao = "Cada esqueleto tem " + cor("" + gt.Const.Necro.Perks.EXERCITO_CHANCE + "%") + " de chance de se reerguer como Esqueleto Fraturado ao morrer (metade de vida, armadura e dano). Não se reergue duas vezes.";

// ---------------------------------------------------------------------
// Tabela das subclasses
// ---------------------------------------------------------------------
// BonusMortos: vagas somadas ao limite do nível (uma unidade = PESO_PADRAO).
// Tipos (= SUBCLASS_TYPES da spec): o que Erguer o Morto / Alternar Tipo
//   oferecem. Grupo/Cooldown da subclasse substituem os da tabela base.
//   MaxUnidades (opcional) limita quantas daquele tipo podem existir.
// Ativas: concedidas no Juramento (não vão para o save; o background
//   recria a partir da flag ao carregar). Scripts "necro_sub_*" são
//   habilidades ocultas com as regras passivas da subclasse.
// Fileiras: os 10 perks da árvore (fileira 1 a 4).
// ---------------------------------------------------------------------
gt.Const.Necro.Subclasses <- {
	legion = {
		Nome = "Senhor da Legião",
		Estilo = "General de formação: um exército de linha de frente.",
		Mecanica = "Os mortos lutam melhor lado a lado.",
		Fraqueza = "Sem alcance; o Necromante fica exposto se a linha cair.",
		BonusMortos = N.LEGIAO_BONUS_MORTOS,
		MaxMagos = 0,
		MagosContamNoLimite = false,
		Tipos = [
			{ Tipo = "guerreiro", Grupo = 3, Cooldown = 4 },
			{ Tipo = "soldado", Grupo = 2, Cooldown = 5 },
			{ Tipo = "paladino", Grupo = 1, Cooldown = 5 },
			{ Tipo = "lanceiro", Grupo = 2, Cooldown = 4 },
			{ Tipo = "carniceiro", Grupo = 1, Cooldown = 4 }
		],
		Ativas = [
			"scripts/skills/actives/necro_legion_form_line",
			"scripts/skills/actives/necro_legion_charge",
			"scripts/skills/special/necro_sub_legion"
		],
		Fileiras = [
			["perk.necro_parede_escudos_mortos", "perk.necro_cadeia_de_comando", "perk.necro_veteranos_eternos"],
			["perk.necro_estandarte_osseo", "perk.necro_baixas_aceitaveis", "perk.necro_flanco_sombrio"],
			["perk.necro_exercito_sem_fim", "perk.necro_linhagem_nobre"],
			["perk.necro_muralha_eterna", "perk.necro_legiao_incontavel"]
		]
	},
	lich = {
		Nome = "Lich",
		Estilo = "Arquimago: os Magos Sepulcrais são o exército.",
		Mecanica = "Vários Magos, cada um com cooldown e usos próprios, copiando as invocações do Lich.",
		Fraqueza = "Mortos frágeis e Lich vulnerável.",
		BonusMortos = N.LICH_BONUS_MORTOS,
		MaxMagos = N.LICH_MAX_MAGOS_BASE,
		MagosContamNoLimite = true,
		Tipos = [
			{ Tipo = "sentinela", Grupo = 1, Cooldown = 4 },
			{ Tipo = "acolito", Grupo = 2, Cooldown = 4 }
		],
		Ativas = [
			"scripts/skills/actives/necro_awaken_mage",
			"scripts/skills/actives/necro_lich_collective",
			"scripts/skills/actives/necro_lich_ray",
			"scripts/skills/special/necro_sub_lich"
		],
		Fileiras = [
			["perk.necro_escola_de_magos", "perk.necro_eco_perfeito", "perk.necro_conjuracao_paralela"],
			["perk.necro_livro_dos_mortos", "perk.necro_arcano_profano", "perk.necro_silencio_da_cripta"],
			["perk.necro_mestre_da_necromancia", "perk.necro_elo_sombrio"],
			["perk.necro_filacterio", "perk.necro_arquimago"]
		]
	},
	plague = {
		Nome = "Mestre da Peste",
		Estilo = "Desgaste e contágio.",
		Mecanica = "Veneno e Necrose se espalham entre os inimigos.",
		Fraqueza = "Contra mortos-vivos o efeito é muito reduzido.",
		BonusMortos = N.PESTE_BONUS_MORTOS,
		MaxMagos = 0,
		MagosContamNoLimite = false,
		Tipos = [
			{ Tipo = "putrefato", Grupo = 2, Cooldown = 5 },
			{ Tipo = "rato", Grupo = 3, Cooldown = 4 },
			{ Tipo = "arqueiro", Grupo = 2, Cooldown = 4 }
		],
		Ativas = [
			"scripts/skills/actives/necro_plague_cloud",
			"scripts/skills/actives/necro_plague_epidemic",
			"scripts/skills/special/necro_sub_plague"
		],
		Fileiras = [
			["perk.necro_sangue_toxico", "perk.necro_contagio", "perk.necro_imunidade_morbida"],
			["perk.necro_corpos_inchados", "perk.necro_febre_cadaverica", "perk.necro_hospedeiro"],
			["perk.necro_colheita_da_morte", "perk.necro_virulencia"],
			["perk.necro_putrefacao_redobrada", "perk.necro_pandemia"]
		]
	},
	knight = {
		Nome = "Cavaleiro da Morte",
		Estilo = "Lutador de linha de frente com poucos mortos de elite.",
		Mecanica = "O Necromante luta pessoalmente; os mortos são poucos, fortes e ligados a ele.",
		Fraqueza = "Poucas unidades; o Necromante está na linha de frente.",
		BonusMortos = N.CAVALEIRO_BONUS_MORTOS,
		MaxMagos = 0,
		MagosContamNoLimite = false,
		Tipos = [
			{ Tipo = "escudeiro", Grupo = 1, Cooldown = 5 }
		],
		Ativas = [
			"scripts/skills/actives/necro_knight_call",
			"scripts/skills/actives/necro_knight_execute",
			"scripts/skills/special/necro_sub_knight"
		],
		Fileiras = [
			["perk.necro_armadura_de_ossos", "perk.necro_lamina_necrotica", "perk.necro_juramento_do_vazio"],
			["perk.necro_elo_de_sangue", "perk.necro_elite_funesta", "perk.necro_sentinela"],
			["perk.necro_golpe_funebre", "perk.necro_cadaver_substituto"],
			["perk.necro_lealdade_eterna", "perk.necro_comandante_de_guerra"]
		]
	},
	shooter = {
		Nome = "Atirador Espectral",
		Estilo = "Caçador de almas: dano à distância.",
		Mecanica = "Alcance, marcação e saraivadas coordenadas.",
		Fraqueza = "Frágil se a escolta cair.",
		BonusMortos = N.ATIRADOR_BONUS_MORTOS,
		MaxMagos = 0,
		MagosContamNoLimite = false,
		Tipos = [
			{ Tipo = "arqueiro", Grupo = 2, Cooldown = 4 },
			{ Tipo = "besteiro", Grupo = 2, Cooldown = 5 },
			{ Tipo = "cacador", Grupo = 1, Cooldown = 5 },
			{ Tipo = "escudeiro", Grupo = 1, Cooldown = 5, MaxUnidades = gt.Const.Necro.Sub.Atirador.EscudeiroMax }
		],
		Ativas = [
			"scripts/skills/actives/necro_shooter_volley",
			"scripts/skills/actives/necro_shooter_mark",
			"scripts/skills/special/necro_sub_shooter"
		],
		Fileiras = [
			["perk.necro_alcance_dos_mortos", "perk.necro_alcance_independente", "perk.necro_municao_profana"],
			["perk.necro_disparo_triplo", "perk.necro_visao_espectral", "perk.necro_postura_fantasma"],
			["perk.necro_chuva_de_flechas", "perk.necro_execucao_a_distancia"],
			["perk.necro_flechas_perfurantes", "perk.necro_olho_do_cacador"]
		]
	},
	gravedigger = {
		Nome = "Coveiro",
		Estilo = "Ressurreição de cadáveres: o recurso são os corpos.",
		Mecanica = "Quase não invoca; levanta o que morre, de qualquer lado.",
		Fraqueza = "Começo lento; depende de baixas na luta.",
		BonusMortos = N.COVEIRO_BONUS_MORTOS,
		MaxMagos = 0,
		MagosContamNoLimite = false,
		Tipos = [
			{ Tipo = "guerreiro", Grupo = 2, Cooldown = 4 }
		],
		Ativas = [
			"scripts/skills/actives/necro_grave_raise",
			"scripts/skills/actives/necro_grave_harvest",
			"scripts/skills/special/necro_sub_gravedigger"
		],
		Fileiras = [
			["perk.necro_memoria_do_cadaver", "perk.necro_necrofago", "perk.necro_coveiro_eficiente"],
			["perk.necro_campo_de_batalha_antigo", "perk.necro_sem_descanso", "perk.necro_exercito_roubado"],
			["perk.necro_pacto_dos_dez_mil", "perk.necro_cemiterio_itinerante"],
			["perk.necro_mestre_dos_cadaveres", "perk.necro_ceifador"]
		]
	},
	ossuary = {
		Nome = "Ossário",
		Estilo = "Arquiteto de abominações.",
		Mecanica = "Funde esqueletos numa Abominação gigante e pode dividi-la de novo.",
		Fraqueza = "Poucas unidades, mas grandes: uma Abominação isolada é um ponto único de falha.",
		BonusMortos = N.OSSARIO_BONUS_MORTOS,
		MaxMagos = 0,
		MagosContamNoLimite = false,
		Tipos = [
			{ Tipo = "guerreiro", Grupo = 2, Cooldown = 4 },
			{ Tipo = "arqueiro", Grupo = 2, Cooldown = 4 }
		],
		Ativas = [
			"scripts/skills/actives/necro_ossuary_fuse",
			"scripts/skills/actives/necro_ossuary_split"
		],
		Fileiras = [
			["perk.necro_nuvem_de_ossos", "perk.necro_osso_fresco", "perk.necro_colosso"],
			["perk.necro_esmagar_giratorio", "perk.necro_fusao_rapida", "perk.necro_costura_de_ossos"],
			["perk.necro_artilharia_de_ossos", "perk.necro_linhagem_de_ossos"],
			["perk.necro_abominacao_alfa", "perk.necro_ressurgir_dos_ossos"]
		]
	},
	maestro = {
		Nome = "Maestro dos Ossos",
		Estilo = "Comandante de sincronia.",
		Mecanica = "Ordens de grupo: os mortos agem em coordenação.",
		Fraqueza = "Sem Ordens ativas, o exército é comum.",
		BonusMortos = N.MAESTRO_BONUS_MORTOS,
		MaxMagos = 0,
		MagosContamNoLimite = false,
		Tipos = [
			{ Tipo = "guerreiro", Grupo = 2, Cooldown = 4 },
			{ Tipo = "lanceiro", Grupo = 2, Cooldown = 4 },
			{ Tipo = "arqueiro", Grupo = 2, Cooldown = 4 },
			{ Tipo = "besteiro", Grupo = 2, Cooldown = 5 },
			{ Tipo = "soldado", Grupo = 2, Cooldown = 5 }
		],
		Ativas = [
			"scripts/skills/actives/necro_mark",
			"scripts/skills/actives/necro_maestro_order",
			"scripts/skills/actives/necro_maestro_cycle",
			"scripts/skills/special/necro_sub_maestro"
		],
		Fileiras = [
			["perk.necro_voz_do_necromante", "perk.necro_batuta_ossea", "perk.necro_sincronia"],
			["perk.necro_ordem_dupla", "perk.necro_partitura_tatica", "perk.necro_coro_de_ossos"],
			["perk.necro_cadencia_perfeita", "perk.necro_crescendo"],
			["perk.necro_opus_final", "perk.necro_essencia_morta"]
		]
	}
};

// Ordem em que o Juramento lista as subclasses.
gt.Const.Necro.OrdemSubclasses <- ["legion", "lich", "plague", "knight", "shooter", "gravedigger", "ossuary", "maestro"];

// ---------------------------------------------------------------------
// Dono de cada perk: "tronco", id da subclasse ou "removido".
// Este é o FILTRO DE EXCLUSIVIDADE: o Grimório só oferece perks do tronco e
// da subclasse jurada, e um perk de outra subclasse se remove ao ser adicionado.
// ---------------------------------------------------------------------
foreach( id, p in gt.Const.Necro.PerkInfo )
{
	p.Subclasse <- "removido";
	p.Fileira <- 0;
}

foreach( id in gt.Const.Necro.Tronco )
{
	gt.Const.Necro.PerkInfo[id].Subclasse = "tronco";
}

foreach( subID, s in gt.Const.Necro.Subclasses )
{
	foreach( f, fileira in s.Fileiras )
	{
		foreach( id in fileira )
		{
			gt.Const.Necro.PerkInfo[id].Subclasse = subID;
			gt.Const.Necro.PerkInfo[id].Fileira = f + 1;
		}
	}
}

// =====================================================================
// EQUIPAMENTO DOS MORTOS POR NÍVEL DO NECROMANTE
// ---------------------------------------------------------------------
// O equipamento de cada morto é sorteado na hora em que ele nasce, a partir
// da FAIXA do nível do Necromante (Faixas: nível mínimo de cada faixa).
// A armadura que o morto usa é a do próprio item (não há mais valor fixo).
//
// Cada tipo de morto tem um Papel (definido no script da entidade):
//   - Armas[papel][faixa]   = lista de armas possíveis (uma é sorteada)
//   - Escudos[papel][faixa] = lista de escudos (papel sem escudo não aparece)
//   - Corpo[faixa] / Cabeca[faixa] = escada de armaduras comum a todos;
//     o Deslocamento do papel sobe/desce de faixa na armadura:
//     leves usam uma faixa abaixo, pesados uma acima.
// null numa lista = "sem nada" (ex.: sem capacete nos níveis baixos).
// =====================================================================
gt.Const.Necro.Equipamento <- {
	// Nível mínimo de cada faixa (6 faixas).
	Faixas = [1, 3, 5, 7, 9, 11],

	// Deslocamento de faixa da armadura por papel.
	Deslocamento = {
		infantaria = 0, pesado = 1, haste = 0, escudeiro = 1,
		bruto = -1, arco = -1, besta = 0, cacador = 0, putrido = -2
	},

	Corpo = [
		[ "scripts/items/armor/tattered_sackcloth", "scripts/items/armor/sackcloth", "scripts/items/armor/leather_wraps", "scripts/items/armor/linen_tunic" ],
		[ "scripts/items/armor/leather_tunic", "scripts/items/armor/thick_tunic", "scripts/items/armor/thick_dark_tunic", "scripts/items/armor/padded_surcoat", "scripts/items/armor/ragged_surcoat" ],
		[ "scripts/items/armor/gambeson", "scripts/items/armor/blotched_gambeson", "scripts/items/armor/padded_leather", "scripts/items/armor/patched_mail_shirt", "scripts/items/armor/leather_lamellar" ],
		[ "scripts/items/armor/worn_mail_shirt", "scripts/items/armor/basic_mail_shirt", "scripts/items/armor/mail_shirt", "scripts/items/armor/leather_scale_armor", "scripts/items/armor/rusted_mail_hauberk" ],
		[ "scripts/items/armor/mail_hauberk", "scripts/items/armor/light_scale_armor", "scripts/items/armor/decayed_reinforced_mail_hauberk", "scripts/items/armor/footman_armor", "scripts/items/armor/reinforced_mail_hauberk" ],
		[ "scripts/items/armor/lamellar_harness", "scripts/items/armor/scale_armor", "scripts/items/armor/decayed_coat_of_scales", "scripts/items/armor/decayed_coat_of_plates", "scripts/items/armor/patchwork_scale_armor" ]
	],

	Cabeca = [
		[ null, null, "scripts/items/helmets/hood", "scripts/items/helmets/headscarf" ],
		[ null, "scripts/items/helmets/hood", "scripts/items/helmets/aketon_cap", "scripts/items/helmets/open_leather_cap", "scripts/items/helmets/full_leather_cap" ],
		[ "scripts/items/helmets/full_aketon_cap", "scripts/items/helmets/rusty_mail_coif", "scripts/items/helmets/mail_coif", "scripts/items/helmets/nasal_helmet", "scripts/items/helmets/dented_nasal_helmet" ],
		[ "scripts/items/helmets/closed_mail_coif", "scripts/items/helmets/kettle_hat", "scripts/items/helmets/padded_nasal_helmet", "scripts/items/helmets/nordic_helmet", "scripts/items/helmets/flat_top_helmet" ],
		[ "scripts/items/helmets/nasal_helmet_with_rusty_mail", "scripts/items/helmets/padded_kettle_hat", "scripts/items/helmets/padded_flat_top_helmet", "scripts/items/helmets/closed_flat_top_helmet", "scripts/items/helmets/nasal_helmet_with_mail" ],
		[ "scripts/items/helmets/bascinet_with_mail", "scripts/items/helmets/kettle_hat_with_mail", "scripts/items/helmets/decayed_full_helm", "scripts/items/helmets/nasal_helmet_with_closed_mail", "scripts/items/helmets/decayed_great_helm" ]
	],

	Armas = {
		// Uma mão (vai com escudo): guerreiros, soldados, paladinos, sentinelas, cavaleiros.
		infantaria = [
			[ "scripts/items/weapons/knife", "scripts/items/weapons/wooden_stick", "scripts/items/weapons/hatchet", "scripts/items/weapons/dagger" ],
			[ "scripts/items/weapons/shortsword", "scripts/items/weapons/hatchet", "scripts/items/weapons/bludgeon", "scripts/items/weapons/scramasax" ],
			[ "scripts/items/weapons/falchion", "scripts/items/weapons/hand_axe", "scripts/items/weapons/morning_star", "scripts/items/weapons/shortsword" ],
			[ "scripts/items/weapons/arming_sword", "scripts/items/weapons/morning_star", "scripts/items/weapons/military_pick", "scripts/items/weapons/flail", "scripts/items/weapons/ancient/khopesh" ],
			[ "scripts/items/weapons/arming_sword", "scripts/items/weapons/fighting_axe", "scripts/items/weapons/warhammer", "scripts/items/weapons/winged_mace", "scripts/items/weapons/ancient/ancient_sword" ],
			[ "scripts/items/weapons/noble_sword", "scripts/items/weapons/fighting_axe", "scripts/items/weapons/warhammer", "scripts/items/weapons/winged_mace", "scripts/items/weapons/three_headed_flail" ]
		],

		// Armas de haste de duas mãos (Lanceiro).
		haste = [
			[ "scripts/items/weapons/pitchfork" ],
			[ "scripts/items/weapons/pitchfork", "scripts/items/weapons/goedendag" ],
			[ "scripts/items/weapons/spetum", "scripts/items/weapons/billhook", "scripts/items/weapons/goedendag" ],
			[ "scripts/items/weapons/spetum", "scripts/items/weapons/billhook", "scripts/items/weapons/pike" ],
			[ "scripts/items/weapons/pike", "scripts/items/weapons/longaxe", "scripts/items/weapons/polehammer", "scripts/items/weapons/ancient/bladed_pike" ],
			[ "scripts/items/weapons/polehammer", "scripts/items/weapons/ancient/bladed_pike", "scripts/items/weapons/ancient/warscythe", "scripts/items/weapons/pike" ]
		],

		// Lança de uma mão + escudo (Escudeiro).
		escudeiro = [
			[ "scripts/items/weapons/militia_spear" ],
			[ "scripts/items/weapons/militia_spear" ],
			[ "scripts/items/weapons/boar_spear" ],
			[ "scripts/items/weapons/boar_spear", "scripts/items/weapons/ancient/ancient_spear" ],
			[ "scripts/items/weapons/fighting_spear", "scripts/items/weapons/ancient/ancient_spear" ],
			[ "scripts/items/weapons/fighting_spear" ]
		],

		// Duas mãos pesadas (Carniceiro).
		bruto = [
			[ "scripts/items/weapons/woodcutters_axe", "scripts/items/weapons/two_handed_wooden_hammer" ],
			[ "scripts/items/weapons/woodcutters_axe", "scripts/items/weapons/two_handed_wooden_hammer", "scripts/items/weapons/reinforced_wooden_flail" ],
			[ "scripts/items/weapons/woodcutters_axe", "scripts/items/weapons/ancient/rhomphaia", "scripts/items/weapons/reinforced_wooden_flail" ],
			[ "scripts/items/weapons/ancient/rhomphaia", "scripts/items/weapons/two_handed_hammer", "scripts/items/weapons/warbrand" ],
			[ "scripts/items/weapons/greataxe", "scripts/items/weapons/two_handed_flanged_mace", "scripts/items/weapons/warbrand" ],
			[ "scripts/items/weapons/greataxe", "scripts/items/weapons/two_handed_hammer", "scripts/items/weapons/greatsword", "scripts/items/weapons/two_handed_flanged_mace" ]
		],

		arco = [
			[ "scripts/items/weapons/short_bow" ],
			[ "scripts/items/weapons/short_bow", "scripts/items/weapons/hunting_bow" ],
			[ "scripts/items/weapons/hunting_bow" ],
			[ "scripts/items/weapons/hunting_bow", "scripts/items/weapons/war_bow" ],
			[ "scripts/items/weapons/war_bow" ],
			[ "scripts/items/weapons/war_bow" ]
		],

		// Caçador Espectral: sempre um degrau acima do arqueiro.
		cacador = [
			[ "scripts/items/weapons/hunting_bow" ],
			[ "scripts/items/weapons/hunting_bow" ],
			[ "scripts/items/weapons/war_bow" ],
			[ "scripts/items/weapons/war_bow" ],
			[ "scripts/items/weapons/war_bow" ],
			[ "scripts/items/weapons/war_bow" ]
		],

		besta = [
			[ "scripts/items/weapons/light_crossbow" ],
			[ "scripts/items/weapons/light_crossbow" ],
			[ "scripts/items/weapons/light_crossbow", "scripts/items/weapons/crossbow" ],
			[ "scripts/items/weapons/crossbow" ],
			[ "scripts/items/weapons/crossbow", "scripts/items/weapons/heavy_crossbow" ],
			[ "scripts/items/weapons/heavy_crossbow" ]
		]
	},

	Escudos = {
		infantaria = [
			[ null, "scripts/items/shields/buckler_shield", "scripts/items/shields/wooden_shield" ],
			[ "scripts/items/shields/buckler_shield", "scripts/items/shields/wooden_shield" ],
			[ "scripts/items/shields/wooden_shield", "scripts/items/shields/worn_kite_shield", "scripts/items/shields/worn_heater_shield" ],
			[ "scripts/items/shields/wooden_shield", "scripts/items/shields/kite_shield", "scripts/items/shields/heater_shield" ],
			[ "scripts/items/shields/kite_shield", "scripts/items/shields/heater_shield", "scripts/items/shields/ancient/auxiliary_shield" ],
			[ "scripts/items/shields/kite_shield", "scripts/items/shields/heater_shield", "scripts/items/shields/ancient/coffin_shield" ]
		],
		escudeiro = [
			[ "scripts/items/shields/wooden_shield" ],
			[ "scripts/items/shields/wooden_shield" ],
			[ "scripts/items/shields/ancient/tower_shield" ],
			[ "scripts/items/shields/ancient/tower_shield" ],
			[ "scripts/items/shields/ancient/tower_shield" ],
			[ "scripts/items/shields/ancient/tower_shield" ]
		]
	},

	// Papéis que usam a lista de armas/escudos de outro papel.
	MesmaListaDe = {
		pesado = "infantaria"
	},

	// Munição de quem atira.
	Municao = {
		arco = "scripts/items/ammo/quiver_of_arrows",
		cacador = "scripts/items/ammo/quiver_of_arrows",
		besta = "scripts/items/ammo/quiver_of_bolts"
	}
};
