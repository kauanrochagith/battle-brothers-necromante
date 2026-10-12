// =====================================================================
// MOD NECROMANTE - Perk: Imunidade Mórbida (Mestre da Peste)
// O Necromante fica imune a veneno e sangramento. A regeneração dos
// Putrefatos fica na racial dos mortos (onTurnStart).
// =====================================================================

this.perk_necro_imunidade_morbida <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_imunidade_morbida");
	}

	function onUpdate( _properties )
	{
		_properties.IsImmuneToPoison = true;
		_properties.IsImmuneToBleeding = true;
	}

});
