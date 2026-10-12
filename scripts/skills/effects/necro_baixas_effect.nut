// =====================================================================
// MOD NECROMANTE - Baixas Aceitáveis (Legião), efeito no morto
// ---------------------------------------------------------------------
// Cada morto aliado que cai ao lado dá +BaixasDano de dano por
// BaixasDuracao turnos, acumulando até BaixasDanoMax. O bônus é lido
// pela racial dos mortos em onAnySkillUsed.
// =====================================================================

this.necro_baixas_effect <- this.inherit("scripts/skills/skill", {
	m = {
		Stacks = 0,
		TurnsLeft = 0
	},
	function create()
	{
		this.m.ID = "effects.necro_baixas";
		this.m.Name = "Baixas Aceitáveis";
		this.m.Description = "A queda de um irmão de ossos só aumenta a fúria deste morto.";
		this.m.Icon = "skills/status_effect_34.png";
		this.m.IconMini = "status_effect_34_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
		this.m.IsSerialized = false;
	}

	function getBonus()
	{
		local L = this.Const.Necro.Sub.Legiao;
		return this.Math.minf(L.BaixasDanoMax, this.m.Stacks * L.BaixasDano);
	}

	function addStack()
	{
		this.m.Stacks = this.m.Stacks + 1;
		this.m.TurnsLeft = this.Const.Necro.Sub.Legiao.BaixasDuracao;
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
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + this.Math.round(this.getBonus() * 100) + "%[/color] de dano por mais " + this.m.TurnsLeft + " turno(s)"
			}
		];
	}

	function onTurnEnd()
	{
		if (--this.m.TurnsLeft <= 0)
		{
			this.removeSelf();
		}
	}

});
