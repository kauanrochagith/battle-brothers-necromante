// =====================================================================
// MOD NECROMANTE - Espólios dos Mortos (janela depois da batalha)
// ---------------------------------------------------------------------
// Os itens dos mortos invocados são anotados; no fim só alguns (sorteados, gastos) viram espólio.
// Logo depois da batalha (no mapa-múndi) abre esta janela com 3 escolhas:
//   1) Pegar os espólios  -> itens vão para o baú (o que não couber é
//                            vendido, se Espolios.VENDER_EXCEDENTE)
//   2) Oferecer por XP    -> XP para o(s) Necromante(s) que invocou(aram)
//   3) Oferecer por ouro  -> coroas
//
// POR QUE UMA JANELA E NÃO BOTÕES NA TELA DE LOOT: a tela de loot do vanilla
// é HTML/JavaScript e não aceita botões novos sem reescrever a interface.
// Esta é uma janela de evento "especial", que o jogo abre assim que ela é
// válida (o mesmo mecanismo do Grimório). O background registra o evento.
// Valores em Const.Necro.Espolios (necro_constants.nut).
// =====================================================================

this.necro_spoils_event <- this.inherit("scripts/events/event", {
	m = {
		Itens = [],
		XPPorMestre = {},
		ValorTotal = 0,
		Resultado = []
	},
	function create()
	{
		this.m.ID = "event.necro_espolios";
		this.m.Title = "Espólios dos Mortos";
		this.m.IsSpecial = true;

		// -------------------------------------------------------------
		// A: lista dos espólios e as 3 escolhas
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
				this.Text = "[img]gfx/ui/events/event_76.png[/img]Quando a batalha termina, os mortos desabam e quase todo o equipamento vira pó junto com eles. Só um pouco, gasto, ainda presta. Você pode ficar com tudo, ou oferecer os espólios aos poderes sombrios em troca de conhecimento ou de ouro.\n\n[color=#bcad8c]" + _event.m.Itens.len() + " item(ns), valor total " + _event.m.ValorTotal + " coroas.[/color]";

				foreach( linha in _event.getSummaryLines() )
				{
					this.List.push(linha);
				}

				this.Options.push({
					Text = "Pegar os espólios",
					function getResult( _event )
					{
						_event.takeItems();
						return "B";
					}

				});
				local xp = _event.getTotalXP();

				if (xp > 0 && _event.hasLivingNecromancer())
				{
					this.Options.push({
						Text = "Oferecer por XP (+" + xp + " XP para o Necromante)",
						function getResult( _event )
						{
							_event.offerForXP();
							return "B";
						}

					});
				}

				this.Options.push({
					Text = "Oferecer por ouro (+" + _event.getGoldValue() + " coroas)",
					function getResult( _event )
					{
						_event.offerForGold();
						return "B";
					}

				});
			}

		});

		// -------------------------------------------------------------
		// B: resultado
		// -------------------------------------------------------------
		this.m.Screens.push({
			ID = "B",
			Text = "",
			Image = "",
			List = [],
			Characters = [],
			Options = [
				{
					Text = "Seguir viagem.",
					function getResult( _event )
					{
						return 0;
					}

				}
			],
			function start( _event )
			{
				this.Text = "[img]gfx/ui/events/event_76.png[/img]Feito.";

				foreach( linha in _event.m.Resultado )
				{
					this.List.push(linha);
				}
			}

		});
	}

	// =================================================================
	// Cálculos
	// =================================================================

	// Cria as instâncias dos itens: sorteia no máximo N entre tudo o que os
	// mortos usaram e entrega os itens gastos (condição entre CONDICAO_MIN e _MAX).
	function buildItems()
	{
		local esp = this.Const.Necro.Espolios;
		this.m.Itens = [];
		this.m.XPPorMestre = {};
		this.m.ValorTotal = 0;

		local pendentes = clone this.Const.Necro.Util.getPendingSpoils();
		local maxNivel = 1;

		foreach( e in pendentes )
		{
			if ("Nivel" in e && e.Nivel > maxNivel)
			{
				maxNivel = e.Nivel;
			}
		}

		local quantos = this.Math.min(pendentes.len(), this.Const.Necro.Util.getSpoilsItemCount(maxNivel));

		for( local i = 0; i < quantos; i = ++i )
		{
			local j = this.Math.rand(i, pendentes.len() - 1);
			local tmp = pendentes[i];
			pendentes[i] = pendentes[j];
			pendentes[j] = tmp;
			local e = pendentes[i];
			local item = this.new(e.Script);
			this.wearItem(item);
			this.m.Itens.push(item);
			this.m.ValorTotal += item.getValue();
			local xp = (e.MasterID in this.m.XPPorMestre) ? this.m.XPPorMestre[e.MasterID] : 0.0;
			this.m.XPPorMestre[e.MasterID] <- this.Math.minf(esp.XP_MAX, xp + item.getValue() * esp.XP_MULT);
		}
	}

	// Desgasta o item: condição sorteada entre CONDICAO_MIN e CONDICAO_MAX do máximo.
	function wearItem( _item )
	{
		local esp = this.Const.Necro.Espolios;

		if (!("m" in _item) || !("Condition" in _item.m) || !("ConditionMax" in _item.m) || _item.m.ConditionMax <= 0)
		{
			return;
		}

		local frac = esp.CONDICAO_MIN + (esp.CONDICAO_MAX - esp.CONDICAO_MIN) * this.Math.rand(0, 100) / 100.0;
		_item.m.Condition = this.Math.max(1, this.Math.floor(_item.m.ConditionMax * frac)) * 1.0;
	}

	function getGoldValue()
	{
		return this.Math.min(this.Const.Necro.Espolios.OURO_MAX, this.Math.floor(this.m.ValorTotal * this.Const.Necro.Espolios.OURO_MULT));
	}

	function getTotalXP()
	{
		local total = 0;

		foreach( id, xp in this.m.XPPorMestre )
		{
			total += this.Math.floor(xp);
		}

		return total;
	}

	// Lista resumida: "3x Escudo de Madeira" com ícone.
	function getSummaryLines()
	{
		local counts = {};
		local order = [];

		foreach( item in this.m.Itens )
		{
			local name = item.getName();

			if (!(name in counts))
			{
				counts[name] <- {
					N = 0,
					Icon = item.getIcon()
				};
				order.push(name);
			}

			counts[name].N += 1;
		}

		local ret = [];
		local max = this.Const.Necro.Espolios.LINHAS_LISTA;

		foreach( i, name in order )
		{
			if (i >= max)
			{
				ret.push({
					id = 10,
					icon = "ui/icons/special.png",
					text = "+ " + (order.len() - max) + " outro(s) tipo(s) de item"
				});
				break;
			}

			ret.push({
				id = 10,
				icon = "ui/items/" + counts[name].Icon,
				text = counts[name].N + "x " + name
			});
		}

		return ret;
	}

	// Necromante vivo no grupo com este ID (ou null).
	function findNecro( _id )
	{
		foreach( bro in this.World.getPlayerRoster().getAll() )
		{
			if (bro.getID() == _id && bro.getSkills().hasSkill(this.Const.Necro.Util.BackgroundID))
			{
				return bro;
			}
		}

		return null;
	}

	function getAnyNecro()
	{
		foreach( bro in this.World.getPlayerRoster().getAll() )
		{
			if (bro.getSkills().hasSkill(this.Const.Necro.Util.BackgroundID))
			{
				return bro;
			}
		}

		return null;
	}

	function hasLivingNecromancer()
	{
		return this.getAnyNecro() != null;
	}

	// =================================================================
	// As 3 escolhas
	// =================================================================
	function takeItems()
	{
		local stash = this.World.Assets.getStash();
		local guardados = 0;
		local vendidos = 0;
		local ouro = 0;

		// Os mais valiosos entram primeiro no baú; o excedente vendido é o mais barato.
		local ordenados = clone this.m.Itens;
		ordenados.sort(function ( _a, _b )
		{
			return _b.getValue() <=> _a.getValue();
		});

		foreach( item in ordenados )
		{
			if (stash.hasEmptySlot())
			{
				stash.add(item);
				guardados = ++guardados;
			}
			else if (this.Const.Necro.Espolios.VENDER_EXCEDENTE)
			{
				ouro += this.Math.floor(item.getValue() * this.Const.Necro.Espolios.OURO_MULT);
				vendidos = ++vendidos;
			}
		}

		this.m.Resultado = [
			{
				id = 10,
				icon = "ui/icons/special.png",
				text = guardados + " item(ns) guardado(s) no baú"
			}
		];

		if (vendidos > 0)
		{
			this.World.Assets.addMoney(ouro);
			this.m.Resultado.push({
				id = 11,
				icon = "ui/icons/asset_money.png",
				text = "Baú cheio: " + vendidos + " item(ns) vendido(s) por [color=" + this.Const.UI.Color.PositiveValue + "]" + ouro + "[/color] coroas"
			});
		}
		else if (guardados < this.m.Itens.len())
		{
			this.m.Resultado.push({
				id = 11,
				icon = "ui/icons/warning.png",
				text = "Baú cheio: " + (this.m.Itens.len() - guardados) + " item(ns) perdido(s)"
			});
		}

		this.finish();
	}

	function offerForXP()
	{
		this.m.Resultado = [];

		foreach( id, xp in this.m.XPPorMestre )
		{
			local amount = this.Math.floor(xp);

			if (amount <= 0)
			{
				continue;
			}

			// Se quem invocou não está mais no grupo, a XP vai para outro Necromante.
			local necro = this.findNecro(id);

			if (necro == null)
			{
				necro = this.getAnyNecro();
			}

			if (necro == null)
			{
				continue;
			}

			// Sem escala de dificuldade, para dar exatamente o número mostrado no botão.
			necro.addXP(amount, false);
			necro.updateLevel();
			this.m.Resultado.push({
				id = 10,
				icon = "ui/icons/xp_received.png",
				text = necro.getName() + " recebe [color=" + this.Const.UI.Color.PositiveValue + "]+" + amount + "[/color] XP"
			});
		}

		this.finish();
	}

	function offerForGold()
	{
		local ouro = this.getGoldValue();
		this.World.Assets.addMoney(ouro);
		this.m.Resultado = [
			{
				id = 10,
				icon = "ui/icons/asset_money.png",
				text = "Você recebe [color=" + this.Const.UI.Color.PositiveValue + "]" + ouro + "[/color] coroas"
			}
		];
		this.finish();
	}

	function finish()
	{
		this.Const.Necro.Util.clearPendingSpoils();
		this.m.Itens = [];
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

		return this.Const.Necro.Espolios.ATIVO && this.Const.Necro.Util.getPendingSpoils().len() != 0;
	}

	function onUpdateScore()
	{
		return;
	}

	function onPrepare()
	{
		this.buildItems();
	}

	function onPrepareVariables( _vars )
	{
	}

	function onDetermineStartScreen()
	{
		return "A";
	}

	function onClear()
	{
		this.m.Resultado = [];
	}

});
