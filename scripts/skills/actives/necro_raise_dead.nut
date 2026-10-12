// =====================================================================
// MOD NECROMANTE - Erguer o Morto (cap. 7.1)
// ---------------------------------------------------------------------
// Invoca um grupo do tipo SELECIONADO (ver Alternar Tipo de Morto).
//   - Cooldown POR TIPO: usar Arqueiros não bloqueia Guerreiros.
//   - Respeita o limite da subclasse (com peso por unidade): spawna só o que couber.
//   - Tipos, grupo e cooldown vêm da subclasse (Const.Necro.Subclasses[...].Tipos).
//   - Os mortos agem a partir da próxima rodada.
// O tipo selecionado fica na flag do Necromante (é salvo no save).
// A versão do Mago (necro_mage_raise.nut) herda daqui.
// =====================================================================

this.necro_raise_dead <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {
		Cooldowns = {}
	},
	function create()
	{
		this.necro_active_base.create();
		this.m.ID = "actives.necro_raise_dead";
		this.m.Name = "Erguer o Morto";
		this.m.Description = "Ergue um grupo de mortos do tipo selecionado nos tiles livres ao seu redor. Corpo a corpo nascem à frente, atiradores atrás. Cada tipo tem seu próprio cooldown.";
		this.m.Icon = "skills/active_139.png";
		this.m.IconDisabled = "skills/active_139_sw.png";
		this.m.Overlay = "active_139";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_01.wav",
			"sounds/enemies/necromancer_02.wav",
			"sounds/enemies/necromancer_03.wav"
		];
		this.m.Order = this.Const.SkillOrder.NonTargeted + 1;
		this.m.IsTargeted = false;
		this.m.ActionPointCost = this.Const.Necro.Ativas.ErguerPA;
		this.m.FatigueCost = this.Const.Necro.Ativas.ErguerFadiga;
		this.m.MinRange = 0;
		this.m.MaxRange = 0;
		this.m.Cooldowns = {};
	}

	// ---------------------------------------------------------------
	// Quem é o Necromante "mestre" e quem invoca (sobrescrito pelo Mago)
	// ---------------------------------------------------------------
	function getMaster()
	{
		return this.getContainer().getActor();
	}

	function getMasterID()
	{
		return this.getContainer().getActor().getID();
	}

	function getSelectedType()
	{
		local actor = this.getContainer().getActor();
		local util = this.getUtil();
		local tipo = actor.getFlags().get(util.FlagTipoSelecionado);

		// Só vale um tipo da subclasse; senão, o primeiro da lista.
		// null = a subclasse ainda não tem nenhum tipo pronto.
		if (tipo == false || tipo == null || !util.isTypeUnlocked(this.getMasterID(), tipo))
		{
			local tipos = util.getUnlockedTypes(this.getMasterID());
			tipo = tipos.len() != 0 ? tipos[0] : null;
		}

		return tipo;
	}

	// Cooldown base do tipo, com Tempo de Guerra.
	function getTypeCooldown( _tipo )
	{
		// Cooldown base vem da tabela da subclasse (SUBCLASS_TYPES).
		local cd = this.getUtil().getTypeBaseCooldown(this.getMasterID(), _tipo);

		if (this.getUtil().hasPerkByMasterID(this.getMasterID(), "perk.necro_tempo_de_guerra"))
		{
			cd = this.Math.max(this.Const.Necro.Perks.TEMPO_GUERRA_MINIMO, cd - this.Const.Necro.Perks.TEMPO_GUERRA_REDUCAO);
		}

		// Legião Incontável: -1 turno (mínimo IncontavelCDMinimo).
		if (this.getUtil().hasPerkByMasterID(this.getMasterID(), "perk.necro_legiao_incontavel"))
		{
			local L = this.Const.Necro.Sub.Legiao;
			cd = this.Math.max(this.Math.min(cd, L.IncontavelCDMinimo), cd - L.IncontavelCD);
		}

		return cd;
	}

	function getTypeCooldownLeft( _tipo )
	{
		return (_tipo in this.m.Cooldowns) ? this.m.Cooldowns[_tipo] : 0;
	}

	function getCooldownMax()
	{
		local tipo = this.getSelectedType();
		return tipo == null ? 0 : this.getTypeCooldown(tipo);
	}

	function getCooldownLeft()
	{
		local tipo = this.getSelectedType();
		return tipo == null ? 0 : this.getTypeCooldownLeft(tipo);
	}

	function resetCooldown()
	{
		this.m.Cooldowns = {};
	}

	function isUsable()
	{
		if (!this.skill.isUsable() || !this.getUtil().isInCombat())
		{
			return false;
		}

		local tipo = this.getSelectedType();

		if (tipo == null || this.getTypeCooldownLeft(tipo) > 0)
		{
			return false;
		}

		local t = this.Const.Necro.Tipos[tipo];
		return this.getUtil().getFreeSlots(this.getMasterID(), ("Peso" in t) ? t.Peso : this.Const.Necro.PESO_PADRAO) > 0;
	}

	function onTurnStart()
	{
		foreach( k, v in this.m.Cooldowns )
		{
			if (v > 0)
			{
				this.m.Cooldowns[k] = v - 1;
			}
		}

		// O início do turno do Necromante é o momento de atualizar o cache de perks.
		if (this.getUtil().isNecromancer(this.getContainer().getActor()))
		{
			this.getUtil().cachePerks(this.getContainer().getActor());
		}
	}

	function onCombatFinished()
	{
		this.skill.onCombatFinished();
		this.m.Cooldowns = {};
	}

	function getTooltip()
	{
		local tipo = this.getSelectedType();
		local util = this.getUtil();
		local ret = this.getDefaultUtilityTooltip();

		if (tipo == null)
		{
			ret.push({
				id = 10,
				type = "text",
				icon = "ui/icons/warning.png",
				text = "[color=" + this.Const.UI.Color.NegativeValue + "]Sua subclasse ainda não tem tipos de morto disponíveis.[/color]"
			});
		}
		else
		{
			ret.push({
				id = 10,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Tipo selecionado: [color=" + this.Const.UI.Color.PositiveValue + "]" + this.Const.Necro.Tipos[tipo].Nome + "[/color] (grupo de " + util.getTypeGroup(this.getMasterID(), tipo) + ")"
			});
		}

		if (util.isInCombat())
		{
			ret.push({
				id = 11,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Mortos em campo (com peso): " + util.countSummonWeight(this.getMasterID()) + "/" + util.getMaxSummons(this.getMasterID())
			});
		}

		local id = 12;

		foreach( k in util.getUnlockedTypes(this.getMasterID()) )
		{
			local left = this.getTypeCooldownLeft(k);
			ret.push({
				id = id,
				type = "text",
				icon = left > 0 ? "ui/icons/warning.png" : "ui/icons/special.png",
				text = this.Const.Necro.Tipos[k].Nome + ": " + (left > 0 ? "[color=" + this.Const.UI.Color.NegativeValue + "]" + left + " turno(s)[/color]" : "[color=" + this.Const.UI.Color.PositiveValue + "]pronto[/color]") + " (cooldown " + this.getTypeCooldown(k) + ")"
			});
			id = ++id;
		}

		this.onAddTooltip(ret);
		return ret;
	}

	// ---------------------------------------------------------------
	// Uso
	// ---------------------------------------------------------------
	function raise( _user, _tipo )
	{
		local master = this.getMaster();

		if (master == null)
		{
			return 0;
		}

		local n = this.getUtil().raiseGroup(_tipo, master, _user);

		if (n > 0)
		{
			this.m.Cooldowns[_tipo] <- this.getTypeCooldown(_tipo);
		}

		return n;
	}

	function onUse( _user, _targetTile )
	{
		// Partículas do "Raise Undead" vanilla em volta do invocador.
		if (_user.getTile().IsVisibleForPlayer && this.Const.Tactical.RaiseUndeadParticles.len() != 0)
		{
			for( local i = 0; i < this.Const.Tactical.RaiseUndeadParticles.len(); i = ++i )
			{
				local p = this.Const.Tactical.RaiseUndeadParticles[i];
				this.Tactical.spawnParticleEffect(true, p.Brushes, _user.getTile(), p.Delay, p.Quantity, p.LifeTimeQuantity, p.SpawnRate, p.Stages);
			}
		}

		return this.raise(_user, this.getSelectedType()) > 0;
	}

});
