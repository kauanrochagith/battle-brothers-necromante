// =====================================================================
// MOD NECROMANTE - Perk: Olho Do Cacador
// Marcador: o efeito é aplicado em necro_undead_racial.nut (onUpdate).
// =====================================================================

this.perk_necro_olho_do_cacador <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_olho_do_cacador");
	}

});
