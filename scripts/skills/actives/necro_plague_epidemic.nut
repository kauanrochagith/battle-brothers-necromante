// =====================================================================
// MOD NECROMANTE - Epidemia (Mestre da Peste)
// ---------------------------------------------------------------------
// Alvo: inimigo com pelo menos 1 acúmulo. Copia EpidemiaFracao (50%,
// arredondado para cima) dos acúmulos de Veneno e de Necrose dele para
// todos os inimigos a até EpidemiaRaio. Pandemia: 100% e raio 2.
// =====================================================================

this.necro_plague_epidemic <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local PE = this.Const.Necro.Sub.Peste;
		this.m.ID = "actives.necro_plague_epidemic";
		this.m.Name = "Epidemia";
		this.m.Description = "A doença de um inimigo salta para os que estão ao redor dele.";
		this.m.Icon = "skills/active_174.png";
		this.m.IconDisabled = "skills/active_174_sw.png";
		this.m.Overlay = "active_174";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_03.wav"
		];
		this.m.Order = this.Const.SkillOrder.UtilityTargeted + 13;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = true;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = false;
		this.m.ActionPointCost = PE.EpidemiaPA;
		this.m.FatigueCost = PE.EpidemiaFadiga;
		this.m.MinRange = 1;
		this.m.MaxRange = PE.EpidemiaAlcance;
		this.m.MaxLevelDifference = 4;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Sub.Peste.EpidemiaCD;
	}

	function hasPandemic()
	{
		return this.getUtil().hasPerkByMasterID(this.getContainer().getActor().getID(), "perk.necro_pandemia");
	}

	function getFraction()
	{
		local PE = this.Const.Necro.Sub.Peste;
		return this.hasPandemic() ? PE.PandemiaFracao : PE.EpidemiaFracao;
	}

	function getRadius()
	{
		local PE = this.Const.Necro.Sub.Peste;
		return this.hasPandemic() ? PE.PandemiaRaio : PE.EpidemiaRaio;
	}

	function onAddTooltip( _tooltip )
	{
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Copia [color=" + this.Const.UI.Color.NegativeValue + "]" + this.Math.round(this.getFraction() * 100) + "%[/color] dos acúmulos de Veneno e Necrose do alvo para os inimigos a até " + this.getRadius() + " tiles"
		});
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile) || !_targetTile.IsOccupiedByActor)
		{
			return false;
		}

		local target = _targetTile.getEntity();
		return target != null && target.isAlive() && !target.isAlliedWith(this.getContainer().getActor()) && this.getUtil().getTotalStacks(target) >= 1;
	}

	function onUse( _user, _targetTile )
	{
		local util = this.getUtil();
		local source = _targetTile.getEntity();
		local frac = this.getFraction();
		local copias = [];

		foreach( id in [util.VenenoID, util.NecroseID] )
		{
			local e = source.getSkills().getSkillByID(id);

			if (e != null && e.getStacks() > 0)
			{
				copias.push({
					ID = id,
					N = this.Math.ceil(e.getStacks() * frac)
				});
			}
		}

		local n = 0;

		foreach( e in util.getActorsInRadius(_targetTile, this.getRadius()) )
		{
			if (e.getID() == source.getID() || !e.isAlliedWith(source) || util.isSummon(e))
			{
				continue;
			}

			foreach( c in copias )
			{
				util.addStacks(e, c.ID, c.N, _user.getID());
			}

			n = ++n;
		}

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " espalha a Epidemia de " + this.Const.UI.getColorizedEntityName(source) + " para " + n + " inimigo(s)");
		}

		this.startCooldown();
		return true;
	}

});
