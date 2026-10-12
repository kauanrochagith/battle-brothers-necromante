// =====================================================================
// MOD NECROMANTE - Vontade Inquebrável (passiva inata, cap. 4)
// ---------------------------------------------------------------------
// A especificação não define números; efeito adotado (ajustável em
// Const.Necro.VONTADE_RESOLUCAO_MEDO):
//   +20 de Resolução em testes contra medo, pânico e controle mental
//   (o mesmo mecanismo do Caçador de Bruxas vanilla).
// Recriada pelo background ao carregar (não vai para o save).
// =====================================================================

this.necro_unbreakable_will <- this.inherit("scripts/skills/skill", {
	m = {},
	function create()
	{
		this.m.ID = "special.necro_unbreakable_will";
		this.m.Name = "Vontade Inquebrável";
		this.m.Description = "Quem comanda os mortos não se curva ao medo dos vivos.";
		this.m.Icon = "ui/perks/perk_08.png";
		this.m.Type = this.Const.SkillType.Perk;
		this.m.Order = this.Const.SkillOrder.Perk;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsHidden = false;
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
				icon = "ui/icons/bravery.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + this.Const.Necro.VONTADE_RESOLUCAO_MEDO + "[/color] de Resolução em testes contra medo, pânico e controle mental"
			}
		];
	}

	function onUpdate( _properties )
	{
		_properties.MoraleCheckBravery[1] += this.Const.Necro.VONTADE_RESOLUCAO_MEDO;
	}

});
