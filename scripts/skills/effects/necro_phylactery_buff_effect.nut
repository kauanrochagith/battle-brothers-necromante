// =====================================================================
// MOD NECROMANTE - Fúria do Filactério (Lich), efeito nos Magos
// ---------------------------------------------------------------------
// Quando o Filactério salva o Lich, cada Mago ganha +FilacterioDanoMagos
// de dano por FilacterioTurnos turnos.
// =====================================================================

this.necro_phylactery_buff_effect <- this.inherit("scripts/skills/skill", {
	m = {
		TurnsLeft = 0
	},
	function create()
	{
		this.m.ID = "effects.necro_phylactery_buff";
		this.m.Name = "Fúria do Filactério";
		this.m.Description = "O mestre voltou do além, e a magia deste Mago arde mais forte.";
		this.m.Icon = "skills/status_effect_82.png";
		this.m.IconMini = "status_effect_82_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
		this.m.IsSerialized = false;
		this.m.TurnsLeft = this.Const.Necro.Sub.Lich.FilacterioTurnos;
	}

	function getTooltip()
	{
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
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + this.Math.round(this.Const.Necro.Sub.Lich.FilacterioDanoMagos * 100) + "%[/color] de dano por mais " + this.m.TurnsLeft + " turno(s)"
			}
		];
	}

	function onUpdate( _properties )
	{
		_properties.DamageTotalMult *= 1.0 + this.Const.Necro.Sub.Lich.FilacterioDanoMagos;
	}

	function onTurnEnd()
	{
		if (--this.m.TurnsLeft <= 0)
		{
			this.removeSelf();
		}
	}

});
