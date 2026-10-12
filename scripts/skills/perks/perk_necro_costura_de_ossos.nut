// =====================================================================
// MOD NECROMANTE - Perk: Costura De Ossos
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onTurnStart).
// =====================================================================

this.perk_necro_costura_de_ossos <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_costura_de_ossos");
	}

});
