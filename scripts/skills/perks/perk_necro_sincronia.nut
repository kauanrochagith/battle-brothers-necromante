// =====================================================================
// MOD NECROMANTE - Perk: Sincronia
// Marcador: o efeito é aplicado em necro_undead_racial.nut.
// =====================================================================

this.perk_necro_sincronia <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_sincronia");
	}

});
