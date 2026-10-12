// =====================================================================
// MOD NECROMANTE - Reanimar Cadáver (Coveiro)
// ---------------------------------------------------------------------
// Alvo: um tile com cadáver registrado (ver necro_corpse_watcher_effect)
// a até ReanimarAlcance. Cria 1 Reanimado com o equipamento e o papel do
// morto (necro_reanimado). Sem cooldown; respeita COVEIRO_MAX_MORTOS.
// Coveiro Eficiente: -1 PA (mínimo 2). Chefes e criaturas mágicas não
// são registrados, então não podem ser reanimados.
// =====================================================================

this.necro_grave_raise <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local CO = this.Const.Necro.Sub.Coveiro;
		this.m.ID = "actives.necro_grave_raise";
		this.m.Name = "Reanimar Cadáver";
		this.m.Description = "Ergue um cadáver do campo de batalha com o equipamento e o ofício que tinha em vida.";
		this.m.Icon = "skills/active_26.png";
		this.m.IconDisabled = "skills/active_26_sw.png";
		this.m.Overlay = "active_26";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_01.wav",
			"sounds/enemies/necromancer_02.wav"
		];
		this.m.Order = this.Const.SkillOrder.UtilityTargeted + 10;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = false;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = false;
		this.m.ActionPointCost = CO.ReanimarPA;
		this.m.FatigueCost = CO.ReanimarFadiga;
		this.m.MinRange = 0;
		this.m.MaxRange = CO.ReanimarAlcance;
		this.m.MaxLevelDifference = 4;
	}

	function onAfterUpdate( _properties )
	{
		local CO = this.Const.Necro.Sub.Coveiro;
		local ap = CO.ReanimarPA;

		if (this.getUtil().hasPerkByMasterID(this.getContainer().getActor().getID(), "perk.necro_coveiro_eficiente"))
		{
			ap = this.Math.max(CO.EficientePAMinimo, ap - CO.EficientePA);
		}

		this.m.ActionPointCost = ap;
	}

	function isUsable()
	{
		local util = this.getUtil();
		local actor = this.getContainer().getActor();
		return this.necro_active_base.isUsable() && util.getFreeSlots(actor.getID()) > 0 && util.getCorpseTiles(actor.getTile(), this.m.MaxRange).len() != 0;
	}

	function onAddTooltip( _tooltip )
	{
		local util = this.getUtil();
		local actor = this.getContainer().getActor();
		local escala = util.getReanimateScale(actor.getID());
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "O reanimado fica com [color=" + this.Const.UI.Color.PositiveValue + "]" + this.Math.round(escala * 100) + "%[/color] da vida e das habilidades do original"
		});

		if (util.isInCombat())
		{
			_tooltip.push({
				id = 11,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Cadáveres ao alcance: " + util.getCorpseTiles(actor.getTile(), this.m.MaxRange).len() + " | Mortos (com peso): " + util.countSummonWeight(actor.getID()) + "/" + util.getMaxSummons(actor.getID())
			});
		}
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		return this.getUtil().findCorpseInfo(_targetTile) != null;
	}

	function onUse( _user, _targetTile )
	{
		local util = this.getUtil();
		local found = util.findCorpseInfo(_targetTile);

		if (found == null)
		{
			return false;
		}

		util.cachePerks(_user);
		return util.reanimateCorpse(_user, _targetTile, found) != null;
	}

});
