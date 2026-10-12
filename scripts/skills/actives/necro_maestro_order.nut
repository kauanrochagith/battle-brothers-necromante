// =====================================================================
// MOD NECROMANTE - Dar Ordem (Maestro dos Ossos)
// ---------------------------------------------------------------------
// Ativa a Ordem selecionada (Alternar Ordem) por ORDEM_DURACAO turnos
// (Batuta Óssea: +1). O estado fica em Runtime.Ordens e é lido pela
// racial dos mortos e pela IA (Muralha segura a posição).
//   - Reagrupar é instantâneo: cada morto anda até ReagruparMovimento tiles
//     na direção do Necromante e cura ReagruparCura da vida máxima.
//     Nunca é fuga: os mortos continuam com moral ignorada.
// Cadência Perfeita: -1 PA e -1 de cooldown. Ordem Dupla: a Ordem
// anterior continua com 50% (Util.giveOrder).
// =====================================================================

this.necro_maestro_order <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local MA = this.Const.Necro.Sub.Maestro;
		this.m.ID = "actives.necro_maestro_order";
		this.m.Name = "Dar Ordem";
		this.m.Description = "Rege os mortos com a Ordem selecionada.";
		this.m.Icon = "skills/active_49.png";
		this.m.IconDisabled = "skills/active_49_sw.png";
		this.m.Overlay = "active_49";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_01.wav"
		];
		this.m.Order = this.Const.SkillOrder.NonTargeted + 10;
		this.m.IsTargeted = false;
		this.m.ActionPointCost = MA.OrdemPA;
		this.m.FatigueCost = MA.OrdemFadiga;
	}

	function hasCadence()
	{
		return this.getUtil().hasPerkByMasterID(this.getContainer().getActor().getID(), "perk.necro_cadencia_perfeita");
	}

	function getCooldownMax()
	{
		local MA = this.Const.Necro.Sub.Maestro;
		return this.Math.max(1, MA.OrdemCD - (this.hasCadence() ? MA.CadenciaCD : 0));
	}

	function onAfterUpdate( _properties )
	{
		local MA = this.Const.Necro.Sub.Maestro;
		this.m.ActionPointCost = this.Math.max(1, MA.OrdemPA - (this.hasCadence() ? MA.CadenciaPA : 0));
	}

	function getSelectedOrder()
	{
		local id = this.getContainer().getActor().getFlags().get("necro_ordem_sel");

		foreach( o in this.Const.Necro.Ordens )
		{
			if (o.ID == id)
			{
				return o;
			}
		}

		return this.Const.Necro.Ordens[0];
	}

	function onAddTooltip( _tooltip )
	{
		local o = this.getSelectedOrder();
		local util = this.getUtil();
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Ordem selecionada: [color=" + this.Const.UI.Color.PositiveValue + "]" + o.Nome + "[/color] - " + o.Descricao
		});
		_tooltip.push({
			id = 11,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Duração: " + util.getOrderDuration(this.getContainer().getActor().getID()) + " turnos"
		});

		if (util.isInCombat())
		{
			foreach( a in util.getActiveOrders(this.getContainer().getActor().getID()) )
			{
				foreach( o2 in this.Const.Necro.Ordens )
				{
					if (o2.ID == a.ID)
					{
						_tooltip.push({
							id = 12,
							type = "text",
							icon = "ui/icons/special.png",
							text = "Ativa: " + o2.Nome + " (" + this.Math.round(a.Mult * 100) + "%, " + a.Turnos + " turno(s))"
						});
					}
				}
			}
		}
	}

	function onUse( _user, _targetTile )
	{
		local o = this.getSelectedOrder();
		this.getUtil().giveOrder(_user.getID(), o.ID);

		if (o.ID == "reagrupar")
		{
			this.regroup(_user, 1.0);
		}

		this.refreshSummons(_user);

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " ordena: " + o.Nome + "!");
		}

		this.startCooldown();
		return true;
	}

	function refreshSummons( _user )
	{
		foreach( e in this.getUtil().getSummonsOfMaster(_user.getID(), false) )
		{
			e.getSkills().update();
		}
	}

	// Reagrupar: anda até ReagruparMovimento tiles na direção do Necromante e cura.
	function regroup( _user, _mult )
	{
		local MA = this.Const.Necro.Sub.Maestro;
		local util = this.getUtil();
		local masterTile = _user.getTile();

		foreach( e in util.getSummonsOfMaster(_user.getID(), false) )
		{
			util.heal(e, this.Math.max(1, this.Math.floor(e.getHitpointsMax() * MA.ReagruparCura * _mult)));

			if (e.getCurrentProperties().IsRooted)
			{
				continue;
			}

			local myTile = e.getTile();
			local best = null;
			local bestDist = myTile.getDistanceTo(masterTile);

			foreach( t in util.getTilesInRadius(myTile, MA.ReagruparMovimento) )
			{
				if (!t.IsEmpty || this.Math.abs(t.Level - myTile.Level) > 2)
				{
					continue;
				}

				local d = t.getDistanceTo(masterTile);

				if (d < bestDist && d >= 1)
				{
					best = t;
					bestDist = d;
				}
			}

			if (best != null)
			{
				this.Tactical.getNavigator().teleport(e, best, null, null, false, 0.0);
			}
		}
	}

});
