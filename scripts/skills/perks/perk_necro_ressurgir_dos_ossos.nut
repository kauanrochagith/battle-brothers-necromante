// =====================================================================
// MOD NECROMANTE - Perk: Ressurgir Dos Ossos
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onDeath).
// =====================================================================

this.perk_necro_ressurgir_dos_ossos <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_ressurgir_dos_ossos");
	}

});
