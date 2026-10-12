// =====================================================================
// MOD NECROMANTE - Opus Final (perk do Maestro dos Ossos)
// ---------------------------------------------------------------------
// Uma vez por combate: as 4 Ordens ficam ativas ao mesmo tempo por
// OpusTurnos turnos, com 100% do efeito (inclui o Reagrupar na hora).
// =====================================================================

this.necro_maestro_opus <- this.inherit("scripts/skills/actives/necro_maestro_order", {
	m = {},
	function create()
	{
		this.necro_maestro_order.create();
		this.m.ID = "actives.necro_maestro_opus";
		this.m.Name = "Opus Final";
		this.m.Description = "Uma vez por combate, todas as Ordens soam ao mesmo tempo.";
		this.m.Icon = "skills/active_50.png";
		this.m.IconDisabled = "skills/active_50_sw.png";
		this.m.Overlay = "active_50";
		this.m.Order = this.Const.SkillOrder.NonTargeted + 12;
	}

	function getCooldownMax()
	{
		return 0;
	}

	function onAfterUpdate( _properties )
	{
	}

	function isUsable()
	{
		local rt = this.getUtil().getRuntime();
		return this.necro_active_base.isUsable() && !(this.getContainer().getActor().getID() in rt.OpusUsado);
	}

	function getTooltip()
	{
		local ret = this.getDefaultUtilityTooltip();
		ret.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "As 4 Ordens a 100% por " + this.Const.Necro.Sub.Maestro.OpusTurnos + " turnos. Uma vez por combate."
		});
		return ret;
	}

	function onUse( _user, _targetTile )
	{
		local util = this.getUtil();
		util.getRuntime().OpusUsado[_user.getID()] <- true;
		util.giveAllOrders(_user.getID(), this.Const.Necro.Sub.Maestro.OpusTurnos);
		this.regroup(_user, 1.0);
		this.refreshSummons(_user);

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " rege o Opus Final!");
		}

		return true;
	}

});
