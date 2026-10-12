// =====================================================================
// MOD NECROMANTE - Nuvem de Peste (Mestre da Peste)
// ---------------------------------------------------------------------
// Tile alvo a até NuvemAlcance. Cria uma nuvem de raio NuvemRaio (o tile
// e os 6 vizinhos, o "3x3" de um mapa hexagonal) que dura NuvemDuracao
// turnos do Necromante. No início do turno de cada inimigo dentro dela,
// ele ganha NuvemAcumulos de Veneno (necro_enemy_aura_effect).
// =====================================================================

this.necro_plague_cloud <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local PE = this.Const.Necro.Sub.Peste;
		this.m.ID = "actives.necro_plague_cloud";
		this.m.Name = "Nuvem de Peste";
		this.m.Description = "Solta uma nuvem pestilenta. Quem começar o turno dentro dela se envenena.";
		this.m.Icon = "skills/active_164.png";
		this.m.IconDisabled = "skills/active_164_sw.png";
		this.m.Overlay = "active_164";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_02.wav"
		];
		this.m.Order = this.Const.SkillOrder.UtilityTargeted + 12;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = false;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = false;
		this.m.ActionPointCost = PE.NuvemPA;
		this.m.FatigueCost = PE.NuvemFadiga;
		this.m.MinRange = 1;
		this.m.MaxRange = PE.NuvemAlcance;
		this.m.MaxLevelDifference = 4;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Sub.Peste.NuvemCD;
	}

	function getAffectedTiles( _targetTile )
	{
		return this.getUtil().getTilesInRadius(_targetTile, this.Const.Necro.Sub.Peste.NuvemRaio);
	}

	function onAddTooltip( _tooltip )
	{
		local PE = this.Const.Necro.Sub.Peste;
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Área de raio " + PE.NuvemRaio + " por " + PE.NuvemDuracao + " turnos: inimigos dentro ganham [color=" + this.Const.UI.Color.NegativeValue + "]" + PE.NuvemAcumulos + "[/color] acúmulo de Veneno no início do turno"
		});
	}

	function onUse( _user, _targetTile )
	{
		local PE = this.Const.Necro.Sub.Peste;
		local util = this.getUtil();
		util.getRuntime().Nuvens.push({
			Tile = _targetTile,
			Raio = PE.NuvemRaio,
			Turnos = PE.NuvemDuracao,
			MasterID = _user.getID()
		});
		util.cachePerks(_user);

		// Os inimigos já recebem o vigia da aura agora (não só na próxima rodada).
		util.attachToAll("scripts/skills/effects/necro_enemy_aura_effect", "effects.necro_enemy_aura", function ( _e )
		{
			return !_e.isAlliedWith(_user);
		});

		if (_targetTile.IsVisibleForPlayer && ("MiasmaParticles" in this.Const.Tactical))
		{
			foreach( t in this.getAffectedTiles(_targetTile) )
			{
				foreach( p in this.Const.Tactical.MiasmaParticles )
				{
					this.Tactical.spawnParticleEffect(true, p.Brushes, t, p.Delay, p.Quantity, p.LifeTimeQuantity, p.SpawnRate, p.Stages);
				}
			}
		}

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " solta uma Nuvem de Peste");
		}

		this.startCooldown();
		return true;
	}

});
