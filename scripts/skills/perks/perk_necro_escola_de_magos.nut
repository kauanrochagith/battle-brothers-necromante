// =====================================================================
// MOD NECROMANTE - Perk: Escola De Magos
// Marcador: o efeito é aplicado em Util.getMaxMages.
// =====================================================================

this.perk_necro_escola_de_magos <- this.inherit("scripts/skills/perks/perk_necro", {
	m = {},
	function create()
	{
		this.perk_necro.create();
		this.setupNecroPerk("perk.necro_escola_de_magos");
	}

});
