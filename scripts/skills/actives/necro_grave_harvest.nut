// =====================================================================
// MOD NECROMANTE - Colheita de Almas (Coveiro)
// ---------------------------------------------------------------------
// Consome até AlmasCadaveres cadáveres registrados (os mais próximos do
// Necromante; depois disso não podem mais ser reanimados) e cura todos os
// mortos dele em AlmasCura da vida máxima.
// =====================================================================

this.necro_grave_harvest <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local CO = this.Const.Necro.Sub.Coveiro;
		this.m.ID = "actives.necro_grave_harvest";
		this.m.Name = "Colheita de Almas";
		this.m.Description = "Consome os cadáveres do campo para remendar os mortos do Necromante.";
		this.m.Icon = "skills/active_156.png";
		this.m.IconDisabled = "skills/active_156_sw.png";
		this.m.Overlay = "active_156";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_03.wav"
		];
		this.m.Order = this.Const.SkillOrder.NonTargeted + 10;
		this.m.IsTargeted = false;
		this.m.ActionPointCost = CO.AlmasPA;
		this.m.FatigueCost = CO.AlmasFadiga;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Sub.Coveiro.AlmasCD;
	}

	function isUsable()
	{
		local util = this.getUtil();
		local actor = this.getContainer().getActor();
		return this.necro_active_base.isUsable() && util.getCorpseTiles(actor.getTile(), 99).len() != 0 && util.countSummons(actor.getID()) != 0;
	}

	function onAddTooltip( _tooltip )
	{
		local CO = this.Const.Necro.Sub.Coveiro;
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/health.png",
			text = "Consome até " + CO.AlmasCadaveres + " cadáveres e cura seus mortos em [color=" + this.Const.UI.Color.PositiveValue + "]" + this.Math.round(CO.AlmasCura * 100) + "%[/color] da vida máxima"
		});
	}

	function onUse( _user, _targetTile )
	{
		local CO = this.Const.Necro.Sub.Coveiro;
		local util = this.getUtil();
		local n = 0;

		foreach( c in util.getCorpseTiles(_user.getTile(), 99) )
		{
			if (n >= CO.AlmasCadaveres)
			{
				break;
			}

			util.consumeCorpse(c.Tile, c.ID);
			n = ++n;
		}

		foreach( e in util.getSummonsOfMaster(_user.getID(), true) )
		{
			util.heal(e, this.Math.max(1, this.Math.floor(e.getHitpointsMax() * CO.AlmasCura)));
		}

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " colhe as almas de " + n + " cadáver(es)");
		}

		this.startCooldown();
		return true;
	}

});
