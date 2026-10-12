// =====================================================================
// MOD NECROMANTE - Perk: Alcance dos Mortos
// Efeito aplicado nos mortos por necro_undead_racial.nut (onAfterUpdate -> Util.applyRangeBonus).
// =====================================================================

this.perk_necro_alcance_dos_mortos <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_alcance_dos_mortos");
	}

});
