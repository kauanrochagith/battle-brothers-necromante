// =====================================================================
// MOD NECROMANTE - Carga Fúnebre (Senhor da Legião)
// ---------------------------------------------------------------------
// Alvo: 1 inimigo visível. Até CargaMaxMortos mortos corpo a corpo
// (os mais próximos do alvo) andam até CargaMovimento tiles para ficar
// ao lado dele e fazem 1 ataque grátis. O deslocamento é um "teleporte
// curto" do navegador do vanilla (o mesmo da Investida), por isso
// ignora Zona de Controle. Esses mortos ficam com -CargaPenalidadePA PA
// no turno seguinte (necro_charge_tired_effect).
// =====================================================================

this.necro_legion_charge <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local L = this.Const.Necro.Sub.Legiao;
		this.m.ID = "actives.necro_legion_charge";
		this.m.Name = "Carga Fúnebre";
		this.m.Description = "Aponta um inimigo: os mortos mais próximos avançam sobre ele e atacam de imediato.";
		this.m.Icon = "skills/active_52.png";
		this.m.IconDisabled = "skills/active_52_sw.png";
		this.m.Overlay = "active_52";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_02.wav"
		];
		this.m.Order = this.Const.SkillOrder.UtilityTargeted + 10;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = true;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = false;
		this.m.ActionPointCost = L.CargaPA;
		this.m.FatigueCost = L.CargaFadiga;
		this.m.MinRange = 1;
		this.m.MaxRange = 10;
		this.m.MaxLevelDifference = 4;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Sub.Legiao.CargaCD;
	}

	function onAddTooltip( _tooltip )
	{
		local L = this.Const.Necro.Sub.Legiao;
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Até " + L.CargaMaxMortos + " mortos corpo a corpo andam até " + L.CargaMovimento + " tiles e atacam o alvo de graça; no turno seguinte ficam com [color=" + this.Const.UI.Color.NegativeValue + "]-" + L.CargaPenalidadePA + "[/color] PA"
		});
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile) || !_targetTile.IsOccupiedByActor)
		{
			return false;
		}

		local target = _targetTile.getEntity();
		return target != null && target.isAlive() && !target.isAlliedWith(this.getContainer().getActor());
	}

	function onUse( _user, _targetTile )
	{
		local L = this.Const.Necro.Sub.Legiao;
		local util = this.getUtil();
		local target = _targetTile.getEntity();
		local candidatos = [];

		foreach( e in util.getSummonsOfMaster(_user.getID(), false) )
		{
			local t = e.getFlags().get(util.FlagTipo);

			if (!(t in this.Const.Necro.Tipos) || this.Const.Necro.Tipos[t].Distancia || e.getCurrentProperties().IsRooted)
			{
				continue;
			}

			local d = e.getTile().getDistanceTo(_targetTile);

			// Precisa conseguir chegar ao lado do alvo andando até CargaMovimento tiles.
			if (d <= L.CargaMovimento + 1)
			{
				candidatos.push({
					E = e,
					D = d
				});
			}
		}

		candidatos.sort(function ( _a, _b )
		{
			return _a.D < _b.D ? -1 : (_a.D > _b.D ? 1 : 0);
		});
		local n = 0;

		foreach( c in candidatos )
		{
			if (n >= L.CargaMaxMortos)
			{
				break;
			}

			if (util.moveAndAttack(c.E, target, L.CargaMovimento, 300 + 350 * n))
			{
				c.E.getSkills().add(this.new("scripts/skills/effects/necro_charge_tired_effect"));
				n = ++n;
			}
		}

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " ordena a Carga Fúnebre contra " + this.Const.UI.getColorizedEntityName(target) + " (" + n + " mortos)");
		}

		this.startCooldown();
		return true;
	}

});
