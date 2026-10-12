// =====================================================================
// MOD NECROMANTE - Perk: Elite Funesta
// Marcador: o efeito é aplicado em necro_undead.nut (getSpawnMults) / racial / necro_knight_call.nut.
// =====================================================================

this.perk_necro_elite_funesta <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_elite_funesta");
	}

});
