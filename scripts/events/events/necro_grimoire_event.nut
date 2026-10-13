// =====================================================================
// MOD NECROMANTE - O Grimório (perks do Necromante) + Juramento (subclasse)
// ---------------------------------------------------------------------
// POR QUE UM EVENTO: no vanilla existe UMA árvore de perks global para todos
// (Const.Perks.Perks, carregada uma vez pela interface). Não dá para ter uma
// árvore própria do Necromante sem reescrever a UI. Então:
//
//   1) Antes do Juramento: o Grimório oferece só o TRONCO COMUM
//      (máx. TRONCO_MAX_PERKS perks).
//   2) Nível JURAMENTO_NIVEL sem subclasse: abre o JURAMENTO (8 subclasses,
//      tela de confirmação, escolha PERMANENTE gravada na flag "necro_subclass").
//      Gasta 1 ponto do Grimório se houver; se não houver (save antigo),
//      abre mesmo assim, sem cobrar.
//   3) Depois do Juramento: só os perks da subclasse jurada, por fileira; a
//      fileira N abre no nível FILEIRA_NIVEL[N-1].
//
// FILTRO DE EXCLUSIVIDADE: getAvailablePerks só devolve perks do tronco ou da
// subclasse do personagem; learn() confere de novo; e o próprio perk se remove
// se cair num personagem de outra subclasse (perk_necro.onAdded).
//
// Cada escolha gasta 1 ponto do GRIMÓRIO (1 por nível, separado dos pontos
// de perk normais, que ficam livres para a árvore de perks do jogo).
// "Decidir depois" esconde o Grimório até o próximo nível.
// =====================================================================

