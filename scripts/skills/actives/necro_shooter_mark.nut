// =====================================================================
// MOD NECROMANTE - Marca do Caçador (Atirador Espectral)
// ---------------------------------------------------------------------
// Marca o alvo por MarcaDuracao turnos (necro_hunter_mark_effect): tiros
// dos mortos e do Necromante ganham +MarcaAcerto de acerto e +MarcaDano de
// dano contra ele. Execução à Distância zera o cooldown ao matar o marcado.
// =====================================================================

this.necro_shooter_mark <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local AT = this.Const.Necro.Sub.Atirador;
		this.m.ID = "actives.necro_shooter_mark";
		this.m.Name = "Marca do Caçador";
		this.m.Description = "Marca uma presa: os tiros dos mortos a encontram com mais facilidade e ferem mais.";
		this.m.Icon = "skills/active_18.png";
		this.m.IconDisabled = "skills/active_18_sw.png";
		this.m.Overlay = "active_18";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_02.wav"
		];
		this.m.Order = this.Const.SkillOrder.UtilityTargeted + 11;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = true;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = false;
		this.m.ActionPointCost = AT.MarcaPA;
		this.m.FatigueCost = AT.MarcaFadiga;
		this.m.MinRange = 1;
		this.m.MaxRange = AT.MarcaAlcance;
		this.m.MaxLevelDifference = 4;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Sub.Atirador.MarcaCD;
	}

	function onAddTooltip( _tooltip )
	{
		local AT = this.Const.Necro.Sub.Atirador;
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/ranged_skill.png",
			text = "Por " + AT.MarcaDuracao + " turnos: [color=" + this.Const.UI.Color.PositiveValue + "]+" + AT.MarcaAcerto + "%[/color] de acerto e [color=" + this.Const.UI.Color.PositiveValue + "]+" + this.Math.round(AT.MarcaDano * 100) + "%[/color] de dano dos seus tiros contra o alvo"
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
		local target = _targetTile.getEntity();
		local effect = target.getSkills().getSkillByID("effects.necro_hunter_mark");

		if (effect == null)
		{
			effect = this.new("scripts/skills/effects/necro_hunter_mark_effect");
			target.getSkills().add(effect);
		}

		effect.setup(_user.getID());
		target.getSkills().update();

		if (!target.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " marca a presa " + this.Const.UI.getColorizedEntityName(target));
		}

		this.startCooldown();
		return true;
	}

});
