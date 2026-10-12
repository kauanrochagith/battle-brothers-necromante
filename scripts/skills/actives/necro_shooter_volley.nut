// =====================================================================
// MOD NECROMANTE - Saraivada Fantasma (Atirador Espectral)
// ---------------------------------------------------------------------
// Alvo: inimigo visível. Todos os mortos à distância com o alvo dentro do
// alcance disparam 1 tiro grátis nele, com +SaraivadaAcerto de acerto.
// No máximo SaraivadaMax atiradores. Os tiros saem em sequência
// (Time.scheduleEvent) para os projéteis não se sobreporem.
// =====================================================================

this.necro_shooter_volley <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local AT = this.Const.Necro.Sub.Atirador;
		this.m.ID = "actives.necro_shooter_volley";
		this.m.Name = "Saraivada Fantasma";
		this.m.Description = "Todos os atiradores mortos que alcançam o alvo disparam nele de uma vez.";
		this.m.Icon = "skills/active_17.png";
		this.m.IconDisabled = "skills/active_17_sw.png";
		this.m.Overlay = "active_17";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_01.wav"
		];
		this.m.Order = this.Const.SkillOrder.UtilityTargeted + 10;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = true;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = false;
		this.m.ActionPointCost = AT.SaraivadaPA;
		this.m.FatigueCost = AT.SaraivadaFadiga;
		this.m.MinRange = 1;
		this.m.MaxRange = 14;
		this.m.MaxLevelDifference = 4;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Sub.Atirador.SaraivadaCD;
	}

	function getShooters( _targetTile )
	{
		local util = this.getUtil();
		local ret = [];

		foreach( e in util.getSummonsOfMaster(this.getContainer().getActor().getID(), false) )
		{
			if (ret.len() >= this.Const.Necro.Sub.Atirador.SaraivadaMax)
			{
				break;
			}

			if (util.getRangedAttack(e, _targetTile) != null)
			{
				ret.push(e);
			}
		}

		return ret;
	}

	function onAddTooltip( _tooltip )
	{
		local AT = this.Const.Necro.Sub.Atirador;
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/ranged_skill.png",
			text = "Até " + AT.SaraivadaMax + " mortos à distância atiram de graça no alvo, com [color=" + this.Const.UI.Color.PositiveValue + "]+" + AT.SaraivadaAcerto + "%[/color] de acerto"
		});
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile) || !_targetTile.IsOccupiedByActor)
		{
			return false;
		}

		local target = _targetTile.getEntity();
		return target != null && target.isAlive() && !target.isAlliedWith(this.getContainer().getActor()) && this.getShooters(_targetTile).len() != 0;
	}

	function onUse( _user, _targetTile )
	{
		local AT = this.Const.Necro.Sub.Atirador;
		local util = this.getUtil();
		local target = _targetTile.getEntity();
		local shooters = this.getShooters(_targetTile);
		local bonus = {
			Acerto = AT.SaraivadaAcerto,
			Dano = 0.0
		};

		foreach( i, e in shooters )
		{
			util.scheduleAttack(e, target, 200 + 250 * i, bonus);
		}

		if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " comanda a Saraivada Fantasma (" + shooters.len() + " atiradores)");
		}

		this.startCooldown();
		return true;
	}

});
