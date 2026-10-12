// =====================================================================
// MOD NECROMANTE - Perk: Osso Fresco
// Marcador: o efeito é aplicado em necro_undead.nut (getSpawnMults) / fusão.
// =====================================================================

this.perk_necro_osso_fresco <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_osso_fresco");
	}

});
