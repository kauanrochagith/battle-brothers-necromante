// =====================================================================
// MOD NECROMANTE - Perk: Linhagem De Ossos
// Marcador: o efeito é aplicado em Util.applyOnHit.
// =====================================================================

this.perk_necro_linhagem_de_ossos <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_linhagem_de_ossos");
	}

});
