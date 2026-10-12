// =====================================================================
// MOD NECROMANTE - Perk: Contagio
// Marcador: o efeito é aplicado em necro_dot_effect.nut (spreadContagion).
// =====================================================================

this.perk_necro_contagio <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_contagio");
	}

});
