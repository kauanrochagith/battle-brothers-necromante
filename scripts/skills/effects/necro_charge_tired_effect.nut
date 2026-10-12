// =====================================================================
// MOD NECROMANTE - Exaustão da Carga Fúnebre (Senhor da Legião)
// ---------------------------------------------------------------------
// Mortos que participaram da Carga Fúnebre ficam com -CargaPenalidadePA
// PA no turno seguinte. O efeito some no fim desse turno.
// =====================================================================

this.necro_charge_tired_effect <- this.inherit("scripts/skills/skill", {
	m = {
		Started = false
	},
	function create()
	{
		this.m.ID = "effects.necro_charge_tired";
		this.m.Name = "Fôlego da Carga";
		this.m.Description = "Este morto se lançou numa carga e ainda está se recompondo.";
		this.m.Icon = "skills/status_effect_60.png";
		this.m.IconMini = "status_effect_60_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
		this.m.IsSerialized = false;
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
				icon = "ui/icons/action_points.png",
				text = "[color=" + this.Const.UI.Color.NegativeValue + "]-" + this.Const.Necro.Sub.Legiao.CargaPenalidadePA + "[/color] PA no próximo turno"
			}
		];
	}

	function onUpdate( _properties )
	{
		_properties.ActionPoints -= this.Const.Necro.Sub.Legiao.CargaPenalidadePA;
	}

	function onTurnStart()
	{
		this.m.Started = true;
	}

	function onTurnEnd()
	{
		if (this.m.Started)
		{
			this.removeSelf();
		}
	}

});
