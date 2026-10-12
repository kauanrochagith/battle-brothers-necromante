// =====================================================================
// MOD NECROMANTE - Alternar Ordem (Maestro dos Ossos)
// ---------------------------------------------------------------------
// 0 PA, 0 Fadiga, sem cooldown. Avança a Ordem selecionada (mesma
// mecânica de Alternar Tipo de Morto). Fica na flag "necro_ordem_sel".
// =====================================================================

this.necro_maestro_cycle <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		this.m.ID = "actives.necro_maestro_cycle";
		this.m.Name = "Alternar Ordem";
		this.m.Description = "Escolhe qual Ordem Dar Ordem vai ativar. Não gasta PA nem Fadiga.";
		this.m.Icon = "skills/active_100.png";
		this.m.IconDisabled = "skills/active_100_sw.png";
		this.m.Overlay = "active_100";
		this.m.Order = this.Const.SkillOrder.NonTargeted + 11;
		this.m.IsTargeted = false;
		this.m.ActionPointCost = 0;
		this.m.FatigueCost = 0;
	}

	function getIndex()
	{
		local id = this.getContainer().getActor().getFlags().get("necro_ordem_sel");

		foreach( i, o in this.Const.Necro.Ordens )
		{
			if (o.ID == id)
			{
				return i;
			}
		}

		return 0;
	}

	function getTooltip()
	{
		local ret = this.getDefaultUtilityTooltip();
		local ordens = this.Const.Necro.Ordens;
		local i = this.getIndex();
		ret.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Atual: [color=" + this.Const.UI.Color.PositiveValue + "]" + ordens[i].Nome + "[/color] | Próxima: " + ordens[(i + 1) % ordens.len()].Nome
		});
		return ret;
	}

	function onUse( _user, _targetTile )
	{
		local ordens = this.Const.Necro.Ordens;
		local next = ordens[(this.getIndex() + 1) % ordens.len()];
		_user.getFlags().set("necro_ordem_sel", next.ID);

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " prepara a Ordem: " + next.Nome);
		}

		return true;
	}

});
