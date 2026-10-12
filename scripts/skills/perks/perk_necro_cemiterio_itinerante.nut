// =====================================================================
// MOD NECROMANTE - Perk: Cemiterio Itinerante
// Marcador: o efeito é aplicado em Util.reanimateCorpse.
// =====================================================================

this.perk_necro_cemiterio_itinerante <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_cemiterio_itinerante");
	}

});
