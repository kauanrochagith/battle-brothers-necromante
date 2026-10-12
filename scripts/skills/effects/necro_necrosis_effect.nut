// =====================================================================
// MOD NECROMANTE - Necrose (cap. 6.2)
// Aplicada por golpes À DISTÂNCIA dos mortos.
// Igual ao Veneno, mais: -1% de dano causado pelo alvo por acúmulo (máx. -10%).
// =====================================================================

this.necro_necrosis_effect <- this.inherit("scripts/skills/effects/necro_dot_effect", {
	m = {},
	function create()
	{
		this.necro_dot_effect.create();
		this.m.ID = "effects.necro_necrosis";
		this.m.Name = "Necrose";
		this.m.KilledString = "Apodreceu vivo";
		this.m.Description = "A carne deste personagem está apodrecendo, enfraquecendo seus golpes.";
		this.m.Icon = "skills/status_effect_123.png";
		this.m.IconMini = "status_effect_123_mini";
		this.m.IconBrush = "status_effect_123";
	}

	function getDamageReduction()
	{
		return this.m.Stacks * this.Const.Necro.NECROSE_REDUCAO_DANO_POR_ACUMULO;
	}

	function onAddExtraTooltip( _tooltip )
	{
		_tooltip.push({
			id = 12,
			type = "text",
			icon = "ui/icons/regular_damage.png",
			text = "Causa [color=" + this.Const.UI.Color.NegativeValue + "]-" + this.Math.round(this.getDamageReduction() * 100) + "%[/color] de dano"
		});
	}

	function onUpdate( _properties )
	{
		this.necro_dot_effect.onUpdate(_properties);
		_properties.DamageTotalMult *= 1.0 - this.getDamageReduction();
	}

});
