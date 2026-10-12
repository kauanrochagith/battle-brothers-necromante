// =====================================================================
// MOD NECROMANTE - Marca do Caçador (Atirador Espectral), efeito no alvo
// ---------------------------------------------------------------------
// MarcaDuracao turnos. Tiros dos mortos e do Necromante dono da marca
// ganham +MarcaAcerto de acerto e +MarcaDano de dano contra o alvo
// (lido na racial e no background). A IA prioriza o alvo (como a Marca do
// Comando, via TargetAttractionMult).
// =====================================================================

this.necro_hunter_mark_effect <- this.inherit("scripts/skills/skill", {
	m = {
		TurnsLeft = 0,
		MasterID = -1
	},
	function create()
	{
		this.m.ID = "effects.necro_hunter_mark";
		this.m.Name = "Marca do Caçador";
		this.m.Description = "Este alvo foi marcado por um Atirador Espectral. Os tiros dos mortos o procuram.";
		this.m.Icon = "skills/status_effect_85.png";
		this.m.IconMini = "status_effect_85_mini";
		this.m.Type = this.Const.SkillType.StatusEffect;
		this.m.Order = this.Const.SkillOrder.VeryLast;
		this.m.IsActive = false;
		this.m.IsStacking = false;
		this.m.IsRemovedAfterBattle = true;
		this.m.IsSerialized = false;
	}

	function getMasterID()
	{
		return this.m.MasterID;
	}

	function setup( _masterID )
	{
		this.m.MasterID = _masterID;
		this.m.TurnsLeft = this.Const.Necro.Sub.Atirador.MarcaDuracao;
	}

	function getTooltip()
	{
		local A = this.Const.Necro.Sub.Atirador;
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
				icon = "ui/icons/ranged_skill.png",
				text = "Tiros contra ele: [color=" + this.Const.UI.Color.NegativeValue + "]+" + A.MarcaAcerto + "%[/color] de acerto e [color=" + this.Const.UI.Color.NegativeValue + "]+" + this.Math.round(A.MarcaDano * 100) + "%[/color] de dano"
			},
			{
				id = 11,
				type = "text",
				icon = "ui/icons/action_points.png",
				text = "Turnos restantes: " + this.m.TurnsLeft
			}
		];
	}

	function onUpdate( _properties )
	{
		_properties.TargetAttractionMult *= this.Const.Necro.Ativas.MarcaPesoIA;
	}

	function onTurnEnd()
	{
		if (--this.m.TurnsLeft <= 0)
		{
			this.removeSelf();
		}
	}

});
