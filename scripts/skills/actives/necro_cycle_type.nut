// =====================================================================
// MOD NECROMANTE - Alternar Tipo de Morto (cap. 7.2)
// ---------------------------------------------------------------------
// 0 PA, 0 Fadiga, sem cooldown, pode ser usada várias vezes por turno.
// Avança ciclicamente pelos tipos da SUBCLASSE (Const.Necro.Subclasses[...].Tipos).
// O vanilla só deixa usar habilidades em combate, mas o tipo escolhido
// fica salvo numa flag do personagem e vale para o próximo combate.
// =====================================================================

this.necro_cycle_type <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		this.m.ID = "actives.necro_cycle_type";
		this.m.Name = "Alternar Tipo de Morto";
		this.m.Description = "Escolhe qual tipo de morto Erguer o Morto vai invocar. Não gasta PA nem Fadiga.";
		this.m.Icon = "skills/active_100.png";
		this.m.IconDisabled = "skills/active_100_sw.png";
		this.m.Overlay = "active_100";
		this.m.Order = this.Const.SkillOrder.NonTargeted + 2;
		this.m.IsTargeted = false;
		this.m.ActionPointCost = 0;
		this.m.FatigueCost = 0;
	}

	function getNextType()
	{
		local actor = this.getContainer().getActor();
		local util = this.getUtil();
		local unlocked = util.getUnlockedTypes(actor.getID());
		local current = actor.getFlags().get(util.FlagTipoSelecionado);
		local idx = unlocked.find(current);

		if (unlocked.len() == 0)
		{
			return null;
		}

		if (idx == null)
		{
			return unlocked.len() > 1 ? unlocked[1] : unlocked[0];
		}

		return unlocked[(idx + 1) % unlocked.len()];
	}

	function onAddTooltip( _tooltip )
	{
		local actor = this.getContainer().getActor();
		local util = this.getUtil();
		local raise = actor.getSkills().getSkillByID("actives.necro_raise_dead");
		local current = raise != null ? raise.getSelectedType() : null;
		local next = this.getNextType();

		if (current == null || next == null)
		{
			_tooltip.push({
				id = 10,
				type = "text",
				icon = "ui/icons/warning.png",
				text = "[color=" + this.Const.UI.Color.NegativeValue + "]Sua subclasse ainda não tem tipos de morto disponíveis.[/color]"
			});
			return;
		}

		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Atual: [color=" + this.Const.UI.Color.PositiveValue + "]" + this.Const.Necro.Tipos[current].Nome + "[/color] | Próximo: " + this.Const.Necro.Tipos[next].Nome
		});
		local nomes = "";

		foreach( i, k in util.getUnlockedTypes(actor.getID()) )
		{
			nomes = nomes + (i > 0 ? ", " : "") + this.Const.Necro.Tipos[k].Nome;
		}

		_tooltip.push({
			id = 11,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Desbloqueados: " + nomes
		});
	}

	function getTooltip()
	{
		local ret = this.getDefaultUtilityTooltip();
		this.onAddTooltip(ret);
		return ret;
	}

	function isUsable()
	{
		return this.necro_active_base.isUsable() && this.getNextType() != null;
	}

	function onUse( _user, _targetTile )
	{
		local next = this.getNextType();

		if (next == null)
		{
			return false;
		}
		_user.getFlags().set(this.getUtil().FlagTipoSelecionado, next);

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " agora vai erguer: " + this.Const.Necro.Tipos[next].Nome);
		}

		return true;
	}

});
