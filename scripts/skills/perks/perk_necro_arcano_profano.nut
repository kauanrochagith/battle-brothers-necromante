// =====================================================================
// MOD NECROMANTE - Perk: Arcano Profano
// Marcador: o efeito é aplicado em necro_mago.nut (onNecroSpawned) + necro_mage_ray.nut.
// =====================================================================

this.perk_necro_arcano_profano <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_arcano_profano");
	}

});
