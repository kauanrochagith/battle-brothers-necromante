// =====================================================================
// MOD NECROMANTE - Perk: Veteranos Eternos
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onTargetKilled / updateLegion).
// =====================================================================

this.perk_necro_veteranos_eternos <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_veteranos_eternos");
	}

});
