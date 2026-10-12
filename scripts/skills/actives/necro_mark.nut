// =====================================================================
// MOD NECROMANTE - Marca do Comando (cap. 7.4)
// ---------------------------------------------------------------------
// Alvo: 1 inimigo visível a até 7 tiles. Duração 2 turnos.
// Os efeitos estão em scripts/skills/effects/necro_mark_effect.nut.
// A versão do Mago (necro_mage_mark.nut) herda daqui com 50% de potência.
// =====================================================================

this.necro_mark <- this.inherit("scripts/skills/actives/necro_active_base", {
	m = {},
	function create()
	{
		this.necro_active_base.create();
		this.m.ID = "actives.necro_mark";
		this.m.Name = "Marca do Comando";
		this.m.Description = "Marca um inimigo. Seus mortos passam a caçá-lo com prioridade e ele sofre mais dano de mortos, do Necromante, de Veneno e de Necrose.";
		this.m.Icon = "skills/active_18.png";
		this.m.IconDisabled = "skills/active_18_sw.png";
		this.m.Overlay = "active_18";
		this.m.SoundOnUse = [
			"sounds/enemies/necromancer_01.wav",
			"sounds/enemies/necromancer_02.wav"
		];
		this.m.Order = this.Const.SkillOrder.UtilityTargeted + 5;
		this.m.IsTargeted = true;
		this.m.IsTargetingActor = true;
		this.m.IsVisibleTileNeeded = true;
		this.m.IsRanged = true;
		this.m.IsShowingProjectile = false;
		this.m.ActionPointCost = this.Const.Necro.Ativas.MarcaPA;
		this.m.FatigueCost = this.Const.Necro.Ativas.MarcaFadiga;
		this.m.MinRange = 1;
		this.m.MaxRange = this.Const.Necro.Ativas.MarcaAlcance;
		this.m.MaxLevelDifference = 4;
	}

	function getCooldownMax()
	{
		return this.Const.Necro.Ativas.MarcaCooldown;
	}

	function onAddTooltip( _tooltip )
	{
		local a = this.Const.Necro.Ativas;
		_tooltip.push({
			id = 10,
			type = "text",
			icon = "ui/icons/vision.png",
			text = "Alcance: [color=" + this.Const.UI.Color.PositiveValue + "]" + a.MarcaAlcance + "[/color] tiles | Duração: " + a.MarcaDuracao + " turnos"
		});
		_tooltip.push({
			id = 11,
			type = "text",
			icon = "ui/icons/regular_damage.png",
			text = "Mortos priorizam o alvo; +" + this.Math.round(a.MarcaBonusDano * this.m.Potency * 100) + "% de dano de mortos/Necromante; +" + this.Math.round(a.MarcaBonusEfeitos * this.m.Potency * 100) + "% de dano de Veneno e Necrose"
		});
		_tooltip.push({
			id = 12,
			type = "text",
			icon = "ui/icons/special.png",
			text = "Se o alvo morrer marcado: " + a.MarcaChanceZerarCooldown + "% de chance de zerar o cooldown"
		});
	}

	function onVerifyTarget( _originTile, _targetTile )
	{
		if (!this.skill.onVerifyTarget(_originTile, _targetTile))
		{
			return false;
		}

		if (!_targetTile.IsOccupiedByActor)
		{
			return false;
		}

		local target = _targetTile.getEntity();
		return target != null && target.isAlive() && !target.isAlliedWith(this.getContainer().getActor());
	}

	function markTarget( _user, _target )
	{
		local util = this.getUtil();
		local effect = _target.getSkills().getSkillByID(util.MarcaID);

		if (effect == null)
		{
			effect = this.new("scripts/skills/effects/necro_mark_effect");
			_target.getSkills().add(effect);
		}

		effect.setup(this.m.Potency, util.getMasterID(_user), _user.getID());
		_target.getSkills().update();

		if (!_target.isHiddenToPlayer())
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(_user) + " marca " + this.Const.UI.getColorizedEntityName(_target));
		}

		this.startCooldown();
	}

	function onUse( _user, _targetTile )
	{
		this.markTarget(_user, _targetTile.getEntity());
		return true;
	}

});
