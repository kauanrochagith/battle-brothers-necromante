// =====================================================================
// MOD NECROMANTE - Perk: Corpos Inchados
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onDeath).
// =====================================================================

this.perk_necro_corpos_inchados <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_corpos_inchados");
	}

});
