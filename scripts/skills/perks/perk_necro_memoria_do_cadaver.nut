// =====================================================================
// MOD NECROMANTE - Perk: Memoria Do Cadaver
// Marcador: o efeito é aplicado em necro_reanimado.nut (setupFromCorpse).
// =====================================================================

this.perk_necro_memoria_do_cadaver <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_memoria_do_cadaver");
	}

});
