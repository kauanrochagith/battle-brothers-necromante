// =====================================================================
// MOD NECROMANTE - Perk: Exercito Roubado
// Marcador: o efeito é aplicado em necro_reanimado.nut / necro_undead_racial.nut.
// =====================================================================

this.perk_necro_exercito_roubado <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_exercito_roubado");
	}

});
