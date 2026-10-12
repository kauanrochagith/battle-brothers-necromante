// =====================================================================
// MOD NECROMANTE - Perk: Lealdade Eterna
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onDeath).
// =====================================================================

this.perk_necro_lealdade_eterna <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_lealdade_eterna");
	}

});