this.necro_grimoire_event <- this.inherit("scripts/events/event", {
	m = {
		Necro = null,
		Modo = "perks",
		Grupo = 0,
		Escolhido = null,
		SubclasseEscolhida = null,
		PaginaJuramento = 0,
		Devolvidos = []
	},
	function create()
	{
		this.m.ID = "event.necro_grimorio";
		this.m.Title = "O Grimório";
		this.m.IsSpecial = true;

		// -------------------------------------------------------------
		// A: escolha de perk (um grupo por vez: tronco ou fileira 1-4)
		// -------------------------------------------------------------
		this.m.Screens.push({
			ID = "A",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [],
			function start( _event )
			{
				local necro = _event.m.Necro;
				local util = this.Const.Necro.Util;
				local sub = util.getSubclass(necro);
				local origem = sub == null ? "o tronco comum" : this.Const.Necro.Subclasses[sub].Nome;
				this.Characters.push(necro.getImagePath());
				this.Text = "[img]gfx/ui/events/event_76.png[/img]" + necro.getName() + " abre o grimório à luz de uma vela. As páginas sussurram os segredos de " + origem + " (" + _event.getGroupName(_event.m.Grupo) + ").\n\n[color=#bcad8c]Pontos do Grimório: " + util.getGrimoirePoints(necro) + "[/color]\n\nCada escolha gasta 1 ponto do Grimório (ganho a cada nível). Os pontos de perk normais continuam livres para a árvore de perks do jogo.";

				foreach( p in _event.getAvailableInGroup(necro, _event.m.Grupo) )
				{
					this.List.push({
						id = 10,
						icon = p.Icone,
						text = "[color=#bcad8c]" + p.Nome + "[/color]: " + p.Descricao
					});
					this.Options.push({
						Text = "Aprender " + p.Nome,
						PerkID = p.ID,
						function getResult( _event )
						{
							return _event.learn(this.PerkID) ? "B" : 0;
						}

					});
				}

				if (_event.getOpenGroups(necro).len() > 1)
				{
					this.Options.push({
						Text = "Ver outra fileira",
						function getResult( _event )
						{
							_event.nextGroup();
							return "A";
						}

					});
				}

				this.Options.push({
					Text = "Decidir depois (até o próximo nível)",
					function getResult( _event )
					{
						_event.postpone();
						return 0;
					}

				});
			}

		});

		// -------------------------------------------------------------
		// B: perk aprendido
		// -------------------------------------------------------------
		this.m.Screens.push({
			ID = "B",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Os mortos ouvem.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local necro = _event.m.Necro;
				local p = this.Const.Necro.PerkInfo[_event.m.Escolhido];
				this.Characters.push(necro.getImagePath());
				this.Text = "[img]gfx/ui/events/event_76.png[/img]" + necro.getName() + " aprendeu [color=#bcad8c]" + p.Nome + "[/color].";
				this.List.push({
					id = 10,
					icon = p.Icone,
					text = p.Descricao
				});
			}

		});

		// -------------------------------------------------------------
		// J: Juramento (lista das 8 subclasses)
		// -------------------------------------------------------------
		this.m.Screens.push({
			ID = "J",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [],
			function start( _event )
			{
				local necro = _event.m.Necro;
				this.Characters.push(necro.getImagePath());
				this.Text = "[img]gfx/ui/events/event_76.png[/img]Chegou a hora do Juramento. " + necro.getName() + " precisa escolher a quem os mortos vão servir.\n\n[color=#bcad8c]A escolha é PERMANENTE[/color]: define os tipos de morto, as habilidades e a árvore de perks deste Necromante. Escolha uma subclasse para ver os detalhes antes de confirmar.";

				// A janela de evento do vanilla só comporta 6 botões (ui/controls/dialog.js,
				// changeDialogFooterRows): com 7+ ela encolhe para 1 linha e só o primeiro
				// aparece. Por isso as 8 subclasses ficam em páginas de JURAMENTO_POR_PAGINA.
				local pagina = _event.getOathPage();

				foreach( i, id in this.Const.Necro.OrdemSubclasses )
				{
					local s = this.Const.Necro.Subclasses[id];
					local naPagina = i / this.Const.Necro.JURAMENTO_POR_PAGINA == pagina;
					this.List.push({
						id = 10,
						icon = "ui/icons/special.png",
						text = (naPagina ? "[color=#bcad8c]" + s.Nome + "[/color]" : s.Nome) + ": " + s.Estilo
					});

					if (naPagina)
					{
						this.Options.push({
							Text = s.Nome,
							SubID = id,
							function getResult( _event )
							{
								_event.m.SubclasseEscolhida = this.SubID;
								return "C";
							}

						});
					}
				}

				if (_event.getOathPageCount() > 1)
				{
					this.Options.push({
						Text = "Ver outras subclasses",
						function getResult( _event )
						{
							_event.nextOathPage();
							return "J";
						}

					});
				}

				this.Options.push({
					Text = "Decidir depois (até o próximo nível)",
					function getResult( _event )
					{
						_event.postpone();
						return 0;
					}

				});
			}

		});

		// -------------------------------------------------------------
		// C: confirmação do Juramento
		// -------------------------------------------------------------
		this.m.Screens.push({
			ID = "C",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Jurar (permanente)",
					function getResult( _event )
					{
						_event.swear(_event.m.SubclasseEscolhida);
						return "S";
					}

				},
				{
					Text = "Voltar",
					function getResult( _event )
					{
						return "J";
					}

				}
			],
			function start( _event )
			{
				local necro = _event.m.Necro;
				local subID = _event.m.SubclasseEscolhida;
				local s = this.Const.Necro.Subclasses[subID];
				local util = this.Const.Necro.Util;
				this.Characters.push(necro.getImagePath());
				this.Text = "[img]gfx/ui/events/event_76.png[/img][color=#bcad8c]" + s.Nome + "[/color]\n\n" + s.Estilo + "\n" + s.Mecanica + "\n\n[color=#bcad8c]Fraqueza:[/color] " + s.Fraqueza + "\n\nDepois de jurar, não há volta.";
				this.List.push({
					id = 10,
					icon = "ui/icons/special.png",
					text = "Limite de mortos: o do nível " + (s.BonusMortos > 0 ? "+" + s.BonusMortos : "(sem bônus)") + (s.MaxMagos > 0 ? " (inclui até " + s.MaxMagos + " Magos)" : "")
				});
				local tipos = "";
				local pendentes = 0;

				foreach( e in s.Tipos )
				{
					if (e.Tipo in this.Const.Necro.Tipos)
					{
						tipos = tipos + (tipos.len() > 0 ? ", " : "") + this.Const.Necro.Tipos[e.Tipo].Nome;
					}
					else
					{
						pendentes = ++pendentes;
					}
				}

				this.List.push({
					id = 11,
					icon = "ui/icons/special.png",
					text = "Tipos de morto: " + (tipos.len() > 0 ? tipos : "nenhum ainda") + (pendentes > 0 ? " (+" + pendentes + " tipo(s) em desenvolvimento)" : "")
				});
				local ativas = "";

				foreach( script in s.Ativas )
				{
					local a = this.new(script);

					// Regras passivas ocultas (necro_sub_*) não aparecem na lista.
					if (a.isHidden())
					{
						continue;
					}

					ativas = ativas + (ativas.len() > 0 ? ", " : "") + a.getName();
				}

				this.List.push({
					id = 12,
					icon = "ui/icons/special.png",
					text = "Habilidades da subclasse: " + (ativas.len() > 0 ? ativas : "em desenvolvimento")
				});
				local perks = 0;

				foreach( f in s.Fileiras )
				{
					perks = perks + f.len();
				}

				this.List.push({
					id = 13,
					icon = "ui/icons/special.png",
					text = "Perks disponíveis na árvore: " + perks + " de 10"
				});
			}

		});

		// -------------------------------------------------------------
		// S: Juramento feito
		// -------------------------------------------------------------
		this.m.Screens.push({
			ID = "S",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Que os mortos marchem.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				local necro = _event.m.Necro;
				local s = this.Const.Necro.Subclasses[_event.m.SubclasseEscolhida];
				this.Characters.push(necro.getImagePath());
				this.Text = "[img]gfx/ui/events/event_76.png[/img]" + necro.getName() + " jurou como [color=#bcad8c]" + s.Nome + "[/color]. Não há volta.";

				foreach( nome in _event.m.Devolvidos )
				{
					this.List.push({
						id = 10,
						icon = "ui/icons/special.png",
						text = "Perk antigo removido e ponto devolvido: " + nome
					});
				}
			}

		});
	}

	// =================================================================
	// Páginas do Juramento (limite de 6 botões da janela de evento)
	// =================================================================
	function getOathPageCount()
	{
		local n = this.Const.Necro.OrdemSubclasses.len();
		return (n + this.Const.Necro.JURAMENTO_POR_PAGINA - 1) / this.Const.Necro.JURAMENTO_POR_PAGINA;
	}

	function getOathPage()
	{
		return this.m.PaginaJuramento;
	}

	function nextOathPage()
	{
		this.m.PaginaJuramento = (this.m.PaginaJuramento + 1) % this.getOathPageCount();
	}

	// =================================================================
	// Regras da árvore
	// =================================================================

	// Grupo 0 = tronco comum; grupos 1-4 = fileiras da subclasse.
	function getGroupName( _grupo )
	{
		return _grupo == 0 ? "tronco comum" : "fileira " + _grupo;
	}

	function countTrunkPerks( _necro )
	{
		local n = 0;

		foreach( id in this.Const.Necro.Tronco )
		{
			if (_necro.getSkills().hasSkill(id))
			{
				n = ++n;
			}
		}

		return n;
	}

	// FILTRO: perks que este Necromante pode aprender agora neste grupo.
	function getAvailableInGroup( _necro, _grupo )
	{
		local ret = [];
		local util = this.Const.Necro.Util;
		local sub = util.getSubclass(_necro);
		local ids = [];

		if (_grupo == 0)
		{
			if (this.countTrunkPerks(_necro) >= this.Const.Necro.TRONCO_MAX_PERKS)
			{
				return ret;
			}

			ids = this.Const.Necro.Tronco;
		}
		else
		{
			// Fileiras só existem depois do Juramento, e cada uma abre num nível.
			if (sub == null || _necro.getLevel() < this.Const.Necro.FILEIRA_NIVEL[_grupo - 1])
			{
				return ret;
			}

			ids = this.Const.Necro.Subclasses[sub].Fileiras[_grupo - 1];
		}

		foreach( id in ids )
		{
			if (!_necro.getSkills().hasSkill(id) && util.isPerkAllowedFor(_necro, id))
			{
				ret.push(this.Const.Necro.PerkInfo[id]);
			}
		}

		return ret;
	}

	function getOpenGroups( _necro )
	{
		local ret = [];

		for( local g = 0; g <= 4; g = ++g )
		{
			if (this.getAvailableInGroup(_necro, g).len() != 0)
			{
				ret.push(g);
			}
		}

		return ret;
	}

	function needsOath( _necro )
	{
		return this.Const.Necro.Util.getSubclass(_necro) == null && _necro.getLevel() >= this.Const.Necro.JURAMENTO_NIVEL;
	}

	// Primeiro Necromante do grupo que tem algo a escolher. Retorna o modo.
	function findNecroWithChoice()
	{
		foreach( bro in this.World.getPlayerRoster().getAll() )
		{
			if (!bro.getSkills().hasSkill(this.Const.Necro.Util.BackgroundID))
			{
				continue;
			}

			// Saves antigos: converte para os pontos próprios do Grimório antes de tudo.
			this.Const.Necro.Util.migrateGrimoire(bro);

			if (bro.getFlags().getAsInt("necro_grimorio_adiado") >= bro.getLevel())
			{
				continue;
			}

			// O Juramento vem antes de qualquer outra escolha a partir do nível 3.
			if (this.needsOath(bro))
			{
				return {
					Necro = bro,
					Modo = "juramento"
				};
			}

			if (this.Const.Necro.Util.getGrimoirePoints(bro) > 0 && this.getOpenGroups(bro).len() != 0)
			{
				return {
					Necro = bro,
					Modo = "perks"
				};
			}
		}

		return null;
	}

	// =================================================================
	// Ações
	// =================================================================
	function nextGroup()
	{
		local open = this.getOpenGroups(this.m.Necro);
		local idx = open.find(this.m.Grupo);
		this.m.Grupo = idx == null ? open[0] : open[(idx + 1) % open.len()];
	}

	function learn( _perkID )
	{
		local necro = this.m.Necro;

		// Confere de novo o filtro (defesa contra qualquer caminho inesperado).
		local ok = false;

		foreach( p in this.getAvailableInGroup(necro, this.m.Grupo) )
		{
			if (p.ID == _perkID)
			{
				ok = true;
			}
		}

		if (!ok || !this.Const.Necro.Util.spendGrimoirePoint(necro))
		{
			return false;
		}

		necro.getSkills().add(this.new(this.Const.Necro.PerkInfo[_perkID].Script));
		necro.getSkills().update();
		this.m.Escolhido = _perkID;
		return true;
	}

	// JURAMENTO: grava a subclasse (permanente), migra perks antigos e concede as ativas.
	function swear( _subID )
	{
		local necro = this.m.Necro;
		local util = this.Const.Necro.Util;

		if (util.getSubclass(necro) != null)
		{
			// Já jurou: não pode jurar de novo.
			return;
		}

		util.migrateGrimoire(necro);

		necro.getFlags().set(util.FlagSubclasse, _subID);

		// O Juramento usa o ponto do Grimório do nível 3 (grátis se não houver).
		util.spendGrimoirePoint(necro);

		// Migração de saves antigos: perks que não são do tronco nem desta
		// subclasse saem e devolvem o ponto.
		this.m.Devolvidos = [];

		foreach( id, info in this.Const.Necro.PerkInfo )
		{
			if (necro.getSkills().hasSkill(id) && !util.isPerkAllowedFor(necro, id))
			{
				necro.getSkills().removeByID(id);
				util.refundGrimoirePoint(necro);
				this.m.Devolvidos.push(info.Nome);
			}
		}

		// Tipo selecionado antigo pode não existir na subclasse nova.
		necro.getFlags().remove(util.FlagTipoSelecionado);

		// Concede as ativas da subclasse e remove as de outras.
		local bg = necro.getSkills().getSkillByID(util.BackgroundID);

		if (bg != null)
		{
			bg.syncSubclassActives();
		}

		necro.getSkills().update();
	}

	function postpone()
	{
		this.m.Necro.getFlags().set("necro_grimorio_adiado", this.m.Necro.getLevel());
	}

	// =================================================================
	// Ciclo de vida do evento
	// =================================================================
	function isValid()
	{
		if (("State" in this.Tactical) && this.Tactical.State != null)
		{
			return false;
		}

		return this.findNecroWithChoice() != null;
	}

	function onUpdateScore()
	{
		return;
	}

	function onPrepare()
	{
		local found = this.findNecroWithChoice();
		this.m.Necro = found.Necro;
		this.m.Modo = found.Modo;
		this.m.Devolvidos = [];

		if (this.m.Modo == "perks")
		{
			// Começa pelo grupo mais alto liberado.
			local open = this.getOpenGroups(this.m.Necro);
			this.m.Grupo = open[open.len() - 1];
		}
	}

	function onPrepareVariables( _vars )
	{
		_vars.push([
			"necro",
			this.m.Necro != null ? this.m.Necro.getName() : ""
		]);
	}

	function onDetermineStartScreen()
	{
		return this.m.Modo == "juramento" ? "J" : "A";
	}

	function onClear()
	{
		this.m.Necro = null;
		this.m.Escolhido = null;
		this.m.SubclasseEscolhida = null;
		this.m.Modo = "perks";
		this.m.Grupo = 0;
		this.m.PaginaJuramento = 0;
		this.m.Devolvidos = [];
	}

});
