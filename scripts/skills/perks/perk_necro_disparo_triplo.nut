// =====================================================================
// MOD NECROMANTE - Perk: Disparo Triplo
// Marcador: o efeito é aplicado em necro_undead_racial.nut (tryTripleShot).
// =====================================================================

this.perk_necro_disparo_triplo <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_disparo_triplo");
	}

});
