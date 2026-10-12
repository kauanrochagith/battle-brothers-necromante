// =====================================================================
// MOD NECROMANTE - Necrófago (perk do Coveiro)
// ---------------------------------------------------------------------
// NecrofagoPA PA: o Necromante consome um cadáver adjacente (qualquer
// cadáver do vanilla) e recupera NecrofagoFadiga de Fadiga.
// =====================================================================

this.necro_grave_devour <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local CO = this.Const.Necro.Sub.Coveiro;
		this.m.ID = "actives.necro_grave_devour";
		this.m.Name = "Necrófago";
		this.m.Description = "Consome um cadáver ao lado para recuperar o fôlego.";
		this.m.Icon = "skills/active_163.png";
		this.m.IconDisabled = "skills/active_163_sw.png";
		this.m.Overlay = "active_163";
		this.m.SoundOnUse = [
			"sounds/enemies/gruesome_feast_01.wav"
		];
		this.m.Order = this.Const.SkillOrder.UtilityTargeted + 12;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = false;
		this.m.IsVisibleTileNeeded = true;
		this.m.ActionPointCost = CO.NecrofagoPA;
		this.m.FatigueCost = 0;
		this.m.MinRange = 1;
		this.m.MaxRange = 1;
	}

	function onAddTooltip( _tooltip )
	{
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/fatigue.png",
			text = "Recupera [color=" + this.Const.UI.Color.PositiveValue + "]" + this.Const.Necro.Sub.Coveiro.NecrofagoFadiga + "[/color] de Fadiga"
		});
	}

	function isUsable()
	{
		return this.necro_active_base.isUsable() && this.getContainer().getActor().getFatigue() > 0;
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		return _targetTile.IsCorpseSpawned && _targetTile.IsEmpty;
	}

	function onUse( _user, _targetTile )
	{
		local util = this.getUtil();
		local found = util.findCorpseInfo(_targetTile);
		util.consumeCorpse(_targetTile, found != null ? found.ID : -1);
		_user.setFatigue(this.Math.max(0, _user.getFatigue() - this.Const.Necro.Sub.Coveiro.NecrofagoFadiga));

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " devora um cadáver");
		}

		return true;
	}

});
