// =====================================================================
// MOD NECROMANTE - Raio Necrótico (Lich)
// ---------------------------------------------------------------------
// Alcance RaioAlcance, acerto FIXO de RaioAcerto% (não usa Habilidade nem
// Defesa), dano RaioDanoMin-RaioDanoMax que ignora armadura.
// Arquimago: dano +50%, cooldown -1, alcance +1.
// Não é um "ataque" do vanilla (IsAttack = false): a rolagem é própria.
// A versão dos Magos (necro_mage_ray) herda daqui.
// =====================================================================

this.necro_lich_ray <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		local LI = this.Const.Necro.Sub.Lich;
		this.m.ID = "actives.necro_lich_ray";
		this.m.Name = "Raio Necrótico";
		this.m.Description = "Um raio de energia sepulcral que atravessa qualquer armadura.";
		this.m.Icon = "skills/active_205.png";
		this.m.IconDisabled = "skills/active_205_sw.png";
		this.m.Overlay = "active_205";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_01.wav"
		];
		this.m.Order = this.Const.SkillOrder.UtilityTargeted + 11;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = true;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = false;
		this.m.ActionPointCost = LI.RaioPA;
		this.m.FatigueCost = LI.RaioFadiga;
		this.m.MinRange = 1;
		this.m.MaxRange = LI.RaioAlcance;
		this.m.MaxLevelDifference = 4;
	}

	function getMasterID()
	{
		return this.getUtil().getMasterID(this.getContainer().getActor());
	}

	function hasArchmage()
	{
		return this.getUtil().hasPerkByMasterID(this.getMasterID(), "perk.necro_arquimago");
	}

	function getCooldownMax()
	{
		local LI = this.Const.Necro.Sub.Lich;
		return this.Math.max(1, LI.RaioCD - (this.hasArchmage() ? LI.ArquimagoCD : 0));
	}

	function getDamageRange()
	{
		local LI = this.Const.Necro.Sub.Lich;
		local mult = this.hasArchmage() ? 1.0 + LI.ArquimagoDano : 1.0;
		return [
			this.Math.round(LI.RaioDanoMin * mult),
			this.Math.round(LI.RaioDanoMax * mult)
		];
	}

	function getHitChance()
	{
		return this.Const.Necro.Sub.Lich.RaioAcerto;
	}

	function onAfterUpdate( _properties )
	{
		local LI = this.Const.Necro.Sub.Lich;
		this.m.MaxRange = LI.RaioAlcance + (this.hasArchmage() ? LI.ArquimagoAlcance : 0);
	}

	function onAddTooltip( _tooltip )
	{
		local d = this.getDamageRange();
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/regular_damage.png",
			text = "Causa [color=" + this.Const.UI.Color.DamageValue + "]" + d[0] + "-" + d[1] + "[/color] de dano que ignora armadura"
		});
		_tooltip.push({
			id = 11,
			type = "text",
			icon = "ui/icons/hitchance.png",
			text = "Acerto fixo de [color=" + this.Const.UI.Color.PositiveValue + "]" + this.getHitChance() + "%[/color] | Alcance " + this.m.MaxRange
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

	function fireAt( _user, _target )
	{
		local d = this.getDamageRange();

		if (this.Math.rand(1, 100) <= this.getHitChance())
		{
			local dmg = this.Math.rand(d[0], d[1]);

			if (!_user.isHiddenToPlayer() || !_target.isHiddenToPlayer())
			{
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " acerta " + this.Const.UI.getColorizedEntityName(_target) + " com o Raio Necrótico (" + dmg + ")");
			}

			this.getUtil().dealDirectDamage(_target, dmg, _user, this);
		}
		else if (!_user.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log("O Raio Necrótico de " + this.Const.UI.getColorizedEntityName(_user) + " erra " + this.Const.UI.getColorizedEntityName(_target));
		}
	}

	function onUse( _user, _targetTile )
	{
		this.fireAt(_user, _targetTile.getEntity());
		this.startCooldown();
		return true;
	}

});
