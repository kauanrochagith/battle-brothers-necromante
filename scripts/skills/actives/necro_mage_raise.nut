// =====================================================================
// MOD NECROMANTE - Erguer o Morto (espelhada) do Mago Sepulcral (cap. 9.2)
// ---------------------------------------------------------------------
//   - Conjura os tipos que o NECROMANTE desbloqueou.
//   - Cooldown PRÓPRIO desta instância: COOLDOWN_MAGO_MULT x cooldown do tipo.
//     (Necromante e cada Mago têm instâncias separadas: nada é compartilhado.)
//   - No máximo MAGO_MAX_INVOCACOES_POR_COMBATE usos por combate.
//   - Mortos do Mago contam no limite de mortos do Necromante (Util.getMaxSummons).
//   - Escolha do tipo: se o inimigo mais próximo está longe, prefere
//     atiradores; senão o tipo menos representado em campo.
// Usada pela IA (ai_necro_mage_cast) sem alvo.
// =====================================================================

this.necro_mage_raise <- this.inherit("scripts/skills/actives/necro_raise_dead", {
	m = {
		UsesThisCombat = 0
	},
	function create()
	{
		this.necro_raise_dead.create();
		this.m.ID = "actives.necro_mage_raise";
		this.m.Name = "Erguer o Morto (Mago)";
		this.m.Description = "O Mago ergue um grupo de mortos de um dos tipos que o Necromante conhece.";
		this.m.UsesThisCombat = 0;
	}

	function getMasterID()
	{
		return this.getContainer().getActor().getFlags().getAsInt(this.Const.Necro.Util.FlagMestre);
	}

	function getMaster()
	{
		return this.Tactical.getEntityByID(this.getMasterID());
	}

	function getTypeCooldown( _tipo )
	{
		local cd = this.Math.ceil(this.necro_raise_dead.getTypeCooldown(_tipo) * this.Const.Necro.COOLDOWN_MAGO_MULT);

		// Conjuração Paralela (Lich): -2 turnos (mínimo ParalelaCDMinimo).
		if (this.getUtil().hasPerkByMasterID(this.getMasterID(), "perk.necro_conjuracao_paralela"))
		{
			local LI = this.Const.Necro.Sub.Lich;
			cd = this.Math.max(this.Math.min(cd, LI.ParalelaCDMinimo), cd - LI.ParalelaCD);
		}

		return cd;
	}

	// Livro dos Mortos (Lich): +1 uso por combate.
	function getMaxUses()
	{
		local n = this.Const.Necro.MAGO_MAX_INVOCACOES_POR_COMBATE;

		if (this.getUtil().hasPerkByMasterID(this.getMasterID(), "perk.necro_livro_dos_mortos"))
		{
			n = n + this.Const.Necro.Sub.Lich.LivroUsos;
		}

		return n;
	}

	// Escolhe o tipo que o Mago vai invocar agora (ou null se nenhum está pronto).
	function chooseType()
	{
		local util = this.getUtil();
		local actor = this.getContainer().getActor();
		local ready = [];

		foreach( tipo in util.getUnlockedTypes(this.getMasterID()) )
		{
			if (this.getTypeCooldownLeft(tipo) <= 0)
			{
				ready.push(tipo);
			}
		}

		if (ready.len() == 0)
		{
			return null;
		}

		// Inimigos longe: prefere atiradores.
		local far = util.getDistanceToNearestEnemy(actor.getTile(), util.getEnemyTiles(actor)) >= this.Const.Necro.Mago.DistanciaPreferirRanged;

		if (far)
		{
			local rangedReady = [];

			foreach( tipo in ready )
			{
				if (this.Const.Necro.Tipos[tipo].Distancia)
				{
					rangedReady.push(tipo);
				}
			}

			if (rangedReady.len() != 0)
			{
				ready = rangedReady;
			}
		}

		// Tipo menos representado em campo.
		local counts = {};

		foreach( e in util.getSummonsOfMaster(this.getMasterID(), false) )
		{
			local t = e.getFlags().get(util.FlagTipo);
			counts[t] <- ((t in counts) ? counts[t] : 0) + 1;
		}

		local best = ready[0];
		local bestCount = 9999;

		foreach( tipo in ready )
		{
			local n = (tipo in counts) ? counts[tipo] : 0;

			if (n < bestCount)
			{
				best = tipo;
				bestCount = n;
			}
		}

		return best;
	}

	function getSelectedType()
	{
		local t = this.chooseType();
		return t != null ? t : "guerreiro";
	}

	function isUsable()
	{
		if (!this.skill.isUsable() || !this.getUtil().isInCombat())
		{
			return false;
		}

		if (this.m.UsesThisCombat >= this.getMaxUses())
		{
			return false;
		}

		local master = this.getMaster();

		if (master == null || !master.isAlive())
		{
			// Sem Necromante vivo, o Mago não tem de onde tirar conhecimento.
			return false;
		}

		return this.chooseType() != null && this.getUtil().getFreeSlots(this.getMasterID()) > 0;
	}

	function onAddTooltip( _tooltip )
	{
		_tooltip.push({
			id = 30,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Invocações neste combate: " + this.m.UsesThisCombat + "/" + this.getMaxUses()
		});
	}

	function onUse( _user, _targetTile )
	{
		local tipo = this.chooseType();

		if (tipo == null)
		{
			return false;
		}

		local n = this.raise(_user, tipo);

		if (n > 0)
		{
			this.m.UsesThisCombat = this.m.UsesThisCombat + 1;
		}

		return n > 0;
	}

});
