// =====================================================================
// MOD NECROMANTE - Marca do Comando (efeito no alvo, cap. 7.4)
// ---------------------------------------------------------------------
//   - IA: TargetAttractionMult x3 (o mesmo mecanismo do "Taunt" vanilla),
//     então os mortos (e qualquer aliado controlado por IA) priorizam o alvo;
//   - +15% de dano recebido de mortos e do Necromante;
//   - +50% de dano de Veneno e Necrose (lido em Const.Necro.Util.getEffectDamageMult);
//   - se o alvo morrer marcado: 50% de chance de zerar o cooldown da Marca.
// Potency = 1.0 (Necromante) ou 0.5 (Mago com Eco do Mago).
// =====================================================================

this.necro_mark_effect <- this.inherit("scripts/skills/skill", {
	m = {
		TurnsLeft = 2,
		Potency = 0.0,
		MasterID = -1,
		SourceID = -1
	},
	function create()
	{
		this.m.ID = "effects.necro_mark";
		this.m.Name = "Marca do Comando";
		this.m.Description = "Este personagem foi marcado por um Necromante. Os mortos o caçam com prioridade.";
		this.m.Icon = "skills/status_effect_84.png";
		this.m.IconMini = "status_effect_84_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
		this.m.IsSerialized = false;
		this.m.TurnsLeft = this.Const.Necro.Ativas.MarcaDuracao;
	}

	function getPotency()
	{
		return this.m.Potency;
	}

	function setup( _potency, _masterID, _sourceID )
	{
		// Uma marca mais forte não é substituída por uma mais fraca.
		this.m.Potency = this.Math.maxf(this.m.Potency, _potency);
		this.m.MasterID = _masterID;
		this.m.SourceID = _sourceID;
		this.m.TurnsLeft = this.Const.Necro.Ativas.MarcaDuracao;
	}

	function getTooltip()
	{
		local a = this.Const.Necro.Ativas;
		return [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			},
			{
				id = 10,
				type = "text",
				icon = "ui/icons/regular_damage.png",
				text = "Recebe [color=" + this.Const.UI.Color.NegativeValue + "]+" + this.Math.round(a.MarcaBonusDano * this.m.Potency * 100) + "%[/color] de dano de mortos e do Necromante"
			},
			{
				id = 11,
				type = "text",
				icon = "ui/icons/health.png",
				text = "Recebe [color=" + this.Const.UI.Color.NegativeValue + "]+" + this.Math.round(a.MarcaBonusEfeitos * this.m.Potency * 100) + "%[/color] de dano de Veneno e Necrose"
			},
			{
				id = 12,
				type = "text",
				icon = "ui/icons/action_points.png",
				text = "Turnos restantes: [color=" + this.Const.UI.Color.NegativeValue + "]" + this.m.TurnsLeft + "[/color]"
			}
		];
	}

	function onUpdate( _properties )
	{
		_properties.TargetAttractionMult *= 1.0 + (this.Const.Necro.Ativas.MarcaPesoIA - 1.0) * this.m.Potency;
	}

	function onBeforeDamageReceived( _attacker, _skill, _hitInfo, _properties )
	{
		if (_attacker == null || _skill == null || !_skill.isAttack())
		{
			return;
		}

		if (this.Const.Necro.Util.getMasterID(_attacker) == this.m.MasterID)
		{
			_properties.DamageReceivedTotalMult *= 1.0 + this.Const.Necro.Ativas.MarcaBonusDano * this.m.Potency;
		}
	}

	// Alvo morreu marcado: chance de zerar o cooldown de quem marcou.
	function onDeath( _fatalityType )
	{
		if (this.Math.rand(1, 100) > this.Const.Necro.Ativas.MarcaChanceZerarCooldown)
		{
			return;
		}

		local source = this.Tactical.getEntityByID(this.m.SourceID);

		if (source == null || !source.isAlive())
		{
			return;
		}

		foreach( id in [
			"actives.necro_mark",
			"actives.necro_mage_mark"
		] )
		{
			local s = source.getSkills().getSkillByID(id);

			if (s != null)
			{
				s.resetCooldown();
			}
		}
	}

	function onTurnEnd()
	{
		if (--this.m.TurnsLeft <= 0)
		{
			this.removeSelf();
		}
	}

});
