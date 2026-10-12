// =====================================================================
// MOD NECROMANTE - Perk: Eco do Mago
// Efeito aplicado em necro_mago.nut (onNecroSpawned) e na racial (getPassiveMult).
// =====================================================================

this.perk_necro_eco_do_mago <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_eco_do_mago");
	}

});
