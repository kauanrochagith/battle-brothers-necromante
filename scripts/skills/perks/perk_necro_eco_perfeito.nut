// =====================================================================
// MOD NECROMANTE - Perk: Eco Perfeito
// Marcador: o efeito é aplicado em necro_undead_racial.nut (getPassiveMult).
// =====================================================================

this.perk_necro_eco_perfeito <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_eco_perfeito");
	}

});
